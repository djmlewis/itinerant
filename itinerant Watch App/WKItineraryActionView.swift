//
//  WKItineraryActionView.swift
//  itinerant Watch App
//
//  Created by David JM Lewis on 27/01/2023.
//

import SwiftUI

struct WKItineraryActionView: View {
    @State var itinerary: Itinerary //  not a Binding because we dont change anything just read
    @Binding var uuidStrStagesActiveStr: String
    @Binding var uuidStrStagesRunningStr: String
    @Binding var dictStageStartDates: [String:String]
    @Binding var dictStageEndDates: [String:String]

    @State private var resetStageElapsedTime: Bool?
    @State private var scrollToStageID: String?
    @State private var stageToHandleSkipActionID: String?
    @State private var stageToStartRunningID: String?

    @EnvironmentObject var wkAppDelegate: AppDelegate

    var body: some View {
        ScrollViewReader { scrollViewReader in
            List {
                ForEach($itinerary.stages) { $stage in
//                    WKStageActionView(stage: $stage, itinerary: $itinerary, uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates, dictStageEndDates: $dictStageEndDates, resetStageElapsedTime: $resetStageElapsedTime, scrollToStageID: $scrollToStageID, stageToHandleSkipActionID: $stageToHandleSkipActionID, stageToStartRunningID: $stageToStartRunningID)
                    StageActionCommonView(stage: $stage, itinerary: $itinerary, uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates, dictStageEndDates: $dictStageEndDates, resetStageElapsedTime: $resetStageElapsedTime, scrollToStageID: $scrollToStageID, stageToHandleSkipActionID: $stageToHandleSkipActionID, stageToStartRunningID: $stageToStartRunningID)
                        .id(stage.id.uuidString)
                        .listItemTint(stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? Color("ColourBackgroundRunning") : stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) ? Color("ColourBackgroundActive") : Color("ColourBackgroundInactive") )
                } /* ForEach */
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                Button {
                    resetItineraryStages()
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                        Text("Reset")
                        Spacer()
                    }
                }
                .listItemTint(.red)
                .padding()
            } /* List */
            .toolbar(content: {
                Button {
                    resetItineraryStages()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise.circle.fill")
                }
                .tint(.red)
                .padding()
            })
            .onChange(of: scrollToStageID) { stageid in
                if stageid != nil {
                    DispatchQueue.main.async {
                        withAnimation {
                            scrollViewReader.scrollTo(stageid!, anchor: .top)
                        }
                    }
                }
            }
            /* List modifiers */
        } /* ScrollViewReader */
        .navigationTitle(itinerary.title)
        .onAppear() {
            if !itinerary.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) && !itinerary.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) && !itinerary.stages.isEmpty {
                let stageuuid = itinerary.stages[0].id.uuidString
                uuidStrStagesActiveStr.append(stageuuid)
                scrollToStageID = stageuuid
            }
            // prime the stages for a skip action
            stageToHandleSkipActionID = wkAppDelegate.unnStageToStopAndStartNextID
       }
        .onChange(of: wkAppDelegate.unnStageToStopAndStartNextID, perform: {
            // prime the stages for a skip action
            stageToHandleSkipActionID = $0
        })
        /* ScrollViewReader modifiers */
    } /* body */
} /* struct */


extension WKItineraryActionView {
    
    func removeAllActiveRunningItineraryStageIDsAndNotifcations() {
        (uuidStrStagesActiveStr,uuidStrStagesRunningStr,dictStageStartDates,dictStageEndDates) = itinerary.removeAllStageIDsAndNotifcationsFrom(str1: uuidStrStagesActiveStr, str2: uuidStrStagesRunningStr, dict1: dictStageStartDates, dict2: dictStageEndDates)
    }
    
    func resetItineraryStages() {
        removeAllActiveRunningItineraryStageIDsAndNotifcations()
        resetStageElapsedTime = true
        // need a delay or we try to change ui too soon
        // toggle scrollToStageID to nil so we scroll up to an already active id
        scrollToStageID = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if !itinerary.stages.isEmpty {
                uuidStrStagesActiveStr.append(itinerary.stages[0].id.uuidString)
            }
        }
        
    }
    
}





struct WKItineraryActionView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello, World!")
    }
}
