//
//  ContentView.swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import SwiftUI

struct ItineraryStoreView: View {
    //  the order of params is relevant !!
    //@Binding var itineraries: [Itinerary]
    
    @State private var isPresentingItineraryEditView = false
    @State private var newItinerary = Itinerary(title: "")
    @State private var isPresentingNewItineraryView = false
    @State private var newItineraryEditableData = Itinerary.EditableData()
    
    @EnvironmentObject var itineraryStore: ItineraryStore
    @EnvironmentObject private var appDelegate: AppDelegate

    @Environment(\.scenePhase) private var scenePhase
    
    
    @State private var presentedItineraryID: [String] = []
    
    var body: some View {
        
        NavigationStack(path: $presentedItineraryID) {
            List {
                ForEach($itineraryStore.itineraries.map({ $0.id.uuidString}), id:\.self) { itineraryID in
                    NavigationLink(value: itineraryID) {
                        Text(itineraryStore.itineraryTitleForID(id: itineraryID))
                    }
                }
                .onDelete(perform: {
                    itineraryStore.removeItinerariesAtOffsets(offsets: $0)
                })
                //.onMove(perform: {itineraries.move(fromOffsets: $0, toOffset: $1)})
            }
            .navigationDestination(for: String.self) { id in
                ItineraryActionView(itinerary: itineraryStore.itineraryForID(id: id))
                //Text("String Detail \(i)")
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
                                    itineraryStore.addItinerary(itinerary: newItinerary)
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
                        presentedItineraryID = ["B93CDEAB-E18E-4941-A9DF-E5421C9B41B1"]
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
        .onChange(of: appDelegate.unnItineraryID) { newValue in
            //debugPrint("change of " + String(describing: newValue))
            guard newValue != nil && itineraryStore.hasItineraryWithID(newValue!) else { return }
            presentedItineraryID = [newValue!]
        }

    } /* body */
} /* View */


struct ItineraryStoreView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            //ItineraryStoreView(itineraries: .constant(Itinerary.sampleItineraryArray()))
        }
        .environmentObject(ItineraryStore())
    }
}
