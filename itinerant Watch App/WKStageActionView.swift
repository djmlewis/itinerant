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
                        Image(systemName: stage.isCountUp ? "stopwatch" : "timer")
                            .padding(.leading, 2.0)
                        if !stage.isCountUp {
                            Text(Stage.stageDurationStringFromDouble(Double(stage.durationSecsInt)))
                                .font(.system(.title3, design: .rounded, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .lineLimit(1)
                                .allowsTightening(true)
                                .minimumScaleFactor(0.5)
                                .padding(.trailing, 2.0)
                        }
                        if stage.isCountUpWithSnoozeAlerts {
                            // Snooze Alarms time duration
                            HStack {
                                Spacer()
                                Image(systemName: "bell.and.waves.left.and.right")
                                Text(Stage.stageDurationStringFromDouble(Double(stage.snoozeDurationSecs)))
                                    .font(.title3)
                                    .lineLimit(1)
                                    .allowsTightening(true)
                                    .minimumScaleFactor(0.5)
                                Spacer()
                           }
                            .frame(maxWidth: .infinity)
                            .opacity(0.5)
                        }
                        if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) || stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) {
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
                if timeDifferenceAtUpdate != 0.0 && stage.isCountDown {
                    GridRow {
                        HStack(spacing:0.0) {
                            Image(systemName: stageRunningOvertime ?  "bell.and.waves.left.and.right" : "bell")
                            Text("\(stageRunningOvertime ? "+" : "" )" + Stage.stageDurationStringFromDouble(fabs((timeDifferenceAtUpdate))))
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
                        Text(Stage.stageDurationStringFromDouble(fabs(timeAccumulatedAtUpdate)))
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
