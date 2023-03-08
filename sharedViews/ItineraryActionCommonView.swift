//
//  ItineraryActionCommonView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI
import UniformTypeIdentifiers
import Combine

struct ItineraryActionCommonView: View {
    @State var itinerary: Itinerary // no need for a Binding on watch
    @Binding var uuidStrStagesActiveStr: String
    @Binding var uuidStrStagesRunningStr: String
    @Binding var dictStageStartDates: [String:String]
    @Binding var dictStageEndDates: [String:String]
    
    @State var stageToHandleHaltActionID: String?
    @State var stageToHandleSkipActionID: String?
    
    @State var resetStageElapsedTime: Bool?
    @State var scrollToStageID: String?
    @State var stageToStartRunningID: String?
    
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var appSettingsObject: SettingsColoursObject

//    @AppStorage(kAppStorageColourStageInactive) var appStorageColourStageInactive: String = kAppStorageDefaultColourStageInactive
//    @AppStorage(kAppStorageColourStageActive) var appStorageColourStageActive: String = kAppStorageDefaultColourStageActive
//    @AppStorage(kAppStorageColourStageRunning) var appStorageColourStageRunning: String = kAppStorageDefaultColourStageRunning
//    @AppStorage(kAppStorageColourStageComment) var appStorageColourStageComment: String = kAppStorageDefaultColourStageComment
//    @AppStorage(kAppStorageColourFontInactive) var appStorageColourFontInactive: String = kAppStorageDefaultColourFontInactive
//    @AppStorage(kAppStorageColourFontActive) var appStorageColourFontActive: String = kAppStorageDefaultColourFontActive
//    @AppStorage(kAppStorageColourFontRunning) var appStorageColourFontRunning: String = kAppStorageDefaultColourFontRunning
//    @AppStorage(kAppStorageColourFontComment) var appStorageColourFontComment: String = kAppStorageDefaultColourFontComment
    
#if !os(watchOS)
    @State var itineraryData = Itinerary.EditableData()
    @State var isPresentingItineraryEditView: Bool = false
    @State var toggleDisclosureDetails: Bool = true
    
    @State var fileSaverShown: Bool = false
    @State var fileSaveDocument: ItineraryFile?
    @State var fileSaveType: UTType = .itineraryDataPackage
    @State var fileSaveName: String?
    @State var fullSizeUIImage: UIImage?
    @State var showFullSizeUIImage: Bool = false
    @State var showFilePicker: Bool = false
    @State var stageIDsToDelete: [String] = [String]()
    @State  var showSettingsView: Bool = false
    @State  var openRequestURL: URL?

    @EnvironmentObject var itineraryStore: ItineraryStore
    
#endif
    
    
    
    var body: some View {
        body_
        
    } /* View */
    
}

extension ItineraryActionCommonView {
    
        
    struct ItineraryDurationUpdatingView: View {
        var itinerary: Itinerary
                
        @State private var updateFrequency: TimeInterval = kUISlowUpdateTimerFrequency
        
        var body: some View {
            TimelineView(.periodic(from: Date(), by: updateFrequency), content: { context in
                if itinerary.someStagesAreCountUp {
                    Text("\(Image(systemName: "timer")) \(Stage.stageFormattedDurationStringFromDouble(itinerary.totalDurationAtDate(atDate: context.date)))") +
                    Text(" +\(Image(systemName: "stopwatch"))")
                } else {
                    Text("\(Image(systemName: "timer")) \(Stage.stageFormattedDurationStringFromDouble(itinerary.totalDurationAtDate(atDate: context.date)))")
                }
            })
            .onChange(of: itinerary.stages, perform: { _ in checkUIupdateSlowTimerStatus() })
            .onAppear { checkUIupdateSlowTimerStatus() }
        }
        
        func checkUIupdateSlowTimerStatus() {
            updateFrequency = itinerary.someStagesAreCountDownToDate ? kUISlowUpdateTimerFrequency : kUISlowUpdateTimerFrequencyInfinite
        }
    }
}

extension ItineraryActionCommonView {
    
    
    func stageBackgroundColour(stage: Stage) -> Color {
        if stage.isCommentOnly {
            return appSettingsObject.colourStageComment//appStorageColourStageComment.rgbaColor!
        }
        if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) {
            return appSettingsObject.colourStageRunning//appStorageColourStageRunning.rgbaColor!
        }
        if stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) {
            return appSettingsObject.colourStageActive//appStorageColourStageActive.rgbaColor!
        }
        return appSettingsObject.colourStageInactive//appStorageColourStageInactive.rgbaColor!
    }

    func removeAllActiveRunningItineraryStageIDsAndNotifcations() {
        (uuidStrStagesActiveStr,uuidStrStagesRunningStr,dictStageStartDates, dictStageEndDates) = itinerary.removeAllStageIDsAndNotifcationsFrom(str1: uuidStrStagesActiveStr, str2: uuidStrStagesRunningStr, dict1: dictStageStartDates, dict2: dictStageEndDates)
    }
    
    func resetItineraryStages() {
        removeAllActiveRunningItineraryStageIDsAndNotifcations()
        resetStageElapsedTime = true
        // need a delay or we try to change ui too soon
        // toggle scrollToStageID to nil so we scroll up to an already active id
        scrollToStageID = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let firstActStageIndx = itinerary.firstIndexActivableStage {
                uuidStrStagesActiveStr.append(itinerary.stages[firstActStageIndx].idStr)
            }
        }
        
    }
    
    func sendItineraryToWatch()  {
        appDelegate.sendItineraryDataToWatch(itinerary.watchDataKeepingUUID)
    }
    
    
}

struct ItineraryActionCommonView_Previews: PreviewProvider {
    static var previews: some View {
        Text("k")
    }
}
