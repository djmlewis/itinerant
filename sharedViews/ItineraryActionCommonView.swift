//
//  ItineraryActionCommonView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI



struct ItineraryActionCommonView: View {
    
    @State var itinerary: Itinerary // not a Binding because we dont change anything just read
    @Binding var uuidStrStagesActiveStr: String
    @Binding var uuidStrStagesRunningStr: String
    @Binding var dictStageStartDates: [String:String]
    @Binding var dictStageEndDates: [String:String]

    @State var resetStageElapsedTime: Bool?
    @State var scrollToStageID: String?
    @State var stageToHandleSkipActionID: String?
    @State var stageToHandleHaltActionID: String?
    @State var stageToStartRunningID: String?

    @EnvironmentObject var appDelegate: AppDelegate

    @AppStorage(kAppStorageColourStageInactive) var appStorageColourStageInactive: String = kAppStorageDefaultColourStageInactive
    @AppStorage(kAppStorageColourStageActive) var appStorageColourStageActive: String = kAppStorageDefaultColourStageActive
    @AppStorage(kAppStorageColourStageRunning) var appStorageColourStageRunning: String = kAppStorageDefaultColourStageRunning
    @AppStorage(kAppStorageColourStageComment) var appStorageColourStageComment: String = kAppStorageDefaultColourStageComment
    @AppStorage(kAppStorageColourFontInactive) var appStorageColourFontInactive: String = kAppStorageDefaultColourFontInactive
    @AppStorage(kAppStorageColourFontActive) var appStorageColourFontActive: String = kAppStorageDefaultColourFontActive
    @AppStorage(kAppStorageColourFontRunning) var appStorageColourFontRunning: String = kAppStorageDefaultColourFontRunning
    @AppStorage(kAppStorageColourFontComment) var appStorageColourFontComment: String = kAppStorageDefaultColourFontComment

#if !os(watchOS)
    @State var itineraryData = Itinerary.EditableData()
    @State var isPresentingItineraryEditView: Bool = false
    @State var toggleDisclosureDetails: Bool = true
    @State var fileSaverShown: Bool = false
    @State var fileSaveDocument: ItineraryDocument?
    @State var fileExporterShown: Bool = false
    @State var fileExportDocument: ItineraryTextDocument?


    @EnvironmentObject var itineraryStore: ItineraryStore
#endif


    

    
    var body: some View {
#if os(watchOS)
        body_watchos
#else
        body_ios
#endif
    } /* View */
    
}



extension ItineraryActionCommonView {
    func stageBackgroundColour(stage: Stage) -> Color {
        if stage.isCommentOnly {
            return appStorageColourStageComment.rgbaColor!
        }
        if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) {
            return appStorageColourStageRunning.rgbaColor!
        }
        if stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) {
            return appStorageColourStageActive.rgbaColor!
        }
        return appStorageColourStageInactive.rgbaColor!
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
        if let firstActStageIndx = itinerary.firstIndexActivableStage {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                uuidStrStagesActiveStr.append(itinerary.stages[firstActStageIndx].idStr)
            }
        }
        
    }
    
    func sendItineraryToWatch()  {
        if let watchdata = itinerary.watchDataNewUUID {
            appDelegate.sendMessageOrData(dict: [
                kUserInfoMessageTypeKey : kMessageFromPhoneWithItineraryData,
                kMessageFromPhoneWithItineraryData : watchdata],
                                          data: nil)
        }
    }
    
    
}

struct ItineraryActionCommonView_Previews: PreviewProvider {
    static var previews: some View {
        Text("k")
    }
}
