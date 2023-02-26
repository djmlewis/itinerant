//
//  WKStageActionView.swift
//  itinerant Watch App
//
//  Created by David JM Lewis on 05/02/2023.
//

import SwiftUI
import Combine


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
            } /* GridRow */
           if stage.isCommentOnly == false {
                GridRow {
                    VStack {
                        HStack(alignment: .center) {
                            Image(systemName: stage.durationSymbolName)
                                .padding(.leading, 2.0)
                            if stage.isCountDownType {
                                if stage.isCountDownToDate {
                                    Button(action: {
                                        presentDatePicker = true
                                    }, label: {
                                        Text(stage.durationString)
                                            .font(.system(.title3, design: .rounded, weight: .semibold))
                                            .lineLimit(2)
                                            .allowsTightening(true)
                                            .minimumScaleFactor(0.5)
                                    })
                                    .disabled(stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .buttonStyle(.borderless)
                                    .controlSize(.regular)
                                    .foregroundColor(stageDurationDateInvalid && !stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ?  Color("ColourInvalidDate") : stageTextColour())
                                    .padding()
                                    .background(stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? Color.clear : Color("ColourButtonGrey"))
                                    .clipShape(Capsule(style: .continuous))
                                    .padding([.top], 6)
                               } else {
                                    Text(stage.durationString)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.system(.title3, design: .rounded, weight: .semibold))
                                        .foregroundColor(stageTextColour())
                                        .lineLimit(2)
                                        .allowsTightening(true)
                                        .minimumScaleFactor(0.5)
                                }
                            }
                        } /* HStack */
                        .frame(maxWidth: .infinity, alignment: .leading)
                        if stage.isPostingRepeatingSnoozeAlerts {
                            // Snooze Alarms time duration
                            HStack {
                                Image(systemName: "bell.and.waves.left.and.right")
                                    .foregroundColor(Color("ColourAdditionalAlarmsImage"))
                               Text(Stage.stageFormattedDurationStringFromDouble(Double(stage.snoozeDurationSecs)))
                                    .lineLimit(1)
                                    .allowsTightening(true)
                                    .minimumScaleFactor(0.5)
                            }
                            .foregroundColor(Color("ColourAdditionalAlarmsText"))
                            .font(.system(.subheadline, design: .rounded, weight: .regular))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .modifier(WKStageAlertslBackground())
                        }
                        if !stage.additionalDurationsArray.isEmpty {
                            (Text("\(Image(systemName: "alarm.waves.left.and.right"))")
                                .foregroundColor(Color("ColourAdditionalAlarmsImage")) +
                            Text(" \(stage.additionalAlertsDurationsString)")
                                .foregroundColor(Color("ColourAdditionalAlarmsText"))
                             )
                                .frame(maxWidth: .infinity, alignment: .center)
                                .allowsTightening(true)
                                .minimumScaleFactor(0.5)
                                .font(.system(.subheadline, design: .rounded, weight: .regular))
                                .multilineTextAlignment(.center)
                                .modifier(WKStageAlertslBackground())
                        } /* if !stage.additionalDurationsArray.isEmpty */
                    } /* VStack */
                    .frame(maxWidth: .infinity)
                    .padding(.bottom,6)
                    .foregroundColor(stageTextColour())
                    .gridCellColumns(2)
                } /* GridRow */
                .padding(0)
            } /* isCommentOnly */
            if stage.isCommentOnly == false && (stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)  || dictStageStartDates[stage.idStr] != nil) {
                GridRow {
                    HStack(spacing:0.0) {
                        Image(systemName: "hourglass")
                        Text(Stage.stageFormattedDurationStringFromDouble(fabs(timeAccumulatedAtUpdate)))
                    }
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color("ColourTimeAccumulatedText"))
                    .background(Color("ColourTimeAccumulatedBackground"))
                    .opacity(timeAccumulatedAtUpdate == 0.0  ? 0.0 : 1.0)
                    .lineLimit(1)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.5)
                    .border(timeAccumulatedAtUpdate > 0.0 ? .white : .clear, width: 1.0)
                    .padding(.leading,2.0)
                    .padding(.trailing,2.0)
                    .gridCellColumns(2)
                }  /* GridRow */
                .padding(.top,3.0)
                if timeDifferenceAtUpdate != 0.0 && stage.isCountDownType {
                    GridRow {
                        HStack(spacing:0.0) {
                            Image(systemName: stageRunningOvertime ? "bell.and.waves.left.and.right" : "timer")
                            Text("\(stageRunningOvertime ? "+" : "" )" + Stage.stageFormattedDurationStringFromDouble(fabs((timeDifferenceAtUpdate))))
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
                } /* if timeDifferenceAtUpdate != 0.0 && stage.isCountDownType */
            } /* if nonComment, running OR ran*/
        } /* Grid */
        .padding(0)
        /* Grid mods */
        .sheet(isPresented: $presentDatePicker, content: {
            StageActionDatePickerCommonView(durationDate: $durationDate, presentDatePicker: $presentDatePicker, initialDurationDate: stage.durationAsDate)
        })

    } /* body */
    
#endif
}
