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
                                                .foregroundColor(.black)
                                                .fontWeight(.heavy)
                                        }
                                    }
                                    .labelsHidden()
                                    Picker("", selection: $mins) {
                                        ForEach(0..<60) {index in
                                            Text("\(index)").tag(index)
                                                .foregroundColor(.black)
                                                .fontWeight(.heavy)
                                        }
                                    }
                                    .labelsHidden()
                                    Picker("", selection: $secs) {
                                        ForEach(0..<60) {index in
                                            Text("\(index)").tag(index)
                                                .foregroundColor(.black)
                                                .fontWeight(.heavy)
                                        }
                                    }
                                    .labelsHidden()
                                }
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            }
                        } /* VStack */
                    } /* if timerDirection == .countDown {VStack}*/
                    Toggle(isOn: $snoozeAlertsOn) {
                        Label("Alert at Snooze Intervals", systemImage:"bell.and.waves.left.and.right")
                            .foregroundColor(textColourForScheme(colorScheme: colorScheme))
                    }
                } /* Section */
            } /* untimedComment != true {Section} */
            if untimedComment != true {
                Section("Time Interval Between Snooze Alerts") {
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
            }
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
    }
    
    
}

extension StageEditView {
    
    func updateDuration(andDirection changeDirection: Bool) -> Void {
        stageEditableData.durationSecsInt = Int(hours) * SEC_HOUR + Int(mins) * SEC_MIN + Int(secs)
        if changeDirection == true { timerDirection = stageEditableData.isCountUp ? .countUp : .countDown }
    }
    
    func updateSnoozeDuration() {
        var newValue = Int(snoozehours) * SEC_HOUR + Int(snoozemins) * SEC_MIN
        if newValue < kSnoozeDurationSecsMin {
            newValue = kSnoozeDurationSecsMin
        }
        stageEditableData.snoozeDurationSecs = newValue
    }
    
    
}

struct StageRowEditView_Previews: PreviewProvider {
    static var previews: some View {
        StageEditView(stageEditableData: .constant(Stage.EditableData()))
    }
}
