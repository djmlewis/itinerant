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
typealias StagePersistentDataArray = [Stage.PersistentData]

struct Stage: Identifiable, Codable, Hashable, Equatable {
    
    let id: UUID
    var title: String
    var details: String
    var snoozeDurationSecs: Int
    var flags: String
    var durationSecsInt: Int
    var additionalDurationsDict: [Int : String] = [Int : String]()
    // runtime
    var imageDataThumbnailActual: Data?
    var imageDataFullActual: Data?

    
    mutating func updateImageDataThumbnailActualFromPackagePath(_ packagePath: String?) {
        if let packagePath {
            if imageDataFullActual == nil {
                let filename = idStr + ImageSizeType.fullsize.rawValue + ItineraryFileExtension.imageData.dotExtension
                let path = (packagePath as NSString).appendingPathComponent(filename)
                imageDataFullActual = FileManager.default.contents(atPath: path)
            }
        }
    }
    
//    var durationSecsInt: Int {
//        get { durationsArray.first! }
//        set(newDuration) { durationsArray[0] = newDuration }
//    }
//    var additionalDurationsDict: [Int] {
//        get {
//            var array = durationsArray
//            _ = array.remove(at: 0)
//            return array
//        }
//        set(array) {
//            var newdurationsarray = [Int]()
//            newdurationsarray.append(durationsArray[0])
//            if !array.isEmpty {
//                newdurationsarray += array
//            }
//            durationsArray = newdurationsarray
//        }
//    }
    
    var persistentData: Stage.PersistentData {
        PersistentData(id: self.id, title: self.title,
                       durationSecsInt: self.durationSecsInt, additionalDurationsDict: self.additionalDurationsDict,
                       details: self.details, snoozeDurationSecs: self.snoozeDurationSecs, flags: self.flags)
    }
    
    var editableData: Stage { Stage(title: self.title,
                                    durationSecsInt: self.durationSecsInt,
                                    additionalDurationsDict: self.additionalDurationsDict,
                                    details: self.details,
                                    snoozeDurationSecs: self.snoozeDurationSecs,
                                    flags: self.flags,
                                    imageDataThumbnailActual: self.imageDataThumbnailActual,
                                    imageDataFullActual: self.imageDataFullActual)
    }
    
    
    // simple init with a durationSecsInt
    init(id: UUID = UUID(), title: String = "", durationSecsInt: Int = kStageInitialDurationSecs, additionalDurationsDict: [Int : String] = [Int : String](), details: String = "", snoozeDurationSecs: Int = kStageInitialSnoozeDurationSecs, flags: String = StageNotificationInterval.countUp.string, imageDataThumbnailActual: Data? = nil, imageDataFullActual: Data? = nil) {
        self.id = id
        self.title = title
        self.durationSecsInt = durationSecsInt
        self.additionalDurationsDict = additionalDurationsDict
        self.details = details
        self.snoozeDurationSecs = max(snoozeDurationSecs,kSnoozeMinimumDurationSecs)
        self.flags = flags
        self.imageDataThumbnailActual = imageDataThumbnailActual
        self.imageDataFullActual = imageDataFullActual
   }
    
    
    // init from PersistentData
    init(persistentData: Stage.PersistentData) {
        self.id = persistentData.id
        self.title = persistentData.title
        self.durationSecsInt = persistentData.durationSecsInt
        self.additionalDurationsDict = persistentData.additionalDurationsDict
        self.details = persistentData.details
        self.snoozeDurationSecs = persistentData.snoozeDurationSecs
        self.flags = persistentData.flags
    }
    
    // Init Stage from WatchData
    init(watchData: Stage.WatchData) {
        // keep the UUID it will be unique
        self.id = watchData.id
        self.title = watchData.title
        self.durationSecsInt = watchData.durationSecsInt
        self.additionalDurationsDict = watchData.additionalDurationsDict
        self.snoozeDurationSecs = max(watchData.snoozeDurationSecs,kSnoozeMinimumDurationSecs)
        self.details = ""
        self.flags = watchData.flags
    }
    
