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
    var flags: String
    
    init(id: UUID = UUID(), title: String = "", durationSecsInt: Int = kStageInitialDurationSecs, details: String = "", snoozeDurationSecs: Int = kStageInitialSnoozeDurationSecs, flags: String = "") {
        self.id = id
        self.title = title
        self.durationSecsInt = durationSecsInt
        self.details = details
        self.snoozeDurationSecs = max(snoozeDurationSecs,kSnoozeDurationSecsMin)
        self.flags = flags
    }
    
    
    
}

// MARK: - WatchData
extension Stage {
    
    struct WatchData: Identifiable, Codable, Hashable {
        let id: UUID
        var title: String
        var durationSecsInt: Int
        var snoozeDurationSecs: Int
        var flags: String

        internal init(id: UUID = UUID(), title: String, durationSecsInt: Int, snoozeDurationSecs: Int, flags: String) {
            self.id = id
            self.title = title
            self.durationSecsInt = durationSecsInt
            self.snoozeDurationSecs = max(snoozeDurationSecs,kSnoozeDurationSecsMin)
            self.flags = flags
        }
    }
    
    var watchDataNewUUID: Stage.WatchData  { WatchData(title: self.title, durationSecsInt: self.durationSecsInt, snoozeDurationSecs: self.snoozeDurationSecs, flags: self.flags) }

    static func stagesFromWatchStages(_ watchStages:StageWatchMessageDataArray) -> StageArray {
        return watchStages.map { Stage(watchData: $0) }
    }
    
    // Init Stage from WatchData
    init(watchData: Stage.WatchData) {
        // keep the UUID it will be unique
        self.id = watchData.id
        self.title = watchData.title
        self.durationSecsInt = watchData.durationSecsInt
        self.snoozeDurationSecs = max(watchData.snoozeDurationSecs,kSnoozeDurationSecsMin)
        self.details = ""
        self.flags = watchData.flags

    }
    
}


// MARK: - EditableData
extension Stage {
    struct EditableData {
        var title: String = ""
        var durationSecsInt: Int = kStageInitialDurationSecs
        var details: String = ""
        var snoozeDurationSecs: Int = kStageInitialSnoozeDurationSecs
        var flags: String = ""

        var isCommentOnly: Bool {
            get {
                flags.contains(kFlagComment)
            }
            set(isComment) {
                flags = flags.replacingOccurrences(of: kFlagComment, with: "",options: [.literal])
                if isComment {
                    flags += kFlagComment
                }
            }
        }
        var isCountUp: Bool {
            get {
                flags.contains(kFlagCountUp)
            }
            set(isUp) {
                flags = flags.replacingOccurrences(of: kFlagCountUp, with: "",options: [.literal])
                if isUp {
                    flags += kFlagCountUp
                }
            }
        }

        var isCountDown: Bool { !isCountUp }
        var isPostingSnoozeAlerts: Bool {
            get {
                flags.contains(kFlagSnoozeAlerts)
            }
            set(isSA) {
                flags = flags.replacingOccurrences(of: kFlagSnoozeAlerts, with: "",options: [.literal])
                if isSA {
                    flags += kFlagSnoozeAlerts
                }
            }
        }
        var postsNotifications: Bool { isCountDown == true || isPostingSnoozeAlerts }

    } /* EditableData */
    
    var editableData: Stage.EditableData { EditableData(title: self.title,
                                                        durationSecsInt: self.durationSecsInt,
                                                        details: self.details,
                                                        snoozeDurationSecs: self.snoozeDurationSecs,
                                                        flags: self.flags) }
    

    mutating func updateEditableData(from editableData: Stage.EditableData) {
        self.title = editableData.title
        self.durationSecsInt = editableData.durationSecsInt
        self.details = editableData.details
        self.snoozeDurationSecs = max(editableData.snoozeDurationSecs,kSnoozeDurationSecsMin)
        self.flags = editableData.flags
    }
    
    // Init Stage from EditableData
    init(editableData: EditableData) {
        // force new ID
        self.id = UUID()
        self.title = editableData.title
        self.durationSecsInt = editableData.durationSecsInt
        self.details = editableData.details
        self.snoozeDurationSecs = max(editableData.snoozeDurationSecs,kSnoozeDurationSecsMin)
        self.flags = editableData.flags
    }

}

// MARK: - Templates, duplicates, Stage StageArray
extension Stage {
    // us func when you want a new init for each call: let value = Stage.staticFunc()  <== use ()
    static func templateStage() -> Stage { Stage(title: "Stage #", details: "Details") }
    
    var duplicateWithNewID: Stage { Stage(title: title, durationSecsInt: durationSecsInt, details: details,snoozeDurationSecs: snoozeDurationSecs, flags: flags) }
    
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
    
    
    
    var isCommentOnly: Bool {
        get {
            flags.contains(kFlagComment)
        }
        set(isComment) {
            flags = flags.replacingOccurrences(of: kFlagComment, with: "",options: [.literal])
            if isComment {
                flags += kFlagComment
            }
        }
    }

    
    func isActive(uuidStrStagesActiveStr: String) -> Bool { uuidStrStagesActiveStr.contains(idStr) }
    
    func isRunning(uuidStrStagesRunningStr: String) -> Bool { uuidStrStagesRunningStr.contains(idStr) }
    
    
    var isActionable: Bool { !isCommentOnly }
    
    var isCountDown: Bool { !isCountUp }
    var isCountUp: Bool {
        get {
            flags.contains(kFlagCountUp)
        }
        set(isUp) {
            flags = flags.replacingOccurrences(of: kFlagCountUp, with: "",options: [.literal])
            if isUp {
                flags += kFlagCountUp
            }
        }
    }
    var isPostingSnoozeAlerts: Bool {
        get {
            flags.contains(kFlagSnoozeAlerts)
        }
        set(isSA) {
            flags = flags.replacingOccurrences(of: kFlagSnoozeAlerts, with: "",options: [.literal])
            if isSA {
                flags += kFlagSnoozeAlerts
            }
        }
    }
    var postsNotifications: Bool { isCountDown == true || isPostingSnoozeAlerts }
    var durationSymbolName: String {
        if isCommentOnly { return "bubble.left" }
        if isCountUp { return "stopwatch" }
        return "timer"
    }
    
    var idStr: String { id.uuidString }
    
    var idNotificationIntervalStrings: [String] {
        return StageNotificationInterval.allSuffixedStrings(forString: idStr)
    }
}

