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
    
    @State private var itineraryData = Itinerary.ItineraryData()
    @State private var isPresentingEditView = false
    
    @State private var stageActiveIndex = -1
    @State private var stageActiveUuid = UUID().uuidString

    
    var body: some View {
        
        VStack(alignment: .leading) {
            List {
                ForEach($itinerary.stages) { $stage in
                        StageActionView(stage: $stage, stageUuidEnabled: $stageActiveUuid, inEditingMode: false )
                }
            }
        }
        .onAppear() {
            if itinerary.stages.count > 0 {
                stageActiveIndex = 0
                stageActiveUuid = itinerary.stages[stageActiveIndex].id.uuidString
            }
        }
        .onChange(of: stageActiveIndex) { index in
            stageActiveUuid = itinerary.stages[index].id.uuidString
        }
        .navigationTitle(itinerary.title)
        .toolbar {
            Button("Modify") {
                isPresentingEditView = true
                itineraryData = itinerary.itineraryData
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
                                itinerary.updateItineraryData(from: itineraryData)
                                itineraryStore.saveStore()
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
