//
//  ItineraryActionView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI

struct ItineraryActionView: View {
    @Binding var itinerary: Itinerary
    
    @EnvironmentObject var itineraryStore: ItineraryStore
    
    @State private var itineraryData = Itinerary.EditableData()
    @State private var isPresentingEditView = false
    
    @Environment(\.scenePhase) private var scenePhase

    
    var body: some View {
        
        VStack(alignment: .leading) {
            List {
                ForEach($itinerary.stages) { $stage in
                    StageActionView(stage: $stage, stageUuidEnabled: $itinerary.uuidActiveStage, inEditingMode: false )
                }
            }
        }
        .onAppear() {
            debugPrint("ItineraryActionView onAppear")
            if itinerary.stages.count > 0 {
                itinerary.uuidActiveStage = itinerary.stages[0].id.uuidString
            }
        }
        .onDisappear() {
            debugPrint("ItineraryActionView onDisappear")
        }
        .task {
            debugPrint("ItineraryActionView task")
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .inactive:
                debugPrint("ItineraryActionView inactive")
            case .active:
                debugPrint("ItineraryActionView active")
            case .background:
                debugPrint("ItineraryActionView background")
            default:
                debugPrint("ItineraryActionView default")
            }
        }
        .navigationTitle(itinerary.title)
        .toolbar {
            Button("Modify") {
                isPresentingEditView = true
                itineraryData = itinerary.itineraryEditableData
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationView {
                ItineraryEditView(itineraryData: $itineraryData)
                    .navigationTitle(itinerary.title)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                isPresentingEditView = false
                                itinerary.updateItineraryEditableData(from: itineraryData)
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
