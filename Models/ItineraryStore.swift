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
let kItineraryPerststentDataFileDirectorySlashNameSlash = "/" + kItineraryPerststentDataFileDirectoryName
let kItineraryPerststentDataFileDirectorySlashName =  "/" + kItineraryPerststentDataFileDirectoryName + "/"





class ItineraryStore: ObservableObject {
    
    @Published var itineraries: ItineraryArray = []

    
    func loadItineraries() {
        let path = NSHomeDirectory() + "/Itinerant"
        if !FileManager.default.fileExists(atPath: path) {
            try! FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false)
        }
        if let files = try? FileManager.default.contentsOfDirectory(atPath: path).filter({ $0.hasSuffix(kItineraryPerststentDataFileDotSuffix)}).sorted() {
            for fileName in files {
                if let fileData = FileManager.default.contents(atPath: path + "/" + fileName) {
                    if let persistentData: Itinerary.PersistentData = try? JSONDecoder().decode(Itinerary.PersistentData.self, from: fileData) {
                        debugPrint("Decode SUCCESS for: \(fileName)")
                        itineraries.append(Itinerary(persistentData: persistentData))
                    } else {
                        debugPrint("Decode failure for: \(fileName)")
                    }
                } else {
                    debugPrint("No fileData for: \(fileName)")
                }
            }
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

    
    
    static func initiateLoadAsync() async throws -> ItineraryArray {
        try await withCheckedThrowingContinuation { continuation in
            // note the call to self.completeLoadAsync sending `result` which wraps either an ItineraryArray or Error
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

    static func completeLoadAsync(completion: @escaping (Result<ItineraryArray, Error>)->Void) {
        debugPrint("completeLoadAsync...")
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try itineraryStoreFileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    // first time around there is no file, so return an empty one
                    DispatchQueue.main.async {
                        debugPrint("completeLoadAsync guard")
                        completion(.success(Itinerary.emptyItineraryArray()))
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
}


