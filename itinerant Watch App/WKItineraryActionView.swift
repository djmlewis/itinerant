//
//  WKItineraryActionView.swift
//  itinerant Watch App
//
//  Created by David JM Lewis on 27/01/2023.
//

import SwiftUI

extension ItineraryActionCommonView {
#if os(watchOS)
    var body_: some View {
        ScrollViewReader { scrollViewReader in
            List {
                ForEach($itinerary.stages) { $stage in
                    StageActionCommonView(stage: $stage, itinerary: $itinerary, uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates, dictStageEndDates: $dictStageEndDates, resetStageElapsedTime: $resetStageElapsedTime, scrollToStageID: $scrollToStageID, stageToHandleSkipActionID: $stageToHandleSkipActionID, stageToHandleHaltActionID: $stageToHandleHaltActionID, stageToStartRunningID: $stageToStartRunningID)
                        .id(stage.idStr)
                        .listItemTint(stageBackgroundColour(stage: stage))
                } /* ForEach */
                itinerary.totalDurationText(atDate: dateAtUpdate)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .listItemTint(.clear)
                    .lineLimit(1)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.5)
                    .padding(.trailing,0)
                    .padding(.leading,0)
                    .font(.system(.subheadline, design: .rounded, weight: .regular))
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
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            // always on main and after a delay
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
                let stageuuid = itinerary.stages[0].idStr
                uuidStrStagesActiveStr.append(stageuuid)
                scrollToStageID = stageuuid
            }
            // prime the stages for a skip or halt action
            stageToHandleSkipActionID = appDelegate.unnStageToStopAndStartNextID
            stageToHandleHaltActionID = appDelegate.unnStageToHaltID
       }
        .onChange(of: appDelegate.unnStageToStopAndStartNextID, perform: {
            // prime the stages for a skip action
            stageToHandleSkipActionID = $0
        })
        .onChange(of: appDelegate.unnStageToHaltID, perform: {
            // prime the stages for a halt action
            stageToHandleHaltActionID = $0
        })
        /* ScrollViewReader modifiers */
    } /* body */
#endif
} /* extension */


