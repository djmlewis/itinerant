//
//  Itinerary.swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import Foundation
import UserNotifications
import Combine
import SwiftUI

func nowReferenceDateTimeInterval() -> TimeInterval { Date.now.timeIntervalSinceReferenceDate }

struct Itinerary: Identifiable, Codable, Hashable {
    // Persistent Data ==>
    let id: UUID //Immutable property will not be decoded if it is declared with an initial value which cannot be overwritten
    var modificationDate: TimeInterval
    // Editable Data ==>
    var title: String
    var stages: StageArray
   // runtime
    var filename: String? { packageFilePath?.fileNameWithoutExtensionFromPath }
    var packageFilePath: String?

    
    // these are full inits including UUID which must be done here to be decoded
    init(id: UUID = UUID(), title: String, stages: StageArray = [], /*filename: String? = nil,*/ modificationDate: TimeInterval, packageFilePath: String? = nil) {
        self.id = id
        self.title = title
        self.stages = stages
        //self.filename = filename
        self.modificationDate = modificationDate
        self.packageFilePath = packageFilePath
    }
    init(persistentData: PersistentData, /*filename: String? = nil,*/ packageFilePath: String? = nil) {
        self.id = persistentData.id
        self.title = persistentData.title
        self.stages = persistentData.stages
        //self.filename = filename
        self.modificationDate = persistentData.modificationDate
        self.packageFilePath = packageFilePath
    }
    
    init(editableData: EditableData, modificationDate: TimeInterval, packageFilePath: String) {
        self.id = UUID()
        self.title = editableData.title
        self.stages = editableData.stages
        self.modificationDate = modificationDate
        self.packageFilePath = packageFilePath
    }
    
    init(id: UUID, modificationDate: TimeInterval) {
        self.id = id
        self.title = ""
        self.stages = []
        //self.filename = nil
        self.modificationDate = modificationDate
        self.packageFilePath = nil
    }
    
    
    mutating func updateModificationDateToNow() {
        modificationDate = nowReferenceDateTimeInterval()
    }
    
    mutating func updateStageDurationFromDate(stageUUID: UUID, durationDate date: Date) {
        if var stage = stageForUUID(stageUUID), let index = stageIndex(forUUIDstr: stageUUID.uuidString) {
            stage.setDurationFromDate(date)
            stages[index] = stage
            updateModificationDateToNow()
            _ = savePersistentData()
        }
    }

}

extension Itinerary {
    static func templateItinerary() -> Itinerary { Itinerary(title: "Itinerary", stages: Stage.templateStageArray(),modificationDate: nowReferenceDateTimeInterval()) }
    static func sampleItineraryArray() -> [Itinerary] { [Itinerary.templateItinerary(), Itinerary.templateItinerary(), Itinerary.templateItinerary()] }
    static func emptyItineraryArray() -> [Itinerary] { [] }
    
    static func errorItinerary() -> Itinerary { Itinerary(title: kUnknownObjectErrorStr, modificationDate: nowReferenceDateTimeInterval()) }
    
    static func duplicateItineraryNewIDModDateUniquefiedPath(from itinerary:Itinerary) -> Itinerary {
        // fix a nil packageFilePath
        let validPackageFilePath = itinerary.packageFilePath == nil ?
        dataPackagesDirectoryPathAddingUniqueifiedFileNameWithoutExtension(itinerary.title) :
        itinerary.packageFilePath!
        return Itinerary(title: itinerary.title,
                         stages: Stage.stageArrayWithNewIDs(from: itinerary.stages),
                         //filename: itinerary.filename,
                         modificationDate: nowReferenceDateTimeInterval(),
                         packageFilePath: dataPackagesDirectoryPathUniquifiedFromPath(validPackageFilePath)!
        )
    }

    
}

// MARK: - Characteristics
extension Itinerary {
    var idStr: String { id.uuidString }
    func hasIDstr(_ idstrtotest: String?) -> Bool {
        // notification ID strings may have suffixes so use contains not ==
        return idstrtotest != nil && idStr == idstrtotest
    }
    
