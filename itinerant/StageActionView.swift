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
                if stage.isCommentOnly == true {
                    Image(systemName: "bubble.left")
                        .foregroundColor(stageTextColour())
                }
                Text(stage.title)
                // Stage title
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .foregroundColor(stageTextColour())
                    .scenePadding(.minimum, edges: .horizontal)
                if !stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) && !stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) {
                    Button(action: {
                        disclosureDetailsExpanded = !disclosureDetailsExpanded
                    }) {
                        Image(systemName: disclosureDetailsExpanded == true ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                    .padding(0)
                }
                if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) || stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) {
                    buttonStartHalt()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(0.0)
            .padding(.trailing, 2)
            if !stage.details.isEmpty &&
                (disclosureDetailsExpanded == true ||
                 stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ||
                 stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr))
            {
                Text(stage.details)
                // Details
                    .frame(maxWidth: .infinity)
                    .font(.system(.body, design: .rounded, weight: .regular))
                    .foregroundColor(stageTextColour())
                    .multilineTextAlignment(.leading)
                    .padding(0.0)
                    .padding(.trailing, 8)
            }
            if stage.isCommentOnly == false {
                HStack {
                    VStack( alignment: .leading,spacing: 4.0) {
                        HStack {
                            // alarm duration and button
                            Image(systemName: stage.durationSymbolName)
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .foregroundColor(stageTextColour())
                           if stage.isCountDownType {
                               if stage.isCountDownToDate {
                                   VStack {
                                       Button(action: {
                                           presentDatePicker = true
                                       }, label: {
                                           Text(stage.durationString)
                                               .fixedSize(horizontal: true, vertical: true)
                                               .font(.system(.title3, design: .rounded, weight: .semibold))
                                               .lineLimit(2)
                                               .allowsTightening(true)
                                               .minimumScaleFactor(0.5)
                                               .padding(12)
                                           
                                       })
                                       .disabled(stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr))
                                       .buttonStyle(.borderless)
                                       .controlSize(.regular)
                                       .foregroundColor(stageDurationDateInvalid && !stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ?  Color.accentColor : stageTextColour())
    //                                   .padding([.top,.bottom])
                                       .background(stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? Color.clear : Color("ColourButtonGrey"))
                                       .clipShape(Capsule(style: .continuous))
                                   }
                                   .frame(maxWidth: .infinity, alignment: .center)
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
                            if stage.isPostingRepeatingSnoozeAlerts {
                                // Snooze Alarms time duration
                                HStack {
                                    Image(systemName: "bell.and.waves.left.and.right")
                                    Text(Stage.stageFormattedDurationStringFromDouble(Double(stage.snoozeDurationSecs)))
                                        .lineLimit(1)
                                        .allowsTightening(true)
                                        .minimumScaleFactor(0.5)
                                        .frame(alignment: .trailing)
                               }
                                .font(.system(.subheadline, design: .rounded, weight: .regular))
                                .modifier(AdditionalAlarmsFontBackgroundColour())
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        if !stage.additionalDurationsArray.isEmpty {
                            VStack(alignment: .center) {
                                HStack {
                                    Image(systemName: "alarm.waves.left.and.right")
                                    Text("\(stage.additionalAlertsDurationsString)")
                                        .frame(alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(.system(.subheadline, design: .rounded, weight: .regular))
                                .modifier(AdditionalAlarmsFontBackgroundColour())
                          }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(0.0)
                        }
                    }
                    .frame(maxWidth: .infinity)
                } /* HStack */
                .padding(0.0)
                .padding(.trailing, 8.0)
                if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)  || dictStageStartDates[stage.idStr] != nil {
                    Grid (horizontalSpacing: 3.0, verticalSpacing: 0.0) {
                        // Times elapsed
                        GridRow {
                            HStack {
                                Image(systemName: "hourglass")
                                // elapsed time
                                Text(Stage.stageFormattedDurationStringFromDouble(fabs(timeAccumulatedAtUpdate)))
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
                            if timeDifferenceAtUpdate != 0.0 && stage.isCountDownType {
                                HStack {
                                    Image(systemName: stageRunningOvertime ? "bell.and.waves.left.and.right" : "timer")
                                    // time remaining or overtime
                                    Text("\(stageRunningOvertime ? "+" : "" )" +
                                         Stage.stageFormattedDurationStringFromDouble(fabs(timeDifferenceAtUpdate)))
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
                            }
                        } /* GridRow */
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .padding(0.0)
                    } /* Grid */
                    .padding(0.0)
                }
            } /*  if stage.isCommentOnly == false */
        } /* VStack */
        .padding(0)
        .cornerRadius(8) /// make the background rounded
        .onChange(of: toggleDisclosureDetails) {  disclosureDetailsExpanded = $0 } // ios only
        .onChange(of: stage.flags) { _ in checkUIupdateSlowTimerStatus() }
        .sheet(isPresented: $presentDatePicker, content: {
            NavigationStack {
                WKStageActionDatePickerView(durationDate: $durationDate, presentDatePicker: $presentDatePicker, initialDurationDate: stage.durationAsDate)
            }
        })

//        /* VStack mods */
    } /* body ios*/
#endif
}
