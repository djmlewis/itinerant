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
    @State private var newItinerary = Itinerary(title: "")
    @State private var isPresentingNewItineraryView = false
    @State private var newItineraryEditableData = Itinerary.EditableData()

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
            .onDelete(perform: {
                itineraryStore.removeItinerariesAtOffsets(offsets: $0)
            })
            //.onMove(perform: {itineraries.move(fromOffsets: $0, toOffset: $1)})
        }
        //.onAppear() {debugPrint("Appear \(itineraries.count)")}
        //.onDisappear() {debugPrint("DisAppear \(itineraries.count)")}
//        .onChange(of: scenePhase) { phase in
//            if phase == .inactive {
//                //itineraryStore.saveStore()
//
//            }
//        }
        .navigationTitle("Itineraries")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                ProgressView()
                    .opacity(itineraryStore.isLoadingItineraries ? 1.0 : 0.0)
            }
            ToolbarItemGroup() {
                Button(action: {
                    newItinerary = Itinerary(title: "")
                    newItineraryEditableData = Itinerary.EditableData()
                    isPresentingItineraryEditView = true
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Itinerary")
            }
        }
        .sheet(isPresented: $isPresentingItineraryEditView) {
            NavigationView {
                ItineraryEditView(itinerary: $newItinerary, itineraryEditableData: $newItineraryEditableData)
                //.navigationTitle(newItinerary.title)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingItineraryEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                newItinerary.updateItineraryEditableData(from: newItineraryEditableData)
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
        .environmentObject(ItineraryStore())
    }
}
