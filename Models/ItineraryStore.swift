//
//  swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import Foundation
import SwiftUI
import UserNotifications


class ItineraryStore: ObservableObject {
    
    @Published var itineraries: [Itinerary] = []
       
    // MARK: - Itinerary Characteristics
    
    func itineraryForID(id:String) -> Itinerary? { return itineraries.first{ $0.idStr.contains(id) } }
    func hasItineraryWithID(_ id: String) -> Bool { return itineraries.firstIndex(where: { $0.idStr.contains(id) }) != nil }
    func itineraryForUUID(_ uuid:UUID) -> Itinerary? { return itineraries.first{ $0.id == uuid } }
    func itineraryIndexForUUID(_ uuid: UUID) -> Int? { return itineraries.firstIndex(where: { $0.id == uuid }) }
    func hasItineraryWithUUID(_ uuid: UUID) -> Bool { return itineraries.firstIndex(where: { $0.id == uuid }) != nil }
    func itineraryForStageIDstr(_ idstr: String) -> Itinerary? { itineraries.first { $0.hasStageWithID(idstr) } }
    
    func itineraryForIDisRunning(id:String, uuidStrStagesRunningStr: String) -> Bool {
        itineraryForID(id: id)?.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ?? false }

    func itineraryForTitle(_ title: String) -> Itinerary? { itineraries.first { $0.title == title } }
    func hasItineraryWithTitle(_ title: String) -> Bool { return itineraryForTitle(title) != nil }
    func itineraryTitleForID(id:String) -> String { itineraryForID(id: id)?.title ?? kUnknownObjectErrorStr }
    var itineraryTitles: [String] { itineraries.map { $0.title } }
    var itineraryUUIDStrs: [String] { itineraries.map { $0.idStr } }
    
    
    func itineraryFileNameForID(id:String) -> String { itineraryForID(id: id)?.filename ?? "---" }
    func hasItineraryWithFilename(_ filename: String) -> Bool { return itineraries.firstIndex(where: { $0.filename == filename }) != nil }

    func itineraryModificationDateForID(id:String) -> Date? {
        guard let timeinterval = itineraryForID(id: id)?.modificationDate else { return nil }
        return Date(timeIntervalSinceReferenceDate: timeinterval)
    }
    
        
    
    // MARK: - Importing

    func importItineraryAtPath(_ filePath:String) -> String? {
        var badFilename: String? = filePath
        do {
            let content = try String(contentsOfFile: filePath)
            if let importedItinerary = itineraryFromImportString(content) {
                // itineraryFromImportString sets modificationDate and packageFilePath
                itineraries.append(importedItinerary)
                sortItineraries()
                _ = importedItinerary.savePersistentData()
                badFilename = nil
            }
        } catch let error {
            debugPrint("importItineraryAtPath", error.localizedDescription)
        }
        return badFilename
    }
    

    // MARK: - Loading & sorting Itineraries
    
