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
    @State private var hours: Int = 0
    @State private var mins: Int = 0
    @State private var secs: Int = 0
    @State private var timerDirection: TimerDirection = .countDown

    @State private var snoozehours: Int = 0
    @State private var snoozemins: Int = 0
    @State private var snoozesecs: Int = 0

    
    //@FocusState private var focusedFieldTag: FieldFocusTag?
    
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Stage title", text: $stageEditableData.title)
            }
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
            }
            Section(header: Text("Details")) {
                TextField("Details", text: $stageEditableData.details,  axis: .vertical)
                    .lineLimit(1...10)
            }
            Section(header: Text("Time between Snooze Alerts")) {
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
                            Picker("", selection: $snoozesecs) {
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
        }
        .onChange(of: timerDirection, perform: {direction in
            if direction == .countUp { stageEditableData.durationSecsInt = 0 }
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
        .onChange(of: snoozehours, perform: {hrs in
            updateSnoozeDuration()
        })
        .onChange(of: snoozemins, perform: {hrs in
            updateSnoozeDuration()
        })
        .onChange(of: snoozesecs, perform: {hrs in
            updateSnoozeDuration()
        })
        .onAppear() {
            timerDirection = stageEditableData.durationSecsInt == 0 ? .countUp : .countDown
            hours = stageEditableData.durationSecsInt / SEC_HOUR
            mins = ((stageEditableData.durationSecsInt % SEC_HOUR) / SEC_MIN)
            secs = stageEditableData.durationSecsInt % SEC_MIN
            snoozehours = stageEditableData.snoozeDurationSecs / SEC_HOUR
            snoozemins = ((stageEditableData.snoozeDurationSecs % SEC_HOUR) / SEC_MIN)
            snoozesecs = stageEditableData.snoozeDurationSecs % SEC_MIN
            //focusedFieldTag = .title
        }
        .onDisappear() {
            //focusedFieldTag = .noneFocused
            if timerDirection == .countUp { stageEditableData.durationSecsInt = 0 }
        }
    }
    
    
}

extension StageEditView {
    
    func updateDuration() -> Void {
        stageEditableData.durationSecsInt = Int(hours) * SEC_HOUR + Int(mins) * SEC_MIN + Int(secs)
        timerDirection = stageEditableData.durationSecsInt == 0 ? .countUp : .countDown
    }
    
    func updateSnoozeDuration() {
        var newValue = Int(snoozehours) * SEC_HOUR + Int(snoozemins) * SEC_MIN + Int(snoozesecs)
        if newValue < 1 {
            newValue = 1
            snoozesecs = 1
        }
        stageEditableData.snoozeDurationSecs = newValue
    }
    
    
}

struct StageRowEditView_Previews: PreviewProvider {
    static var previews: some View {
        StageEditView(stageEditableData: .constant(Stage.EditableData()))
    }
}
