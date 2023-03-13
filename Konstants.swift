//
//  Konstants.swift
//  itinerant
//
//  Created by David JM Lewis on 24/01/2023.
//

import Foundation
import UniformTypeIdentifiers
import UIKit



// MARK: - ItineraryFile document
enum ItineraryFileType: String {
    case dataPackage = "uk.djml.itinerant.itinerarypackage"
    case dataFile = "uk.djml.itinerant.itinerary"
    case settingsFile = "uk.djml.itinerant.settings"
    case textFile = "uk.djml.itinerant.text"
}

extension UTType {
    static let itineraryDataPackage = UTType(exportedAs: ItineraryFileType.dataPackage.rawValue)
    static let itineraryDataFile = UTType(exportedAs: ItineraryFileType.dataFile.rawValue)
    static let itinerarySettingsFile = UTType(exportedAs: ItineraryFileType.settingsFile.rawValue)
    static let itineraryTextFile = UTType(exportedAs: ItineraryFileType.textFile.rawValue)
    
}

enum ItineraryFileExtension: String, CaseIterable {
    // dont add redundant cases as it is iterated
    case dataPackage = "itinerarypkg"
    case dataFile = "itinerary"
    case settingsFile = "settings"
    case textFile = "export"
    case imageData = "dat"
    
    var dotExtension: String { return "." + self.rawValue }
    
    static func validExtension(_ extensionStr: String) -> Bool {
        return ItineraryFileExtension.allCases.firstIndex { $0.rawValue == extensionStr } != nil
    }
}

let kPackageNamePersistentDataFile = "itineraryPersistentData" + ItineraryFileExtension.dataFile.dotExtension
let kPackageNameImageFileItinerary = "itineraryImageData"
let kPackageNameImageFileItineraryThumbnail = kPackageNameImageFileItinerary + ImageSizeType.thumbnail.rawValue + ItineraryFileExtension.imageData.dotExtension
let kPackageNameImageFileItineraryFullsize = kPackageNameImageFileItinerary + ImageSizeType.fullsize.rawValue + ItineraryFileExtension.imageData.dotExtension
let kPackageNameItineraryColourSettingsFile = "itineraryColourSettings" + ItineraryFileExtension.settingsFile.dotExtension

enum ImageSizeType: String, CaseIterable {
    // dont add redundant cases as it is iterated
    case thumbnail = "ⓣ"
    case fullsize = "ⓕ"
}

// MARK: - ItineraryStore
let kItineraryStoreFileName = "itinerant/itineraryStore_10" + ".data"
let kItineraryDataPackagesDirectoryName = "itineraries"
let kUnknownObjectErrorStr = "error: Unkown"

// MARK: - Itinerary
let kImportHeadingLines: Int = 1
let kImportLinesPerStage: Int = 6
let kSeparatorImportFile = "\n"
let kUntitledString = "Untitled"

// MARK: - Stage

let kStageMinimumDurationSecs: Int = 1
let kStageMinimumDurationSecsDbl: Double = 1.0
let kStageMinimumDurationForDateDbl: Double = SEC_MIN_DBL
let kStageMinimumDurationForFutureDateDbl: Double = kStageMinimumDurationForDateDbl * 2.0
let kStageInitialDurationSecs: Int = 0
let kSnoozeMinimumDurationSecs: Int = 60
let kStageAlertMinimumDurationSecs: Int = 1
let kStageInitialSnoozeDurationSecs: Int = kSnoozeMinimumDurationSecs
let kStageDurationsArraySeparator = ","
let kStageAdditionalDurationsInternalSeparator = "¶"

enum StageNotificationInterval: CaseIterable {
    case comment  // here for completeness for string func
    case countUp // here for completeness for string func
    // count types are mutually exclusive
    case countDownEnd
    case countDownToDate
    case countTypeUnknown // results when any count type is set false
    // --
    case snoozeRepeatingIntervals
    case snoozeSingleInterval  // here for completeness for string func
    case additionalAlert  // here for completeness for string func
    
