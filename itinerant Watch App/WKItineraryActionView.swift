//
//  WKItineraryActionView.swift
//  itinerant Watch App
//
//  Created by David JM Lewis on 27/01/2023.
//

import SwiftUI

extension ItineraryActionCommonView {
    
    var body_watchos: some View {
        ScrollViewReader { scrollViewReader in
            List {
                ForEach($itinerary.stages) { $stage in
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
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 32, alignment: .center)
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
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 32, alignment: .center)
                        Spacer()
                    }
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
            stageToHandleSkipActionID = appDelegate.unnStageToStopAndStartNextID
       }
        .onChange(of: appDelegate.unnStageToStopAndStartNextID, perform: {
            // prime the stages for a skip action
            stageToHandleSkipActionID = $0
        })
        /* ScrollViewReader modifiers */
    } /* body */
} /* extension */


