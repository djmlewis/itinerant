//
//  StageRowEditView.swift
//  itinerant
//
//  Created by David JM Lewis on 04/01/2023.
//

import SwiftUI
import PhotosUI


struct StageEditView: View {
    @Binding var stageEditableData: Stage
    
    @State private var untimedComment: Bool =  false
    @State private var snoozeAlertsOn: Bool =  false
    
    @State private var hours: Int = 0
    @State private var mins: Int = 0
    @State private var secs: Int = 0
    @State private var timerDirection: TimerDirection = .countDownEnd
    @State private var durationDate: Date = validFutureDate()

    @State private var snoozehours: Int = 0
    @State private var snoozemins: Int = 0

    @Environment(\.colorScheme) var colorScheme

    @State private var additionaldurationsarray = [Int]()
    @State private var showingAddAlertSheet = false
    @State private var addedhours: Int = 0
    @State private var addedmins: Int = 0
    @State private var addedsecs: Int = 0
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State var fullSizeUIImage: UIImage?
    @State var showFullSizeUIImage: Bool = false

    
    var body: some View {
        Form {
            Section(content: {}, header: {
                VStack(alignment: .leading) {
                    HStack {
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
                        Spacer()
                        Text("Image")
                            .font(.system(.title3, design: .rounded, weight: .regular))
                        Spacer()
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
                                    // Retrieve selected asset in the form of Data
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        // make a thumbnail
                                        if let uiImage = UIImage(data: data) {
                                            uiImage.prepareThumbnail(of: CGSize(width: kImageColumnWidth, height:uiImage.size.height * (kImageColumnWidth/uiImage.size.width))) { thumbnailImage in
                                                let thumbnaildata = thumbnailImage?.pngData()
                                                DispatchQueue.main.async {
                                                    selectedImageData = thumbnaildata
                                                    stageEditableData.imageDataFullActual = data
                                                    stageEditableData.imageDataThumbnailActual = thumbnaildata
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                    }
                    .frame(maxWidth: kImageColumnWidth, alignment: .leading)
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
                                .frame(idealWidth: kImageColumnWidth, alignment: .leading)
                                .fixedSize(horizontal: true, vertical: false)
                                .padding(0)
                        })
                        .buttonStyle(.borderless)
                    }
                }
            })
            Section {
                TextField("Stage title", text: $stageEditableData.title,  axis: .vertical)
            } header: {
                Text("Title")
                    .font(.system(.title3, design: .rounded, weight: .regular))
            } /* Section */
            Section {
                TextField("Details", text: $stageEditableData.details,  axis: .vertical)
            } header: {
                Text("Details")
                    .font(.system(.title3, design: .rounded, weight: .regular))
            }
            Section {
                Toggle(isOn: $untimedComment) {
                    Text("Display Only As Comment")
                        .foregroundColor(textColourForScheme(colorScheme: colorScheme))
                }
            } header: {
                Text("\(Image(systemName: "bubble.left")) Comment")
                    .font(.system(.title3, design: .rounded, weight: .regular))
            }
            if untimedComment != true {
                Section {
                    /* Duration Pickers */
                    HStack {
                        //                            Image(systemName: timerDirection.symbolName)
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
                        .font(.system(.title3, design: .rounded, weight: .regular))
                } /* Section */
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
                        .font(.system(.title3, design: .rounded, weight: .regular))
                } /* Section */
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
                        .font(.system(.title3, design: .rounded, weight: .regular))
                }
                Section {
                    if !additionaldurationsarray.isEmpty {
                        List {
                            ForEach(additionaldurationsarray, id: \.self) { secsInt in
                                Text(Stage.stageFormattedDurationStringFromDouble(Double(secsInt)))
                            }
                            .onDelete {
                                additionaldurationsarray.remove(atOffsets: $0)
                                stageEditableData.additionalDurationsArray = additionaldurationsarray
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(0)
                    } else {
                        Text("Tap + to add")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(0)
                            .opacity(0.5)
                            .italic()
                        
                    }
                } header: {
                    HStack {
                        Text("\(Image(systemName: "alarm.waves.left.and.right")) Timed Notifications")
                            .padding(0)
                            .font(.system(.title3, design: .rounded, weight: .regular))
                        Spacer()
                        Button {
                            addedhours = 0
                            addedmins = 0
                            addedsecs = 0
                            showingAddAlertSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .padding(0)
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                } /* Section */
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
            additionaldurationsarray = stageEditableData.additionalDurationsArray
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
                VStack {
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
                    Spacer()
                } /* VStack */
                .navigationTitle("Additional Alert Time")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingAddAlertSheet = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            let duration = durationFromAdditionalHMS()
                            if !additionaldurationsarray.contains(duration) && duration >= kStageAlertMinimumDurationSecs {
                                DispatchQueue.main.async {
                                    additionaldurationsarray.append(duration)
                                    additionaldurationsarray.sort()
                                    stageEditableData.additionalDurationsArray = additionaldurationsarray
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

extension StageEditView {
    
    
    func durationFromHMS() -> Int {
        Int(hours) * SEC_HOUR + Int(mins) * SEC_MIN + Int(secs)
    }
    func durationFromAdditionalHMS() -> Int {
        Int(addedhours) * SEC_HOUR + Int(addedmins) * SEC_MIN + Int(addedsecs)
    }

    func updateDuration() {
        switch stageEditableData.durationCountType {
        case .countDownEnd:
            stageEditableData.durationSecsInt = durationFromHMS()
        case .countDownToDate:
            stageEditableData.setDurationFromDate(durationDate)//durationSecsInt = Int(dateYMDHM(fromDate: durationDate).timeIntervalSinceReferenceDate)
        default:
            stageEditableData.durationSecsInt = 0
        }
    }
    
    func updateSnoozeDuration() {
        var newValue = Int(snoozehours) * SEC_HOUR + Int(snoozemins) * SEC_MIN
        if newValue < kSnoozeMinimumDurationSecs {
            newValue = kSnoozeMinimumDurationSecs
        }
        stageEditableData.snoozeDurationSecs = newValue
    }
    
    
}



struct StageRowEditView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
    }
}
