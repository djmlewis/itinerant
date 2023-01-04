//
//  ItineraryEditView.swift
//  itinerant
//
//  Created by David JM Lewis on 04/01/2023.
//

import SwiftUI

struct ItineraryEditView: View {
    
    @Binding var itineraryData: Itinerary.ItineraryData

    @State private var itineraryName: String = ""

    
    var body: some View {
        Form {
            Section(header: Text("Itinerary Info")) {
                TextField("Itinerary title", text: $itineraryData.title)
            }
            Section(header: Text("Stages")) {
                List {
                    ForEach($itineraryData.stages) { $stage in
                        NavigationLink(destination: StageEditView(stage: $stage)) {
                            StageActionView(stage: $stage)
                        }
                    }
                }
                HStack() {
                    Spacer()
                    Button(action: {

                    }) {
                        Text("Add Stage")
                    }
                }
            }
        }
    }
}

struct ItineraryEditView_Previews: PreviewProvider {
    static var previews: some View {
        ItineraryEditView(itineraryData: .constant(Itinerary.templateItinerary().itineraryData))
    }
}
