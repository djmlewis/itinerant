//
//  Itinerary.swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import Foundation

typealias ItineraryArray = [Itinerary]

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

// use an extension to abstract utility funcs & props
extension Itinerary {
    static func templateItinerary() -> Itinerary { Itinerary(title: "Itinerary") }
    static func sampleItineraryArray() -> ItineraryArray { [Itinerary.templateItinerary(), Itinerary.templateItinerary(), Itinerary.templateItinerary()] }
    static func emptyItineraryArray() -> ItineraryArray { [] }
}