    func stageActive(uuidStrStagesActiveStr: String) -> Stage? { stages.first { uuidStrStagesActiveStr.contains($0.idStr) } }
    func isActive(uuidStrStagesActiveStr: String) -> Bool { stages.first { uuidStrStagesActiveStr.contains($0.idStr) } != nil }
    
    func stageRunning(uuidStrStagesRunningStr: String) ->  Stage? { stages.first { uuidStrStagesRunningStr.contains($0.idStr) } }
    func isRunning(uuidStrStagesRunningStr: String) ->   Bool { stages.first { uuidStrStagesRunningStr.contains($0.idStr) } != nil }
    
    var someStagesAreCountUp: Bool { stages.firstIndex { $0.isCountUp } != nil }

    var someStagesAreCountDownToDate: Bool { stages.firstIndex { $0.isCountDownToDate } != nil }

    func stageIndex(forUUIDstr uuidstr: String) -> Int? {
        return stages.firstIndex(where: { $0.hasIDstr(uuidstr) })
    }
    
    func indexOfNextActivableStage(fromUUIDstr uuidstr: String ) -> Int? {
        // stops at .count
        guard stages.count > 0, let currindex = stageIndex(forUUIDstr: uuidstr) else { return nil }
        var nextIndex = currindex + 1
        while nextIndex < stages.count {// no looping
            if stages[nextIndex].isActionable { return nextIndex }
            nextIndex += 1
        }
        return nil
    }
    var firstIndexActivableStage: Int? {
        guard !stages.isEmpty else { return nil }
        return stages.firstIndex { $0.isActionable }
    }
    
    func stageForUUID(_ stageUUID: UUID) -> Stage? { stages.first(where: { $0.id == stageUUID }) }
    
    var lastStageUUIDstr: String? { stages.last?.idStr }
    var firstStageUUIDstr: String? { stages.first?.idStr }

    var stagesIDstrs: [String] { stages.map { $0.idStr }}
    
    func totalDurationAtDate(atDate date: Date) -> Double { Double(stages.reduce(0) { partialResult, stage in
        // remove any negative flag values with max(...,0)
        partialResult + max(stage.durationSecsIntCorrected(atDate: date),0)
    }) }
    
}


// MARK: - Reset
extension Itinerary {
    
    func removeAllStageIDsAndNotifcationsFrom(str1: String, str2: String, dict1: [String:String], dict2:[String:String]) -> (String, String, [String:String], [String:String]) {
        var currentStr1 = str1
        var currentStr2 = str2
        var currentDict1 = dict1
        var currentDict2 = dict2
        stagesIDstrs.forEach { uuidstr in
            removeAllPendingAndDeliveredStageNotifications(forUUIDstr: uuidstr)
            currentStr1 = currentStr1.replacingOccurrences(of: uuidstr, with: "",options: [.literal])
            currentStr2 = currentStr2.replacingOccurrences(of: uuidstr, with: "",options: [.literal])
            currentDict1[uuidstr] = nil
            currentDict2[uuidstr] = nil
        }
        return (currentStr1, currentStr2, currentDict1,currentDict2)
    }
    
    func removeOnlyAllStageActiveRunningStatusLeavingStartEndDates(str1: String, str2: String) -> (String, String) {
        var currentStr1 = str1
        var currentStr2 = str2
        stagesIDstrs.forEach { uuidstr in
            removeAllPendingAndDeliveredStageNotifications(forUUIDstr: uuidstr)
            currentStr1 = currentStr1.replacingOccurrences(of: uuidstr, with: "",options: [.literal])
            currentStr2 = currentStr2.replacingOccurrences(of: uuidstr, with: "",options: [.literal])
        }
        return (currentStr1, currentStr2)
    }

    
}

// MARK: - WatchMessageData
extension Itinerary {
    init?(messageItineraryData data: Data) {
        if let watchData = try? JSONDecoder().decode(Itinerary.WatchMessageData.self, from: data) {
            self.id = watchData.id // !!! will MATCH the sending Itinerary on phone !!!
            self.title = watchData.title
            self.stages = Stage.stagesFromWatchStages(watchData.messageStages)
            //self.filename = watchData.filename // start with this
            self.modificationDate = watchData.modificationDate
        } else { return nil }
    }

