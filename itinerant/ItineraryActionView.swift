//
//  ItineraryActionView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI

struct ItineraryActionView: View {
    @Binding var itinerary: Itinerary
    
    @State private var itineraryData = Itinerary.ItineraryData()
    @State private var isPresentingEditView = false
    
    var body: some View {
        
        VStack {
            List {
                ForEach($itinerary.stages) { $stage in
                    NavigationLink(destination: StageActionView(stage: $stage)) {
                        StageRowView(stage: $stage)
                    }
                }
            }
        }
        .navigationTitle(itinerary.title)
        .toolbar {
            Button("Edit") {
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
                            Button("Done") {
                                isPresentingEditView = false
                                itinerary.updateItineraryData(from: itineraryData)
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
