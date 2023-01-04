//
//  Itinerary.swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import Foundation


struct Itinerary: Identifiable, Codable {
    let id: UUID
    var title: String
    var stages: StageArray
    
    init(id: UUID = UUID(), title: String, stages: StageArray = Stage.sampleStageArray()) {
        self.id = id
        self.title = title
        self.stages = stages
    }

}


// abstract the editable vars of Itinerary into a struct ItineraryData that can be passed around and edited
extension Itinerary {
    struct ItineraryData {
        var title: String = ""
        var stages: StageArray = Stage.emptyStageArray()
    }
    
    var itineraryData: ItineraryData {
        ItineraryData(title: title, stages: stages)
    }
    
    mutating func updateItineraryData(from itineraryData: ItineraryData) {
        title = itineraryData.title
        stages = itineraryData.stages
    }
    
    init(itineraryData: ItineraryData) {
        id = UUID()
        title = itineraryData.title
        stages = itineraryData.stages
    }
}


typealias ItineraryArray = [Itinerary]

extension Itinerary {
    static func templateItinerary() -> Itinerary { Itinerary(title: "Itinerary") }
    static func sampleItineraryArray() -> ItineraryArray { [Itinerary.templateItinerary(), Itinerary.templateItinerary(), Itinerary.templateItinerary()] }
    static func emptyItineraryArray() -> ItineraryArray { [] }
}

