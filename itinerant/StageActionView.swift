//
//  StageActionView.swift
//  itinerant
//
//  Created by David JM Lewis on 05/02/2023.
//

import SwiftUI

extension StageActionCommonView {
    var body_iOS: some View {
        VStack(alignment: .leading) {
            if stage.isCommentOnly == false {
                HStack {
                    // alarm duration and button
                    Image(systemName: stage.durationSymbolName)
                    // Timer type icon
                        .foregroundColor(stageTextColour())
                    if !stage.isCountUp {
                        Text(Stage.stageDurationStringFromDouble(Double(stage.durationSecsInt)))
                        // Alarm time duration
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(stageTextColour())
                            .lineLimit(1)
                            .allowsTightening(true)
                            .minimumScaleFactor(0.5)
                    }
                    if stage.isCountUpWithSnoozeAlerts {
                        // Snooze Alarms time duration
                        HStack {
                            Spacer()
                            Image(systemName: "bell.and.waves.left.and.right")
                            Text(Stage.stageDurationStringFromDouble(Double(stage.snoozeDurationSecs)))
                                .font(.title3)
                                .fontWeight(.bold)
                                .lineLimit(1)
                                .allowsTightening(true)
                                .minimumScaleFactor(0.5)
                            Spacer()
                       }
                        .foregroundColor(stageTextColour())
                        .frame(maxWidth: .infinity)
                        .opacity(0.5)
                    }
                    Spacer()
                    if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) || stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) {
                        Button(action: {
                            // Start Stop
                            handleStartStopButtonTapped()
                        }) {
                            Image(systemName: stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? "stop.circle" : "play.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .foregroundColor(.white)
                        .buttonStyle(BorderlessButtonStyle())
                        .frame(width: 46, alignment: .leading)
                    }
                }
                if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)  || dictStageStartDates[stage.id.uuidString] != nil {
                    Grid (horizontalSpacing: 3.0, verticalSpacing: 0.0) {
                        // Times elapsed
                        GridRow {
                            HStack {
                                Image(systemName: "hourglass")
                                // elapsed time
                                Text(Stage.stageDurationStringFromDouble(fabs(timeAccumulatedAtUpdate)))
                                    .bold()
                            }
                            .padding(4.0)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.black)
                            .background(.white)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke( .black, lineWidth: 1.0)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                            .opacity(timeAccumulatedAtUpdate == 0.0  ? 0.0 : 1.0)
                            HStack {
                                Image(systemName: stageRunningOvertime ?  "bell.and.waves.left.and.right" : "bell")
                                // time remaining or overtime
                                Text("\(stageRunningOvertime ? "+" : "" )" +
                                     Stage.stageDurationStringFromDouble(fabs(timeDifferenceAtUpdate)))
                                .bold()
                            }
                            .padding(4.0)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(stageRunningOvertime ? Color("ColourOvertimeFont") : Color("ColourRemainingFont"))
                            .background(stageRunningOvertime ? Color("ColourOvertimeBackground") : Color("ColourRemainingBackground"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke( .black, lineWidth: 1.0)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                            .opacity(timeDifferenceAtUpdate == 0.0 || stage.isCountUp  ? 0.0 : 1.0)
                        } /* GridRow */
                        .padding(0.0)
                    } /* Grid */
                    .padding(0.0)
                }
            } /*  if stage.isCommentOnly == false */
            HStack {
                // title and expand details
                if stage.isCommentOnly == false {
                    Button(action: {
                        disclosureDetailsExpanded = !disclosureDetailsExpanded
                    }) {
                        Image(systemName: disclosureDetailsExpanded == true ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                if stage.isCommentOnly == true {
                    Image(systemName: "bubble.left")
                        .foregroundColor(stageTextColour())
                }
                Text(stage.title)
                // Stage title
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(stageTextColour())
                    .scenePadding(.minimum, edges: .horizontal)
            }
            .padding(0.0)
            if stage.isCommentOnly == false && !stage.details.isEmpty && disclosureDetailsExpanded == true{
                Text(stage.details)
                // Details
                    .font(.body)
                    .foregroundColor(stageTextColour())
                    .multilineTextAlignment(.leading)
                    .padding(0.0)
            }
        } /* VStack */
        .padding(0)
        .cornerRadius(8) /// make the background rounded
        .gesture(gestureActivateStage())
        .onAppear() { handleOnAppear() }
        .onDisappear() { handleOnDisappear() }
        .onReceive(uiUpdateTimer) { handleReceive_uiUpdateTimer(newDate: $0) }
        .onChange(of: resetStageElapsedTime) { resetStage(newValue: $0) }
        .onChange(of: uuidStrStagesActiveStr) { if stage.isActive(uuidStrStagesActiveStr: $0) { scrollToStageID = stage.id.uuidString} }
        .onChange(of: stageToHandleSkipActionID) {  handleReceive_stageToHandleSkipActionID(idStr: $0)  }
        .onChange(of: stageToHandleHaltActionID) {  handleReceive_stageToHandleHaltActionID(idStr: $0)  }
        .onChange(of: stageToStartRunningID) { handleReceive_stageToStartRunningID(idStr: $0) }
        .onChange(of: toggleDisclosureDetails) {  disclosureDetailsExpanded = $0 }
        /* VStack mods */
    } /* body ios*/

}
