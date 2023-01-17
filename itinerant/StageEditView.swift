//
//  StageRowEditView.swift
//  itinerant
//
//  Created by David JM Lewis on 04/01/2023.
//

import SwiftUI

struct StageEditView: View {
    
    @Binding var stage: Stage
    @State private var hours: Int = 3
    @State private var mins: Int = 5
    @State private var secs: Int = 6
    @FocusState private var focusedFieldTag: FieldFocusTag?
    
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Stage title", text: $stage.title)
                    .focused($focusedFieldTag, equals: .title)
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
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
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
            debugPrint(stage.durationSecsInt / SEC_HOUR,(stage.durationSecsInt % SEC_HOUR) / SEC_MIN,stage.durationSecsInt % SEC_MIN)
            hours = stage.durationSecsInt / SEC_HOUR
            mins = ((stage.durationSecsInt % SEC_HOUR) / SEC_MIN)
            secs = stage.durationSecsInt % SEC_MIN
            focusedFieldTag = .title
        }
        .onDisappear() {
            focusedFieldTag = .noneFocused
        }
    }
    
    
}

extension StageEditView {
    
    func updateDuration() -> Void {
        stage.durationSecsInt = Int(hours) * SEC_HOUR + Int(mins) * SEC_MIN + Int(secs)
    }
}

struct StageRowEditView_Previews: PreviewProvider {
    static var previews: some View {
        StageEditView(stage: .constant(Stage.templateStage()))
    }
}
