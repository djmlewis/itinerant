//
//  ItineraryActionView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI

struct ItineraryActionView: View {
    @Binding var itinerary: Itinerary
    
    
    var body: some View {
        
        VStack {
            List {
                ForEach($itinerary.stages) { $stage in
                    NavigationLink(destination: StageActionView(stage: $stage)) {
                        StageRowView(stage: $stage)
                    }
                }
            }
            .navigationTitle(itinerary.title)
        }
    }
}

struct ItineraryActionView_Previews: PreviewProvider {
    static var previews: some View {
        ItineraryActionView(itinerary: .constant(Itinerary.templateItinerary()))
    }
}
