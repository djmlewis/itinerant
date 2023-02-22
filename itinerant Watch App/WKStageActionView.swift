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
            if stage.isCommentOnly == false {
                GridRow {
                    HStack(spacing: 0.0) {
                        VStack {
                            HStack {
                                Image(systemName: stage.durationSymbolName)
                                    .padding(.leading, 2.0)
                                if stage.isCountDownType {
                                    Text(stage.durationString)
                                        .font(.system(.title3, design: .rounded, weight: .semibold))
                                        .modifier(StageInvalidDurationSymbolBackground(stageDurationDateInvalid: stageDurationDateInvalid, stageTextColour: stageTextColour()))
                                        .lineLimit(2)
                                        .allowsTightening(true)
                                        .minimumScaleFactor(0.5)
                                        .padding(.trailing, 2.0)
                                }
                                if stage.isPostingRepeatingSnoozeAlerts {
                                    // Snooze Alarms time duration
                                    HStack {
                                        Spacer()
                                        Image(systemName: "bell.and.waves.left.and.right")
                                        Text(Stage.stageFormattedDurationStringFromDouble(Double(stage.snoozeDurationSecs)))
                                            .lineLimit(1)
                                            .allowsTightening(true)
                                            .minimumScaleFactor(0.5)
                                        Spacer()
                                    }
                                   .font(.system(.subheadline, design: .rounded, weight: .regular))
                                    .opacity(0.7)
                                }
                            } /* HStack */
                            if !stage.additionalDurationsArray.isEmpty {
                                    HStack {
                                        Text("\(Image(systemName: "alarm.waves.left.and.right")) \(stage.additionalAlertsDurationsString)")
                                            .allowsTightening(true)
                                            .minimumScaleFactor(0.5)
                                    }
                                    .font(.system(.subheadline, design: .rounded, weight: .regular))
                                    .opacity(0.7)
                            } /* if !stage.additionalDurationsArray.isEmpty */
                        } /* VStack */
                        .foregroundColor(stageTextColour())
                       if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) || stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) {
                            Spacer()
                            buttonStartHalt()
                        }
                    } /* HStack */
                    .foregroundColor(stageTextColour())
                    .gridCellColumns(2)
                } /* GridRow */
                .padding(0)
            } /* isCommentOnly */
            GridRow {
                Text(stage.title)
                    .padding(0)
                    .gridCellColumns(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .foregroundColor(stageTextColour())
            }
            if stage.isCommentOnly == false && (stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)  || dictStageStartDates[stage.idStr] != nil) {
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
    } /* body */
#endif
}
