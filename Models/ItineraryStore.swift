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
        appFilesFolderURL().path().removingPercentEncoding ?? appFilesFolderURL().path()
    }
    static func appFilesFolderPathWithAppendedFileComponent(_ component: String) -> String {
        (appFilesFolderPath() as NSString).appendingPathComponent(component)
    }
    
    static func appDataFilesFolderPath() -> String {
        (appFilesFolderPath() as NSString).appendingPathComponent(kItineraryPerststentDataFileDirectoryName)
    }
    static func appDataFilesFolderPathWithAppendedFileComponent(_ component: String) -> String {
        (appDataFilesFolderPath() as NSString).appendingPathComponent(component)
    }
    static func pathToFileIsAppDataFilesFolderPath(_ filePath: String) -> Bool {
        appDataFilesFolderPath() == ((filePath as NSString).deletingLastPathComponent)
    }
    
    static func appPackageFilesInDefaultLocation() -> [String]? {
        if let files = try? FileManager.default.contentsOfDirectory(atPath: ItineraryStore.appDataFilesFolderPath()).filter({ $0.hasSuffix(ItineraryFileExtension.dataPackage.dotExtension)}).sorted() { return files } else {
            debugPrint("appPackageFilesInDefaultLocation No Files!")
            return nil
        }
    }
    
    // using URLs to construct paths then export as Strs leads to issues with spaces in the filename. stick with strings
    static func appDataPackagePathWithSuffixForFileNameWithoutSuffix(_ filename:String) -> String {
        appDataFilesFolderPathWithAppendedFileComponent(filename + ItineraryFileExtension.dataPackage.dotExtension)
    }
    static func appFilePathForFileNameWithExtension(_ filenamewithextn: String) -> String {
        if filenamewithextn.hasSuffix(ItineraryFileExtension.dataFile.rawValue) {
            return appDataFilesFolderPathWithAppendedFileComponent(filenamewithextn) }
        if filenamewithextn.hasSuffix(ItineraryFileExtension.dataPackage.rawValue) {
            return appDataFilesFolderPathWithAppendedFileComponent(filenamewithextn) }
        if filenamewithextn.hasSuffix(ItineraryFileExtension.textFile.rawValue) {
            return appFilesFolderPathWithAppendedFileComponent(filenamewithextn) }
        return appFilesFolderPathWithAppendedFileComponent(filenamewithextn)

    }
    
    static func uniqueifiedDataPackageNameWithoutExtensionFrom(nameOnly initialFileName: String) -> String {
        if let files = try? FileManager.default.contentsOfDirectory(atPath: ItineraryStore.appDataFilesFolderPath()).filter({ $0.hasSuffix(ItineraryFileExtension.dataPackage.dotExtension)}), //kItineraryPerststentDataFileDotSuffix
           files.count > 0 {
            let filenames = files.map { $0.components(separatedBy: ".").first }
            var index = 1
            var modifiedFilename = initialFileName
            while filenames.first(where: { $0 == modifiedFilename }) != nil {
                modifiedFilename = initialFileName + " \(index)"
                index += 1
            }
            return modifiedFilename
        }
        return initialFileName
    }

    
    

    func importItinerary(atPath filePath:String) {
        do {
            let content = try String(contentsOfFile: filePath)
            if var importedItinerary = Itinerary.importItinerary(fromString: content) {
                // all fields are populated
                addItinerary(itinerary: importedItinerary)
                sortItineraries()
            }
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    func loadItineraryPackage(atPath packagePath:String) -> String? {
        //var pathdelete: String? = filePath // we nil it if all success
        #warning("dont return pathdelete")
        if let contents = try? FileManager.default.contentsOfDirectory(atPath: packagePath) {
            // Try to load the PersistentData
            if let persistentDataData = FileManager.default.contents(atPath: (packagePath as NSString).appendingPathComponent(kItineraryDocumentFileNameItineraryPersistentDataFile)) {
                if let decodedPersistentData: Itinerary.PersistentData = try? JSONDecoder().decode(Itinerary.PersistentData.self, from: persistentDataData) {
                    // we know we can open this itinerary.
                    // if internal keep its filename, otherwise make a unique one as needed
                    let isExternalLocation = !(ItineraryStore.pathToFileIsAppDataFilesFolderPath(packagePath))
                    let duplicateUUID = hasItineraryWithUUID(decodedPersistentData.id)
                    let filename = isExternalLocation ?
                    ItineraryStore.uniqueifiedDataPackageNameWithoutExtensionFrom(nameOnly: decodedPersistentData.title) :
                    packagePath.fileNameWithoutExtensionFromPath
                    // now copy the original if UUID is unique, otherwise make new UUIDs for everything
                    var loadedItinerary: Itinerary
                    if duplicateUUID {
                        loadedItinerary = Itinerary.duplicateItineraryWithAllNewIDsAndModDate(from: Itinerary(persistentData: decodedPersistentData, filename: filename))
                        loadedItinerary.packageFilePath = ItineraryStore.appDataFilesFolderPathWithAppendedFileComponent(filename + ItineraryFileExtension.dataPackage.dotExtension)
                    } else {
                        loadedItinerary = Itinerary(persistentData: decodedPersistentData, filename: filename, packageFilePath: packagePath)
                    }
                    // add to our itineraries
                    itineraries.append(loadedItinerary)
                    // copy the package to itineraries folder if external or duplicated
                    if isExternalLocation || duplicateUUID {
                        _ = loadedItinerary.savePersistentData()
                    }
                    sortItineraries()
                } else {
                    debugPrint("Decode failure for: \(packagePath)")
                }
            } else {
                debugPrint("No itinerary data file for: \(packagePath)")
            }
        } else {
            debugPrint("No directory contents for: \(packagePath)")
        }
        return nil
    }
    
    /*func loadItinerary(atPath filePath:String, externalLocation: Bool) -> String? {
        var pathdelete: String? = filePath // we nil it if all success
        if let fileData = FileManager.default.contents(atPath: filePath) {
            if let persistentData: Itinerary.PersistentData = try? JSONDecoder().decode(Itinerary.PersistentData.self, from: fileData) {
                // if we are importing we must make a unique file name from the title so we dont overwrite an existing one in the folder,
                // otherwise we will use the existing filename as we must overwrite anyway ones we are loading from the folder on re-load
                let filename = externalLocation ?
                    ItineraryStore.uniqueifiedDataPackageNameWithoutExtensionFrom(nameOnly: persistentData.title) :
                    filePath.fileNameWithoutExtensionFromPath
                let newItinerary = Itinerary(persistentData: persistentData, filename: filename)
                let newUUIDstr = newItinerary.idStr
                if itineraries.first(where: { $0.idStr == newUUIDstr}) != nil || externalLocation {
                    // we are loading an itinerary with the same UUID as already in our array,
                    // or importing one from outside the itineraries folder
                    // so duplicate with new UUID and save as a new file with the new UUID as the filename in the itineraries folder
                    // make a new UUID() for id and for all stages
                    // make a new filename as this is a new itinerary
                    var cleanItinerary = Itinerary.duplicateItineraryWithAllNewIDsAndModDate(from: newItinerary)
                    cleanItinerary.filename = ItineraryStore.uniqueifiedDataPackageNameWithoutExtensionFrom(nameOnly: cleanItinerary.title)
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
    }*/
    
    
    func completeLoadItineraries() -> [String] {
        var filesToDeleteArray = [String]()
        if let files = ItineraryStore.appPackageFilesInDefaultLocation(), !files.isEmpty {
            // prevent duplication
            itineraries = []
            for fileName in files {
                let filePath = ItineraryStore.appFilePathForFileNameWithExtension(fileName)
                // ignore pathdelete return as we only get sent valid itineraries..
                let filePathToDelete = loadItineraryPackage(atPath: filePath)
                if filePathToDelete != nil {
                    filesToDeleteArray.append(filePathToDelete!)
                }
            }
            sortItineraries()
        } else { debugPrint("Directory read failed) or files count == 0")}
        return filesToDeleteArray
    }
    
    func tryToLoadItineraries() -> [String] {
        var filesToDeleteArray = [String]()
        var isDir: ObjCBool = true
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
    func itineraryForUUID(_ uuid:UUID) -> Itinerary? {
        return itineraries.first{ $0.id == uuid }
    }
    func itineraryIndexForUUID(_ uuid: UUID) -> Int? {
        return itineraries.firstIndex(where: { $0.id == uuid })
    }
    func hasItineraryWithUUID(_ uuid: UUID) -> Bool {
        return itineraries.firstIndex(where: { $0.id == uuid }) != nil
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
            let filePath = ItineraryStore.appDataPackagePathWithSuffixForFileNameWithoutSuffix(filename)
            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        itineraries.remove(atOffsets: offsets)
    }
    func removeItineraryWithUUID(_ uuid: UUID) -> Void {
        guard let itineraryToDelete = itineraryForUUID(uuid), let filename =  itineraryToDelete.filename else { return }
        let filePath = ItineraryStore.appDataPackagePathWithSuffixForFileNameWithoutSuffix(filename)
        do {
            try FileManager.default.removeItem(atPath: filePath)
        } catch {
            debugPrint(error.localizedDescription)
        }
        itineraries.removeAll(where: { $0.id == uuid })
    }

    func addItinerary(itinerary: Itinerary) {
        var itinerymutable = itinerary
        itinerymutable.updateModificationDateToNow()
        _ = itinerymutable.savePersistentData()
        itineraries.append(itinerymutable)
    }
    func updateItinerary(itinerary: Itinerary) -> String? {
        guard let index = itineraries.firstIndex(where: { $0.idStr == itinerary.idStr }) else { debugPrint("Unable to update itinerary"); return nil  }
        var itinerymutable = itinerary
        itinerymutable.updateModificationDateToNow()
        _ = itinerymutable.savePersistentData()
        itineraries[index] = itinerymutable
        return itinerymutable.filename
    }

    func addItineraryFromWatchMessageData(itinerary: Itinerary, duplicateOption: DuplicateFileOptions) {
        var mutableItinerary = itinerary
        switch duplicateOption {
        case .keepBoth:
            mutableItinerary = Itinerary.duplicateItineraryWithAllNewIDsAndModDate(from: mutableItinerary)
            mutableItinerary.title = mutableItinerary.title.uniqueifiedStringForArray(itineraryTitles)
            // uuids
        case .replaceExisting:
            removeItineraryWithUUID(mutableItinerary.id)
        case .noDuplicate:
            break
        }
        // we've removed any duplicate file if .replaceExisting
        mutableItinerary.filename = (mutableItinerary.filename ?? mutableItinerary.title).uniqueifiedDataFileNameWithoutExtension
        addItinerary(itinerary: mutableItinerary)
        sortItineraries()
    }

    func updateStageDurationFromDate(stageUUID: UUID, itineraryUUID: UUID, durationDate date: Date) {
        if var itinerary = itineraryForUUID(itineraryUUID), let index = itineraryIndexForUUID(itineraryUUID) {
            itinerary.updateStageDurationFromDate(stageUUID: stageUUID, durationDate: date)
            itineraries[index] = itinerary
        }
    }
}
