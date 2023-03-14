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
        VStack(alignment: .leading, spacing: 0.0) {
            HStack {
                HStack {
                    // title and expand details
                    if stage.isCommentOnly == true {
                        Image(systemName: "bubble.left")
                            .foregroundColor(stageTextColourForStatus)
                    }
                    Text(stage.title)
                    // Stage title
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(stageTextColourForStatus)
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
                .padding(kiOSStageViewsRowPad)
            }
            .frame(maxWidth: .infinity)
            .padding(0)
            .background(stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) ? Color("ColourStageActiveHeading") : Color.clear)
            if stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) {
                HStack{}
                    .frame(maxWidth: .infinity, minHeight:1)
                    .padding(0)
                    .background(Color.white)
            }
            if (disclosureDetailsExpanded == true ||
                 stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ||
                 stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr))
            {
                if !stage.details.isEmpty {
                    ZStack(alignment: .topLeading) {
                        Text("Hidden")
                            .opacity(0.0)
                            .frame(maxWidth: .infinity)
                            .background(GeometryReader { Color.clear.preference(key: StageActionCommonView.ZStackMeasuringPreferenceKey.self, value: $0.size) } )
                            .onPreferenceChange(StageActionCommonView.ZStackMeasuringPreferenceKey.self) { detailsMeasuredWidth = $0.width }
                        UITextViewWrapper(text: $stage.details, calculatedHeight: $calculatedHeight, fontColor: $detailsTextColour, imageMeasuredSize: $imageMeasuredSize, dynamicTypeSize: $textDynamicTypeSize)
                            .frame(minHeight: calculatedHeight, maxHeight: calculatedHeight)
                            .padding([.leading, .trailing], kDetailsSidePadding)
                        if let imagedata = stage.imageDataThumbnailActual,
                           let uiImage = UIImage(data: imagedata) {
                            HStack(spacing: 0.0) {
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
                                        .frame(
                                            width: sizeForSize(imageSize: uiImage.size, maxHeight: calculatedHeight, maxWidth: detailsMeasuredWidth - (detailsMeasuredWidth / 1.618)).width,
                                            height: sizeForSize(imageSize: uiImage.size, maxHeight: calculatedHeight, maxWidth: detailsMeasuredWidth - (detailsMeasuredWidth / 1.618)).height)
                                        .fixedSize(horizontal: true, vertical: true) // <-- fix BOTH
                                    // check height HERE to avoid padding
                                        .background(GeometryReader { Color.red.preference(key: StageActionCommonView.ImageMeasuringPreferenceKey.self, value: $0.size) } )
                                        .onPreferenceChange(StageActionCommonView.ImageMeasuringPreferenceKey.self) { imageMeasuredSize = $0 }
                                        .padding(.top, kFontSizedPadding)
                                        .padding([.leading], kDetailsSidePadding)
                                })
                                .buttonStyle(.borderless)
                                Spacer() // always LEFT not leading
                            } /* HStack */
                            .padding(0)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            if stage.isCommentOnly == false {
                HStack {
                    // alarm duration and button
                    Image(systemName: stage.durationSymbolName)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundColor(stageTextColourForStatus)
                    if stage.isCountDownType {
                        if stage.isCountDownToDate {
                            TimelineView(.periodic(from: Date(), by: kUISlowUpdateTimerFrequency)) { context in
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
                                    .foregroundColor(stage.invalidDurationForCountDownTypeAtDate(context.date) && !stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ?  Color("ColourInvalidDate") : stageTextColourForStatus)
                                    .background(stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? Color.clear : Color("ColourButtonGrey"))
                                    .clipShape(Capsule(style: .continuous))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                //.padding([.top], 6)
                            }
                        } else {
                            Text(stage.durationString)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(.title3, design: .rounded, weight: .semibold))
                                .foregroundColor(stageTextColourForStatus)
                                .lineLimit(2)
                                .allowsTightening(true)
                                .minimumScaleFactor(0.5)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(kiOSStageViewsRowPad)
                /* *** Additional Alerts stack *** */
                Stage.additionalAndSnoozeAlertsHStackForStage(stage)
                if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)  || dictStageStartDates[stage.idStr] != nil {
                    HStack(spacing: 0) {
                        HStack {
                            Image(systemName: "hourglass")
                            // elapsed time
                            Text(Stage.stageFormattedDurationStringFromDouble(fabs(timeAccumulatedAtUpdate)))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(kiOSStageViewsRowPad)
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
                            .padding(kiOSStageViewsRowPad)
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


func sizeForSize(imageSize: CGSize, maxHeight: CGFloat, maxWidth: CGFloat) -> CGSize {
    
    if imageSize.height > imageSize.width {
        // use maxHeight and adjust width
        let newWidth = (imageSize.width / imageSize.height) * maxHeight
        // check width is not > maxWidth  and return if OK
        if newWidth <= maxWidth { return CGSize(width: newWidth, height: maxHeight) }
        // recalculate with width first as height will be less
        let newHeight = (imageSize.height / imageSize.width) * maxWidth
        return CGSize(width: maxWidth, height: newHeight)
    } else {
        // use maxWidth and adjust height
        let newHeight = (imageSize.height / imageSize.width) * maxWidth
        // check newHeight is not > maxHeight and return if OK
        if newHeight <= maxHeight { return CGSize(width: maxWidth, height: newHeight) }
        // recalculate with height first as width will be less
        let newWidth = (imageSize.width / imageSize.height) * maxHeight
        return CGSize(width: newWidth, height: maxHeight)
        
    }
}
