//
//  ContentView.swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import SwiftUI

struct ItineraryStoreView: View {
    //  the order of params is relevant !!
    @Binding var itineraries: ItineraryArray
    
    @State private var isPresentingItineraryEditView = false
    @State private var newItineraryData = Itinerary.EditableData()
    @State private var isPresentingNewItinView = false
    @State private var isLoadingItineraries = true
    
    @EnvironmentObject var itineraryStore: ItineraryStore
    
    @Environment(\.scenePhase) private var scenePhase
    
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
        .task {
            isLoadingItineraries = true
            itineraryStore.loadItineraries(isLoadingItineraries: &isLoadingItineraries)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .inactive {
                //itineraryStore.saveStore()
                
            }
        }
        .navigationTitle("Itineraries")
        //.navigationBarItems(leading: EditButton())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ProgressView()
                    .opacity(isLoadingItineraries ? 1.0 : 0.0)
            }
            ToolbarItemGroup() {
                Button(action: {
                    isPresentingItineraryEditView = true
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Itinerary")
                EditButton()
            }
        }
        .sheet(isPresented: $isPresentingItineraryEditView) {
            NavigationView {
                ItineraryEditView(itineraryData: $newItineraryData)
                //.navigationTitle(newItinerary.title)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                newItineraryData = Itinerary.EditableData()
                                isPresentingItineraryEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                let newItinerary = Itinerary(editableData: newItineraryData)
                                itineraries.append(newItinerary)
                                newItinerary.savePersistentData()
                                isPresentingItineraryEditView = false
                            }
                        }
                    }
            }
        }
        
    }
}


struct ItineraryStoreView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ItineraryStoreView(itineraries: .constant(Itinerary.sampleItineraryArray()))
        }
    }
}
