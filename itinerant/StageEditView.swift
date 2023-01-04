//
//  StageRowEditView.swift
//  itinerant
//
//  Created by David JM Lewis on 04/01/2023.
//

import SwiftUI

struct StageEditView: View {
    
    @Binding var stage: Stage
    @State private var hours: Double = 0
    @State private var mins: Double = 0
    @State private var secs: Double = 0
    
    
    var body: some View {
        Form {
            Section(header: SectionHeaderView(imageName: "info.circle", title: "Stage Information")) {
                TextField("Itinerary title", text: $stage.title)
            }
            Section(header: SectionHeaderView(imageName: "clock", title: "Stage Duration")) {
                GeometryReader { metrics in
                    HStack {
                        Text("\(Int(hours))")
                            .frame(width: metrics.size.width * 0.08, alignment: .trailing)
                        Slider(value: $hours, in: 0...23, step: 1) {
                            Text("Hours")
                        }
                        Text("Hours")
                            .frame(width: metrics.size.width * 0.15, alignment: .leading)
                            .allowsTightening(true)
                    }
                }
                GeometryReader { metrics in
                    HStack {
                        Text("\(Int(mins))")
                            .frame(width: metrics.size.width * 0.08, alignment: .trailing)
                        Slider(value: $mins, in: 0...59, step: 1) {
                            Text("Minutes")
                        }
                        Text("Mins")
                            .frame(width: metrics.size.width * 0.15, alignment: .leading)
                            .allowsTightening(true)
                    }
                }
                GeometryReader { metrics in
                    HStack {
                        Text("\(Int(secs))")
                            .frame(width: metrics.size.width * 0.08, alignment: .trailing)
                        Slider(value: $secs, in: 0...59, step: 1) {
                            Text("Seconds")
                        }
                        Text("Secs")
                            .frame(width: metrics.size.width * 0.15, alignment: .leading)
                            .allowsTightening(true)
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
        .onAppear {
            hours = Double(stage.durationSecsInt / SEC_HOUR)
            mins = Double((stage.durationSecsInt % SEC_HOUR) / SEC_MIN)
            secs = Double(stage.durationSecsInt % SEC_MIN)
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
