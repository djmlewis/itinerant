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
    static func appFilesFolderPath() -> String {
        appFilesFolderURL().path()
    }
    // using URLs to construct paths then export as Strs leads to issues with spaces in the filename. stick with strings
    static func appDataFilePathWithSuffixForFileNameWithoutSuffix(_ filename:String) -> String {
        appFilesFolderPath() + "/" + filename + "." + ItineraryFileExtension.dataFile.rawValue
    }
    static func appFilePathForFileNameWithSuffix(_ filename:String) -> String {
        appFilesFolderPath() + "/" + filename
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
                let newItinerary = Itinerary(persistentData: persistentData)
                let newUUIDstr = newItinerary.id.uuidString
                if itineraries.first(where: { $0.id.uuidString == newUUIDstr}) != nil {
                    // we are loading an itinerary with the same UUID as already in our array,
                    // so duplicate with new UUID and save as a new file with the new UUID as the filename
                    // delete the original file to stop it happening repeatedly
                     try! FileManager.default.removeItem(atPath: filePath)
                    // make a new UUID() for id and for all stages
                    let cleanItinerary = Itinerary.duplicateItineraryWithAllNewIDs(from: newItinerary)
                    cleanItinerary.savePersistentData()
                    itineraries.append(cleanItinerary)
                    //debugPrint("added with new UUID for: \(filePath)")
                } else {
                    //debugPrint("added from file for: \(filePath)")
                    itineraries.append(newItinerary)
                }
            } else {
                debugPrint("Decode failure for: \(filePath)")
            }
        } else {
            debugPrint("No fileData for: \(filePath)")
        }

    }
    
    func loadItineraries() {
        if let files = try? FileManager.default.contentsOfDirectory(atPath: ItineraryStore.appFilesFolderPath()).filter({ $0.hasSuffix(kItineraryPerststentDataFileDotSuffix)}).sorted() {
            if files.count > 0 {
                for fileName in files {
                    let filePath = ItineraryStore.appFilePathForFileNameWithSuffix(fileName)
                    loadItinerary(atPath: filePath)
                }
            } else {debugPrint("files count == 0")}
        } else { debugPrint("Directory read failed)")}
    }
    
    
    func reloadItineraries() {
        // this force erases all the itineraries so they better be saved to file
        itineraries = []
        loadItineraries()
    }
    
    
    func itineraryForID(id:String) -> Itinerary {
        itineraries.first { $0.id.uuidString == id } ?? Itinerary(title: kUnknownObjectErrorStr)
    }
    func itineraryTitleForID(id:String) -> String {
        itineraries.first { $0.id.uuidString == id }?.title ?? kUnknownObjectErrorStr
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
    
    func addItinerary(itinerary: Itinerary) -> Void {
        itineraries.append(itinerary)
        itinerary.savePersistentData()
        
    }
    func updateItinerary(itinerary: Itinerary) -> Void {
        guard let index = itineraries.firstIndex(where: { $0.id.uuidString == itinerary.id.uuidString }) else { debugPrint("Unable to update itinerary"); return  }
        itineraries[index] = itinerary
        itinerary.savePersistentData()
    }

    func hasItineraryWithID(_ id: String) -> Bool {
        guard let _ = itineraries.firstIndex(where: { $0.id.uuidString == id }) else { return false }
        return true
    }
}
