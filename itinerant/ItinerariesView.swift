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
    //let saveAction: ()->Void // this is passed in when we init from App as what to do  to save Store
    @EnvironmentObject var itineraryStore: ItineraryStore
    
    @State private var isPresentingItineraryEditView = false
    @State private var newItineraryData = Itinerary.ItineraryData()


    @Environment(\.scenePhase) private var scenePhase
    @State private var isPresentingNewItinView = false
    
    var body: some View {
        List {
            ForEach($itineraries) { $itinerary in
                NavigationLink(destination: ItineraryActionView(itinerary: $itinerary)) {
                    VStack(alignment: .leading) {
                        Text(itinerary.title)
                    }
                    
                }
            }
            .onDelete(perform: {itineraries.remove(atOffsets: $0)})
            .onMove(perform: {itineraries.move(fromOffsets: $0, toOffset: $1)})
        }
        .onChange(of: scenePhase) { phase in
            if phase == .inactive { itineraryStore.saveStore() }
        }
        .navigationTitle("Itineraries")
        //.navigationBarItems(leading: EditButton())
        .toolbar {
            Button(action: {
                isPresentingItineraryEditView = true
            }) {
                Image(systemName: "plus")
            }
            .accessibilityLabel("Add Itinerary")
            EditButton()
        }
        .sheet(isPresented: $isPresentingItineraryEditView) {
            NavigationView {
                ItineraryEditView(itineraryData: $newItineraryData)
                    //.navigationTitle(newItinerary.title)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                newItineraryData = Itinerary.ItineraryData()
                                isPresentingItineraryEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                itineraries.append(Itinerary(itineraryData: newItineraryData))
                                itineraryStore.saveStore()
                                isPresentingItineraryEditView = false
                            }
                        }
                    }
            }
        }

    }
}


struct ItinerariesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ItinerariesView(itineraries: .constant(Itinerary.sampleItineraryArray())/*, saveAction: {}*/)
        }
    }
}
