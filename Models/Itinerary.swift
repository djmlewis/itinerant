//
//  Itinerary.swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import Foundation
import UserNotifications



struct Itinerary: Identifiable, Codable, Hashable {
    // Persistent Data ==>
    let id: UUID //Immutable property will not be decoded if it is declared with an initial value which cannot be overwritten
    // Editable Data ==>
    var title: String
    var stages: StageArray
    
    var stagesIDstrs: [String] { stages.map { $0.id.uuidString }}
    
    // these are full inits including UUID which must be done here to be decoded
    init(id: UUID = UUID(), title: String, stages: StageArray = []) {
        self.id = id
        self.title = title
        self.stages = stages
        
    }
    init(persistentData: PersistentData) {
        self.id = persistentData.id
        self.title = persistentData.title
        self.stages = persistentData.stages
    }
    
    init(editableData: EditableData) {
        self.id = UUID()
        self.title = editableData.title
        self.stages = editableData.stages
    }
    
    init(id: UUID) {
        self.id = id
        self.title = ""
        self.stages = []
    }
    
    
    static func duplicateItineraryWithAllNewIDs(from itinerary:Itinerary) -> Itinerary {
        return Itinerary(title: itinerary.title, stages: Stage.stageArrayWithNewIDs(from: itinerary.stages))
    }
    
}


extension Itinerary {
    
    func removeAllStageIDsAndNotifcations(from str1: String, andFrom str2: String) -> (String, String) {
        let uuidstrs = stagesIDstrs
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: uuidstrs)
        var currentStr1 = str1
        var currentStr2 = str2
        uuidstrs.forEach { uuidstr in
            currentStr1 = currentStr1.replacingOccurrences(of: uuidstr, with: "",options: [.literal])
            currentStr2 = currentStr2.replacingOccurrences(of: uuidstr, with: "",options: [.literal])
        }
        return (currentStr1, currentStr2)
    }
    
    
    func hasRunningStage(uuidStrStagesRunningStr: String) -> Bool {
        stages.first { uuidStrStagesRunningStr.contains($0.id.uuidString) } != nil
    }
    
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
        self.savePersistentData()
    }
    
}


// abstract ALL the vars of Itinerary into a struct ItineraryPersistentData that can be saved
extension Itinerary {
    struct PersistentData: Codable {
        // editable
        let title: String
        let stages: StageArray
        // persistent
        let id: UUID
    }
    
    var itineraryPersistentData: PersistentData {
        PersistentData(title: title, stages: stages, id: id)
    }

    
    func savePersistentData() {
        
        let persistendData = Itinerary.PersistentData(title: title,
                                                      stages: stages,
                                                      id: id
        )
        
        if let data: Data = try? JSONEncoder().encode(persistendData) {
            do {
                try data.write(to: URL(fileURLWithPath: ItineraryStore.appDataFilePathWithSuffixForFileNameWithoutSuffix(id.uuidString)))
            } catch  {
                debugPrint("Save write failure for: \(title)")
            }
        } else {
            debugPrint("Encode failure for: \(title)")
        }
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
        return Itinerary(title: title, stages: stages)
    }
    
}


//typealias ItineraryArray = [Itinerary]

extension Itinerary {
    static func templateItinerary() -> Itinerary { Itinerary(title: "Itinerary", stages: Stage.templateStageArray()) }
    static func sampleItineraryArray() -> [Itinerary] { [Itinerary.templateItinerary(), Itinerary.templateItinerary(), Itinerary.templateItinerary()] }
    static func emptyItineraryArray() -> [Itinerary] { [] }
    
    
    
}

