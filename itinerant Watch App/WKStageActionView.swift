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
                    if let imagedata = stage.imageDataThumbnailActual, let uiImage = UIImage(data: imagedata) {
                        Button(action: {
                            fullSizeUIImage = uiImage
                            showFullSizeUIImage = true
                        }, label: {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(maxWidth: kHaltButtonWidth, maxHeight: kHaltButtonWidth)
                                .padding(0)
                        })
                        .buttonStyle(.borderless)
                    }
                    Text(stage.title)
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(stageTextColour())
                        .frame(maxWidth: .infinity)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                        .padding([.top,.bottom],0)
                        .padding([.leading,.trailing],3)
                   if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) || stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) {
                        buttonStartHalt()
                            .padding(0)
                    }
                } /* HStack */
                .gridCellColumns(2)
                .frame(maxWidth: .infinity)
                .padding(0)
            } /* GridRow */
           if stage.isCommentOnly == false {
                GridRow {
                    VStack {
                        HStack(alignment: .center) {
                            Image(systemName: stage.durationSymbolName)
                                .padding(.leading, 2.0)
                            if stage.isCountDownType {
                                if stage.isCountDownToDate {
                                    TimelineView(.periodic(from: Date(), by: kUISlowUpdateTimerFrequency)) { context in
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
                                        .foregroundColor(stage.invalidDurationForCountDownTypeAtDate(context.date)  && !stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ?  Color("ColourInvalidDate") : stageTextColour())
                                        .padding()
                                        .background(stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? Color.clear : Color("ColourButtonGrey"))
                                        .clipShape(Capsule(style: .continuous))
                                        .padding([.top], 6)
                                    }
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
                        Stage.additionalAndSnoozeAlertsHStackForStage(stage)
                    } /* VStack */
                    .frame(maxWidth: .infinity)
//                    .padding(.bottom,6)
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
                    .minimumScaleFactor(0.7)
                    //.border(timeAccumulatedAtUpdate > 0.0 ? .white : .clear, width: 1.0)
//                    .padding(.leading,2.0)
//                    .padding(.trailing,2.0)
                    .gridCellColumns(2)
                }  /* GridRow */
                //.padding(.top,3.0)
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
                        .minimumScaleFactor(0.7)
                        //.border(timeDifferenceAtUpdate < 0.0 ? .white : .clear, width: 1.0)
//                        .padding(.leading,2.0)
//                        .padding(.trailing,2.0)
                        .gridCellColumns(2)
                    }  /* GridRow */
                    //.padding(.top,3.0)
                } /* if timeDifferenceAtUpdate != 0.0 && stage.isCountDownType */
            } /* if nonComment, running OR ran*/
        } /* Grid */
        .padding(0)
        .padding(.bottom,6)
       /* Grid mods */
        .fullScreenCover(isPresented: $showFullSizeUIImage, content: {
            FullScreenImageView(fullSizeUIImage: $fullSizeUIImage, showFullSizeUIImage: $showFullSizeUIImage)
        }) /* fullScreenCover */
        .sheet(isPresented: $presentDatePicker, content: {
            StageActionDatePickerCommonView(durationDate: $durationDate, presentDatePicker: $presentDatePicker, initialDurationDate: stage.durationAsDate)
        })

    } /* body */
    
#endif
}
