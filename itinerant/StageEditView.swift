//
//  StageRowEditView.swift
//  itinerant
//
//  Created by David JM Lewis on 04/01/2023.
//

import SwiftUI


struct StageEditView: View {

    @Binding var stageEditableData: Stage
    
    @State private var untimedComment: Bool =  false
    @State private var snoozeAlertsOn: Bool =  false
    
    @State private var hours: Int = 0
    @State private var mins: Int = 0
    @State private var secs: Int = 0
    @State private var timerDirection: TimerDirection = .countDownEnd
    @State private var durationDate: Date = Date.now

    @State private var snoozehours: Int = 0
    @State private var snoozemins: Int = 0

    @Environment(\.colorScheme) var colorScheme

    @State private var additionaldurationsarray = [Int]()
    @State private var showingAddAlertSheet = false
    @State private var addedhours: Int = 0
    @State private var addedmins: Int = 0
    @State private var addedsecs: Int = 0

    //@FocusState private var focusedFieldTag: FieldFocusTag?
    
    
    var body: some View {
        Form {
            Section("Title") {
                TextField("Stage title", text: $stageEditableData.title)
            }
            Section("Details") {
                TextField("Details", text: $stageEditableData.details,  axis: .vertical)
            }
            Toggle(isOn: $untimedComment) {
                Label("Comment only", systemImage:"bubble.left")
                    .foregroundColor(textColourForScheme(colorScheme: colorScheme))
            }
            if untimedComment != true {
                Section("Duration") {
                        /* Duration Pickers */
                        HStack {
                            Image(systemName: timerDirection.symbolName)
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
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                }
                            } /* VStack */
                        } /* if timerDirection == .countDown {VStack}*/
                        if timerDirection == .countDownToDate {
                            Group{
                                DatePicker(
                                    "End On:",
                                    selection: $durationDate,
                                    in: validFutureDate()...,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                Text("The end time must be at least 1 minute in the future when the stage starts")
                                    .font(.system(.subheadline, design: .rounded, weight: .regular))
                                    .multilineTextAlignment(.center)
                                    .opacity(0.5)
                            }
                        }
                        /* Duration Pickers */
                } /* Section */

                Section("\(Image(systemName: "bell.and.waves.left.and.right")) Snooze Notifications Interval") {
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
                                            .foregroundColor(.black)
                                            .fontWeight(.heavy)
                                    }
                                }
                                .labelsHidden()
                                .padding(0)
                                Picker("", selection: $snoozemins) {
                                    ForEach(0..<60) {index in
                                        Text("\(index)").tag(index)
                                            .foregroundColor(.black)
                                            .fontWeight(.heavy)
                                    }
                                }
                                .labelsHidden()
                                .padding(0)
                           }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            .padding(0)
                        }
                        .padding(0)
                    } /* VStack */
                    .padding(0)
                } /* Section */
                Section("\(Image(systemName: "bell.and.waves.left.and.right")) Repeating Notifications") {
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
                }
                /* Section */
            //} /* if !stageEditableData.durationsArray.isEmpty */
            } /* untimedComment != true {Section} */
        }
        .onChange(of: untimedComment, perform: {
            stageEditableData.isCommentOnly = $0
        })
        .onChange(of: timerDirection, perform: {
            stageEditableData.durationCountType = $0.stageNotificationIntervalType
            //debugPrint("onChange(of: timerDirection", $0, $0.stageNotificationIntervalType, stageEditableData.durationCountType, stageEditableData.flags)
            updateDuration(andDirection: false)
        })
        .onChange(of: snoozeAlertsOn, perform: {
            stageEditableData.isPostingRepeatingSnoozeAlerts = $0
        })
        .onChange(of: hours, perform: {hrs in
            updateDuration(andDirection: true)
        })
        .onChange(of: mins, perform: {hrs in
            updateDuration(andDirection: true)
        })
        .onChange(of: secs, perform: {hrs in
            updateDuration(andDirection: true)
        })
        .onChange(of: durationDate, perform: {date in
            updateDuration(andDirection: true)
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
            
        }
        .onDisappear() {
            // !! Called AFTER the StageDisplayView Save button action
            // pointless to change EditableData
        }
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
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    }
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

    func updateDuration(andDirection changeDirection: Bool) -> Void {
        switch stageEditableData.durationCountType {
        case .countDownEnd:
            stageEditableData.durationSecsInt = durationFromHMS()
        case .countDownToDate:
            stageEditableData.durationSecsInt = Int(dateYMDHM(fromDate: durationDate).timeIntervalSinceReferenceDate)
        default:
            stageEditableData.durationSecsInt = 0
        }
        //if changeDirection == true { timerDirection = stageEditableData.isCountUp ? .countUp : .countDownEnd }
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
