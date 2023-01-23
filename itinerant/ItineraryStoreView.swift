//
//  ContentView.swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import SwiftUI

let kSceneStoreUuidStrStageActive = "uuidStrStageActiveStr"
let kSceneStoreUuidStrStageRunning = "uuidStrStageRunningStr"
let kSceneStoreUuidStrItineraryResetView = "kSceneStoreUuidStrItineraryResetView"


struct ItineraryStoreView: View {
    
    @SceneStorage(kSceneStoreUuidStrStageActive) var uuidStrStagesActiveStr: String = ""
    @SceneStorage(kSceneStoreUuidStrStageRunning) var uuidStrStagesRunningStr: String = ""

    @EnvironmentObject var itineraryStore: ItineraryStore
    @EnvironmentObject private var appDelegate: AppDelegate
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var isPresentingItineraryEditView = false
    @State private var isPresentingNewItineraryView = false
    @State private var newItinerary = Itinerary(title: "")
    @State private var newItineraryEditableData = Itinerary.EditableData()
    @State private var fileImporterShown: Bool = false
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
                        (uuidStrStagesActiveStr,uuidStrStagesRunningStr) = itineraryStore.itineraries[index].removeAllStageIDsAndNotifcations(from: uuidStrStagesActiveStr, andFrom: uuidStrStagesRunningStr)
                    }
                    // now its safe to delete those Itineraries
                    itineraryStore.removeItinerariesAtOffsets(offsets: offsets)
                })
            }
            .navigationDestination(for: String.self) { id in
                ItineraryActionView(itinerary: itineraryStore.itineraryForID(id: id), uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr)
            }
            .navigationTitle("Itineraries")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: {
                        fileImporterShown = true
                    }) {
                        Image(systemName: "square.and.arrow.down")
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
        } /* NavStack */
        .onChange(of: appDelegate.unnItineraryID) { newValue in
            //debugPrint("change of " + String(describing: newValue))
            guard newValue != nil && itineraryStore.hasItineraryWithID(newValue!) else { return }
            presentedItineraryID = [newValue!]
        }
        .fileImporter(isPresented: $fileImporterShown, allowedContentTypes: [.text,.plainText,.utf8PlainText], allowsMultipleSelection: false, onCompletion: { (result) in
            switch result {
            case .success(let urls):
                do {
                    let selectedFile = urls[0]
                    if selectedFile.startAccessingSecurityScopedResource() {
                        let content = try String(contentsOfFile: selectedFile.path)
                        if let importedItinerary = Itinerary.importItinerary(fromString: content) {
                            itineraryStore.addItinerary(itinerary: importedItinerary)
                        }
                    }
                    selectedFile.stopAccessingSecurityScopedResource()
                }
                catch let error {
                    debugPrint("unable to read import file", error.localizedDescription)
                }
                break
            case .failure(let error):
                debugPrint(error)
            }
        }) /* fileImporter */

    } /* body */
} /* View */


struct ItineraryStoreView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack() {
        }
    }
}