    func tryToLoadItineraries() -> [String] {
        var filesToDeleteArray = [String]()
        var isDir: ObjCBool = true
        if !FileManager.default.fileExists(atPath: appDataPackagesDirectoryPath(), isDirectory: &isDir) {
            do {
                try FileManager.default.createDirectory(at: appDataPackagesDirectoryURL(), withIntermediateDirectories: true)
                filesToDeleteArray = completeLoadItineraries()
            } catch let error {
                debugPrint("unable to create data files directory", error.localizedDescription)
            }
        } else { filesToDeleteArray = completeLoadItineraries() }
        return filesToDeleteArray
    }
//          |
//          V
    func completeLoadItineraries() -> [String] {
        var filesToDeleteArray = [String]()
        if let files = dataPackagesInDataPackagesDirectory(), !files.isEmpty {
            // prevent duplication
            itineraries = []
            for fileName in files {
                let filePath = appDocumentsOrPackagesDirectoryPathDependingOnFileNameSuffix(fileName)
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
//          |
//          V
    func loadItineraryPackage(atPath packagePath:String) -> String? {
        var pathdelete: String? = packagePath // we nil it if all success
            if let persistentDataData = FileManager.default.contents(atPath: (packagePath as NSString).appendingPathComponent(kPackageNamePersistentDataFile)) {
                if let decodedPersistentData: Itinerary.PersistentData = try? JSONDecoder().decode(Itinerary.PersistentData.self, from: persistentDataData) {
                    // we know we can open this itinerary.
                    // if internal keep its filename, otherwise make a unique one as needed
                    let isExternalLocation = !(filePathEqualsAppDataPackagesDirectoryPath(packagePath))
                    let duplicateUUIDFileName = hasItineraryWithUUID(decodedPersistentData.id) || hasItineraryWithFilename(packagePath.fileNameWithoutExtensionFromPath)
                    let packagepathcorrect = isExternalLocation  ?
                    // duplicateItineraryWithAllNewIDsAndModDate also uniquefies. packagePath is NOT nil, try to preserve original filename
                    dataPackagesDirectoryPathUniquifiedFromPath(packagePath)! :
                    packagePath
                    // now copy the original if UUID is unique, otherwise make new UUIDs for everything
                    var loadedItinerary: Itinerary
                    if duplicateUUIDFileName {
                        loadedItinerary = Itinerary.duplicateItineraryNewIDModDateUniquefiedPath(from: Itinerary(persistentData: decodedPersistentData, packageFilePath: packagepathcorrect))
                    } else {
                        loadedItinerary = Itinerary(persistentData: decodedPersistentData, packageFilePath: packagepathcorrect)
                    }
                    
                    if isExternalLocation || duplicateUUIDFileName {
                        // copy the package to itineraries folder if external or duplicated. savePersistentData() creates a package as needed
                        _ = loadedItinerary.savePersistentData()
                        // now transfer the supporting files from the duplicated/transferred package, while renaming them
                        copyAllSupportFiles(fromPath: packagePath, toPath: loadedItinerary.packageFilePath,
                                            fromIDs: decodedPersistentData.stages.map({ $0.idStr }),
                                            toIDs: loadedItinerary.stages.map({ $0.idStr }))
                   }
                    
                    // now load images - here to avoid duplicating lots of image files during a savePersistentData()
                    loadedItinerary.loadAllImageFilesFromPackage()
                    
                    // add to our itineraries
                    itineraries.append(loadedItinerary)
                    // nil the return
                    pathdelete = nil
                } else {
                    debugPrint("Decode failure for: \(packagePath)")
                }
            } else {
                debugPrint("No itinerary data file for: \(packagePath)")
            }
        return pathdelete
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
    
        
// MARK: - Support Files In Package
    func copyAllSupportFiles(fromPath: String?, toPath: String?, fromIDs: [String], toIDs:[String]) {
        if let oldPath = fromPath, let newPath = toPath, oldPath != newPath {
            let oldPathNSS = oldPath as NSString
            let newPathNSS = newPath as NSString
            let fileManager = FileManager.default
            do {
                /* **** itinerary image files **** */
                try fileManager.copyItem(atPath: oldPathNSS.appendingPathComponent(kPackageNameImageFileItineraryThumbnail), toPath: newPathNSS.appendingPathComponent(kPackageNameImageFileItineraryThumbnail))
                try fileManager.copyItem(atPath: oldPathNSS.appendingPathComponent(kPackageNameImageFileItineraryFullsize), toPath: newPathNSS.appendingPathComponent(kPackageNameImageFileItineraryFullsize))
                /* **** stage image files. One-pass renaming **** */
                if fromIDs.count == toIDs.count {
                    for i in 0..<fromIDs.count {
                        try ImageSizeType.allCases.forEach { type in
                            let suffix = type.rawValue + ItineraryFileExtension.imageData.dotExtension
                            let fromName = fromIDs[i] + suffix
                            let toName = toIDs[i] + suffix
                            try fileManager.copyItem(atPath: oldPathNSS.appendingPathComponent(fromName), toPath: newPathNSS.appendingPathComponent(toName))
                        }
                    }
                }
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        } else {
            debugPrint("nil path or oldpath == newPath!!", fromPath as Any, toPath as Any)
        }
    }

// MARK: - Removing Itineraries
    
    func removeItinerariesAtOffsets(offsets:IndexSet) -> Void {
        let filenamesToDelete = offsets.map { itineraries[$0].filename! }
        for filename in filenamesToDelete {
            let filePath = dataPackagesDirectoryPathAddingSuffixToFileNameWithoutExtension(filename)
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
        let filePath = dataPackagesDirectoryPathAddingSuffixToFileNameWithoutExtension(filename)
        do {
            try FileManager.default.removeItem(atPath: filePath)
        } catch {
            debugPrint(error.localizedDescription)
        }
        itineraries.removeAll(where: { $0.id == uuid })
    }

    // MARK: - Adding Itineraries

    
    func addItineraryFromWatchMessage(itinerary: Itinerary, duplicateOption: DuplicateFileOptions) {
        var mutableItinerary = itinerary
        switch duplicateOption {
        case .keepBoth:
            mutableItinerary = Itinerary.duplicateItineraryNewIDModDateUniquefiedPath(from: mutableItinerary)
        case .replaceExisting:
            removeItineraryWithUUID(mutableItinerary.id)
        case .noDuplicate:
            break
        }
        // we've removed any duplicate file if .replaceExisting
        itineraries.append(mutableItinerary)
        sortItineraries()
        _ = mutableItinerary.savePersistentData()
    }

    // MARK: - Updating Itineraries & Stage Duration

    func updateItinerary(itinerary: Itinerary) -> String? {
        guard let index = itineraries.firstIndex(where: { $0.idStr == itinerary.idStr }) else { debugPrint("Unable to update itinerary"); return nil  }
        var itinerymutable = itinerary
        itinerymutable.updateModificationDateToNow()
        _ = itinerymutable.savePersistentData()
        itinerymutable.writeImageDataToPackage(itinerymutable.imageDataThumbnailActual, imageSizeType: .thumbnail)
        itinerymutable.writeImageDataToPackage(itinerymutable.imageDataFullActual, imageSizeType: .fullsize)
        itineraries[index] = itinerymutable
        return itinerymutable.filename
    }

    func updateStageDurationFromDate(stageUUID: UUID, itineraryUUID: UUID, durationDate date: Date) {
        if var itinerary = itineraryForUUID(itineraryUUID), let index = itineraryIndexForUUID(itineraryUUID) {
            itinerary.updateStageDurationFromDate(stageUUID: stageUUID, durationDate: date)
            itineraries[index] = itinerary
        }
    }
}



// MARK: - STATIC Directory & file paths and file names
    
    func appDocumentsDirectoryURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    func appDocumentsDirectoryPath() -> String {
        appDocumentsDirectoryURL().path().removingPercentEncoding ?? appDocumentsDirectoryURL().path()
    }
    func appendPathComponentToAppDocumentsDirectoryPath(_ component: String) -> String {
        (appDocumentsDirectoryPath() as NSString).appendingPathComponent(component)
    }

    func appDataPackagesDirectoryURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(path: kItineraryDataPackagesDirectoryName)
    }
    func appDataPackagesDirectoryPath() -> String {
        appDataPackagesDirectoryURL().path().removingPercentEncoding ?? appDataPackagesDirectoryURL().path()
        //(appDocumentsDirectoryPath() as NSString).appendingPathComponent(kItineraryDataPackagesDirectoryName)
    }
    func filePathEqualsAppDataPackagesDirectoryPath(_ filePath: String) -> Bool {
        appDataPackagesDirectoryPath() == ((filePath as NSString).deletingLastPathComponent)
    }

    func appendPathComponentToAppDataPackagesDirectoryPath(_ component: String) -> String {
        (appDataPackagesDirectoryPath() as NSString).appendingPathComponent(component)
    }
    // using URLs to construct paths then export as Strs leads to issues with spaces in the filename. stick with strings
    func dataPackagesDirectoryPathAddingSuffixToFileNameWithoutExtension(_ filename:String) -> String {
        appendPathComponentToAppDataPackagesDirectoryPath(filename + ItineraryFileExtension.dataPackage.dotExtension)
    }
    func appDocumentsOrPackagesDirectoryPathDependingOnFileNameSuffix(_ filenamewithextn: String) -> String {
        if filenamewithextn.hasSuffix(ItineraryFileExtension.dataFile.rawValue) {
            return appendPathComponentToAppDataPackagesDirectoryPath(filenamewithextn) }
        if filenamewithextn.hasSuffix(ItineraryFileExtension.dataPackage.rawValue) {
            return appendPathComponentToAppDataPackagesDirectoryPath(filenamewithextn) }
        if filenamewithextn.hasSuffix(ItineraryFileExtension.textFile.rawValue) {
            return appendPathComponentToAppDocumentsDirectoryPath(filenamewithextn) }
        return appendPathComponentToAppDocumentsDirectoryPath(filenamewithextn)

    }

    func dataPackagesInDataPackagesDirectory() -> [String]? {
        if let files = try? FileManager.default.contentsOfDirectory(atPath: appDataPackagesDirectoryPath()).filter({ $0.hasSuffix(ItineraryFileExtension.dataPackage.dotExtension)}).sorted() { return files } else {
            debugPrint("dataPackagesInDataPackagesDirectory empty!")
            return nil
        }
    }
    
    func uniqueifiedDataPackagesDirectoryFileNameForFileNameWithoutExtension(_ initialFileName: String) -> String {
        if let files = try? FileManager.default.contentsOfDirectory(atPath: appDataPackagesDirectoryPath()).filter({ $0.hasSuffix(ItineraryFileExtension.dataPackage.dotExtension)}),
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

    func dataPackagesDirectoryPathAddingUniqueifiedFileNameWithoutExtension(_ filename:String) -> String {
        let uniquename = uniqueifiedDataPackagesDirectoryFileNameForFileNameWithoutExtension(filename)
        return appendPathComponentToAppDataPackagesDirectoryPath(uniquename + ItineraryFileExtension.dataPackage.dotExtension)
    }

func dataPackagesDirectoryPathUniquifiedFromPath(_ path: String?)  -> String? {
    if let validPath = path  {
        return dataPackagesDirectoryPathAddingUniqueifiedFileNameWithoutExtension(((validPath as NSString).lastPathComponent as NSString).deletingPathExtension)
    }
    return nil
}

    func uniqueifiedDataPackagesDirectoryFileNameFromPath(_ path: String?) -> String? {
        if let validpath = path {
            return uniqueifiedDataPackagesDirectoryFileNameForFileNameWithoutExtension(((validpath as NSString).lastPathComponent as NSString).deletingPathExtension)
        }
        return nil
    }

// MARK: - STATIC Importing
 func itineraryFromImportString(_ string: String) -> Itinerary? {
    var lines = string.split(separator: kSeparatorImportFile, omittingEmptySubsequences: false)
    guard (lines.count - kImportHeadingLines) % kImportLinesPerStage == 0 else {
        return nil
    }
    let title = String(lines.removeFirst())
    var stages: [Stage] = []
    var firstIndex: Int = 0
    while firstIndex + kImportLinesPerStage <= lines.count {
        let slice = lines[firstIndex..<(firstIndex + kImportLinesPerStage)]
        let stage = Stage(fromImportLines: slice)
        stages.append(stage)
        firstIndex += kImportLinesPerStage
    }
    // we must set the filename, modificationDate and packageFilePath
    let uniqueFilename = uniqueifiedDataPackagesDirectoryFileNameForFileNameWithoutExtension(title)
    return Itinerary(title: title, stages: stages,
                     modificationDate: nowReferenceDateTimeInterval(),
    packageFilePath: dataPackagesDirectoryPathAddingSuffixToFileNameWithoutExtension(uniqueFilename))
}

