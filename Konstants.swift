//
//  Konstants.swift
//  itinerant
//
//  Created by David JM Lewis on 24/01/2023.
//

import Foundation
import UniformTypeIdentifiers

// MARK: - ItineraryFile document
enum ItineraryFileType: String {
    case dataFile = "uk.djml.itinerant.itinerary"
    case settingsFile = "uk.djml.itinerant.settings"
    case textFile = "uk.djml.itinerant.text"
}

extension UTType {
    static let itineraryDataFile = UTType(exportedAs: ItineraryFileType.dataFile.rawValue)
    static let itinerarySettingsFile = UTType(exportedAs: ItineraryFileType.settingsFile.rawValue)
    static let itineraryTextFile = UTType(exportedAs: ItineraryFileType.textFile.rawValue)
    
}

enum ItineraryFileExtension: String, CaseIterable {
    case dataFile = "itinerary"
    case settingsFile = "settings"
    case textFile = "export"
    
    static func validExtension(_ extensionStr: String) -> Bool {
        return ItineraryFileExtension.allCases.firstIndex { $0.rawValue == extensionStr } != nil
    }
}

// MARK: - ItineraryStore
let kItineraryStoreFileName = "itinerant/itineraryStore_10" + ".data"
let kItineraryUUIDsFileName = "itineraryUUIDs" + ".data"

let kItineraryPerststentDataFileSuffix = ItineraryFileExtension.dataFile.rawValue
let kItinerarySettingsFileSuffix = ItineraryFileExtension.settingsFile.rawValue
let kItinerarySettingsFileDotSuffix = "." + ItineraryFileExtension.settingsFile.rawValue
let kItineraryTextFileDotSuffix = "." + ItineraryFileExtension.textFile.rawValue
let kItineraryPerststentDataFileDotSuffix = "." + kItineraryPerststentDataFileSuffix
let kItineraryPerststentDataFileDirectoryName = "itineraries"
let kItineraryPerststentDataFileDirectorySlashNameSlash = "/" + kItineraryPerststentDataFileDirectoryName + "/"
let kItineraryPerststentDataFileDirectorySlashName =  "/" + kItineraryPerststentDataFileDirectoryName

let kUnknownObjectErrorStr = "error: Unkown"

// MARK: - Itinerary
let kImportHeadingLines: Int = 1
let kImportLinesPerStage: Int = 5
let kSeparatorImportFile = "\n"

// MARK: - Stage
//let kStageDurationCommentOnly: Int = -1
//let kStageDurationCountUpTimer: Int = 0
//let kStageDurationCountUpWithSnoozeAlerts: Int = -2
let kStageInitialDurationSecs: Int = 0
let kSnoozeDurationSecsMin: Int = 60
let kStageInitialSnoozeDurationSecs: Int = kSnoozeDurationSecsMin

let kFlagComment = "Ⓒ"
let kFlagCountUp = "Ⓤ"
let kFlagCountDown = "Ⓓ" // not actually used in flags but in StageNotificationInterval
let kFlagSnoozeRepeatingAlerts = "Ⓡ"
let kFlagSnoozeSingleAlert = "Ⓩ"

enum StageNotificationInterval: CaseIterable {
    case countDownEnd
    case snoozeRepeatingIntervals
    case snoozeSingleInterval
    
    var string: String {
        switch self {
        case .countDownEnd:
            return  kFlagCountDown
        case .snoozeRepeatingIntervals:
            return  kFlagSnoozeRepeatingAlerts
        case .snoozeSingleInterval:
            return  kFlagSnoozeSingleAlert
        }
    }
    
    static func stripAllSuffixesFromStr(_ str: String?) -> String? {
        guard var validstr = str else { return nil }
        StageNotificationInterval.allCases.forEach {
            validstr = validstr.replacingOccurrences(of: $0.string, with: "")
        }
        return str
    }
    
    static func allSuffixedStrings(forString str: String) -> [String] {
        var stringArray = [String]()
        StageNotificationInterval.allCases.forEach { stringArray.append(str + $0.string) }
        return stringArray
    }
}

extension String {
    func strippedOfNotificationFlags() -> String {
        return StageNotificationInterval.stripAllSuffixesFromStr(self)!
    }
}

// MARK: - ItinerantApp

// MARK: - ItineraryStoreView
let kAppStorageColourStageInactive = "kAppStorageColourStageInactive"
let kAppStorageColourStageActive = "kAppStorageColourStageActive"
let kAppStorageColourStageRunning = "kAppStorageColourStageRunning"
let kAppStorageColourStageComment = "kAppStorageColourStageComment"
let kAppStorageColourFontInactive = "kAppStorageColourFontInactive"
let kAppStorageColourFontActive = "kAppStorageColourFontActive"
let kAppStorageColourFontRunning = "kAppStorageColourFontRunning"
let kAppStorageColourFontComment = "kAppStorageColourFontComment"


let kAppStorageDefaultColourStageInactive = "0.664\t0.664\t0.664\t1.0"
let kAppStorageDefaultColourStageActive = "0.011\t0.133\t0.673\t1.0"
let kAppStorageDefaultColourStageRunning = "0.996\t0.274\t0.0\t1.0"
let kAppStorageDefaultColourStageComment = "0.0\t0.0\t0.0\t1.0"
let kAppStorageDefaultColourFontInactive = "1.0\t1.0\t1.0\t1.0"
let kAppStorageDefaultColourFontActive = "1.0\t1.0\t1.0\t1.0"
let kAppStorageDefaultColourFontRunning = "1.0\t1.0\t1.0\t1.0"
let kAppStorageDefaultColourFontComment = "1.0\t1.0\t1.0\t1.0"

let kAppStorageStageInactiveTextDark = "kAppStorageStageInactiveTextDark"
let kAppStorageStageActiveTextDark = "kAppStorageStageActiveTextDark"
let kAppStorageStageRunningTextDark = "kAppStorageStageRunningTextDark"
let kAppStorageStageCommentTextDark = "kAppStorageStageCommentTextDark"


let kSceneStoreUuidStrStageActive = "uuidStrStageActiveStr"
let kSceneStoreUuidStrStageRunning = "uuidStrStageRunningStr"
let kSceneStoreDictStageStartDates = "kSceneStoreDictStageStartDates"
let kSceneStoreDictStageEndDates = "kSceneStoreDictStageEndDates"
let kSceneStoreUuidStrItineraryResetView = "kSceneStoreUuidStrItineraryResetView"

enum DuplicateFileOptions {
    case noDuplicate, replaceExisting, keepBoth
}

// MARK: - ItineraryActionView
let kItineraryUUIDStr = "kItineraryUUIDStr"
let kStageUUIDStr = "kStageUUIDStr"
let kItineraryTitle = "kItineraryTitle"
let kStageTitle = "kStageTitle"
let kStageSnoozeDurationSecs = "kStageSnoozeDurationSecs"
let kNotificationDueTime = "kNotificationDueTime"


// MARK: - StageActionView
let kSceneStoreStageTimeStartedRunning = "timeStartedRunning"
let kUIUpdateTimerFrequency = 0.2



// MARK: - WatchConnectivity
let kUserInfoMessageTypeKey = "kUserInfoMessageTypeKey"
let kMessageFromWatchKey = "kMessageFromWatchKey"
let kMessageFromPhoneWithItineraryData = "kMessageFromPhoneWithItineraryData"
let kMessageFromPhoneWithSettingsData = "kMessageFromPhoneWithSettingsData"

// MARK: - Color String
let kColorStringSeparator = "\t"
