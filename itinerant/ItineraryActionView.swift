//
//  ItineraryActionView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI

let kItineraryUUIDStr = "kItineraryUUIDStr"
let kStageUUIDStr = "kStageUUIDStr"
let kItineraryTitle = "kItineraryTitle"
let kStageTitle = "kStageTitle"

struct ItineraryActionView: View {

    @State var itinerary: Itinerary
    @Binding var uuidStrStagesActiveStr: String
    @Binding var uuidStrStagesRunningStr: String

    @State private var itineraryData = Itinerary.EditableData()
    @State private var isPresentingItineraryEditView = false

    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var itineraryStore: ItineraryStore


    var stageActive: Stage? { itinerary.stages.first { uuidStrStagesActiveStr.contains($0.id.uuidString) } }
    var myStageIsActive: Bool { itinerary.stages.first { uuidStrStagesActiveStr.contains($0.id.uuidString) } != nil }
    var stageRunning: Stage? { itinerary.stages.first { uuidStrStagesRunningStr.contains($0.id.uuidString) } }
    var myStageIsRunning: Bool { itinerary.stages.first { uuidStrStagesRunningStr.contains($0.id.uuidString) } != nil }

    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach($itinerary.stages) { $stage in
                    StageActionView(stage: $stage, itinerary: $itinerary, uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr)
                }
            }
        }
        .onAppear() {
            if !myStageIsRunning && !myStageIsActive && !itinerary.stages.isEmpty {
                uuidStrStagesActiveStr.append(itinerary.stages[0].id.uuidString)
            }
        }
//        .onDisappear() {
//            debugPrint("ItineraryActionView onDisappear \(itineraryStore.itineraries.count)")
//        }
//        .onChange(of: scenePhase) { phase in
//            switch phase {
//            case .inactive:
//                debugPrint("ItineraryActionView inactive")
//            case .active:
//                debugPrint("ItineraryActionView active")
//            case .background:
//                debugPrint("ItineraryActionView background")
//            default:
//                debugPrint("ItineraryActionView default")
//            }
//        }
        .navigationTitle(itinerary.title)
        .toolbar {
            Button("Modify") {
                itineraryData = itinerary.itineraryEditableData
                isPresentingItineraryEditView = true
            }
            .disabled(myStageIsRunning)
        }
        .onChange(of: itinerary, perform: { itineraryStore.updateItinerary(itinerary: $0) })
        .sheet(isPresented: $isPresentingItineraryEditView) {
            NavigationView {
                // pass a BOUND COPY of itineraryData to amend and use to update if necessary
                ItineraryEditView(itinerary: $itinerary, itineraryEditableData: $itineraryData)
                    .navigationTitle(itinerary.title)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingItineraryEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                itinerary.updateItineraryEditableData(from: itineraryData)
                                isPresentingItineraryEditView = false
                            }
                        }
                    }
            }
        }
        
    }
}

extension ItineraryActionView {
    
    
    
    func resetActiveView() {
        
    }
    
}

struct ItineraryActionView_Previews: PreviewProvider {
    static var previews: some View {
        Text("k")
        //ItineraryActionView(itinerary: .constant(Itinerary.templateItinerary()))
    }
}
