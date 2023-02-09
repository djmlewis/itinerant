//
//  Konstants.swift
//  itinerant
//
//  Created by David JM Lewis on 24/01/2023.
//

import Foundation
import UniformTypeIdentifiers

// Define this document's type.
enum ItineraryFileType: String {
    case dataFile = "uk.djml.itinerant.itinerary"
    case importFile = "uk.djml.itinerant.import"
    case settingsFile = "uk.djml.itinerant.settings"
    case textFile = "uk.djml.itinerant.text"
}

extension UTType {
    static let itineraryDataFile = UTType(exportedAs: ItineraryFileType.dataFile.rawValue)
    static let itineraryImportFile = UTType(exportedAs: ItineraryFileType.importFile.rawValue)
    static let itinerarySettingsFile = UTType(exportedAs: ItineraryFileType.settingsFile.rawValue)
    static let itineraryTextFile = UTType(exportedAs: ItineraryFileType.textFile.rawValue)
}

enum ItineraryFileExtension: String {
    case dataFile = "itinerary"
    case importFile = "import"
    case settingsFile = "settings"
    case textFile = "txt"
}

// MARK: - ItineraryStore
let kItineraryStoreFileName = "itinerant/itineraryStore_10" + ".data"
let kItineraryUUIDsFileName = "itineraryUUIDs" + ".data"

let kItineraryPerststentDataFileSuffix = ItineraryFileExtension.dataFile.rawValue
let kItineraryPerststentImportFileSuffix = ItineraryFileExtension.importFile.rawValue
let kItinerarySettingsFileSuffix = ItineraryFileExtension.settingsFile.rawValue
let kItinerarySettingsFileDotSuffix = "." + ItineraryFileExtension.settingsFile.rawValue
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
let kStageDurationCountUpTimer: Int = 0
let kStageDurationCountUpWithSnoozeAlerts: Int = -2
let kStageInitialDurationSecs: Int = 0
let kSnoozeDurationSecsMin: Int = 60
let kStageInitialSnoozeDurationSecs: Int = kSnoozeDurationSecsMin

let kFlagComment = "C"

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
