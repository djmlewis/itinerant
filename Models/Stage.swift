//
//  Stage.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import Foundation

typealias StageArray = [Stage]


struct Stage: Identifiable, Codable {
    let id: UUID
    var title: String
    var durationSecsInt: Int
    
    init(id: UUID = UUID(), title: String = "Stage", durationSecsInt: Int = 0) {
        self.id = id
        self.title = title
        self.durationSecsInt = durationSecsInt
    }
}


extension Stage {
    static func templateStage() -> Stage { Stage() }
    static func sampleStageArray() -> StageArray { [Stage.templateStage(), Stage.templateStage(), Stage.templateStage()] }
    static func emptyStageArray() -> StageArray { [] }
}
