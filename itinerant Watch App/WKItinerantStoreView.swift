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
    @SceneStorage(kSceneStoreDictStageEndDates) var dictStageEndDates: [String:String] = [:]

    @EnvironmentObject var itineraryStore: ItineraryStore
    @EnvironmentObject private var appDelegate: AppDelegate
    
    @State private var presentedItineraryID: [String] = []
    @State private var showConfirmationAddDuplicateItinerary: Bool = false
    
    
    var body: some View {
        NavigationStack(path: $presentedItineraryID) {
            List {
                ForEach($itineraryStore.itineraries.map({ $0.id.uuidString}), id:\.self) { itineraryID in
                    NavigationLink(value: itineraryID) {
                        VStack(alignment: .center, spacing: 0.0) {
                            Text(itineraryStore.itineraryTitleForID(id: itineraryID))
                                .font(.system(.title3, design: .rounded, weight: .semibold))
                            if let date = itineraryStore.itineraryModificationDateForID(id: itineraryID) {
                                HStack {
                                    Image(systemName:"square.and.pencil")
                                    Text(date.formatted(date: .numeric, time: .shortened))
                                        .lineLimit(1)
                                        .allowsTightening(true)
                                        .minimumScaleFactor(0.5)
                                }
                                .font(.system(.caption, design: .rounded, weight: .regular))
                            }
                     }
                    }
                    .listItemTint(itineraryStore.itineraryForIDisRunning(id: itineraryID, uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? Color("ColourBackgroundRunning") : Color("ColourBackgroundDarkGrey"))
                } /* ForEach */
                .onDelete(perform: { offsets in
                    // remove all references to any stage ids for these itineraries first. offsets is the indexset
                    offsets.forEach { index in
                        (uuidStrStagesActiveStr,uuidStrStagesRunningStr,dictStageStartDates,dictStageEndDates) = itineraryStore.itineraries[index].removeAllStageIDsAndNotifcationsFrom(str1: uuidStrStagesActiveStr, str2: uuidStrStagesRunningStr, dict1: dictStageStartDates, dict2: dictStageEndDates)
                    }
                    // now its safe to delete those Itineraries
                    itineraryStore.removeItinerariesAtOffsets(offsets: offsets)
                })
                
            } /* List */
            .navigationDestination(for: String.self) { id in
                ItineraryActionCommonView(itinerary: itineraryStore.itineraryForID(id: id) ?? Itinerary.errorItinerary(), uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates, dictStageEndDates: $dictStageEndDates)
            }
            .navigationTitle("Itineraries")
            
        }
        .onChange(of: appDelegate.unnItineraryToOpenID) { newValue in
            // handle notifications to switch itinerary
            guard newValue != nil && itineraryStore.hasItineraryWithID(newValue!) else { return }
            presentedItineraryID = [newValue!]
        }
        .onChange(of: appDelegate.newItinerary) { itineraryToAdd in
            // for messages with Itinerary to load
            if let validItinerary = itineraryToAdd {
                if itineraryStore.hasItineraryWithTitle(validItinerary.title) {
                    showConfirmationAddDuplicateItinerary = true
                } else {
                    itineraryStore.addItineraryFromWatchMessageData(itinerary: validItinerary, duplicateOption: .noDuplicate)
                }
            }
        }
        .confirmationDialog("‘\(appDelegate.newItinerary?.title ?? "Unknown")’ already exists", isPresented: $showConfirmationAddDuplicateItinerary) {
            // we only get called when appDelegate.newItinerary is non-nil so !
            if let validItinerary = appDelegate.newItinerary {
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
