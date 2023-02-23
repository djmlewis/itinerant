//
//  WKStageActionView.swift
//  itinerant Watch App
//
//  Created by David JM Lewis on 05/02/2023.
//

import SwiftUI

extension StageActionCommonView {
#if os(watchOS)
    var body_: some View {
        Grid (alignment: .center, horizontalSpacing: 0.0, verticalSpacing: 0.0) {
            GridRow {
                HStack(spacing: 0.0) {
                    Text(stage.title)
                        .padding(0)
                        .gridCellColumns(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                        .foregroundColor(stageTextColour())
                    if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) || stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) {
                        buttonStartHalt()
                    }
                } /* HStack */
                .frame(maxWidth: .infinity)
                .gridCellColumns(2)
            }
            if stage.isCommentOnly == false {
                GridRow {
                        VStack {
                            HStack {
                                Image(systemName: stage.durationSymbolName)
                                    .padding(.leading, 2.0)
                                if stage.isCountDownType {
                                    Button(action: {
                                        debugPrint("buuton aye")
                                    }, label: {
                                        Text(stage.durationString)
                                            .font(.system(.title3, design: .rounded, weight: .semibold))
                                            .lineLimit(2)
                                            .allowsTightening(true)
                                            .minimumScaleFactor(0.5)
                                    })
                                    .disabled(stage.isCountDownToDate == false || stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) == false)
                                    .buttonStyle(.borderless)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .modifier(StageInvalidDurationSymbolBackground(stageDurationDateInvalid: stageDurationDateInvalid, stageTextColour: stageTextColour()))
                                    .padding(.trailing, 2.0)
                                }
                            } /* HStack */
                            .frame(maxWidth: .infinity, alignment: .leading)
                            if stage.isPostingRepeatingSnoozeAlerts {
                                // Snooze Alarms time duration
                                HStack {
                                    Image(systemName: "bell.and.waves.left.and.right")
                                    Text(Stage.stageFormattedDurationStringFromDouble(Double(stage.snoozeDurationSecs)))
                                        .lineLimit(1)
                                        .allowsTightening(true)
                                        .minimumScaleFactor(0.5)
                                }
                                .font(.system(.subheadline, design: .rounded, weight: .regular))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .modifier(WKStageAlertslBackground())
                            }
                            if !stage.additionalDurationsArray.isEmpty {
                                    //HStack {
                                        Text("\(Image(systemName: "alarm.waves.left.and.right")) \(stage.additionalAlertsDurationsString)")
                                            .allowsTightening(true)
                                            .minimumScaleFactor(0.5)
                                    //}
                                    .font(.system(.subheadline, design: .rounded, weight: .regular))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .modifier(WKStageAlertslBackground())
                            } /* if !stage.additionalDurationsArray.isEmpty */
                        } /* VStack */
                        .frame(maxWidth: .infinity)
                        .foregroundColor(stageTextColour())
                        .gridCellColumns(2)
                } /* GridRow */
                .padding(0)
            } /* isCommentOnly */
            if stage.isCommentOnly == false && (stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)  || dictStageStartDates[stage.idStr] != nil) {
                if timeDifferenceAtUpdate != 0.0 && stage.isCountDownType {
                    GridRow {
                        HStack(spacing:0.0) {
                            Image(systemName: stageRunningOvertime ? "bell.and.waves.left.and.right" : "timer")
                            Text("\(stageRunningOvertime ? "+" : " -" )" + Stage.stageFormattedDurationStringFromDouble(fabs((timeDifferenceAtUpdate))))
                        }
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(stageRunningOvertime ? Color("ColourOvertimeFont") : Color("ColourRemainingFont"))
                        .background(stageRunningOvertime ? Color("ColourOvertimeBackground") : Color("ColourRemainingBackground"))
                        .lineLimit(1)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.5)
                        .border(timeDifferenceAtUpdate < 0.0 ? .white : .clear, width: 1.0)
                        .padding(.leading,2.0)
                        .padding(.trailing,2.0)
                        .gridCellColumns(2)
                    }  /* GridRow */
                    .padding(.top,3.0)
                }
                GridRow {
                    HStack(spacing:0.0) {
                        Image(systemName: "hourglass")
                        Text(Stage.stageFormattedDurationStringFromDouble(fabs(timeAccumulatedAtUpdate)))
                    }
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.black)
                    .background(.white)
                    .opacity(timeAccumulatedAtUpdate == 0.0  ? 0.0 : 1.0)
                    .lineLimit(1)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.5)
                    .border(timeAccumulatedAtUpdate > 0.0 ? .black : .clear, width: 1.0)
                    .padding(.leading,2.0)
                    .padding(.trailing,2.0)
                    .gridCellColumns(2)
                }  /* GridRow */
                .padding(.top,3.0)
            } /* if nonComment, running OR ran*/
        } /* Grid */
        .padding(0)
        /* Grid mods */
        .sheet(isPresented: $presentDatePicker, content: {
            Group{
                Text("The end time must be at least 1 minute in the future when the stage starts")
                    .font(.system(.subheadline, design: .rounded, weight: .regular))
                    .multilineTextAlignment(.center)
                    .opacity(0.5)
            }
        })
    } /* body */
#endif
}
