//
//  ContentView.swift
//  itinerant Watch App
//
//  Created by David JM Lewis on 30/12/2022.
//

import SwiftUI

struct WKItinerantStoreView: View {
    @SceneStorage(kSceneStoreUuidStrStageActive) var uuidStrStagesActiveStr: String = ""
    @SceneStorage(kSceneStoreUuidStrStageRunning) var uuidStrStagesRunningStr: String = ""
    @SceneStorage(kSceneStoreDictStageStartDates) var dictStageStartDates: [String:String] = [:]

    @EnvironmentObject var itineraryStore: ItineraryStore
    @EnvironmentObject private var wkAppDelegate: WKAppDelegate
    
    @State private var presentedItineraryID: [String] = []
    @State private var showConfirmationAddDuplicateItinerary: Bool = false
    
    
    var body: some View {
        NavigationStack(path: $presentedItineraryID) {
            List {
                ForEach($itineraryStore.itineraries.map({ $0.id.uuidString}), id:\.self) { itineraryID in
                    NavigationLink(value: itineraryID) {
                        HStack {
                            Text(itineraryStore.itineraryTitleForID(id: itineraryID))
                                .font(.system(.title3, design: .rounded, weight: .semibold))
                        }
                    }
                    .listItemTint(itineraryStore.itineraryForIDisRunning(id: itineraryID, uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? Color("ColourBackgroundRunning") : Color("ColourBackgroundDarkGrey"))
                } /* ForEach */
                .onDelete(perform: { offsets in
                    // remove all references to any stage ids for these itineraries first. offsets is the indexset
                    offsets.forEach { index in
                        (uuidStrStagesActiveStr,uuidStrStagesRunningStr,dictStageStartDates) = itineraryStore.itineraries[index].removeAllStageIDsAndNotifcations(from: uuidStrStagesActiveStr, andFrom: uuidStrStagesRunningStr, andFromDict: dictStageStartDates)
                    }
                    // now its safe to delete those Itineraries
                    itineraryStore.removeItinerariesAtOffsets(offsets: offsets)
                })
                
            } /* List */
            .navigationDestination(for: String.self) { id in
                WKItineraryActionView(itinerary: itineraryStore.itineraryForID(id: id) ?? Itinerary.errorItinerary(), uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates)
            }
            .navigationTitle("Itineraries")
            
        }
        .onChange(of: wkAppDelegate.unnItineraryID) { newValue in
            // handle notifications to switch itinerary
            guard newValue != nil && itineraryStore.hasItineraryWithID(newValue!) else { return }
            presentedItineraryID = [newValue!]
        }
        .onChange(of: wkAppDelegate.newItinerary) { itineraryToAdd in
            // for messages with Itinerary to load
            if let validItinerary = itineraryToAdd {
                if itineraryStore.hasItineraryWithTitle(validItinerary.title) {
                    showConfirmationAddDuplicateItinerary = true
                } else {
                    itineraryStore.addItineraryFromWatchMessageData(itinerary: validItinerary, duplicateOption: .noDuplicate)
                }
            }
        }
        .confirmationDialog("‘\(wkAppDelegate.newItinerary?.title ?? "Unknown")’ already exists", isPresented: $showConfirmationAddDuplicateItinerary) {
            // we only get called when wkAppDelegate.newItinerary is non-nil so !
            if let validItinerary = wkAppDelegate.newItinerary {
                Button("Keep Both", role: nil, action: { itineraryStore.addItineraryFromWatchMessageData(itinerary: validItinerary ,duplicateOption: .keepBoth) })
                Button("Replace Existing", role: .destructive, action: { itineraryStore.addItineraryFromWatchMessageData(itinerary: validItinerary,duplicateOption: .replaceExisting) })
            }
        }
    } /* View */
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello World")
    }
}
