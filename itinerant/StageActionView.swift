//
//  StageActionView.swift
//  itinerant
//
//  Created by David JM Lewis on 05/02/2023.
//

import SwiftUI

#if !os(watchOS)
let kRowPad = 6.0
#endif

extension StageActionCommonView {
    
#if !os(watchOS)
    var body_: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            HStack {
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(stageTextColour())
                        .scenePadding(.minimum, edges: .horizontal)
                        .multilineTextAlignment(.leading)
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
                .padding(kRowPad)
            }
            .frame(maxWidth: .infinity)
            .padding(0)
            .background(stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) ? Color("ColourStageActiveHeading") : Color.clear)
            if //!stage.details.isEmpty &&
                (disclosureDetailsExpanded == true ||
                 stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ||
                 stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr))
            {
                HStack(alignment: .top, spacing: 0.0) {
                    if !stage.details.isEmpty {
                        Text(stage.details)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(.body, design: .rounded, weight: .regular))
                            .foregroundColor(stageTextColour())
                            .multilineTextAlignment(.leading)
                    }
                    if let imagedata = stage.imageDataThumbnailActual,
                       let uiImage = UIImage(data: imagedata) {
                        Spacer()
                        Button(action: {
                            if let imagedata = getSetStageFullSizeImageData(),
                               let uiImage = UIImage(data: imagedata) {
                                fullSizeUIImage = uiImage
                                showFullSizeUIImage = true
                            }
                        }, label: {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(idealWidth: kImageColumnWidthHalf, alignment: .trailing)
                                .fixedSize(horizontal: true, vertical: false)
                                .padding(0)
                        })
                        .buttonStyle(.borderless)
                   }

               } /* HStack */
                .frame(maxWidth: .infinity)
                .padding(kRowPad)
            }
            if stage.isCommentOnly == false {
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
                                .foregroundColor(stageDurationDateInvalid && !stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ?  Color("ColourInvalidDate") : stageTextColour())
                                .background(stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? Color.clear : Color("ColourButtonGrey"))
                                .clipShape(Capsule(style: .continuous))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            //.padding([.top], 6)
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
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(kRowPad)
                HStack(spacing: 0.0) {
                    if stage.isPostingRepeatingSnoozeAlerts {
                        // Snooze Alarms time duration
                        HStack {
                            Image(systemName: "bell.and.waves.left.and.right")
                                .foregroundColor(Color("ColourAdditionalAlarmsImage"))
                            Text(Stage.stageFormattedDurationStringFromDouble(Double(stage.snoozeDurationSecs)))
                                .foregroundColor(Color("ColourAdditionalAlarmsText"))
                                .lineLimit(1)
                                .allowsTightening(true)
                                .minimumScaleFactor(0.5)
                        }
                        .font(.system(.subheadline, design: .rounded, weight: .regular))
                        .padding(kRowPad)
                    }
                    if !stage.additionalDurationsDict.isEmpty {
                        VStack(alignment: .center) {
                            HStack {
                                Image(systemName: "alarm.waves.left.and.right")
                                    .foregroundColor(Color("ColourAdditionalAlarmsImage"))
                                Text("\(stage.additionalAlertsDurationsString)")
                                    .foregroundColor(Color("ColourAdditionalAlarmsText"))
                                    .frame(alignment: .leading) // leading to be adjacent to image
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .center) // centered here
                            .font(.system(.subheadline, design: .rounded, weight: .regular))
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(kRowPad)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color("ColourAdditionalAlarmsBackground"))
                if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)  || dictStageStartDates[stage.idStr] != nil {
                    HStack(spacing: 0) {
                        HStack {
                            Image(systemName: "hourglass")
                            // elapsed time
                            Text(Stage.stageFormattedDurationStringFromDouble(fabs(timeAccumulatedAtUpdate)))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(kRowPad)
                        .background(Color("ColourTimeAccumulatedBackground"))
                        .foregroundColor(Color("ColourTimeAccumulatedText"))
                        .opacity(timeAccumulatedAtUpdate == 0.0  ? 0.0 : 1.0)
                        if timeDifferenceAtUpdate != 0.0 && stage.isCountDownType {
                            HStack {
                                Image(systemName: stageRunningOvertime ? "bell.and.waves.left.and.right" : "timer")
                                // time remaining or overtime
                                Text("\(stageRunningOvertime ? "+" : "" )" +
                                     Stage.stageFormattedDurationStringFromDouble(fabs(timeDifferenceAtUpdate)))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundColor(stageRunningOvertime ? Color("ColourOvertimeFont") : Color("ColourRemainingFont"))
                            .padding(kRowPad)
                            .background(stageRunningOvertime ? Color("ColourOvertimeBackground") : Color("ColourRemainingBackground"))
                        }
                    } /* HStack */
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .frame(maxWidth: .infinity)
                } /* if running */
            } /*  if stage.isCommentOnly == false */
        } /* VStack */
        .background(stageBackgroundColour(stage: stage))
        .padding(0)
        //.cornerRadius(8) /// make the background rounded
        .onChange(of: toggleDisclosureDetails) {  disclosureDetailsExpanded = $0 } // ios only
        .onChange(of: stage.flags) { _ in checkUIupdateSlowTimerStatus() }
        .sheet(isPresented: $presentDatePicker, content: {
            NavigationStack {
                StageActionDatePickerCommonView(durationDate: $durationDate, presentDatePicker: $presentDatePicker, initialDurationDate: stage.durationAsDate)
            }
        })
        .fullScreenCover(isPresented: $showFullSizeUIImage, content: {
            FullScreenImageView(fullSizeUIImage: $fullSizeUIImage, showFullSizeUIImage: $showFullSizeUIImage)
        }) /* fullScreenCover */

        //        /* VStack mods */
    } /* body ios*/
#endif
}
