//
//  ItineraryActionView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI

let kSceneStoreUuidStrStageActive = "uuidStrStageActive"
let kSceneStoreUuidStrStageRunning = "uuidStrStageRunning"

let kItineraryUUIDStr = "kItineraryUUIDStr"
let kStageUUIDStr = "kStageUUIDStr"
let kItineraryTitle = "kItineraryTitle"
let kStageTitle = "kStageTitle"

struct ItineraryActionView: View {
    //var itineraryUUIDstr: String
    @State var itinerary: Itinerary
    @State private var itineraryData = Itinerary.EditableData()
    @State private var isPresentingItineraryEditView = false

    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var itineraryStore: ItineraryStore

    @SceneStorage(kSceneStoreUuidStrStageActive) var uuidStrStageActive: String = ""
    @SceneStorage(kSceneStoreUuidStrStageRunning) var uuidStrStageRunning: String = ""

    var stageRunning: Stage? { itinerary.stages.first { $0.id.uuidString == uuidStrStageRunning } }
    var myStageIsRunning: Bool { itinerary.stages.first { $0.id.uuidString == uuidStrStageRunning } != nil }
    var stageActive: Stage? { itinerary.stages.first { $0.id.uuidString == uuidStrStageActive } }

    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach($itinerary.stages) { $stage in
                    StageActionView(stage: $stage, itinerary: $itinerary, uuidStrStageActive: $uuidStrStageActive, uuidStrStageRunning: $uuidStrStageRunning)
                }
            }
        }
        .onAppear() {
            debugPrint(itinerary.title,uuidStrStageRunning)
            if itinerary.stages.count > 0 {
                uuidStrStageActive = itinerary.stages[0].id.uuidString
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



struct ItineraryActionView_Previews: PreviewProvider {
    static var previews: some View {
        Text("k")
        //ItineraryActionView(itinerary: .constant(Itinerary.templateItinerary()))
    }
}
