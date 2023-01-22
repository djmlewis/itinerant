//
//  ContentView.swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import SwiftUI

let kSceneStoreUuidStrStageActive = "uuidStrStageActiveStr"
let kSceneStoreUuidStrStageRunning = "uuidStrStageRunningStr"


struct ItineraryStoreView: View {
    
    @SceneStorage(kSceneStoreUuidStrStageActive) var uuidStrStagesActiveStr: String = ""
    @SceneStorage(kSceneStoreUuidStrStageRunning) var uuidStrStagesRunningStr: String = ""

    @State private var isPresentingItineraryEditView = false
    @State private var isPresentingNewItineraryView = false
    @State private var newItinerary = Itinerary(title: "")
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
                .onDelete(perform: { offsets in
                    // remove all references to any stage ids for these itineraries first. offsets is the indexset
                    offsets.forEach { index in
                        itineraryStore.itineraries[index].stages.forEach { stage in
                            let uuidstr = stage.id.uuidString
                            uuidStrStagesActiveStr = uuidStrStagesActiveStr.replacingOccurrences(of: uuidstr, with: "")
                            uuidStrStagesRunningStr = uuidStrStagesRunningStr.replacingOccurrences(of: uuidstr, with: "")
                        }
                    }
                    // now its safe to delete those Itineraries
                    itineraryStore.removeItinerariesAtOffsets(offsets: offsets)
                })
                //.onMove(perform: {itineraries.move(fromOffsets: $0, toOffset: $1)})
            }
            .navigationDestination(for: String.self) { id in
                ItineraryActionView(itinerary: itineraryStore.itineraryForID(id: id), uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr)
            }
            .navigationTitle("Itineraries")
            .sheet(isPresented: $isPresentingItineraryEditView) {
                NavigationView {
                    ItineraryEditView(itinerary: $newItinerary, itineraryEditableData: $newItineraryEditableData)
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
