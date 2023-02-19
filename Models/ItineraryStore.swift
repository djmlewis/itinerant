//
//  ItineraryStore.swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import Foundation
import SwiftUI
import UserNotifications




class ItineraryStore: ObservableObject {
    
    @Published var itineraries: [Itinerary] = []
       
    
    static func appFilesFolderURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    static func appDataFilesFolderURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(path: kItineraryPerststentDataFileDirectoryName)
    }
    static func appFilesFolderPath() -> String {
        appFilesFolderURL().path()
    }
    static func appDataFilesFolderPath() -> String {
        appFilesFolderPath()+"/"+kItineraryPerststentDataFileDirectoryName
    }
    // using URLs to construct paths then export as Strs leads to issues with spaces in the filename. stick with strings
    static func appDataFilePathWithSuffixForFileNameWithoutSuffix(_ filename:String) -> String {
        appDataFilesFolderPath() + "/" + filename + "." + ItineraryFileExtension.dataFile.rawValue
    }
    static func appFilePathForFileNameWithExtension(_ filenamewithextn: String) -> String {
        let component = "/" + filenamewithextn
        if filenamewithextn.hasSuffix(ItineraryFileExtension.dataFile.rawValue) { return appDataFilesFolderPath() + component }
        if filenamewithextn.hasSuffix(ItineraryFileExtension.textFile.rawValue) { return appFilesFolderPath() + component }
        return appFilesFolderPath() + component

    }

    func importItinerary(atPath filePath:String) {
        do {
            let content = try String(contentsOfFile: filePath)
            if var importedItinerary = Itinerary.importItinerary(fromString: content) {
                importedItinerary.filename = Itinerary.uniqueifiedDataFileNameWithoutExtensionFrom(nameOnly: importedItinerary.title)
                addItinerary(itinerary: importedItinerary)
                sortItineraries()
            }
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    func loadItinerary(atPath filePath:String, externalLocation: Bool) -> String? {
        var pathdelete: String? = filePath // we nil it if all success
        if let fileData = FileManager.default.contents(atPath: filePath) {
            if let persistentData: Itinerary.PersistentData = try? JSONDecoder().decode(Itinerary.PersistentData.self, from: fileData) {
                // if we are importing we must make a unique file name from the title so we dont overwrite an existing one in the folder,
                // otherwise we will use the existing filename as we must overwrite anyway ones we are loading from the folder on re-load
                let filename = externalLocation ?
                    Itinerary.uniqueifiedDataFileNameWithoutExtensionFrom(nameOnly: persistentData.title) :
                    filePath.fileNameWithoutExtensionFromPath!
                let newItinerary = Itinerary(persistentData: persistentData, filename: filename)
                let newUUIDstr = newItinerary.idStr
                //let outsideDatFilesFolder = !filePath.contains(ItineraryStore.appDataFilesFolderPath())
                if itineraries.first(where: { $0.idStr == newUUIDstr}) != nil || externalLocation {
                    // we are loading an itinerary with the same UUID as already in our array,
                    // or importing one from outside the itineraries folder
                    // so duplicate with new UUID and save as a new file with the new UUID as the filename in the itineraries folder
                    // make a new UUID() for id and for all stages
                    // make a new filename as this is a new itinerary
                    var cleanItinerary = Itinerary.duplicateItineraryWithAllNewIDsAndModDate(from: newItinerary)
                    cleanItinerary.filename = Itinerary.uniqueifiedDataFileNameWithoutExtensionFrom(nameOnly: cleanItinerary.title)
                    // we already updated modificationDate in the duplication
                    _ = cleanItinerary.savePersistentData()
                    itineraries.append(cleanItinerary)
                    if externalLocation { sortItineraries() }
                    //debugPrint("added with new UUID for: \(filePath)")
                } else {
                    itineraries.append(newItinerary)
                    if externalLocation { sortItineraries() }
                }
                // set pathDelete nil so we dont delete it!
                pathdelete = nil
            } else {
                debugPrint("Decode failure for: \(filePath)")
            }
        } else {
            debugPrint("No fileData for: \(filePath)")
        }
        return pathdelete
    }
    
    
    func completeLoadItineraries() -> [String] {
        var filesToDeleteArray = [String]()
        if let files = try? FileManager.default.contentsOfDirectory(atPath: ItineraryStore.appDataFilesFolderPath()).filter({ $0.hasSuffix(kItineraryPerststentDataFileDotSuffix)}).sorted() {
            if files.count > 0 {
                // prevent duplication
                itineraries = []
                for fileName in files {
                    let filePath = ItineraryStore.appFilePathForFileNameWithExtension(fileName)
                    // ignore pathdelete return as we only get sent valid itineraries..
                    let filePathToDelete = loadItinerary(atPath: filePath, externalLocation: false)
                    if filePathToDelete != nil {
                        filesToDeleteArray.append(filePathToDelete!)
                    }
                }
                sortItineraries()
            } else {debugPrint("files count == 0")}
        } else { debugPrint("Directory read failed)")}
        return filesToDeleteArray
    }
    
    func tryToLoadItineraries() -> [String] {
        var isDir: ObjCBool = true
        var filesToDeleteArray = [String]()
        if !FileManager.default.fileExists(atPath: ItineraryStore.appDataFilesFolderPath(), isDirectory: &isDir) {
            do {
                try FileManager.default.createDirectory(at: ItineraryStore.appDataFilesFolderURL(), withIntermediateDirectories: true)
                filesToDeleteArray = completeLoadItineraries()
            } catch let error {
                debugPrint("unable to create data files directory", error.localizedDescription)
            }
        } else { filesToDeleteArray = completeLoadItineraries() }
        return filesToDeleteArray
    }
    
    
    func reloadItineraries() -> [String] {
        // this force erases all the itineraries so they better be saved to file
        // ignore any invalid files as we should not get any
        return tryToLoadItineraries()
    }
    
    func sortItineraries() {
        itineraries.sort {
            if $0.title == $1.title && $0.filename != nil && $1.filename != nil { return $0.filename! < $1.filename! }
            return $0.title < $1.title
        }
    }
    
    func itineraryForID(id:String) -> Itinerary? {
        return itineraries.first{ $0.idStr.contains(id) }
    }
    func hasItineraryWithID(_ id: String) -> Bool {
        return itineraries.firstIndex(where: { $0.idStr.contains(id) }) != nil
    }
    func itineraryForTitle(_ title: String) -> Itinerary? {
        itineraries.first { $0.title == title }
    }
    func hasItineraryWithTitle(_ title: String) -> Bool {
        return itineraryForTitle(title) != nil
    }
    func itineraryTitleForID(id:String) -> String {
        itineraryForID(id: id)?.title ?? kUnknownObjectErrorStr
    }
    var itineraryTitles: [String] { itineraries.map { $0.title } }
    var itineraryUUIDStrs: [String] { itineraries.map { $0.idStr } }

    func itineraryFileNameForID(id:String) -> String {
        itineraryForID(id: id)?.filename ?? "---"
    }
    func itineraryForIDisRunning(id:String, uuidStrStagesRunningStr: String) -> Bool {
        itineraryForID(id: id)?.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ?? false
    }

    func itineraryModificationDateForID(id:String) -> Date? {
        guard let timeinterval = itineraryForID(id: id)?.modificationDate else { return nil }
        return Date(timeIntervalSinceReferenceDate: timeinterval)
    }

    
    func removeItinerariesAtOffsets(offsets:IndexSet) -> Void {
        let filenamesToDelete = offsets.map { itineraries[$0].filename! }
        for filename in filenamesToDelete {
            let filePath = ItineraryStore.appDataFilePathWithSuffixForFileNameWithoutSuffix(filename)
            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        itineraries.remove(atOffsets: offsets)
    }
    func removeItineraryWithTitle(_ title: String) -> Void {
        guard let itineraryToDelete = itineraryForTitle(title), let filename =  itineraryToDelete.filename else { return }
        let filePath = ItineraryStore.appDataFilePathWithSuffixForFileNameWithoutSuffix(filename)
        do {
            try FileManager.default.removeItem(atPath: filePath)
        } catch {
            debugPrint(error.localizedDescription)
        }
        itineraries.removeAll(where: { $0.title == title })
    }

    func addItinerary(itinerary: Itinerary) {
        var itinerymutable = itinerary
        itinerymutable.updateModificationDateToNow()
        itinerymutable.filename = itinerymutable.savePersistentData()
        itineraries.append(itinerymutable)
    }
    func updateItinerary(itinerary: Itinerary) -> String? {
        guard let index = itineraries.firstIndex(where: { $0.idStr == itinerary.idStr }) else { debugPrint("Unable to update itinerary"); return nil  }
        var itinerymutable = itinerary
        itinerymutable.updateModificationDateToNow()
        itinerymutable.filename = itinerymutable.savePersistentData()
        itineraries[index] = itinerymutable
        return itinerymutable.filename
    }

    func addItineraryFromWatchMessageData(itinerary: Itinerary, duplicateOption: DuplicateFileOptions) {
        var mutableItinerary = itinerary
        switch duplicateOption {
        case .keepBoth:
            mutableItinerary.title = mutableItinerary.title.uniqueifiedStringForArray(itineraryTitles)
            // uuids
        case .replaceExisting:
            removeItineraryWithTitle(mutableItinerary.title)
        case .noDuplicate:
            break
        }
        // we've removed any duplicate file if .replaceExisting
        mutableItinerary.filename = (mutableItinerary.filename ?? mutableItinerary.title).uniqueifiedDataFileNameWithoutExtension
        addItinerary(itinerary: mutableItinerary)
        sortItineraries()
    }

    
}
