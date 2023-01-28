//
//  ContentView.swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import SwiftUI
import UniformTypeIdentifiers.UTType



struct ItineraryStoreView: View {
    
    @SceneStorage(kSceneStoreUuidStrStageActive) var uuidStrStagesActiveStr: String = ""
    @SceneStorage(kSceneStoreUuidStrStageRunning) var uuidStrStagesRunningStr: String = ""
    @SceneStorage(kSceneStoreDictStageStartDates) var dictStageStartDates: [String:String] = [:]

    @EnvironmentObject var itineraryStore: ItineraryStore
    @EnvironmentObject private var appDelegate: AppDelegate
        
    @State private var isPresentingItineraryEditView = false
    @State private var isPresentingNewItineraryView = false
    @State private var newItinerary = Itinerary(title: "",modificationDate: nowReferenceDateTimeInterval())
    @State private var newItineraryEditableData = Itinerary.EditableData()
    @State private var fileImporterShown: Bool = false
    
    @State private var presentedItineraryID: [String] = []

    
    var body: some View {
        NavigationStack(path: $presentedItineraryID) {
            List {
                ForEach($itineraryStore.itineraries.map({ $0.id.uuidString}), id:\.self) { itineraryID in
                    NavigationLink(value: itineraryID) {
                        HStack {
                            Text(itineraryStore.itineraryTitleForID(id: itineraryID))
                                .font(.title)
                                .subtitledLabel(with: itineraryStore.itineraryFileNameForID(id: itineraryID), iconName: "doc", stackAlignment: .leading, subtitleAlignment: .trailing)
                            Spacer()
                            ProgressView()
                                .opacity(itineraryStore.itineraryForID(id: itineraryID).hasRunningStage(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? 1.0 : 0.0)
                                .tint(Color("ColourBackgroundRunning"))
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
                ItineraryActionView(itinerary: itineraryStore.itineraryForID(id: id), uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates)
            }
            .navigationTitle("Itineraries")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: {
                            //fileImportFileType = .itineraryImportFile
                            fileImporterShown = true
                        }) {
                            Label("Import file…", systemImage: "doc")
                        }
                        Button(action: {
                            itineraryStore.reloadItineraries()
                        }) {
                            Label("Refresh list…", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Label("Load…", systemImage: "square.and.arrow.down")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        newItinerary = Itinerary(title: "",modificationDate: nowReferenceDateTimeInterval())
                        newItineraryEditableData = Itinerary.EditableData()
                        isPresentingItineraryEditView = true
                    }) {
                        Image(systemName: "plus")
                    }
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
                                    // set the filename first before any updates
                                    newItinerary.filename = Itinerary.uniqueifiedDataFileNameWithoutExtensionFrom(nameOnly: newItineraryEditableData.title)
                                    newItinerary.updateItineraryEditableData(from: newItineraryEditableData)
                                    itineraryStore.addItinerary(itinerary: newItinerary)
                                    itineraryStore.sortItineraries()
                                    isPresentingItineraryEditView = false
                                }
                            }
                        }
                }
            }
        } /* NavStack */
        .onChange(of: appDelegate.unnItineraryID) { newValue in
            // handle notifications to switch itinerary
            guard newValue != nil && itineraryStore.hasItineraryWithID(newValue!) else { return }
            presentedItineraryID = [newValue!]
        }
        .fileImporter(isPresented: $fileImporterShown, allowedContentTypes: [.itineraryDataFile,.itineraryImportFile], onCompletion: { (result) in
            // fileImporter in single file selection mode
            switch result {
            case .success(let selectedFileURL):
                if selectedFileURL.startAccessingSecurityScopedResource() {
                    switch selectedFileURL.pathExtension {
                    case ItineraryFileExtension.dataFile.rawValue:
                        itineraryStore.loadItinerary(atPath: selectedFileURL.path, importing: true)
                    case ItineraryFileExtension.importFile.rawValue:
                        itineraryStore.importItinerary(atPath: selectedFileURL.path)
                    default:
                        break
                    }
                }
                selectedFileURL.stopAccessingSecurityScopedResource()
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
