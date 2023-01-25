//
//  ItineraryStore.swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import Foundation
import SwiftUI




class ItineraryStore: ObservableObject {
    
    @Published var itineraries: [Itinerary] = []
    @Published var permissionToNotify: Bool = false
    
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
        if filenamewithextn.hasSuffix(ItineraryFileExtension.importFile.rawValue) { return appFilesFolderPath() + component }
        return appFilesFolderPath() + component

    }

    func importItinerary(atPath filePath:String) {
        do {
            let content = try String(contentsOfFile: filePath)
            if let importedItinerary = Itinerary.importItinerary(fromString: content) {
                addItinerary(itinerary: importedItinerary)
            }
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    func loadItinerary(atPath filePath:String) {
        if let fileData = FileManager.default.contents(atPath: filePath) {
            if let persistentData: Itinerary.PersistentData = try? JSONDecoder().decode(Itinerary.PersistentData.self, from: fileData) {
                var newItinerary = Itinerary(persistentData: persistentData)
                newItinerary.filename = filePath.fileNameWithoutExtensionFromPath()
                let newUUIDstr = newItinerary.id.uuidString
                let outsideDatFilesFolder = !filePath.contains(ItineraryStore.appDataFilesFolderPath())
                if itineraries.first(where: { $0.id.uuidString == newUUIDstr}) != nil || outsideDatFilesFolder {
                    // we are loading an itinerary with the same UUID as already in our array,
                    // or importing one from outside the itineraries folder
                    // so duplicate with new UUID and save as a new file with the new UUID as the filename in the itineraries folder
                    // delete the original file to stop it happening repeatedly if its inside the datFilesFolder
                    if !outsideDatFilesFolder { try! FileManager.default.removeItem(atPath: filePath) }
                    // make a new UUID() for id and for all stages
                    var cleanItinerary = Itinerary.duplicateItineraryWithAllNewIDs(from: newItinerary)
                    cleanItinerary.filename = cleanItinerary.savePersistentData()
                    itineraries.append(cleanItinerary)
                    //debugPrint("added with new UUID for: \(filePath)")
                } else {
                    itineraries.append(newItinerary)
                }
            } else {
                debugPrint("Decode failure for: \(filePath)")
            }
        } else {
            debugPrint("No fileData for: \(filePath)")
        }

    }
    
    
    func completeLoadItineraries() {
        if let files = try? FileManager.default.contentsOfDirectory(atPath: ItineraryStore.appDataFilesFolderPath()).filter({ $0.hasSuffix(kItineraryPerststentDataFileDotSuffix)}).sorted() {
            if files.count > 0 {
                for fileName in files {
                    let filePath = ItineraryStore.appFilePathForFileNameWithExtension(fileName)
                    loadItinerary(atPath: filePath)
                }
            } else {debugPrint("files count == 0")}
        } else { debugPrint("Directory read failed)")}
    }
    
    func tryToLoadItineraries() {
        var isDir: ObjCBool = true
        if !FileManager.default.fileExists(atPath: ItineraryStore.appDataFilesFolderPath(), isDirectory: &isDir) {
            do {
                try FileManager.default.createDirectory(at: ItineraryStore.appDataFilesFolderURL(), withIntermediateDirectories: true)
                completeLoadItineraries()
            } catch let error {
                debugPrint("unable to create data files directory", error.localizedDescription)
            }
        } else { completeLoadItineraries() }
    }
    
    
    func reloadItineraries() {
        // this force erases all the itineraries so they better be saved to file
        itineraries = []
        tryToLoadItineraries()
    }
    
    
    func itineraryForID(id:String) -> Itinerary {
        itineraries.first { $0.id.uuidString == id } ?? Itinerary(title: kUnknownObjectErrorStr)
    }
    func itineraryTitleForID(id:String) -> String {
        itineraries.first { $0.id.uuidString == id }?.title ?? kUnknownObjectErrorStr
    }
    func itineraryFileNameForID(id:String) -> String {
        itineraries.first { $0.id.uuidString == id }?.filename ?? "---"
    }

    func removeItinerariesAtOffsets(offsets:IndexSet) -> Void {
        let idsToDelete = offsets.map { itineraries[$0].id.uuidString }
        for id in idsToDelete {
            let filePath = ItineraryStore.appDataFilePathWithSuffixForFileNameWithoutSuffix(id)
            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        itineraries.remove(atOffsets: offsets)
        
    }
    
    func addItinerary(itinerary: Itinerary) {
        var itinerymutable = itinerary
        itinerymutable.filename = itinerary.savePersistentData()
        itineraries.append(itinerymutable)
    }
    func updateItinerary(itinerary: Itinerary) -> String? {
        guard let index = itineraries.firstIndex(where: { $0.id.uuidString == itinerary.id.uuidString }) else { debugPrint("Unable to update itinerary"); return nil  }
        var itinerymutable = itinerary
        itinerymutable.filename = itinerary.savePersistentData()
        itineraries[index] = itinerymutable
        return itinerymutable.filename
    }

    func hasItineraryWithID(_ id: String) -> Bool {
        guard let _ = itineraries.firstIndex(where: { $0.id.uuidString == id }) else { return false }
        return true
    }
}