    struct WatchMessageData: Identifiable, Codable, Hashable {
        let id: UUID //Immutable property will not be decoded if it is declared with an initial value which cannot be overwritten
        var modificationDate: TimeInterval
        var title: String
        var messageStages: StageWatchMessageDataArray
        var filename: String

        internal init(id: UUID, modificationDate: TimeInterval, title: String, messageStages: StageWatchMessageDataArray, filename: String) {
            self.id = id
            self.modificationDate = modificationDate
            self.title = title
            self.messageStages = messageStages
            self.filename = filename
        }
    }
        
    var watchDataKeepingUUID: Data? { try? JSONEncoder().encode(Itinerary.WatchMessageData(
        id: id,
        modificationDate: modificationDate,
        title: title,
        messageStages: watchStages(),
        filename: filename ?? "") ) }
    
    func watchStages() -> StageWatchMessageDataArray { stages.map { $0.watchDataNewUUID } }

}

// MARK: - ItineraryEditableData
extension Itinerary {
    struct EditableData {
        var title: String = ""
        var stages: StageArray = []
        
        
        func stageIndex(forUUIDstr uuidstr: String) -> Int? {
            return stages.firstIndex(where: { $0.hasIDstr(uuidstr) })
        }
        
    }
    
    var itineraryEditableData: EditableData {
        EditableData(title: title, stages: stages)
    }
    
    mutating func updateItineraryEditableData(from itineraryEditableData: EditableData) {
        title = itineraryEditableData.title
        stages = itineraryEditableData.stages
        updateModificationDateToNow()
        _ = savePersistentData()
    }
    

}


// MARK: - PersistentData
extension Itinerary {
    struct PersistentData: Codable {
        // editable
        let title: String
        let stages: StageArray
        // persistent (+ editable)
        let id: UUID
        var modificationDate: TimeInterval
    }
    
    var itineraryPersistentData: PersistentData {
        PersistentData(title: title, stages: stages, id: id, modificationDate: modificationDate)
    }

    
    func savePersistentData() -> String? {
        /* ***  Always call updateModificationDateToNow() - if needed - before calling this function *** */
        if let encodedPersistentData: Data = try? JSONEncoder().encode(self.itineraryPersistentData) {
            // fix a nil packageFilePath
            let validPackageFilePath = packageFilePath == nil ?
            dataPackagesDirectoryPathAddingUniqueifiedFileNameWithoutExtension(title) :
            packageFilePath!
            
            var isDir: ObjCBool = true
            if FileManager.default.fileExists(atPath: validPackageFilePath, isDirectory: &isDir) {
                // write directly into the package
                let fileURL = URL(fileURLWithPath: (validPackageFilePath as NSString).appendingPathComponent(kPackageNamePersistentDataFile) )
                do {
                    try encodedPersistentData.write(to: fileURL)
                } catch let error {
                    debugPrint("unable write PD into package at ", validPackageFilePath,error.localizedDescription)
                }
            } else {
                // create a new package and write the encoded PDdata into it in one go
                // make the regularFileWithContents dict with PDdata in it
                let itineraryPDFileWrap = FileWrapper(regularFileWithContents: encodedPersistentData)
                let packageFileWrapper = FileWrapper(directoryWithFileWrappers: [kPackageNamePersistentDataFile : itineraryPDFileWrap])
                do {
                    try packageFileWrapper.write(to: URL(filePath: validPackageFilePath), originalContentsURL: nil)
                } catch let error {
                    debugPrint("unable to create new package at ", validPackageFilePath,error.localizedDescription)
                }
            }
            
        } else {
            debugPrint("decode failure for:", packageFilePath as Any)
        }
        return nil
    }
    
    
}


extension Itinerary {
        
    var exportString: String {
        var lines: [String] = [title]
        stages.forEach { lines += $0.exportArray }
        
        return  lines.joined(separator: kSeparatorImportFile)
    }
    
    
}




