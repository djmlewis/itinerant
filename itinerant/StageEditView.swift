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
    @State private var snoozeAlertDuringCountUp: Bool =  false

    @State private var hours: Int = 0
    @State private var mins: Int = 0
    @State private var secs: Int = 0
    @State private var timerDirection: TimerDirection = .countDown

    @State private var snoozehours: Int = 0
    @State private var snoozemins: Int = 0
//    @State private var snoozesecs: Int = 0

    
    //@FocusState private var focusedFieldTag: FieldFocusTag?
    
    
    var body: some View {
        Form {
            Toggle(isOn: $untimedComment) {
                Label("Comment only", systemImage:"bubble.left")
            }
            Section(header: Text(untimedComment == true ? "Comment" : "Title")) {
                TextField("Stage title", text: $stageEditableData.title)
            }
            if untimedComment != true {
                Section(header: Text("Details")) {
                    TextField("Details", text: $stageEditableData.details,  axis: .vertical)
                        .lineLimit(1...10)
                }
            }/* Section */
            if untimedComment != true {
                Section(header: Text("Stage Duration")) {
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
                                    //.fontWeight(.heavy)
                                    Text("Minutes")
                                    //.fontWeight(.heavy)
                                    Text("Seconds")
                                    //.fontWeight(.heavy)
                                }
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
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
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                    }
                    else {
                        Toggle(isOn: $snoozeAlertDuringCountUp) {
                            Label("Alert at Snooze intervals", systemImage:"bell")
                        }
                    }
                }
            } /* Section */
            if untimedComment != true {
                Section(header: Text("Time Interval Between Snooze Alerts")) {
                    VStack(spacing: 2) {
                        HStack {
                            Group {
                                Text("Hours")
                                //.fontWeight(.heavy)
                                Text("Minutes")
                                //.fontWeight(.heavy)
//                                Text("Seconds")
                                //.fontWeight(.heavy)
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                        }
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
                                Picker("", selection: $snoozemins) {
                                    ForEach(0..<60) {index in
                                        Text("\(index)").tag(index)
                                            .foregroundColor(.black)
                                            .fontWeight(.heavy)
                                    }
                                }
                                .labelsHidden()
//                                Picker("", selection: $snoozesecs) {
//                                    ForEach(0..<60) {index in
//                                        Text("\(index)").tag(index)
//                                            .foregroundColor(.black)
//                                            .fontWeight(.heavy)
//                                    }
//                                }
//                                .labelsHidden()
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                } /* Section */
            }
        }
        .onChange(of: untimedComment, perform: {
            if $0 == true { stageEditableData.durationSecsInt = kStageDurationCommentOnly }
            else { updateDuration(andDirection: true) }
        })
        .onChange(of: timerDirection, perform: {
            if $0 == .countUp { stageEditableData.durationSecsInt = kStageDurationCountUpTimer }
            else { updateDuration(andDirection: false) }
        })
        .onChange(of: snoozeAlertDuringCountUp, perform: {
            if $0 == true { stageEditableData.durationSecsInt = kStageDurationCountUpWithSnoozeAlerts }
            else { stageEditableData.durationSecsInt = kStageDurationCountUpTimer }
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
//        .onChange(of: snoozesecs, perform: {hrs in
//            updateSnoozeDuration()
//        })
        .onAppear() {
            untimedComment = stageEditableData.isCommentOnly
            if untimedComment == true {
                // leave the defaults
            } else {
                timerDirection = stageEditableData.isCountUp ? .countUp : .countDown
                snoozeAlertDuringCountUp = stageEditableData.isCountUpWithSnoozeAlerts
                hours = stageEditableData.durationSecsInt / SEC_HOUR
                mins = ((stageEditableData.durationSecsInt % SEC_HOUR) / SEC_MIN)
                secs = stageEditableData.durationSecsInt % SEC_MIN
            }
            snoozehours = stageEditableData.snoozeDurationSecs / SEC_HOUR
            snoozemins = ((stageEditableData.snoozeDurationSecs % SEC_HOUR) / SEC_MIN)
//            snoozesecs = stageEditableData.snoozeDurationSecs % SEC_MIN

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
        var newValue = Int(snoozehours) * SEC_HOUR + Int(snoozemins) * SEC_MIN /*+ Int(snoozesecs)*/
        if newValue < kSnoozeDurationSecsMin {
            newValue = kSnoozeDurationSecsMin
//            snoozesecs = 1
        }
        stageEditableData.snoozeDurationSecs = newValue
    }
    
    
}

struct StageRowEditView_Previews: PreviewProvider {
    static var previews: some View {
        StageEditView(stageEditableData: .constant(Stage.EditableData()))
    }
}