    mutating func updateEditableData(from editableData: Stage) {
        self.title = editableData.title
        self.durationSecsInt = editableData.durationSecsInt
        self.additionalDurationsDict = editableData.additionalDurationsDict
        self.details = editableData.details
        self.snoozeDurationSecs = max(editableData.snoozeDurationSecs,kSnoozeMinimumDurationSecs)
        self.flags = editableData.flags
        self.imageDataThumbnailActual = editableData.imageDataThumbnailActual
        self.imageDataFullActual = editableData.imageDataFullActual
    }
    
}

// MARK: - PersistentData
extension Stage {
    struct PersistentData: Codable {
        let id: UUID
        var title: String
        var durationSecsInt: Int
        var additionalDurationsDict: [Int : String]
        var details: String
        var snoozeDurationSecs: Int
        var flags: String
        
        var idStr: String { id.uuidString }

    }
}

// MARK: - WatchData
extension Stage {
    
    struct WatchData: Identifiable, Codable, Hashable {
        let id: UUID
        var title: String
        var durationSecsInt: Int
        var additionalDurationsDict: [Int : String] = [Int : String]()
        var snoozeDurationSecs: Int
        var flags: String

        internal init(id: UUID = UUID(), title: String, durationSecsInt: Int, additionalDurationsDict: [Int : String], snoozeDurationSecs: Int, flags: String) {
            self.id = id
            self.title = title
            self.durationSecsInt = durationSecsInt
            self.additionalDurationsDict = additionalDurationsDict
            self.snoozeDurationSecs = max(snoozeDurationSecs,kSnoozeMinimumDurationSecs)
            self.flags = flags
        }
    }
    
    var watchDataNewUUID: Stage.WatchData  { WatchData(title: self.title, durationSecsInt: self.durationSecsInt, additionalDurationsDict: self.additionalDurationsDict, snoozeDurationSecs: self.snoozeDurationSecs, flags: self.flags) }

    static func stagesFromWatchStages(_ watchStages:StageWatchMessageDataArray) -> StageArray {
        return watchStages.map { Stage(watchData: $0) }
    }
    
    
}


extension Stage {
    // us func when you want a new init for each call: let value = Stage.staticFunc()  <== use ()
    static func templateStage() -> Stage { Stage(title: "Stage #", details: "Details") }
    
    var duplicateWithNewID: Stage { Stage(title: title, durationSecsInt: durationSecsInt, additionalDurationsDict: additionalDurationsDict, details: details, snoozeDurationSecs: snoozeDurationSecs, flags: flags) }
    
    static func templateStageArray() -> StageArray { [Stage.templateStage(), Stage.templateStage(), Stage.templateStage()] }
    //static func emptyStageArray() -> StageArray { [] }

    static func stageArrayWithNewIDs(from stages: StageArray) -> StageArray {
        var newstages = StageArray()
        stages.forEach { stage in
            var newstage = Stage()
            newstage.updateEditableData(from: stage.editableData)
            newstages.append(newstage)
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
        formatter.allowedUnits = [.year,.day,.hour,.minute,.second]
        return formatter
    }()

    static func stageDateString(fromDate date: Date) -> String {
        date.formatted(date: .numeric, time: .shortened)
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
            if Double(durationSecsInt) - date.timeIntervalSinceReferenceDate < kStageMinimumDurationForDateDbl * 2.0 { return false }
        default:
            break
        }
        return true
    }
    
    func invalidDurationForCountDownTypeAtDate(_ date: Date) -> Bool {
        !validDurationForCountDownTypeAtDate(date)
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
        return Stage.stageDurationFormatter.string(from: time) ?? ""
    }
    static func stageDurationStringHardPaddedFromDouble(_ time: Double) -> String {
        stageFormattedDurationStringFromDouble(time).replacingOccurrences(of: " ", with: "\u{202F}")
    }

