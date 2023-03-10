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
                ForEach($itineraryLocalCopy.stages) { $stage in
                    StageActionCommonView(stage: $stage, itinerary: $itineraryLocalCopy, uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates, dictStageEndDates: $dictStageEndDates, resetStageElapsedTime: $resetStageElapsedTime, scrollToStageID: $scrollToStageID, stageToHandleSkipActionID: $stageToHandleSkipActionID, stageToHandleHaltActionID: $stageToHandleHaltActionID, stageToStartRunningID: $stageToStartRunningID)
                        .id(stage.idStr)
                        .listItemTint(stageBackgroundColour(stage: stage))
                } /* ForEach */
                ItineraryDurationUpdatingView(itinerary: itineraryLocalCopy)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .listItemTint(.clear)
                    .lineLimit(1)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.5)
                    .padding(.trailing,0)
                    .padding(.leading,0)
                    .font(.system(.subheadline, design: .rounded, weight: .regular))
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
        .navigationTitle(itineraryLocalCopy.title)
        .onAppear() {
            if !itineraryLocalCopy.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) && !itineraryLocalCopy.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) && !itineraryLocalCopy.stages.isEmpty {
                let stageuuid = itineraryLocalCopy.stages[0].idStr
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


