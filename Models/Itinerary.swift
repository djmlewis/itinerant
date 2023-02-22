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
    var filename: String?
    
    
    // these are full inits including UUID which must be done here to be decoded
    init(id: UUID = UUID(), title: String, stages: StageArray = [], filename: String? = nil, modificationDate: TimeInterval) {
        self.id = id
        self.title = title
        self.stages = stages
        self.filename = filename
        self.modificationDate = modificationDate
    }
    init(persistentData: PersistentData, filename: String? = nil) {
        self.id = persistentData.id
        self.title = persistentData.title
        self.stages = persistentData.stages
        self.filename = filename
        self.modificationDate = persistentData.modificationDate
    }
    
    init(editableData: EditableData, modificationDate: TimeInterval) {
        self.id = UUID()
        self.title = editableData.title
        self.stages = editableData.stages
        self.filename = nil
        self.modificationDate = modificationDate
    }
    
    init(id: UUID, modificationDate: TimeInterval) {
        self.id = id
        self.title = ""
        self.stages = []
        self.filename = nil
        self.modificationDate = modificationDate
    }
    
    
    mutating func updateModificationDateToNow() {
        modificationDate = nowReferenceDateTimeInterval()
    }
    
}

extension Itinerary {
    static func templateItinerary() -> Itinerary { Itinerary(title: "Itinerary", stages: Stage.templateStageArray(),modificationDate: nowReferenceDateTimeInterval()) }
    static func sampleItineraryArray() -> [Itinerary] { [Itinerary.templateItinerary(), Itinerary.templateItinerary(), Itinerary.templateItinerary()] }
    static func emptyItineraryArray() -> [Itinerary] { [] }
    
    static func errorItinerary() -> Itinerary { Itinerary(title: kUnknownObjectErrorStr, modificationDate: nowReferenceDateTimeInterval()) }
    
    static func duplicateItineraryWithAllNewIDsAndModDate(from itinerary:Itinerary) -> Itinerary {
        return Itinerary(title: itinerary.title, stages: Stage.stageArrayWithNewIDs(from: itinerary.stages), filename: itinerary.filename, modificationDate: nowReferenceDateTimeInterval())
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
    
    var someStagesAreCountUp: Bool { stages.reduce(false) { partialResult, stage in
        partialResult || stage.isCountUp
    } }
    
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
        guard stages.count > 0 else { return nil }
        var nextIndex = 0
        while nextIndex < stages.count {// one pass
            if stages[nextIndex].isActionable { return nextIndex }
            nextIndex += 1
        }
        return nil
    }
    
    var lastStageUUIDstr: String? { stages.last?.idStr }
    
    var stagesIDstrs: [String] { stages.map { $0.idStr }}
    
    func totalDurationAtDate(atDate date: Date) -> Double { Double(stages.reduce(0) { partialResult, stage in
        // remove any negative flag values with max(...,0)
        partialResult + stage.durationSecsIntCorrected(atDate: date)
    }) }
        
    func totalDurationText(atDate dateAtUpdate: Date) -> Text {
        return Text("\(Image(systemName: "timer")) \(Stage.stageFormattedDurationStringFromDouble(totalDurationAtDate(atDate: dateAtUpdate)))") +
        (someStagesAreCountUp ? Text(" +") : Text("")) +
        (someStagesAreCountUp ? Text("\(Image(systemName: "stopwatch"))") : Text(""))
    }
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
            self.id = watchData.id
            self.title = watchData.title
            self.stages = Stage.stagesFromWatchStages(watchData.messageStages)
            self.filename = watchData.filename // start with this
            self.modificationDate = watchData.modificationDate
        } else { return nil }
    }

    struct WatchMessageData: Identifiable, Codable, Hashable {
        let id: UUID //Immutable property will not be decoded if it is declared with an initial value which cannot be overwritten
        var modificationDate: TimeInterval
        var title: String
        var messageStages: StageWatchMessageDataArray
        var filename: String

        internal init(id: UUID = UUID(), modificationDate: TimeInterval, title: String, messageStages: StageWatchMessageDataArray, filename: String) {
            self.id = id
            self.modificationDate = modificationDate
            self.title = title
            self.messageStages = messageStages
            self.filename = filename
        }
    }
        
    var watchDataNewUUID: Data? { try? JSONEncoder().encode(Itinerary.WatchMessageData(// UUID is allocated in init
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
        _ = self.savePersistentData()
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
        /* ***  Always call updateModificationDateToNow() before calling this function *** */
        let persistendData = Itinerary.PersistentData(title: title,
                                                      stages: stages,
                                                      id: id,
                                                      modificationDate: modificationDate
        )
        if let data: Data = try? JSONEncoder().encode(persistendData) {
            do {
                let initialfilename = filename ?? title // revert to title if a nil arrives
                let fileURL = URL(fileURLWithPath: ItineraryStore.appDataFilePathWithSuffixForFileNameWithoutSuffix(initialfilename))
                try data.write(to: fileURL)
                return initialfilename
            } catch  let error {
                debugPrint("Save write failure for: \(title)", error.localizedDescription)
            }
        } else {
            debugPrint("Encode failure for: \(title)")
        }
        return nil
    }
    
    static func uniqueifiedDataFileNameWithoutExtensionFrom(nameOnly initialFileName: String) -> String {
        if let files = try? FileManager.default.contentsOfDirectory(atPath: ItineraryStore.appDataFilesFolderPath()).filter({ $0.hasSuffix(kItineraryPerststentDataFileDotSuffix)}),
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
    
}


extension Itinerary {
    
    static func importItinerary(fromString string: String) -> Itinerary? {
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
//            let stage = Stage(title: String(lines[firstIndex]),
//                              durationSecsInt: Int(lines[firstIndex+2]) ?? 0,
//                              details: String(lines[firstIndex+1]),
//                              snoozeDurationSecs: Int(lines[firstIndex+3]) ?? 0,
//                              flags: String(lines[firstIndex+4])
//            )
            stages.append(stage)
            firstIndex += kImportLinesPerStage
        }
        return Itinerary(title: title, stages: stages, modificationDate: nowReferenceDateTimeInterval())
    }
    
    var exportString: String {
        var lines: [String] = [title]
        stages.forEach { lines += $0.exportArray }
        
        return  lines.joined(separator: kSeparatorImportFile)
    }
    
    
}


//typealias ItineraryArray = [Itinerary]


