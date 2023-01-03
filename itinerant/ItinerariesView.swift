//
//  ContentView.swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import SwiftUI

struct ItinerariesView: View {
    //  the order of params is relevant !!
    @Binding var itineraries: ItineraryArray
    let saveAction: ()->Void // this is passed in when we init from App as what to do  to save Store
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var isPresentingNewItinView = false
    
    var body: some View {
        List {
            ForEach($itineraries) { $itinerary in
                NavigationLink(destination: ItineraryActionView(itinerary: $itinerary)) {
                    VStack {
                        Text(itinerary.id.uuidString)
                        Text(itinerary.title)
                    }
                }
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .inactive { saveAction() }
        }
        .navigationTitle("Itineraries")
        .toolbar {
            Button(action: {
                //isPresentingNewItinView = true
                addItinerary()
            }) {
                Image(systemName: "plus")
            }
            .accessibilityLabel("Add Itinerary")
        }
        
    }
}

extension ItinerariesView {
    
    func addItinerary() -> Void {
        let newItin = Itinerary.templateItinerary()
        itineraries.append(newItin)
        //isPresentingNewItinView = false
        //newScrumData = DailyScrum.Data()
        saveAction()
    }
    
    
}

struct ItinerariesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ItinerariesView(itineraries: .constant(Itinerary.sampleItineraryArray()), saveAction: {})
        }
    }
}
