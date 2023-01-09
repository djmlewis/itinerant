//
//  ItineraryActionView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI

struct ItineraryActionView: View {
    @Binding var itinerary: Itinerary
    @State private var itineraryData = Itinerary.EditableData()
    @State private var isPresentingEditView = false
    
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var itineraryStore: ItineraryStore
    
    
    var body: some View {
        
        VStack(alignment: .leading) {
            List {
                ForEach($itinerary.stages) { $stage in
                    StageActionView(stage: $stage, itinerary: $itinerary, inEditingMode: false )
                }
            }
        }
        .onAppear() {
            //debugPrint("ItineraryActionView onAppear \(itineraryStore.itineraries.count)")
            if itinerary.stages.count > 0 {
                itinerary.uuidActiveStage = itinerary.stages[0].id.uuidString
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
                isPresentingEditView = true
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationView {
                // pass a BOUND COPY of itineraryData to amend and use to update if necessary
                ItineraryEditView(itinerary: $itinerary, itineraryEditableData: $itineraryData)
                    .navigationTitle(itinerary.title)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                itinerary.updateItineraryEditableData(from: itineraryData)
                                isPresentingEditView = false
                            }
                        }
                    }
            }
        }
        
    }
}



struct ItineraryActionView_Previews: PreviewProvider {
    static var previews: some View {
        ItineraryActionView(itinerary: .constant(Itinerary.templateItinerary()))
    }
}
