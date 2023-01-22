//
//  Stage.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import Foundation

typealias StageArray = [Stage]


struct Stage: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var durationSecsInt: Int
    var details: String
    var editableData: Stage.EditableData { EditableData(title: self.title, durationSecsInt: self.durationSecsInt, details: self.details) }
    
    init(id: UUID = UUID(), title: String = "", durationSecsInt: Int = 0, details: String = "") {
        self.id = id
        self.title = title
        self.durationSecsInt = durationSecsInt
        self.details = details
    }
}

extension Stage {
    struct EditableData {
        var title: String = ""
        var durationSecsInt: Int = 0
        var details: String = ""
    }
        
    mutating func updateEditableData(from editableData: Stage.EditableData) {
        self.title = editableData.title
        self.durationSecsInt = editableData.durationSecsInt
        self.details = editableData.details

    }
}

extension Stage {
    // us func when you want a new init for each call: let value = Stage.staticFunc()  <== use ()
    static func templateStage() -> Stage { Stage(title: "Stage #", durationSecsInt: 15, details: "Details") }
    static func templateStageArray() -> StageArray { [Stage.templateStage(), Stage.templateStage(), Stage.templateStage()] }
    //static func emptyStageArray() -> StageArray { [] }
    
    // use let when you want a single init for all calls:  let value = Stage.staticLet  <== no ()
    static let stageDurationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour,.minute,.second]
        return formatter
    }()

}
