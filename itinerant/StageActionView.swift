//
//  StageActionView.swift
//  itinerant
//
//  Created by David JM Lewis on 05/02/2023.
//

import SwiftUI

extension StageActionCommonView {
#if !os(watchOS)
    var body_: some View {
        VStack(alignment: .leading) {
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
                        buttonStartHalt()
                    }
                }
                if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)  || dictStageStartDates[stage.idStr] != nil {
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
                            if timeDifferenceAtUpdate != 0.0 && stage.isCountDown {
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
                                //.opacity(timeDifferenceAtUpdate == 0.0 || stage.isCountUp  ? 0.0 : 1.0)
                            }
                        } /* GridRow */
                        .padding(0.0)
                    } /* Grid */
                    .padding(0.0)
                }
            } /*  if stage.isCommentOnly == false */
        } /* VStack */
        .padding(0)
        .cornerRadius(8) /// make the background rounded
        .onChange(of: toggleDisclosureDetails) {  disclosureDetailsExpanded = $0 } // ios only
//        /* VStack mods */
    } /* body ios*/
#endif
}
