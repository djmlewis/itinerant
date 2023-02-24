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


struct Stage: Identifiable, Codable, Hashable, Equatable {
    let id: UUID
    var title: String
    var details: String
    var snoozeDurationSecs: Int
    var flags: String
    var durationsArray: [Int] = [kStageInitialDurationSecs] // always available with a first value of kStageInitialDurationSecs
    var durationSecsInt: Int {
        get { durationsArray.first! }
        set(newDuration) { durationsArray[0] = newDuration }
    }
    var additionalDurationsArray: [Int] {
        get {
            var array = durationsArray
            _ = array.remove(at: 0)
            return array
        }
        set(array) {
            var newdurationsarray = [Int]()
            newdurationsarray.append(durationsArray[0])
            if !array.isEmpty {
                newdurationsarray += array
            }
            durationsArray = newdurationsarray
        }
    }
    
        var editableData: Stage { Stage(title: self.title,
                                        durationsArray: self.durationsArray,
                                        details: self.details,
                                        snoozeDurationSecs: self.snoozeDurationSecs,
                                        flags: self.flags) }



    // simple init with a durationSecsInt
    init(id: UUID = UUID(), title: String = "", durationsArray: [Int] = [kStageInitialDurationSecs], details: String = "", snoozeDurationSecs: Int = kStageInitialSnoozeDurationSecs, flags: String = StageNotificationInterval.countUp.string) {
        self.id = id
        self.title = title
        self.durationsArray = durationsArray
        self.details = details
        self.snoozeDurationSecs = max(snoozeDurationSecs,kSnoozeMinimumDurationSecs)
        self.flags = flags
    }
    
        // Init Stage from EditableData
        init(editableData: Stage) {
            // force new ID
            self.id = UUID()
            self.title = editableData.title
            self.durationsArray = editableData.durationsArray
            self.details = editableData.details
            self.snoozeDurationSecs = max(editableData.snoozeDurationSecs,kSnoozeMinimumDurationSecs)
            self.flags = editableData.flags
        }

        mutating func updateEditableData(from editableData: Stage) {
            self.title = editableData.title
            self.durationsArray = editableData.durationsArray
            self.details = editableData.details
            self.snoozeDurationSecs = max(editableData.snoozeDurationSecs,kSnoozeMinimumDurationSecs)
            self.flags = editableData.flags
        }
    
}

// MARK: - WatchData
extension Stage {
    
    struct WatchData: Identifiable, Codable, Hashable {
        let id: UUID
        var title: String
        var durationsArray: [Int] = [kStageInitialDurationSecs] // always available with a first value of kStageInitialDurationSecs
        var durationSecsInt: Int {
            get { durationsArray.first! }
            set(newDuration) { durationsArray[0] = newDuration }
        }
        var snoozeDurationSecs: Int
        var flags: String

        internal init(id: UUID = UUID(), title: String, durationsArray: [Int]  = [kStageInitialDurationSecs], snoozeDurationSecs: Int, flags: String) {
            self.id = id
            self.title = title
            self.durationsArray = durationsArray
            self.snoozeDurationSecs = max(snoozeDurationSecs,kSnoozeMinimumDurationSecs)
            self.flags = flags
        }
    }
    
    var watchDataNewUUID: Stage.WatchData  { WatchData(title: self.title, durationsArray: self.durationsArray, snoozeDurationSecs: self.snoozeDurationSecs, flags: self.flags) }

    static func stagesFromWatchStages(_ watchStages:StageWatchMessageDataArray) -> StageArray {
        return watchStages.map { Stage(watchData: $0) }
    }
    
    // Init Stage from WatchData
    init(watchData: Stage.WatchData) {
        // keep the UUID it will be unique
        self.id = watchData.id
        self.title = watchData.title
        self.durationsArray = watchData.durationsArray
        self.snoozeDurationSecs = max(watchData.snoozeDurationSecs,kSnoozeMinimumDurationSecs)
        self.details = ""
        self.flags = watchData.flags

    }
    
}


