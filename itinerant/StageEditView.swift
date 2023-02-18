//
//  StageRowEditView.swift
//  itinerant
//
//  Created by David JM Lewis on 04/01/2023.
//

import SwiftUI

enum TimerDirection: String, CaseIterable, Identifiable {
    case countDown = "Count Down", countUp = "Count Up"
    var id: Self { self }
}

struct StageEditView: View {

    @Binding var stageEditableData: Stage.EditableData
    
    @State private var untimedComment: Bool =  false
    @State private var snoozeAlertsOn: Bool =  false
    
    @State private var hours: Int = 0
    @State private var mins: Int = 0
    @State private var secs: Int = 0
    @State private var timerDirection: TimerDirection = .countDown
    
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
                        Image(systemName: "timer")
                            .opacity(timerDirection == .countDown ? 1.0 : 0.0)
                        Picker("", selection: $timerDirection) {
                            ForEach(TimerDirection.allCases) { direction in
                                Text(direction.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        Image(systemName: "stopwatch")
                            .opacity(timerDirection == .countUp ? 1.0 : 0.0)
                    }
                    if timerDirection == .countDown {
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
                    Toggle(isOn: $snoozeAlertsOn) {
                        HStack {
                            VStack {
                                Image(systemName: "bell.and.waves.left.and.right")
                            }
                            VStack {
                                Text("Repeating Notifications At Snooze Intervals")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                            .foregroundColor(textColourForScheme(colorScheme: colorScheme))
                    }
                } /* Section */
                Section {
                    if !additionaldurationsarray.isEmpty {
                        List {
                            ForEach(additionaldurationsarray, id: \.self) { secsInt in
                                Text(Stage.stageDurationStringFromDouble(Double(secsInt)))
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
                        Text("\(Image(systemName: "alarm.waves.left.and.right")) Additional Notifications")
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
            stageEditableData.isCountUp = $0 == .countUp
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
                timerDirection = stageEditableData.isCountUp ? .countUp : .countDown
                snoozeAlertsOn = stageEditableData.isPostingRepeatingSnoozeAlerts
                hours = stageEditableData.durationSecsInt / SEC_HOUR
                mins = ((stageEditableData.durationSecsInt % SEC_HOUR) / SEC_MIN)
                secs = stageEditableData.durationSecsInt % SEC_MIN
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
        stageEditableData.durationSecsInt = durationFromHMS()
        if changeDirection == true { timerDirection = stageEditableData.isCountUp ? .countUp : .countDown }
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
        StageEditView(stageEditableData: .constant(Stage.EditableData()))
    }
}
