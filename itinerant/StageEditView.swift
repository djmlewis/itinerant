//
//  StageRowEditView.swift
//  itinerant
//
//  Created by David JM Lewis on 04/01/2023.
//

import SwiftUI

struct StageEditView: View {
    
    @Binding var stageEditableData: Stage.EditableData
    @State private var hours: Int = 0
    @State private var mins: Int = 0
    @State private var secs: Int = 0
    @FocusState private var focusedFieldTag: FieldFocusTag?
    
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Stage title", text: $stageEditableData.title)
                    .focused($focusedFieldTag, equals: .title)
            }
            Section(header: Text("Description")) {
                TextField("Title", text: $stageEditableData.details,  axis: .vertical)
                    .lineLimit(1...10)

            }
            Section(header: Text("Duration")) {
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
                            Picker("", selection: $mins) {
                                ForEach(0..<60) {index in
                                    Text("\(index)").tag(index)
                                        .foregroundColor(.black)
                                        .fontWeight(.heavy)
                                }
                            }
                            Picker("", selection: $secs) {
                                ForEach(0..<60) {index in
                                    Text("\(index)").tag(index)
                                        .foregroundColor(.black)
                                        .fontWeight(.heavy)
                                }
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
        }
        .onChange(of: hours, perform: {hrs in
            updateDuration()
        })
        .onChange(of: mins, perform: {hrs in
            updateDuration()
        })
        .onChange(of: secs, perform: {hrs in
            updateDuration()
        })
        .onAppear() {
            //debugPrint(stageEditableData.durationSecsInt / SEC_HOUR,(stageEditableData.durationSecsInt % SEC_HOUR) / SEC_MIN,stageEditableData.durationSecsInt % SEC_MIN)
            hours = stageEditableData.durationSecsInt / SEC_HOUR
            mins = ((stageEditableData.durationSecsInt % SEC_HOUR) / SEC_MIN)
            secs = stageEditableData.durationSecsInt % SEC_MIN
            focusedFieldTag = .title
        }
        .onDisappear() {
            focusedFieldTag = .noneFocused
        }
    }
    
    
}

extension StageEditView {
    
    func updateDuration() -> Void {
        stageEditableData.durationSecsInt = Int(hours) * SEC_HOUR + Int(mins) * SEC_MIN + Int(secs)
    }
}

struct StageRowEditView_Previews: PreviewProvider {
    static var previews: some View {
        StageEditView(stageEditableData: .constant(Stage.EditableData()))
    }
}
