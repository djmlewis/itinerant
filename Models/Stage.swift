//
//  Stage.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import Foundation
import SwiftUI

typealias StageArray = [Stage]
typealias StageWatchMessageDataArray = [Stage.WatchData]


struct Stage: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var durationSecsInt: Int
    var details: String
    var snoozeDurationSecs: Int
    
    init(id: UUID = UUID(), title: String = "", durationSecsInt: Int = kStageInitialDurationSecs, details: String = "", snoozeDurationSecs: Int = kStageInitialSnoozeDurationSecs) {
        self.id = id
        self.title = title
        self.durationSecsInt = durationSecsInt
        self.details = details
        self.snoozeDurationSecs = max(snoozeDurationSecs,kSnoozeDurationSecsMin)
    }
    
    init(editableData: EditableData) {
        // force new ID
        self.id = UUID()
        self.title = editableData.title
        self.durationSecsInt = editableData.durationSecsInt
        self.details = editableData.details
        self.snoozeDurationSecs = max(editableData.snoozeDurationSecs,kSnoozeDurationSecsMin)
    }
    
    
}

// MARK: - WatchData
extension Stage {
    
    init(watchData: Stage.WatchData) {
        // keep the UUID it will be unique
        self.id = watchData.id
        self.title = watchData.title
        self.durationSecsInt = watchData.durationSecsInt
        self.snoozeDurationSecs = max(watchData.snoozeDurationSecs,kSnoozeDurationSecsMin)
       self.details = ""
    }

    var watchDataNewUUID: Stage.WatchData  { WatchData(title: self.title, durationSecsInt: self.durationSecsInt, snoozeDurationSecs: self.snoozeDurationSecs) }

    struct WatchData: Identifiable, Codable, Hashable {
        internal init(id: UUID = UUID(), title: String, durationSecsInt: Int, snoozeDurationSecs: Int) {
            self.id = id
            self.title = title
            self.durationSecsInt = durationSecsInt
            self.snoozeDurationSecs = max(snoozeDurationSecs,kSnoozeDurationSecsMin)
        }
        
        let id: UUID
        var title: String
        var durationSecsInt: Int
        var snoozeDurationSecs: Int
    }
    
    static func stagesFromWatchStages(_ watchStages:StageWatchMessageDataArray) -> StageArray {
        return watchStages.map { Stage(watchData: $0) }
    }
    

    
}


// MARK: - EditableData
extension Stage {
    struct EditableData {
        var title: String = ""
        var durationSecsInt: Int = kStageInitialDurationSecs
        var details: String = ""
        var snoozeDurationSecs: Int = kStageInitialSnoozeDurationSecs
        
        var isCommentOnly: Bool { durationSecsInt == kStageDurationCommentOnly }
        var isCountDown: Bool { durationSecsInt != kStageDurationCountUpTimer && durationSecsInt != kStageDurationCountUpWithSnoozeAlerts }
        var isCountUp: Bool { durationSecsInt == kStageDurationCountUpTimer || durationSecsInt == kStageDurationCountUpWithSnoozeAlerts}
        var isCountUpWithSnoozeAlerts: Bool { durationSecsInt == kStageDurationCountUpWithSnoozeAlerts}
        var postsNotifications: Bool { isCountDown == true || isCountUpWithSnoozeAlerts }

    } /* EditableData */
    
    var editableData: Stage.EditableData { EditableData(title: self.title,
                                                        durationSecsInt: self.durationSecsInt,
                                                        details: self.details,
                                                        snoozeDurationSecs: self.snoozeDurationSecs) }
    

    mutating func updateEditableData(from editableData: Stage.EditableData) {
        self.title = editableData.title
        self.durationSecsInt = editableData.durationSecsInt
        self.details = editableData.details
        self.snoozeDurationSecs = max(editableData.snoozeDurationSecs,kSnoozeDurationSecsMin)

    }
}

// MARK: - Templates, duplicates, Stage StageArray
extension Stage {
    // us func when you want a new init for each call: let value = Stage.staticFunc()  <== use ()
    static func templateStage() -> Stage { Stage(title: "Stage #", details: "Details") }
    
    var duplicateWithNewID: Stage { Stage(title: title, durationSecsInt: durationSecsInt, details: details,snoozeDurationSecs: snoozeDurationSecs) }
    
    static func templateStageArray() -> StageArray { [Stage.templateStage(), Stage.templateStage(), Stage.templateStage()] }
    //static func emptyStageArray() -> StageArray { [] }

    static func stageArrayWithNewIDs(from stages: StageArray) -> StageArray {
        var newstages = StageArray()
        stages.forEach { stage in
            newstages.append(Stage(editableData: stage.editableData))
        }
        return newstages
    }
    
}

// MARK: - Duration
extension Stage {

    // use let when you want a single init for all calls:  let value = Stage.staticLet  <== no ()
    static let stageDurationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour,.minute,.second]
        return formatter
    }()

    static func stageDurationStringFromDouble(_ time: Double) -> String {
        Stage.stageDurationFormatter.string(from: time) ?? ""
    }

}


// MARK: - Characteristics
extension Stage {
    func isActive(uuidStrStagesActiveStr: String) -> Bool { uuidStrStagesActiveStr.contains(id.uuidString) }
    
    func isRunning(uuidStrStagesRunningStr: String) -> Bool { uuidStrStagesRunningStr.contains(id.uuidString) }
    
    var isCommentOnly: Bool { durationSecsInt == kStageDurationCommentOnly }
    
    var isActionable: Bool { !isCommentOnly }
    
    var isCountDown: Bool { durationSecsInt != kStageDurationCountUpTimer && durationSecsInt != kStageDurationCountUpWithSnoozeAlerts }
    var isCountUp: Bool { durationSecsInt == kStageDurationCountUpTimer || durationSecsInt == kStageDurationCountUpWithSnoozeAlerts }
    var isCountUpWithSnoozeAlerts: Bool { durationSecsInt == kStageDurationCountUpWithSnoozeAlerts }
    var postsNotifications: Bool { isCountDown == true || isCountUpWithSnoozeAlerts }
    var durationSymbolName: String {
        switch durationSecsInt {
        case kStageDurationCountUpTimer, kStageDurationCountUpWithSnoozeAlerts:
            return "stopwatch"
        case kStageDurationCommentOnly:
            return "bubble.left"
        default:
            return "timer"
        }
    }
}

