//
//  ContentView.swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import SwiftUI

struct ItineraryStoreView: View {
    //  the order of params is relevant !!
    @Binding var itineraries: [Itinerary]
    
    @State private var isPresentingItineraryEditView = false
    @State private var newItinerary = Itinerary(title: "")
    @State private var isPresentingNewItineraryView = false
    @State private var newItineraryEditableData = Itinerary.EditableData()
    
    @EnvironmentObject var itineraryStore: ItineraryStore
    
    @Environment(\.scenePhase) private var scenePhase
    
    @EnvironmentObject var appGlobals: AppGlobals
    @EnvironmentObject private var appDelegate: AppDelegate
    
    @State private var presentedItinerary: [Itinerary] = [] {
        didSet {
            debugPrint(presentedItinerary)
        }
    }
    
    var body: some View {
        NavigationStack(path: $presentedItinerary) {
            List {
                ForEach($itineraries) { $itinerary in
                    NavigationLink(itinerary.title) {
                        ItineraryActionView(itinerary: $itinerary)
                    }
                }
                .onDelete(perform: {
                    itineraryStore.removeItinerariesAtOffsets(offsets: $0)
                })
                //.onMove(perform: {itineraries.move(fromOffsets: $0, toOffset: $1)})
            }
            .navigationTitle("Itineraries")
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ProgressView()
                        .opacity(itineraryStore.isLoadingItineraries ? 1.0 : 0.0)
                }
                ToolbarItemGroup() {
                    Button(action: {
                        if let itinerary = itineraries.first(where: { $0.id.uuidString == "AE248CC3-2C41-438A-A0EA-DAE373784979" }) {
                            presentedItinerary = [itinerary]
                        }
                    }) {
                        Image(systemName: "circle")
                    }
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
        }
        List(presentedItinerary) { itinerary in
            /*@START_MENU_TOKEN@*/Text(itinerary.title)/*@END_MENU_TOKEN@*/
        }

    } /* body */
} /* View */


struct ItineraryStoreView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ItineraryStoreView(itineraries: .constant(Itinerary.sampleItineraryArray()))
        }
        .environmentObject(ItineraryStore())
    }
}
