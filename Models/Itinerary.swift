//
//  Itinerary.swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import Foundation


struct Itinerary: Identifiable, Codable {
    let id: UUID //Immutable property will not be decoded if it is declared with an initial value which cannot be overwritten
    var title: String
    var stages: StageArray
    
    var uuidActiveStage: String = ""
    var uuidRunningStage: String = ""
    
    // these are full inits including UUID which must be done here to be decoded
    init(title: String, stages: StageArray = Stage.sampleStageArray()) {
        self.id = UUID()
        // use self here to distinguish from parameters
        self.title = title
        self.stages = stages
    }
    init(editableData: EditableData) {
        id = UUID()
        title = editableData.title
        stages = editableData.stages
    }
    init(persistentData: PersistentData) {
        id = persistentData.id
        title = persistentData.title
        stages = persistentData.stages
        uuidActiveStage = persistentData.uuidActiveStage
        uuidRunningStage = persistentData.uuidRunningStage
    }

    mutating func updateUuidActiveStage(newUuid: String) {
        uuidActiveStage = newUuid
        self.savePersistentData()
    }
    mutating func updateUuidRunningStage(newUuid: String) {
        uuidRunningStage = newUuid
        self.savePersistentData()
    }
    
    
    
    func savePersistentData() {
        
        let persistendData = Itinerary.PersistentData(title: title,
                                                      stages: stages,
                                                      id: id,
                                                      uuidActiveStage: uuidActiveStage,
                                                      uuidRunningStage: uuidRunningStage)
        
        if let data: Data = try? JSONEncoder().encode(persistendData) {
            do {
                try data.write(to: URL(fileURLWithPath: NSHomeDirectory() + "/Itinerant/" + id.uuidString + ".itinerary"))
            } catch  {
                debugPrint("Save write failure for: \(title)")
            }
        } else {
            debugPrint("Encode failure for: \(title)")
        }
    }
    
    
}


// abstract the editable vars of Itinerary into a struct ItineraryEditableData that can be passed around and edited
extension Itinerary {
    struct EditableData {
        var title: String = ""
        var stages: StageArray = Stage.emptyStageArray()
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
        let uuidActiveStage: String
        let uuidRunningStage: String
        
        
    }
    
    
    
}


typealias ItineraryArray = [Itinerary]

extension Itinerary {
    static func templateItinerary() -> Itinerary { Itinerary(title: "Itinerary") }
    static func sampleItineraryArray() -> ItineraryArray { [Itinerary.templateItinerary(), Itinerary.templateItinerary(), Itinerary.templateItinerary()] }
    static func emptyItineraryArray() -> ItineraryArray { [] }
    
    
}