extension Stage {
    // us func when you want a new init for each call: let value = Stage.staticFunc()  <== use ()
    static func templateStage() -> Stage { Stage(title: "Stage #", details: "Details") }
    
    var duplicateWithNewID: Stage { Stage(title: title, durationsArray: durationsArray, details: details, snoozeDurationSecs: snoozeDurationSecs, flags: flags) }
    
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

    static func stageDateString(fromDate date: Date) -> String {
        let formatted = date.formatted(
            .dateTime
                .day()
                .month(.abbreviated)
                .year()
                .hour()
                .minute(.twoDigits)
        )
        return formatted
        
        //        let verbatim = Date.VerbatimFormatStyle(
        //            format: "\(day: .defaultDigits) \(month: .abbreviated) \(year: .defaultDigits) \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .oneBased)):\(minute: .twoDigits)",
        //            locale: Locale.autoupdatingCurrent,
        //            timeZone: TimeZone.autoupdatingCurrent,
        //            calendar: .autoupdatingCurrent
        //        )
        //        return verbatim.format(date)
    }
    
    mutating func setDurationFromDate(_ date: Date) { durationSecsInt = Int(dateYMDHM(fromDate: date).timeIntervalSinceReferenceDate) }

    // count flags are mutually exclusive
    // setting any flag to false results in an indeterminate state
    var durationCountType: StageNotificationInterval {
        get {
            if self.isCountUp { return .countUp }
            if self.isCountDownToDate { return .countDownToDate }
            if self.isCountDown { return .countDownEnd }
            return .countTypeUnknown
        }
        set(newType) {
            flags = flags.strippedOfCountFlags
            flags += newType.string
        }
    }
    var isCountDownType: Bool {durationCountType == .countDownToDate || durationCountType == .countDownEnd }
    var isCountDown: Bool {
        get { flags.contains(StageNotificationInterval.countDownEnd.string) }
    }
    var isCountDownToDate: Bool {
        get { flags.contains(StageNotificationInterval.countDownToDate.string) }
    }
    var isCountUp: Bool {
        get { flags.contains(StageNotificationInterval.countUp.string) }
    }
    // - count flags
    
    var durationAsDate: Date { Date(timeIntervalSinceReferenceDate: Double(durationSecsInt)) }
    
    func durationSecsIntCorrected(atDate date: Date) -> Int {
        if isCountDown { return durationSecsInt }
        // date may return a negative value
        if isCountDownToDate { return Int(durationAsDate.timeIntervalSince(date)) }
        return 0
    }
        
    var durationSymbolName: String {
        //if !validDurationForCountDownTypeAtDate(Date.now) { return "exclamationmark.triangle.fill"}
        return durationCountType.timerDirection.symbolName
    }
       
    func validDurationForCountDownTypeAtDate(_ date: Date) -> Bool {
        switch self.durationCountType {
        case .countDownEnd:
            if durationSecsInt < kStageMinimumDurationSecs { return false }
        case .countDownToDate:
            if Double(durationSecsInt) - date.timeIntervalSinceReferenceDate < kStageMinimumDurationForDateDbl { return false }
        default:
            break
        }
        return true

    }
    
    func durationValidForNotificationInterval(_ intervalType: StageNotificationInterval) ->  Bool {
        switch intervalType {
            // we adjust for a too short countDownEnd and snooze durations so let them pass?
        case .countDownEnd:
            if durationSecsInt < kStageMinimumDurationSecs { return false }
        case .snoozeRepeatingIntervals:
            if durationSecsInt < kSnoozeMinimumDurationSecs { return false }
        case .countDownToDate:
            if durationSecsInt - Int(Date.now.timeIntervalSinceReferenceDate) < kStageMinimumDurationSecs { return false }
        default:
            break
        }
        return true

    }