    var additionalAlertsDurationsString: String {
        let array = additionalDurationsDict.keys.sorted().map( {Stage.stageDurationStringHardPaddedFromDouble(Double($0)) } )
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
    
    @ViewBuilder  var additionalDurationsDisplayString: some View {
        
        VStack(spacing:0.0) {
            ForEach(additionalDurationsDict.keys.sorted(), id: \.self) { keyint in
                HStack(alignment: .top, spacing: 0.0) {
                    Text(Stage.stageDurationStringHardPaddedFromDouble(Double(keyint)))
                        .foregroundColor(Color("ColourAdditionalAlarmsText"))
                   Spacer()
                    Text(additionalDurationsDict[keyint] ?? "---")
                        .foregroundColor(Color("ColourAdditionalAlarmsMessage"))
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
        }
        .padding(0.0)
    }
    
    @ViewBuilder  static func additionalAndSnoozeAlertsHStackForStage(_ stage: Stage) -> some View {
        VStack(spacing: 0.0) {
            if stage.isPostingRepeatingSnoozeAlerts {
                HStack(spacing: 4.0) {
                    Image(systemName: "bell.and.waves.left.and.right")
                        .foregroundColor(Color("ColourAdditionalAlarmsImage"))
                    Text(Stage.stageFormattedDurationStringFromDouble(Double(stage.snoozeDurationSecs)))
                        .lineLimit(1)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.5)
                        .frame(alignment: .leading)
                        .foregroundColor(Color("ColourAdditionalAlarmsText"))
               }
                .font(.system(.subheadline, design: .rounded, weight: .regular))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding([.bottom,.top], kiOSStageViewsRowPad)
                .padding([.leading,.trailing], 8)
                .background(Color("ColourSnoozeAlarmsBackground"))
            } /* isPostingRepeatingSnoozeAlerts */
            if !stage.additionalDurationsDict.isEmpty {
                VStack(alignment: .center) {
                    HStack(spacing: 0.0) {
                        Image(systemName: "alarm.waves.left.and.right")
                            .foregroundColor(Color("ColourAdditionalAlarmsImage"))
                            .padding(0.0)
                        Spacer()
                        stage.additionalDurationsDisplayString
                   }
                    .font(.system(.subheadline, design: .rounded, weight: .regular))
                    .frame(maxWidth: .infinity, alignment: .center)
               }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding([.bottom,.top], kiOSStageViewsRowPad)
                .padding(.leading, 4)
                .padding(.trailing, 8)
                .background(Color("ColourAdditionalAlarmsBackground"))
           } /* additionalDurationsDict */
        } /* VStack */
        .frame(maxWidth: .infinity)
    }
    
    
    var additionalDurationsDictString: String {
        guard !additionalDurationsDict.isEmpty else { return String(format: "%i", kStageInitialDurationSecs) }

        return additionalDurationsDict.keys.sorted().map( { String(format: "%i", $0) + kStageAdditionalDurationsInternalSeparator + additionalDurationsDict[$0]! } ).joined(separator: kStageDurationsArraySeparator)
    }
    
    static func additionalDurationsDictFromString(_ string: String) -> [Int : String] {
        var decodedDict = [Int : String]()
        for rowStr in string.components(separatedBy: kStageDurationsArraySeparator) { 
            let parts = rowStr.components(separatedBy: kStageAdditionalDurationsInternalSeparator)
            if parts.count == 2, let key = Int(parts[0]) {
                decodedDict[key] = parts[1]
            }
        }
        return decodedDict
    }
    
    var exportArray: [String] {
        return [
            title,
            details,
            String(format: "%i", durationSecsInt),
            additionalDurationsDictString,
            String(format: "%i", snoozeDurationSecs),
            flags.isEmpty ? StageNotificationInterval.countUp.string : flags,
        ]
    }
    
    init(fromImportLines lines: ArraySlice<Substring>) {
        self.id = UUID()
        let firstIndex = lines.startIndex
        self.title =  String(lines[firstIndex])
        self.details = String(lines[firstIndex+1])
        self.durationSecsInt = Int(lines[firstIndex+2]) ?? kStageInitialDurationSecs
        self.additionalDurationsDict = Stage.additionalDurationsDictFromString(String(lines[firstIndex+3]))
        self.snoozeDurationSecs = Int(lines[firstIndex+4]) ?? kStageInitialSnoozeDurationSecs
        self.flags = String(lines[firstIndex+5]).replacingOccurrences(of: " ", with: "")
        // default to countdown
        if self.flags.isEmpty { self.flags = StageNotificationInterval.countUp.string }
    }
}

