//
//  ContentView.swift
//  itinerant Watch App
//
//  Created by David JM Lewis on 30/12/2022.
//

import SwiftUI
import WatchConnectivity

let names: [String] = ["iphone.gen3","arrowshape.right","applewatch"]

struct WKItinerantStoreView: View {
    @SceneStorage(kSceneStoreUuidStrStageActive) var uuidStrStagesActiveStr: String = ""
    @SceneStorage(kSceneStoreUuidStrStageRunning) var uuidStrStagesRunningStr: String = ""
    @SceneStorage(kSceneStoreDictStageStartDates) var dictStageStartDates: [String:String] = [:]
    @SceneStorage(kSceneStoreDictStageEndDates) var dictStageEndDates: [String:String] = [:]

    @EnvironmentObject var itineraryStore: ItineraryStore
    @EnvironmentObject private var appDelegate: AppDelegate
    
    @State private var presentedItineraryID: [String] = []
    @State private var showConfirmationAddDuplicateItinerary: Bool = false
    
    @AppStorage(kAppStorageColourStageRunning) var appStorageColourStageRunning: String = kAppStorageDefaultColourStageRunning
    @AppStorage(kAppStorageColourFontRunning) var appStorageColourFontRunning: String = kAppStorageDefaultColourFontRunning
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack(path: $presentedItineraryID) {
            List {
                ForEach($itineraryStore.itineraries.map({ $0.id.uuidString}), id:\.self) { itineraryID in
                    NavigationLink(value: itineraryID) {
                        VStack(spacing: 0.0) {
                            Text(itineraryStore.itineraryTitleForID(id: itineraryID))
                                .font(.system(.title3, design: .rounded, weight: .semibold))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                           if let date = itineraryStore.itineraryModificationDateForID(id: itineraryID) {
                                HStack {
                                    Image(systemName:"square.and.pencil")
                                    Text(date.formatted(date: .numeric, time: .shortened))
                                        .lineLimit(1)
                                        .allowsTightening(true)
                                        .minimumScaleFactor(0.5)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                               }
                                .font(.system(.caption, design: .rounded, weight: .regular))
                                .opacity(0.6)
                            }
                     }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .listItemTint(backgroundColourForID(itineraryID))
                    .foregroundColor(textColourForID(itineraryID))
                } /* ForEach */
                .onDelete(perform: { offsets in
                    // remove all references to any stage ids for these itineraries first. offsets is the indexset
                    removeItinerariesAtOffsets(offsets)
                })
                
            } /* List */
            .navigationDestination(for: String.self) { id in
                ItineraryActionCommonView(itinerary: itineraryStore.itineraryForID(id: id) ?? Itinerary.errorItinerary(), uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates, dictStageEndDates: $dictStageEndDates)
            }
            .navigationTitle("Itineraries")
            .toolbar{
                Button(action: {
                    requestItinerariesSync()
                }, label: {
                    Text("Sync \(Image(systemName: "iphone.gen3")) \(Image(systemName: "arrowshape.right")) \(Image(systemName: "applewatch"))")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                })
                .tint(.accentColor)
                .padding()
            }

            
        }
        .onChange(of: appDelegate.unnItineraryToOpenID) { newValue in
            // handle notifications to switch itinerary
            guard newValue != nil && itineraryStore.hasItineraryWithID(newValue!) else { return }
            presentedItineraryID = [newValue!]
        }
        .onChange(of: appDelegate.newItinerary) { itineraryToAdd in
            // for messages with Itinerary to load
            if let validItinerary = itineraryToAdd {
                if itineraryStore.hasItineraryWithUUID(validItinerary.id) || itineraryStore.hasItineraryWithTitle(validItinerary.title) {
                    showConfirmationAddDuplicateItinerary = true
                } else {
                    itineraryStore.addItineraryFromWatchMessage(itinerary: validItinerary, duplicateOption: .noDuplicate)
                }
            }
        }
        .confirmationDialog("‘\(appDelegate.newItinerary?.title ?? "Unknown")’ appears to be a duplicate",
                            isPresented: $showConfirmationAddDuplicateItinerary) {
            if let validItinerary = appDelegate.newItinerary {
                Button("Replace Existing", role: .destructive, action: {
                    itineraryStore.addItineraryFromWatchMessage(itinerary: validItinerary,duplicateOption: .replaceExisting)
                })
                Button("Keep Both", role: nil, action: {
                    itineraryStore.addItineraryFromWatchMessage(itinerary: validItinerary ,duplicateOption: .keepBoth)
                })
                Button("Skip", role: nil, action: { })
            }
        }
    } /* View */
    
}


extension WKItinerantStoreView {
    
    func removeItinerariesAtOffsets(_ offsets: IndexSet) {
        // remove all references to any stage ids for these itineraries first. offsets is the indexset
        offsets.forEach { index in
            (uuidStrStagesActiveStr,uuidStrStagesRunningStr,dictStageStartDates,dictStageEndDates) = itineraryStore.itineraries[index].removeAllStageIDsAndNotifcationsFrom(str1: uuidStrStagesActiveStr, str2: uuidStrStagesRunningStr, dict1: dictStageStartDates, dict2: dictStageEndDates)
        }
        // now its safe to delete those Itineraries
        itineraryStore.removeItinerariesAtOffsets(offsets: offsets)
    }
    
    func requestItinerariesSync() {
        if WCSession.default.isReachable {
            //debugPrint("sending by message")
            WCSession.default.sendMessage([kUserInfoMessageTypeKey : kMessageFromWatchRequestingItinerariesSync]) { replyDict in
                if replyDict[kUserInfoMessageTypeKey] as! String == kMessageFromPhoneStandingByToSync {
                    // dont bother to erase and we will check clashes
//                    if !itineraryStore.itineraries.isEmpty { removeItinerariesAtOffsets(IndexSet(integersIn: itineraryStore.itineraries.startIndex..<itineraryStore.itineraries.endIndex)) }
                    WCSession.default.sendMessage([kUserInfoMessageTypeKey : kMessageFromWatchInitiateSyncNow], replyHandler: nil)
                }

            }
        }
    }

    
    func textColourForID(_ itineraryID: String) -> Color? {
        return itineraryStore.itineraryForIDisRunning(id: itineraryID, uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? appStorageColourFontRunning.rgbaColor : (textColourForScheme(colorScheme: colorScheme))
    }
    func backgroundColourForID(_ itineraryID: String) -> Color? {
        return itineraryStore.itineraryForIDisRunning(id: itineraryID, uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? appStorageColourStageRunning.rgbaColor : Color.clear
    }

}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello World")
    }
}
