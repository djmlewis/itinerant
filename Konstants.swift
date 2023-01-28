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
}

extension UTType {
    static let itineraryDataFile = UTType(exportedAs: ItineraryFileType.dataFile.rawValue)
    static let itineraryImportFile = UTType(exportedAs: ItineraryFileType.importFile.rawValue)
}

enum ItineraryFileExtension: String {
    case dataFile = "itinerary"
    case importFile = "import"
}

// MARK: - ItineraryStore
let kItineraryStoreFileName = "itinerant/itineraryStore_10" + ".data"
let kItineraryUUIDsFileName = "itineraryUUIDs" + ".data"

let kItineraryPerststentDataFileSuffix = ItineraryFileExtension.dataFile.rawValue
let kItineraryPerststentImportFileSuffix = ItineraryFileExtension.importFile.rawValue
let kItineraryPerststentDataFileDotSuffix = "." + kItineraryPerststentDataFileSuffix
let kItineraryPerststentDataFileDirectoryName = "itineraries"
let kItineraryPerststentDataFileDirectorySlashNameSlash = "/" + kItineraryPerststentDataFileDirectoryName + "/"
let kItineraryPerststentDataFileDirectorySlashName =  "/" + kItineraryPerststentDataFileDirectoryName

let kUnknownObjectErrorStr = "error: Unkown"

// MARK: - Itinerary
let kImportHeadingLines: Int = 1
let kImportLinesPerStage: Int = 3

// MARK: - Stage
let kStageInitialDurationSecs: Int = 60
let kStageInitialSnoozeDurationSecs: Int = 5 * SEC_MIN

// MARK: - ItinerantApp

// MARK: - ItineraryStoreView
let kSceneStoreUuidStrStageActive = "uuidStrStageActiveStr"
let kSceneStoreUuidStrStageRunning = "uuidStrStageRunningStr"
let kSceneStoreDictStageStartDates = "kSceneStoreDictStageStartDates"
let kSceneStoreUuidStrItineraryResetView = "kSceneStoreUuidStrItineraryResetView"

// MARK: - ItineraryActionView
let kItineraryUUIDStr = "kItineraryUUIDStr"
let kStageUUIDStr = "kStageUUIDStr"
let kItineraryTitle = "kItineraryTitle"
let kStageTitle = "kStageTitle"
let kStageSnoozeDurationSecs = "kStageSnoozeDurationSecs"



// MARK: - StageActionView
let kSceneStoreStageTimeStartedRunning = "timeStartedRunning"
let kUIUpdateTimerFrequency = 0.2



// MARK: - WatchConnectivity
let kMessageKey = "message"
let kMessageItineraryData = "kMessageItinerary"
