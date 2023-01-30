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
    
    @State private var resetStageElapsedTime: Bool?
    @State private var scrollToStageID: String?
    
    @EnvironmentObject var wkAppDelegate: WKAppDelegate

    
    var body: some View {
        ScrollViewReader { scrollViewReader in
            List {
                ForEach($itinerary.stages) { $stage in
                    WKStageActionView(stage: $stage, itinerary: $itinerary, uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates, resetStageElapsedTime: $resetStageElapsedTime, scrollToStageID: $scrollToStageID)
                        .id(stage.id.uuidString)
                        .listItemTint(stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? Color("ColourBackgroundRunning") : stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) ? Color("ColourBackgroundActive") : Color("ColourBackgroundInactive") )
                } /* ForEach */
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                Button {
                    resetItineraryStages()
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.counterclockwise")
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
                    Label("Reset", systemImage: "arrow.counterclockwise")
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
        }
        /* ScrollViewReader modifiers */
    } /* body */
} /* struct */


extension WKItineraryActionView {
    
    func removeAllActiveRunningItineraryStageIDsAndNotifcations() {
        (uuidStrStagesActiveStr,uuidStrStagesRunningStr,dictStageStartDates) = itinerary.removeAllStageIDsAndNotifcations(from: uuidStrStagesActiveStr, andFrom: uuidStrStagesRunningStr, andFromDict: dictStageStartDates)
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
