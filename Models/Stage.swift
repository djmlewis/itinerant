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
    
    init(id: UUID = UUID(), title: String = "Stage #", durationSecsInt: Int = SEC_HOUR * 3 + SEC_MIN * 7 + 37) {
        self.id = id
        self.title = title
        self.durationSecsInt = durationSecsInt
    }
}


extension Stage {
    
    // us func when you want a new init for each call: let value = Stage.staticFunc()  <== use ()
    static func templateStage() -> Stage { Stage() }
    static func sampleStageArray() -> StageArray { [Stage.templateStage(), Stage.templateStage(), Stage.templateStage()] }
    static func emptyStageArray() -> StageArray { [] }
    
    // use let when you want a single init for all calls:  let value = Stage.staticLet  <== no ()
    static let stageDurationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour,.minute,.second]
        return formatter
    }()

}
