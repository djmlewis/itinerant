//
//  WKItineraryActionView.swift
//  itinerant Watch App
//
//  Created by David JM Lewis on 27/01/2023.
//

import SwiftUI

struct WKItineraryActionView: View {
    @State var itinerary: Itinerary // not sure why thgis is a State not a Binding
    @Binding var uuidStrStagesActiveStr: String
    @Binding var uuidStrStagesRunningStr: String
    @Binding var dictStageStartDates: [String:String]
    
    @State private var resetStageElapsedTime: Bool?
    @State private var scrollToStageID: String?
    
    @EnvironmentObject var itineraryStore: ItineraryStore
    @EnvironmentObject var wkAppDelegate: WKAppDelegate

    
    var stageActive: Stage? { itinerary.stages.first { uuidStrStagesActiveStr.contains($0.id.uuidString) } }
    var myStageIsActive: Bool { itinerary.stages.first { uuidStrStagesActiveStr.contains($0.id.uuidString) } != nil }
    var stageRunning: Stage? { itinerary.stages.first { uuidStrStagesRunningStr.contains($0.id.uuidString) } }
    var myStageIsRunning: Bool { itinerary.stages.first { uuidStrStagesRunningStr.contains($0.id.uuidString) } != nil }
    var totalDuration: Double { Double(itinerary.stages.reduce(0) { partialResult, stage in
        partialResult + stage.durationSecsInt
    }) }
    var someStagesAreCountUp: Bool { itinerary.stages.reduce(false) { partialResult, stage in
        partialResult || stage.durationSecsInt == 0
    } }

    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollViewReader { scrollViewReader in
                List {
                    ForEach($itinerary.stages) { $stage in
                        WKStageActionView(stage: $stage, itinerary: $itinerary, uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates, resetStageElapsedTime: $resetStageElapsedTime, scrollToStageID: $scrollToStageID)
                            .id(stage.id.uuidString)
                    }
                }
                .onChange(of: scrollToStageID) { stageid in
                    if stageid != nil { scrollViewReader.scrollTo(stageid!) }
                }
            }
        }
        .navigationTitle(itinerary.title)
        .onAppear() {
            if !myStageIsRunning && !myStageIsActive && !itinerary.stages.isEmpty {
                uuidStrStagesActiveStr.append(itinerary.stages[0].id.uuidString)
            }
        }
//        .onChange(of: itinerary, perform: {itinerary.filename = itineraryStore.updateItinerary(itinerary: $0) })
    }
}

struct WKItineraryActionView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello, World!")
    }
}
