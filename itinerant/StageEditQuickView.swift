//
//  StageeditQuickView.swift
//  itinerant
//
//  Created by David JM Lewis on 12/03/2023.
//

import SwiftUI
import PhotosUI

extension StageEditCommonView {
    
    var body_quick: some View {
        NavigationStack {
            VStack {
                if collapseForMoving == true {
                    HStack (spacing: 0.0) {
                        Text(itineraryEditableData?.indexStringOfStageUUID(stageEditableData.id) ?? "No index")
                            .padding()
                            .font(.system(.title, design: .rounded, weight: .semibold))
                            .foregroundColor(.white)
                      Button {
                            showConfirmDeleteStage = true
                        } label: {
                            Image(systemName:"trash")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(.red)
                        .frame(width: 24)
                        .padding([.leading], 48)
                        .confirmationDialog("Delete this stage?", isPresented: $showConfirmDeleteStage, titleVisibility: .visible) {
                            Button("Cancel", role: .cancel) {
                                showConfirmDeleteStage = false
                            }
                            Button("Delete", role: .destructive) {
                                DispatchQueue.main.async {
                                    stageUUIDToDelete = nil
                                    stageUUIDToDelete = stageEditableData.id
                                }
                                showConfirmDeleteStage = false
                            }
                            
                        } message: {
                            Text("This cannot be undone")
                                .foregroundColor(.red)
                        }
                        Group {
                            Text(stageEditableData.title)
                                .frame(maxWidth: .infinity)
                                .padding()
                            Image(systemName: stageEditableData.isCommentOnly ? "bubble.left" : timerDirection.symbolName)
                                .frame(width: 24)
                                .padding([.trailing], 48)
                       }
                        .font(.system(.title, design: .rounded, weight: .semibold))
                        .foregroundColor(.white)
                   }
                    .frame(maxWidth: .infinity, minHeight: 32)
                    .background(Color("ColourControlsBackground"))
                } else {
                    Grid(horizontalSpacing: 18) {
                        GridRow(alignment: .top) {
                            VStack(alignment: .leading, spacing: 0.0) {
                                VStack(alignment: .center) {
                                    HStack {
                                        Spacer()
                                        Button {
                                            DispatchQueue.main.async {
                                                selectedImageData = nil
                                                selectedItem = nil
                                                stageEditableData.imageDataFullActual = nil
                                                stageEditableData.imageDataThumbnailActual = nil
                                            }
                                        } label: {
                                            Image(systemName:"trash")
                                                .font(.system(.title3, design: .rounded, weight: .regular))
                                        }
                                        .disabled(selectedImageData == nil)
                                        .buttonStyle(.borderless)
                                        Text("Image")
                                            .font(.system(.headline, design: .rounded, weight: .semibold).lowercaseSmallCaps())
                                        PhotosPicker(
                                            selection: $selectedItem,
                                            matching: .images,
                                            photoLibrary: .shared()) {
                                                Image(systemName:"photo.on.rectangle.angled")
                                                    .font(.system(.title3, design: .rounded, weight: .regular))
                                                
                                            }
                                            .buttonStyle(.borderless)
                                            .onChange(of: selectedItem) { newItem in
                                                Task {
                                                    do {
                                                        if let data = try await newItem?.loadTransferable(type: Data.self) {
                                                            // make a thumbnail
                                                            if let uiImage = UIImage(data: data) {
                                                                uiImage.prepareThumbnail(of: CGSize(width: kImageColumnWidth, height:uiImage.size.height * (kImageColumnWidth/uiImage.size.width))) { thumbnailImage in
                                                                    let thumbnaildata = thumbnailImage?.jpegData(compressionQuality: 0.5)
                                                                    DispatchQueue.main.async {
                                                                        selectedImageData = thumbnaildata
                                                                        stageEditableData.imageDataFullActual = data
                                                                        stageEditableData.imageDataThumbnailActual = thumbnaildata
                                                                    }
                                                                }
                                                            } else {
                                                                debugPrint("photo picker loadTransferable error")
                                                                showFullSizeUIImageAlert = true
                                                            }
                                                        } else {
                                                            debugPrint("photo picker  prepareThumbnail error")
                                                            showFullSizeUIImageAlert = true
                                                        }
                                                    } catch let error {
                                                        debugPrint("photo picker", error.localizedDescription)
                                                        showFullSizeUIImageAlert = true
                                                    }
                                                }
                                            }
                                        Spacer()
                                    }
                                    .padding(.bottom,4)
                                    .frame( alignment: .center)
                                    .alert("Unable To Load Image", isPresented: $showFullSizeUIImageAlert) {
                                    } message: {
                                        Text("That image could not be loaded from the library. Possibly it is not downloaded from iCloud")
                                    }
                                    if let selectedImageData,
                                       let uiImage = UIImage(data: selectedImageData) {
                                        Button(action: {
                                            if let imagedata = stageEditableData.imageDataFullActual,
                                               let uiImage = UIImage(data: imagedata) {
                                                fullSizeUIImage = uiImage
                                                showFullSizeUIImage = true
                                            }
                                        }, label: {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxWidth: kImageColumnWidth, maxHeight: kImageColumnWidth, alignment: .center)
                                            //.fixedSize(horizontal: true, vertical: false)
                                                .padding(0)
                                        })
                                        .buttonStyle(.borderless)
                                    }  else {
                                        Text("Tap \(Image(systemName:"photo.on.rectangle.angled")) to add image")
                                            .font(.system(.footnote, design: .rounded, weight: .regular))
                                            .frame(alignment: .center)
                                            .padding(0)
                                            .opacity(0.5)
                                            .italic()
                                    }
                                }
                                
                                Text("Title")
                                    .font(.system(.headline, design: .rounded, weight: .semibold).lowercaseSmallCaps())
                                    .padding(.top, 24)
                                    .padding(.bottom, kTitleBottomPadding)
                                TextField("Stage title", text: $stageEditableData.title,  axis: .vertical)
                                    .lineLimit(nil)
                                    .frame(maxWidth: .infinity)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                
                                Text("Details")
                                    .font(.system(.headline, design: .rounded, weight: .semibold).lowercaseSmallCaps())
                                    .padding(.top, 24)
                                    .padding(.bottom, kTitleBottomPadding)
                                TextField("Details", text: $stageEditableData.details,  axis: .vertical)
                                    .lineLimit(nil)
                                //.frame(maxWidth: .infinity)
                                //.fixedSize(horizontal: false, vertical: true)
                                
                                
                                Text("\(Image(systemName: "bubble.left")) Comment")
                                    .font(.system(.headline, design: .rounded, weight: .semibold).lowercaseSmallCaps())
                                    .padding(.top, 24)
                                    .padding(.bottom, kTitleBottomPadding)
                                ZStack {
                                    Toggle(isOn: $untimedComment) {
                                        Text("Is Comment")
                                            .foregroundColor(textColourForScheme(colorScheme: colorScheme))
                                    }
                                    .padding(6.0)
                                }
                                .padding([.leading, .trailing], 32)
                                .background(Color("ColourControlBackground"))
                                .cornerRadius(6.0)
                                
                            } /* end VStack Left */
                            
                            // ****  RIGHT COLUMN **** //
                            if untimedComment == false && showRightColumn == true {
                                VStack(alignment: .leading, spacing: 0.0) {/* VStack right side */
                                    /* Duration Pickers */
                                    Text("\(Image(systemName: timerDirection.symbolName)) Duration")
                                        .font(.system(.headline, design: .rounded, weight: .semibold).lowercaseSmallCaps())
                                    VStack(alignment: .leading, spacing: 0.0) {
                                        VStack(spacing: 0.0) {
                                            /* Duration Pickers */
                                            Picker("", selection: $timerDirection) {
                                                ForEach(TimerDirection.allCases) { direction in
                                                    Text(direction.rawValue)
                                                        .font(.system(.caption, design: .rounded, weight: .regular).lowercaseSmallCaps())
                                                }
                                            }
                                            .padding([.leading, .trailing], 4)
                                            .padding([.bottom,.top], 8)
                                            .pickerStyle(.segmented)
                                            .labelsHidden()
                                            if timerDirection == .countDownEnd {
                                                ZStack(alignment: .top) {
                                                    HStack {
                                                        Group {
                                                            Text("Hours")
                                                            Text("Minutes")
                                                            Text("Seconds")
                                                        }
                                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                                        .lineLimit(1)
                                                        .font(.system(.caption, design: .rounded, weight: .regular).lowercaseSmallCaps())
                                                        .padding(0)
                                                        .background(Color("ColourControlBackground"))
                                                    }
                                                    .padding(0)
                                                    HStack {
                                                        Group {
                                                            Picker("", selection: $hours) {
                                                                ForEach(0..<24) {index in
                                                                    Text("\(index)").tag(index)
                                                                }
                                                            }
                                                            .labelsHidden()
                                                            Picker("", selection: $mins) {
                                                                ForEach(0..<60) {index in
                                                                    Text("\(index)").tag(index)
                                                                }
                                                            }
                                                            .labelsHidden()
                                                            Picker("", selection: $secs) {
                                                                ForEach(0..<60) {index in
                                                                    Text("\(index)").tag(index)
                                                                }
                                                            }
                                                        }
                                                        .pickerStyle(.wheel)
                                                        .padding(0)
                                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                                    }
                                                } /* ZStack */
                                                .frame(maxHeight: 130)
                                                .padding([.leading, .trailing], 18)
                                            } /* if timerDirection == .countDown {VStack}*/
                                            if timerDirection == .countDownToDate {
                                                VStack(alignment: .center){
                                                    TextInvalidDate(date: durationDate)
                                                        .font(.system(.subheadline, design: .rounded, weight: .regular))
                                                    DatePicker(
                                                        "End On:",
                                                        selection: $durationDate,
                                                        in: validFutureDate()...,
                                                        displayedComponents: [.date, .hourAndMinute]
                                                    )
                                                    .labelsHidden()
                                                }
                                                .frame(maxWidth: .infinity,alignment: .center)
                                                .padding([.bottom], 8)
                                            }
                                        }
                                        .background(Color("ColourControlBackground"))
                                        .cornerRadius(6.0)
                                    }
                                    /* Duration Pickers */
                                    
                                    Text("\(Image(systemName: "zzz")) Snooze Interval")
                                        .font(.system(.headline, design: .rounded, weight: .semibold).lowercaseSmallCaps())
                                        .padding(.top, 24)
                                        .padding(.bottom, kTitleBottomPadding)
                                    ZStack(alignment: .top) {
                                        HStack {
                                            Group {
                                                Text("Hours")
                                                Text("Minutes")
                                            }
                                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                            .lineLimit(1)
                                            .font(.system(.caption, design: .rounded, weight: .regular).lowercaseSmallCaps())
                                            .padding(0)
                                        }
                                        .padding(.top,8)
                                        .padding([.leading, .trailing], 18)
                                        HStack {
                                            Group {
                                                Picker("", selection: $snoozehours) {
                                                    ForEach(0..<24) {index in
                                                        Text("\(index)").tag(index)
                                                    }
                                                }
                                                .labelsHidden()
                                                .padding(0)
                                                Picker("", selection: $snoozemins) {
                                                    ForEach(0..<60) {index in
                                                        Text("\(index)").tag(index)
                                                    }
                                                }
                                                .labelsHidden()
                                                .padding(0)
                                            }
                                            .pickerStyle(.wheel)
                                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                            .padding(0)
                                        }
                                        .padding(0)
                                        .padding([.leading, .trailing], 30.0)
                                    } /* VStack */
                                    .frame(maxHeight: 130)
                                    .padding(0)
                                    .background(Color("ColourControlBackground"))
                                    .cornerRadius(6.0)
                                    
                                    
                                    Text("\(Image(systemName: "bell.and.waves.left.and.right")) Repeating Notifications")
                                        .font(.system(.headline, design: .rounded, weight: .semibold).lowercaseSmallCaps())
                                        .padding(.top, 24)
                                        .padding(.bottom, kTitleBottomPadding)
                                    ZStack {
                                        Toggle(isOn: $snoozeAlertsOn) {
                                            Text("At Snooze Intervals")
                                                .foregroundColor(textColourForScheme(colorScheme: colorScheme))
                                        }
                                        .padding(6)
                                    }
                                    .padding([.leading, .trailing], 32)
                                    .background(Color("ColourControlBackground"))
                                    .cornerRadius(6.0)
                                    
                                    HStack {
                                        Text("\(Image(systemName: "alarm.waves.left.and.right")) Timed Notifications")
                                            .font(.system(.headline, design: .rounded, weight: .semibold).lowercaseSmallCaps())
                                        Spacer()
                                        Button {
                                            addedhours = 0
                                            addedmins = 0
                                            addedsecs = 0
                                            addedMessage = ""
                                            showingAddAlertSheet = true
                                        } label: {
                                            Image(systemName: "plus")
                                        }
                                        .padding(0)
                                        .buttonStyle(.bordered)
                                        .controlSize(.small)
                                    }
                                    .padding(.top, 24)
                                    .padding(.bottom, kTitleBottomPadding)
                                    if !additionaldurationsDictKeys.isEmpty {
                                        ZStack {
                                            VStack {
                                                ScrollView(.vertical) {
                                                    ForEach(additionaldurationsDictKeys, id: \.self) { secsInt in
                                                        if let message = stageEditableData.additionalDurationsDict[secsInt] {
                                                            HStack {
                                                                Text(Stage.stageFormattedDurationStringFromDouble(Double(secsInt)))
                                                                    .foregroundColor(Color("ColourAdditionalAlarmsText"))
                                                                Spacer()
                                                                Text(message)
                                                                    .foregroundColor(Color("ColourAdditionalAlarmsMessage"))
                                                                    .multilineTextAlignment(.trailing)
                                                                Button {
                                                                    DispatchQueue.main.async {
                                                                        stageEditableData.additionalDurationsDict[secsInt] = nil
                                                                        rebuidAdditionalDurationsDictKeys()
                                                                    }
                                                                } label: {
                                                                    Image(systemName:"trash")
                                                                        .font(.system(.title3, design: .rounded, weight: .regular))
                                                                }
                                                                .tint(.red)
                                                                .padding(.leading, 12)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            .padding([.leading, .trailing], 48)
                                            .padding([.top,.bottom], 8)
                                        }
                                        .background(Color("ColourControlBackground"))
                                        .cornerRadius(6.0)
                                        .padding(0)
                                    } else {
                                        Text("Tap + to add")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .multilineTextAlignment(.center)
                                            .padding(0)
                                            .opacity(0.5)
                                            .italic()
                                            .padding([.top,.bottom], 8)
                                            .background(Color("ColourControlBackground"))
                                            .cornerRadius(6.0)
                                        
                                    }
                                    
                                } /* VStack Right */
                            } /* if untimedComment */
                            
                        } /* GridRow */
                        .textFieldStyle(.roundedBorder)
                    } /* Grid */
                    .padding(24)
                    
                    HStack { // buttons
                        //Text(stageEditableData.idStr)
                        Text(itineraryEditableData?.indexStringOfStageUUID(stageEditableData.id) ?? "No index")
                            .padding()
                            .font(.system(.title2, design: .rounded, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Button {
                            showConfirmDeleteStage = true
                        } label: {
                            Image(systemName:"trash")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(.red)
                        .frame(width: 24)
                        .confirmationDialog("Delete this stage?", isPresented: $showConfirmDeleteStage, titleVisibility: .visible) {
                            Button("Cancel", role: .cancel) {
                                showConfirmDeleteStage = false
                            }
                            Button("Delete", role: .destructive) {
                                DispatchQueue.main.async {
                                    stageUUIDToDelete = nil
                                    stageUUIDToDelete = stageEditableData.id
                                }
                                showConfirmDeleteStage = false
                            }
                            
                        } message: {
                            Text("This cannot be undone")
                                .foregroundColor(.red)
                        }
                        Spacer().frame(maxWidth: 48)
                        Button(action: {
                            newStageMeta = nil
                            newStageMeta = NewStageMeta(stageInitiatingIDstr: stageEditableData.idStr, duplicate: true, newStage: stageEditableData.duplicateWithNewID)
                        }) {
                            Image(systemName: "doc.on.doc")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .buttonStyle(.borderless)
                        .frame(width: 24)
                        .padding([.top,.bottom], kiOSStageViewsRowPad)
                        Spacer().frame(maxWidth: 48)
                        Button(action: {
                            DispatchQueue.main.async {
                                newStageMeta = nil
                                newStageMeta = NewStageMeta(stageInitiatingIDstr: stageEditableData.idStr, duplicate: true, newStage: Stage())
                            }
                        }) {
                            Image(systemName: "plus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .buttonStyle(.borderless)
                        .frame(width: 24)
                        .padding([.top,.bottom], kiOSStageViewsRowPad)
                        Spacer()
                        
                        
                        
                    } /* HStack buttons */
                    .foregroundColor( .accentColor)
                    .background(Color("ColourControlsBackground"))
                    .padding(0)
                } /* contents shown when collapse = false */
            } /* VStack */
            .onChange(of: untimedComment, perform: { newValue in
                stageEditableData.isCommentOnly = newValue
            })
            .onChange(of: timerDirection, perform: { newValue in
                stageEditableData.durationCountType = newValue.stageNotificationIntervalType
                updateDuration()
            })
            .onChange(of: snoozeAlertsOn, perform: { newValue in
                stageEditableData.isPostingRepeatingSnoozeAlerts = newValue
            })
            .onChange(of: hours, perform: {hrs in
                updateDuration()
            })
            .onChange(of: mins, perform: {hrs in
                updateDuration()
            })
            .onChange(of: secs, perform: {hrs in
                updateDuration()
            })
            .onChange(of: durationDate, perform: {date in
                updateDuration()
            })
            .onChange(of: snoozehours, perform: {hrs in
                updateSnoozeDuration()
            })
            .onChange(of: snoozemins, perform: {hrs in
                updateSnoozeDuration()
            })
            .onAppear() {
                rebuidAdditionalDurationsDictKeys()
                //additionaldurationsDictKeys = stageEditableData.additionalDurationsDict.map({ $0.key }).sorted()
                untimedComment = stageEditableData.isCommentOnly
                if untimedComment == true {
                    // leave the defaults
                } else {
                    timerDirection = stageEditableData.durationCountType.timerDirection
                    snoozeAlertsOn = stageEditableData.isPostingRepeatingSnoozeAlerts
                    if stageEditableData.isCountDown {
                        hours = stageEditableData.durationSecsInt / SEC_HOUR
                        mins = ((stageEditableData.durationSecsInt % SEC_HOUR) / SEC_MIN)
                        secs = stageEditableData.durationSecsInt % SEC_MIN
                    }
                    if stageEditableData.isCountDownToDate {
                        durationDate = max(stageEditableData.durationAsDate,validFutureDate())
                    }
                }
                snoozehours = stageEditableData.snoozeDurationSecs / SEC_HOUR
                snoozemins = (stageEditableData.snoozeDurationSecs % SEC_HOUR) / SEC_MIN
                selectedImageData = stageEditableData.imageDataThumbnailActual
            }
            .onDisappear() {
                // !! Called AFTER the StageDisplayView Save button action
                // pointless to change EditableData
            }
            .fullScreenCover(isPresented: $showFullSizeUIImage, content: {
                FullScreenImageView(fullSizeUIImage: $fullSizeUIImage, showFullSizeUIImage: $showFullSizeUIImage)
            }) /* fullScreenCover */
            .sheet(isPresented: $showingAddAlertSheet) {
                NavigationStack {
                    Form {
                        Section("Time Of Notification") {
                            VStack(spacing:0.0) {
                                HStack {
                                    Group {
                                        Text("Hours")
                                        Text("Minutes")
                                        Text("Seconds")
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                    .font(.system(.caption, design: .rounded, weight: .regular).lowercaseSmallCaps())
                                }
                                HStack {
                                    Group {
                                        Picker("", selection: $addedhours) {
                                            ForEach(0..<24) {index in
                                                Text("\(index)").tag(index)
                                            }
                                        }
                                        .labelsHidden()
                                        Picker("", selection: $addedmins) {
                                            ForEach(0..<60) {index in
                                                Text("\(index)").tag(index)
                                            }
                                        }
                                        .labelsHidden()
                                        Picker("", selection: $addedsecs) {
                                            ForEach(0..<60) {index in
                                                Text("\(index)").tag(index)
                                            }
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .labelsHidden()
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                }
                            }
                        }
                        Section("Notification Message") {
                            TextField("Enter Message", text: $addedMessage)
                        }
                    } /* VStack */
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingAddAlertSheet = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                let duration = durationFromAdditionalHMS()
                                if duration >= kStageAlertMinimumDurationSecs {
                                    // amend the dict oustide the additionaldurationsDictKeys.append or crash
                                    stageEditableData.additionalDurationsDict[duration] = addedMessage
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        rebuidAdditionalDurationsDictKeys()
                                        //                                        // duplicate key amended the Dict but not added to array.
                                        //                                        if !additionaldurationsDictKeys.contains(duration) {
                                        //                                            additionaldurationsDictKeys.append(duration)
                                        //                                            additionaldurationsDictKeys.sort()
                                        //                                        }
                                    }
                                }
                                showingAddAlertSheet = false
                            }
                        }
                    }
                }
            } /* sheet */
        }
    } /* body */
    
    
    
    
} /* extension */