    var string: String {
        switch self {
        case .comment:
            return  "Ⓒ"
        case .countUp:
            return  "Ⓤ"
        case .countDownEnd:
            return  "Ⓓ"
        case .countDownToDate:
            return  "Ⓚ"
        case .countTypeUnknown:
            return "Ⓧ"
        case .snoozeRepeatingIntervals:
            return  "Ⓡ"
        case .snoozeSingleInterval:
            return  "Ⓩ"
        case .additionalAlert:
            return "Ⓐ"
        }
    }
    
    var timerDirection: TimerDirection {
        switch self {
        case .countUp: return .countUp
        case .countDownEnd: return .countDownEnd
        case .countDownToDate: return .countDownToDate
        default: return .countUp
        }
    }
    
    static var countFlags: [StageNotificationInterval] { [.countDownEnd, .countDownToDate, .countUp, .countTypeUnknown] }
    static var countFlagStrings: [String] { StageNotificationInterval.countFlags.map { $0.string } }
    static func stripCountFlags(_ flags: String) -> String {
        var flagsvar = flags
        StageNotificationInterval.countFlagStrings.forEach { flagsvar = flagsvar.replacingOccurrences(of: $0, with: "") }
        return flagsvar
    }
}

extension String {
    var strippedOfCountFlags: String { StageNotificationInterval.stripCountFlags(self) }
}

enum TimerDirection: String, CaseIterable, Identifiable {
    case countDownEnd = "Count Down"
    case countDownToDate = "End Date"
    case countUp = "Count Up"
    
    var id: Self { self }
    
    var symbolName: String {
        switch self {
        case .countUp:
            return "stopwatch"
        case .countDownEnd:
            return "timer"
        case .countDownToDate:
            return "calendar.badge.clock"
        }
    }
    
    var stageNotificationIntervalType: StageNotificationInterval {
        switch self {
        case .countDownEnd: return .countDownEnd
        case .countDownToDate: return .countDownToDate
        case .countUp: return .countUp
        }
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

// MARK: - Images
let kImageColumnWidth = 150.00
let kImageColumnWidthHalf = kImageColumnWidth / 2.0
//let kImageColumnWidthThird = kImageColumnWidth / 3.0


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
let yearsAheadBlock = 5

#if os(watchOS)
let kUISlowUpdateTimerFrequency = 1.0
#else
let kUISlowUpdateTimerFrequency = 1.0
let kFontSizedPadding = UIFont.preferredFont(forTextStyle: .body).lineHeight / 2.0
let kDetailsSidePadding = 12.0
let kTitleBottomPadding = 3.0
#endif
let kUISlowUpdateTimerFrequencyInfinite = Double.greatestFiniteMagnitude

let kiOSStageViewsRowPad = 6.0

let kAppStorageShowUnableToNotifyWarning = "kAppStorageShowUnableToNotifyWarning"

// MARK: - WatchConnectivity
let kUserInfoMessageTypeKey = "kUserInfoMessageTypeKey"
let kMessageFromWatchKey = "kMessageFromWatchKey"
let kMessageFromPhoneWithItineraryData = "kMessageFromPhoneWithItineraryData"
let kMessageFromPhoneWithSettingsData = "kMessageFromPhoneWithSettingsData"
let kMessageFromPhoneRequestingSettingsData = "kMessageFromPhoneRequestingSettingsData"
let kMessageFromWatchWithSettingsData = "kMessageFromWatchWithSettingsData"
let kMessageFromWatchRequestingItinerariesSync = "kMessageFromWatchRequestingItinerariesSync"
let kMessageFromPhoneStandingByToSync = "kMessageFromPhoneStandingByToSync"
let kMessageFromWatchInitiateSyncNow = "kMessageFromWatchInitiateSyncNow"


// MARK: - Color String
let kColorStringSeparator = "\t"

// MARK: - Dates

let kPickersDateComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
