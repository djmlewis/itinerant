//
//  StageRowEditView.swift
//  itinerant
//
//  Created by David JM Lewis on 04/01/2023.
//

import SwiftUI
import PhotosUI
import PhotosUI


extension StageEditCommonView {
    
    var body_slow: some View {
        Form {
            Section { } header: {
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
                                .frame(idealWidth: kImageColumnWidth, alignment: .center)
                                .fixedSize(horizontal: true, vertical: false)
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
            }
            .textCase(nil)
            Section {
                TextField("Stage title", text: $stageEditableData.title,  axis: .vertical)
            } header: {
                Text("Title")
                    .font(.system(.headline, design: .rounded, weight: .semibold).lowercaseSmallCaps())
            } /* Section */
            .textCase(nil)
            Section {
                TextField("Details", text: $stageEditableData.details,  axis: .vertical)
            } header: {
                Text("Details")
                    .font(.system(.headline, design: .rounded, weight: .semibold).lowercaseSmallCaps())
            }
            .textCase(nil)
            Section {
                Toggle(isOn: $untimedComment) {
                    Text("Display Only As Comment")
                        .foregroundColor(textColourForScheme(colorScheme: colorScheme))
                }
            } header: {
                Text("\(Image(systemName: "bubble.left")) Comment")
                    .font(.system(.headline, design: .rounded, weight: .semibold).lowercaseSmallCaps())
            }
            .textCase(nil)
            if untimedComment != true {
                Section {
                    /* Duration Pickers */
                    HStack {
                        Picker("", selection: $timerDirection) {
                            ForEach(TimerDirection.allCases) { direction in
                                Text(direction.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                    }
                    if timerDirection == .countDownEnd {
                        VStack(spacing: 2) {
                            HStack {
                                Group {
                                    Text("Hours")
                                    Text("Minutes")
                                    Text("Seconds")
                                }
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            }
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
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            }
                        } /* VStack */
                    } /* if timerDirection == .countDown {VStack}*/
                    if timerDirection == .countDownToDate {
                        HStack(alignment: .center){
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
                    }
                    /* Duration Pickers */
                } header: {
                    Text("\(Image(systemName: timerDirection.symbolName)) Duration")
                        .font(.system(.headline, design: .rounded, weight: .semibold).lowercaseSmallCaps())
                } /* Section */
                .textCase(nil)
                Section {
                    VStack(spacing:0) {
                        HStack {
                            Group {
                                Text("Hours")
                                Text("Minutes")
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            .padding(0)
                        }
                        .padding(0)
                        HStack {
                            Group {
                                Picker("", selection: $snoozehours) {
                                    ForEach(0..<24) {index in
                                        Text("\(index)").tag(index)
                                        //.foregroundColor(.black)
                                            .fontWeight(.heavy)
                                    }
                                }
                                .labelsHidden()
                                .padding(0)
                                Picker("", selection: $snoozemins) {
                                    ForEach(0..<60) {index in
                                        Text("\(index)").tag(index)
                                        //.foregroundColor(.black)
                                            .fontWeight(.heavy)
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
                    } /* VStack */
                    .padding(0)
                } header: {
                    Text("\(Image(systemName: "zzz")) Snooze Interval")
                        .font(.system(.headline, design: .rounded, weight: .semibold).lowercaseSmallCaps())
                } /* Section */
                .textCase(nil)
                Section {
                    Toggle(isOn: $snoozeAlertsOn) {
                        HStack {
                            VStack {
                                Image(systemName: "bell.and.waves.left.and.right")
                            }
                            VStack {
                                Text("Show Repeating Notifications At Snooze Intervals")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .foregroundColor(textColourForScheme(colorScheme: colorScheme))
                    }
                } header: {
                    Text("\(Image(systemName: "bell.and.waves.left.and.right")) Repeating Notifications")
                        .font(.system(.headline, design: .rounded, weight: .semibold).lowercaseSmallCaps())
                }
                .textCase(nil)
                Section {
                    if !additionaldurationsDictKeys.isEmpty {
                        List {
                            ForEach(additionaldurationsDictKeys, id: \.self) { secsInt in
                                HStack {
                                    Text(Stage.stageFormattedDurationStringFromDouble(Double(secsInt)))
                                        .foregroundColor(Color("ColourAdditionalAlarmsText"))
                                    Spacer()
                                    Text(stageEditableData.additionalDurationsDict[secsInt]!)
                                        .foregroundColor(Color("ColourAdditionalAlarmsMessage"))
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                            .onDelete { offsets in
                                DispatchQueue.main.async {
                                    offsets.forEach { indx in
                                        stageEditableData.additionalDurationsDict[additionaldurationsDictKeys[indx]] = nil
                                    }
                                    additionaldurationsDictKeys.remove(atOffsets: offsets)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(0)
                    } else {
                        Text("Tap + to add")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .padding(0)
                            .opacity(0.5)
                            .italic()
                        
                    }
                } header: {
                    HStack {
                        Text("\(Image(systemName: "alarm.waves.left.and.right")) Timed Notifications")
                            .padding(0)
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
                } /* Section */
                .textCase(nil)
                //} /* if !stageEditableData.durationsArray.isEmpty */
            } /* untimedComment != true {Section} */
        } /* Form */
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
            //additionaldurationsDict = stageEditableData.additionalDurationsDict
            additionaldurationsDictKeys = stageEditableData.additionalDurationsDict.map({ $0.key }).sorted()
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
                        HStack {
                            Group {
                                Text("Hours")
                                Text("Minutes")
                                Text("Seconds")
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
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
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
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
                                DispatchQueue.main.async {
                                    // duplicate key amended the Dict but not added to array.
                                    if !additionaldurationsDictKeys.contains(duration) {
                                        additionaldurationsDictKeys.append(duration)
                                        additionaldurationsDictKeys.sort()
                                    }
                                }
                            }
                            showingAddAlertSheet = false
                        }
                    }
                }
            }
        } /* sheet */
        
    }
    
    
}

