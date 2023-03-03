//
//  ItineraryDocument.swift
//  itinerant
//
//  Created by David JM Lewis on 24/01/2023.
//

import SwiftUI
import UniformTypeIdentifiers


struct ItineraryFile: FileDocument {
    static var readableContentTypes = [/*UTType.itineraryDataFile,*/ UTType.itineraryTextFile, UTType.itinerarySettingsFile, UTType.itineraryDataPackage]

    var exportText: String?
    var itineraryPersistentData: Itinerary.PersistentData?
    var settingsDict: [ String : String ]?
    var packageItinerary: Itinerary?
    
    // a simple initializer that creates new, empty documents
    
    init(packageItinerary: Itinerary) {
        // ATM we are preserving ID!!!
        self.packageItinerary = packageItinerary
    }
    
    init(exportText: String) {
        self.exportText = exportText
    }

    init(editableData: Itinerary.EditableData) {
        // force a new UUID for saving in itinerary AND stages!
        self.itineraryPersistentData = Itinerary.PersistentData(title: editableData.title,
                                                                stages: Itinerary.stagesPersistentData(Stage.stageArrayWithNewIDs(from: editableData.stages)),
                                                                id: UUID(),
                                                                modificationDate: nowReferenceDateTimeInterval() )
    }

    init(settingsDict: [String:String]) {
        // force a new UUID for saving in itinerary AND stages!
        self.settingsDict = settingsDict
    }

    // this initializer loads data that has been saved previously
    init(configuration: ReadConfiguration) throws {
        if configuration.contentType == .itineraryDataPackage {
            if let wrappers = configuration.file.fileWrappers {
                if let itineraryPDFileWrap = wrappers[kPackageNamePersistentDataFile] {
                    if let data = itineraryPDFileWrap.regularFileContents {
                        self.itineraryPersistentData = try JSONDecoder().decode(Itinerary.PersistentData.self, from: data)
                    }
                }
                /* should load images here */
            } else {
                throw CocoaError(.fileReadCorruptFile)
            }

        } else if let data = configuration.file.regularFileContents {
            switch configuration.contentType {
            case .itineraryTextFile:
                exportText = String(decoding: data, as: UTF8.self)
            case .itineraryDataFile:
                self.itineraryPersistentData = try JSONDecoder().decode(Itinerary.PersistentData.self, from: data)
            case .itinerarySettingsFile:
                self.settingsDict = try JSONDecoder().decode([String:String].self, from: data)
            default:
                break
            }
            
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    // this will be called when the system wants to write our data to disk
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        var data: Data = Data()
            switch configuration.contentType {
            case .itineraryTextFile where exportText != nil:
                data = Data(exportText!.utf8)
            case .itineraryDataFile where itineraryPersistentData != nil:
                data = try JSONEncoder().encode(itineraryPersistentData)
            case .itinerarySettingsFile where settingsDict != nil:
                data = try JSONEncoder().encode(settingsDict)
            case .itineraryDataPackage where packageItinerary != nil:
                if let encodedItinerary = try? JSONEncoder().encode(packageItinerary!.itineraryPersistentData) {
                    var directoryDict: [String : FileWrapper] = [String : FileWrapper]()
                    // add persistentData
                    let itineraryPDFileWrap = FileWrapper(regularFileWithContents: encodedItinerary)
                    directoryDict[kPackageNamePersistentDataFile] = itineraryPDFileWrap
                    // add itinerary imageThumbnail if nonnil
                    if packageItinerary?.imageDataThumbnailActual != nil {
                        let fileWrap = FileWrapper(regularFileWithContents: packageItinerary!.imageDataThumbnailActual!)
                        directoryDict[kPackageNameImageFileItineraryThumbnail] = fileWrap
                    }
                    // add itinerary imagefullsize if nonnil
                    if packageItinerary?.imageDataFullActual != nil {
                        let fileWrap = FileWrapper(regularFileWithContents: packageItinerary!.imageDataFullActual!)
                        directoryDict[kPackageNameImageFileItineraryFullsize] = fileWrap
                    }
                    return FileWrapper(directoryWithFileWrappers: directoryDict)
                }
            default:
                break
            }
        return FileWrapper(regularFileWithContents: data)
    }
}




//final class SettingsDocument: ReferenceFileDocument {
//
//    typealias Snapshot = [ String : String ]
//    
//    @Published var dictData: [ String : String ]
//    
//    // Define the document type this app is able to load.
//    /// - Tag: ContentType
//    static var readableContentTypes: [UTType] { [.itinerarySettingsFile] }
//    
//    /// - Tag: Snapshot
//    func snapshot(contentType: UTType) throws -> [String:String] {
//        dictData // Make a copy.
//    }
//    
//    init() {
//        dictData = [String:String]()
//    }
//
//    init(dict: [String:String]) {
//        // force a new UUID for saving in itinerary AND stages!
//        self.dictData = dict
//    }
//    
//    
//    // Load a file's contents into the document.
//    /// - Tag: DocumentInit
//    init(configuration: ReadConfiguration) throws {
//        guard let data = configuration.file.regularFileContents
//        else {
//            throw CocoaError(.fileReadCorruptFile)
//        }
//        self.dictData = try JSONDecoder().decode([String:String].self, from: data)
//    }
//    
//    /// Saves the document's data to a file.
//    /// - Tag: FileWrapper
//    func fileWrapper(snapshot: [String:String], configuration: WriteConfiguration) throws -> FileWrapper {
//        let data = try JSONEncoder().encode(snapshot)
//        let fileWrapper = FileWrapper(regularFileWithContents: data)
//        return fileWrapper
//    }
//}