    var durationString: String {
        if isCountDown { return Stage.stageDurationFormatter.string(from: Double(durationSecsInt)) ?? "" }
        if isCountDownToDate  { return Stage.stageDateString(fromDate: durationAsDate) }
        return "---"
    }
    var durationStringHardPadded: String {
        durationString.replacingOccurrences(of: " ", with: "\u{202F}")
    }
    static func stageFormattedDurationStringFromDouble(_ time: Double) -> String {
        Stage.stageDurationFormatter.string(from: time) ?? ""
    }
    static func stageDurationStringHardPaddedFromDouble(_ time: Double) -> String {
        stageFormattedDurationStringFromDouble(time).replacingOccurrences(of: " ", with: "\u{202F}")
    }

    var additionalAlertsDurationsString: String {
        let array = additionalDurationsArray.map( {Stage.stageDurationStringHardPaddedFromDouble(Double($0)) } )
        return array.joined(separator: "\u{202F}• ")
    }
}


// MARK: - Characteristics
extension Stage {
    
    var idStr: String { id.uuidString }
    
    func hasIDstr(_ idstrtotest: String?) -> Bool {
        // notification ID strings may have suffixes so use contains not ==
        return idstrtotest != nil && idStr == idstrtotest!
    }

    func isActive(uuidStrStagesActiveStr: String) -> Bool { uuidStrStagesActiveStr.contains(idStr) }
    
    func isRunning(uuidStrStagesRunningStr: String) -> Bool { uuidStrStagesRunningStr.contains(idStr) }
    
    var isCommentOnly: Bool {
        get {
            flags.contains(StageNotificationInterval.comment.string)
        }
        set(isComment) {
            flags = flags.replacingOccurrences(of: StageNotificationInterval.comment.string, with: "",options: [.literal])
            if isComment {
                flags += StageNotificationInterval.comment.string
            }
        }
    }
        
    var isActionable: Bool {
        if isCommentOnly { return false }
        return true
    }
    
    var isPostingRepeatingSnoozeAlerts: Bool {
        get { flags.contains(StageNotificationInterval.snoozeRepeatingIntervals.string) }
        set(isSA) {
            flags = flags.replacingOccurrences(of: StageNotificationInterval.snoozeRepeatingIntervals.string, with: "",options: [.literal])
            if isSA { flags += StageNotificationInterval.snoozeRepeatingIntervals.string }
        }
    }
    var postsNotifications: Bool { isCountDown == true || isPostingRepeatingSnoozeAlerts }
    

    func additionalAlertNotificationString(index: Int) -> String {
        idStr + StageNotificationInterval.additionalAlert.string + String(format: "%i", index)
    }
}

// MARK: - import export
extension Stage {
    
    var durationsArrayString: String {
        guard durationsArray.isEmpty else { return String(format: "%i", kStageInitialDurationSecs) }
        return durationsArray.map( { String(format: "%i", $0) } ).joined(separator: kStageDurationsArraySeparator)
    }
    
    var exportArray: [String] {
        return [
            title,
            details,
            durationsArrayString,
            String(format: "%i", snoozeDurationSecs),
            flags.isEmpty ? StageNotificationInterval.countUp.string : flags,
        ]
    }
    
    init(fromImportLines lines: ArraySlice<Substring>) {
        self.id = UUID()
        let firstIndex = lines.startIndex
        self.title =  String(lines[firstIndex])
        self.details = String(lines[firstIndex+1])
        self.durationsArray = lines[firstIndex+2].components(separatedBy: kStageDurationsArraySeparator).compactMap({ max(Int($0) ?? kStageInitialDurationSecs, kStageInitialDurationSecs) })
        if self.durationsArray.isEmpty { durationsArray = [kStageInitialDurationSecs] }
        self.snoozeDurationSecs = Int(lines[firstIndex+3]) ?? kStageInitialSnoozeDurationSecs
        self.flags = String(lines[firstIndex+4]).replacingOccurrences(of: " ", with: "")
        // default to countdown
        if self.flags.isEmpty { self.flags = StageNotificationInterval.countUp.string }
    }
}

