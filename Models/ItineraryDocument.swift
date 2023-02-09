//
//  ItineraryDocument.swift
//  itinerant
//
//  Created by David JM Lewis on 24/01/2023.
//

import SwiftUI
import UniformTypeIdentifiers


final class ItineraryDocument: ReferenceFileDocument {

    typealias Snapshot = Itinerary.PersistentData
    
    @Published var itineraryPersistentData: Itinerary.PersistentData
    
    // Define the document type this app is able to load.
    /// - Tag: ContentType
    static var readableContentTypes: [UTType] { [.itineraryDataFile] }
    
    /// - Tag: Snapshot
    func snapshot(contentType: UTType) throws -> Itinerary.PersistentData {
        itineraryPersistentData // Make a copy.
    }
    
    init() {
        itineraryPersistentData = Itinerary.PersistentData(title: "", stages: [], id: UUID(), modificationDate: nowReferenceDateTimeInterval())
    }

    init(editableData: Itinerary.EditableData) {
        // force a new UUID for saving in itinerary AND stages!
        self.itineraryPersistentData = Itinerary.PersistentData(title: editableData.title,
                                                                stages: Stage.stageArrayWithNewIDs(from: editableData.stages),
                                                                id: UUID(),
                                                                modificationDate: nowReferenceDateTimeInterval() )
    }
    
    
    // Load a file's contents into the document.
    /// - Tag: DocumentInit
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.itineraryPersistentData = try JSONDecoder().decode(Itinerary.PersistentData.self, from: data)
    }
    
    /// Saves the document's data to a file.
    /// - Tag: FileWrapper
    func fileWrapper(snapshot: Itinerary.PersistentData, configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(snapshot)
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        return fileWrapper
    }
}

final class SettingsDocument: ReferenceFileDocument {

    typealias Snapshot = [ String : String ]
    
    @Published var dictData: [ String : String ]
    
    // Define the document type this app is able to load.
    /// - Tag: ContentType
    static var readableContentTypes: [UTType] { [.itinerarySettingsFile] }
    
    /// - Tag: Snapshot
    func snapshot(contentType: UTType) throws -> [String:String] {
        dictData // Make a copy.
    }
    
    init() {
        dictData = [String:String]()
    }

    init(dict: [String:String]) {
        // force a new UUID for saving in itinerary AND stages!
        self.dictData = dict
    }
    
    
    // Load a file's contents into the document.
    /// - Tag: DocumentInit
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.dictData = try JSONDecoder().decode([String:String].self, from: data)
    }
    
    /// Saves the document's data to a file.
    /// - Tag: FileWrapper
    func fileWrapper(snapshot: [String:String], configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(snapshot)
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        return fileWrapper
    }
}

final class ItineraryTextDocument: ReferenceFileDocument {

    typealias Snapshot = String
    
    @Published var text: String
    
    // Define the document type this app is able to load.
    /// - Tag: ContentType
    static var readableContentTypes: [UTType] { [.itineraryTextFile] }
    
    /// - Tag: Snapshot
    func snapshot(contentType: UTType) throws -> String {
        text // Make a copy.
    }
    
    init() {
        text = String()
    }

    init(string: String) {
        // force a new UUID for saving in itinerary AND stages!
        self.text = string
    }
    
    
    // Load a file's contents into the document.
    /// - Tag: DocumentInit
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.text = String(decoding: data, as: UTF8.self)
    }
    
    /// Saves the document's data to a file.
    /// - Tag: FileWrapper
    func fileWrapper(snapshot: String, configuration: WriteConfiguration) throws -> FileWrapper {
        let data =  Data(snapshot.utf8)
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        return fileWrapper
    }
}
