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
    @EnvironmentObject var wkAppDelegate: WKAppDelegate
    
    @State private var presentedItineraryID: [String] = []

    
    
    
    var body: some View {
        NavigationStack(path: $presentedItineraryID) {
            List {
                ForEach($itineraryStore.itineraries.map({ $0.id.uuidString}), id:\.self) { itineraryID in
                    NavigationLink(value: itineraryID) {
                        HStack {
                            Text(itineraryStore.itineraryTitleForID(id: itineraryID))
                                .font(.title3)
                        }
                    }
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
                WKItineraryActionView(itinerary: itineraryStore.itineraryForID(id: id), uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates)
            }
            .navigationTitle("Itineraries")
        }
        .onChange(of: wkAppDelegate.newItinerary) { itineraryToAdd in
            if itineraryToAdd != nil {
                itineraryStore.addItinerary(itinerary: itineraryToAdd!)
            }
        }

        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello World")
    }
}
