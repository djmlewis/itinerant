//
//  ItineraryStore.swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import Foundation
import SwiftUI

let kItineraryStoreFileName = "itinerant/itineraryStore_10" + ".data"
let kItineraryUUIDsFileName = "itineraryUUIDs" + ".data"

let kItineraryPerststentDataFileSuffix = "itinerary"
let kItineraryPerststentDataFileDotSuffix = "." + kItineraryPerststentDataFileSuffix
let kItineraryPerststentDataFileDirectoryName = "Itinerant"
let kItineraryPerststentDataFileDirectorySlashNameSlash = "/" + kItineraryPerststentDataFileDirectoryName + "/"
let kItineraryPerststentDataFileDirectorySlashName =  "/" + kItineraryPerststentDataFileDirectoryName

let kUnknownObjectErrorStr = "error: Unkown"



class ItineraryStore: ObservableObject {
    
    @Published var itineraries: [Itinerary] = []
    @Published var permissionToNotify: Bool = false
    @Published var isLoadingItineraries = false
    
    static func appFilesFolderPathNoSlash() -> String {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path()  + kItineraryPerststentDataFileDirectoryName
    }
    static func appFilesFolderPathTrailingSlash() -> String {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path()  + kItineraryPerststentDataFileDirectorySlashNameSlash
    }
    static func appFilePathWithSuffixForFileNameWithoutSuffix(_ filename:String) -> String {
        appFilesFolderPathTrailingSlash() + filename + kItineraryPerststentDataFileDotSuffix
    }
    
    
    func loadItineraries(isLoadingItineraries: inout Bool) {
        func noFilesToLoad() {
            isLoadingItineraries = false
            debugPrint("No files to load)")
        }
        let path = ItineraryStore.appFilesFolderPathNoSlash()
        if !FileManager.default.fileExists(atPath: path) {
            try! FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false)
        }
        if let files = try? FileManager.default.contentsOfDirectory(atPath: path).filter({ $0.hasSuffix(kItineraryPerststentDataFileDotSuffix)}).sorted() {
            if files.count > 0 {
                for fileName in files {
                    let filePath = path + "/" + fileName
                    if let fileData = FileManager.default.contents(atPath: filePath) {
                        if let persistentData: Itinerary.PersistentData = try? JSONDecoder().decode(Itinerary.PersistentData.self, from: fileData) {
                            let newItinerary = Itinerary(persistentData: persistentData)
                            let newUUIDstr = newItinerary.id.uuidString
                            if itineraries.filter({ $0.id.uuidString == newUUIDstr}).count > 0 {
                                try! FileManager.default.removeItem(atPath: filePath)
                                // make a new UUID()
                                let cleanItinerary = Itinerary(title: newItinerary.title, stages: newItinerary.stages
                                                               //,uuidActiveStage: newItinerary.uuidActiveStage,
                                                               //uuidRunningStage: newItinerary.uuidRunningStage
                                )
                                cleanItinerary.savePersistentData()
                                itineraries.append(cleanItinerary)
                                debugPrint("added with new UUID for: \(fileName)")
                            } else {
                                debugPrint("added from file for: \(fileName)")
                                itineraries.append(newItinerary)
                            }
                            if itineraries.count >= files.count {
                                isLoadingItineraries = false
                            }
                        } else {
                            debugPrint("Decode failure for: \(fileName)")
                        }
                    } else {
                        debugPrint("No fileData for: \(fileName)")
                    }
                }
            } else {noFilesToLoad()}
        } else {noFilesToLoad()}
    }
    
    func itineraryForID(id:String) -> Itinerary {
        itineraries.first { $0.id.uuidString == id } ?? Itinerary(title: kUnknownObjectErrorStr)
    }
    func itineraryTitleForID(id:String) -> String {
        itineraries.first { $0.id.uuidString == id }?.title ?? kUnknownObjectErrorStr
    }
    
    func removeItinerariesAtOffsets(offsets:IndexSet) -> Void {
        let idsToDelete = offsets.map { itineraries[$0].id.uuidString }
        let path = ItineraryStore.appFilesFolderPathNoSlash()
        for id in idsToDelete {
            let filePath = path + id + kItineraryPerststentDataFileDotSuffix
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

/*
 func saveStore() -> Void {
 Task {
 do { try await ItineraryStore.initiateSaveAsync(itineraries: itineraries) }
 catch { fatalError("Error saving itineraries") }
 }
 }
 
 private static func itineraryStoreFileURL() throws -> URL {
 try FileManager.default.url(for: .documentDirectory,
 in: .userDomainMask,
 appropriateFor: nil,
 create: false)
 .appendingPathComponent(kItineraryStoreFileName)
 }
 
 
 
 static func initiateLoadAsync() async throws -> [Itinerary] {
 try await withCheckedThrowingContinuation { continuation in
 // note the call to self.completeLoadAsync sending `result` which wraps either an [Itinerary] or Error
 completeLoadAsync { result in
 switch result {
 case .failure(let error):
 debugPrint("initiateLoadAsync failure")
 continuation.resume(throwing: error)
 case .success(let itinsLoaded):
 debugPrint("initiateLoadAsync success")
 continuation.resume(returning: itinsLoaded)
 }
 }
 }
 }
 
 static func completeLoadAsync(completion: @escaping (Result<[Itinerary], Error>)->Void) {
 debugPrint("completeLoadAsync...")
 DispatchQueue.global(qos: .background).async {
 do {
 let fileURL = try itineraryStoreFileURL()
 guard let file = try? FileHandle(forReadingFrom: fileURL) else {
 // first time around there is no file, so return an empty one
 DispatchQueue.main.async {
 debugPrint("completeLoadAsync guard")
 completion(.success(Itinerary.empty[Itinerary]()))
 }
 return
 }
 let itinsLoaded = try JSONDecoder().decode(ItineraryArray.self, from: file.availableData)
 DispatchQueue.main.async {
 debugPrint("completeLoadAsync decoded")
 completion(.success(itinsLoaded))
 }
 } catch {
 DispatchQueue.main.async {
 debugPrint("completeLoadAsync failure")
 completion(.failure(error))
 }
 }
 }
 }
 */

/*
 @discardableResult
 static func initiateSaveAsync(itineraries: ItineraryArray) async throws -> Int {
 try await withCheckedThrowingContinuation { continuation in
 // note the call to self.completeSaveAsync sending `result` which wraps either an ItineraryArray or Error
 completeSaveAsync(itineraries: itineraries) { result in
 switch result {
 case .failure(let error):
 debugPrint("initiateSaveAsync failure")
 continuation.resume(throwing: error)
 case .success(let itinsSaved):
 debugPrint("initiateSaveAsync success")
 continuation.resume(returning: itinsSaved)
 }
 }
 }
 }
 
 static func completeSaveAsync(itineraries: ItineraryArray, completion: @escaping (Result<Int, Error>)->Void) {
 DispatchQueue.global(qos: .background).async {
 do {
 let data = try JSONEncoder().encode(itineraries)
 let outfile = try itineraryStoreFileURL()
 try data.write(to: outfile)
 debugPrint("completeSaveAsync success")
 DispatchQueue.main.async { completion(.success(itineraries.count)) }
 } catch {
 debugPrint("completeSaveAsync failure")
 DispatchQueue.main.async { completion(.failure(error)) }
 }
 }
 }
 */



