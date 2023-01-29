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
    
    var stagesIDstrs: [String] { stages.map { $0.id.uuidString }}
    
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
    
    static func errorItinerary() -> Itinerary { Itinerary(title: kUnknownObjectErrorStr, modificationDate: nowReferenceDateTimeInterval()) }
    
    static func duplicateItineraryWithAllNewIDsAndModDate(from itinerary:Itinerary) -> Itinerary {
        return Itinerary(title: itinerary.title, stages: Stage.stageArrayWithNewIDs(from: itinerary.stages), filename: itinerary.filename, modificationDate: nowReferenceDateTimeInterval())
    }
    
    mutating func updateModificationDateToNow() {
        modificationDate = nowReferenceDateTimeInterval()
    }
    
}


extension Itinerary {
    
    func stageActive(uuidStrStagesActiveStr: String) -> Stage? { stages.first { uuidStrStagesActiveStr.contains($0.id.uuidString) } }
    func isActive(uuidStrStagesActiveStr: String) -> Bool { stages.first { uuidStrStagesActiveStr.contains($0.id.uuidString) } != nil }
    func stageRunning(uuidStrStagesRunningStr: String) ->  Stage? { stages.first { uuidStrStagesRunningStr.contains($0.id.uuidString) } }
    func isRunning(uuidStrStagesRunningStr: String) ->   Bool { stages.first { uuidStrStagesRunningStr.contains($0.id.uuidString) } != nil }
    var totalDuration: Double { Double(stages.reduce(0) { partialResult, stage in
        partialResult + stage.durationSecsInt
    }) }
    var someStagesAreCountUp: Bool { stages.reduce(false) { partialResult, stage in
        partialResult || stage.durationSecsInt == 0
    } }

    
    
    
}


extension Itinerary {
    
    func removeAllStageIDsAndNotifcations(from str1: String, andFrom str2: String, andFromDict dict: [String:String]) -> (String, String, [String:String]) {
        let uuidstrs = stagesIDstrs
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: uuidstrs)
        var currentStr1 = str1
        var currentStr2 = str2
        var currentDict = dict
        uuidstrs.forEach { uuidstr in
            currentStr1 = currentStr1.replacingOccurrences(of: uuidstr, with: "",options: [.literal])
            currentStr2 = currentStr2.replacingOccurrences(of: uuidstr, with: "",options: [.literal])
            currentDict[uuidstr] = nil
        }
        return (currentStr1, currentStr2, currentDict)
    }
    
    
    func hasRunningStage(uuidStrStagesRunningStr: String) -> Bool {
        stages.first { uuidStrStagesRunningStr.contains($0.id.uuidString) } != nil
    }
    
}

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

// abstract the editable vars of Itinerary into a struct ItineraryEditableData that can be passed around and edited
extension Itinerary {
    struct EditableData {
        var title: String = ""
        var stages: StageArray = []
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


// abstract ALL the vars of Itinerary into a struct ItineraryPersistentData that can be saved
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
        var lines = string.split { $0 == "\n"}
        guard (lines.count - kImportHeadingLines) % kImportLinesPerStage == 0 else {
            return nil
        }
        let title = String(lines.removeFirst())
        var stages: [Stage] = []
        var firstIndex: Int = 0
        while firstIndex + kImportLinesPerStage <= lines.count {
            let stage = Stage(title: String(lines[firstIndex]), durationSecsInt: Int(lines[firstIndex+1]) ?? 0, details: String(lines[firstIndex+2]))
            stages.append(stage)
            firstIndex += kImportLinesPerStage
        }
        return Itinerary(title: title, stages: stages, modificationDate: nowReferenceDateTimeInterval())
    }
    
}


//typealias ItineraryArray = [Itinerary]

extension Itinerary {
    static func templateItinerary() -> Itinerary { Itinerary(title: "Itinerary", stages: Stage.templateStageArray(),modificationDate: nowReferenceDateTimeInterval()) }
    static func sampleItineraryArray() -> [Itinerary] { [Itinerary.templateItinerary(), Itinerary.templateItinerary(), Itinerary.templateItinerary()] }
    static func emptyItineraryArray() -> [Itinerary] { [] }
    
    
    
}

