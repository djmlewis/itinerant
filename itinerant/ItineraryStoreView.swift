//
//  ContentView.swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import SwiftUI
import UniformTypeIdentifiers.UTType



struct ItineraryStoreView: View {
    @AppStorage(kAppStorageColourStageInactive) var appStorageColourStageInactive: String = kAppStorageDefaultColourStageInactive
    @AppStorage(kAppStorageColourStageActive) var appStorageColourStageActive: String = kAppStorageDefaultColourStageActive
    @AppStorage(kAppStorageColourStageRunning) var appStorageColourStageRunning: String = kAppStorageDefaultColourStageRunning
    @AppStorage(kAppStorageStageInactiveTextDark) var appStorageStageInactiveTextDark: Bool = true
    @AppStorage(kAppStorageStageActiveTextDark) var appStorageStageActiveTextDark: Bool = true
    @AppStorage(kAppStorageStageRunningTextDark) var appStorageStageRunningTextDark: Bool = true

    @SceneStorage(kSceneStoreUuidStrStageActive) var uuidStrStagesActiveStr: String = ""
    @SceneStorage(kSceneStoreUuidStrStageRunning) var uuidStrStagesRunningStr: String = ""
    @SceneStorage(kSceneStoreDictStageStartDates) var dictStageStartDates: [String:String] = [:]

    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var itineraryStore: ItineraryStore

    @State private var isPresentingItineraryEditView = false
    @State private var isPresentingNewItineraryView = false
    @State private var newItinerary = Itinerary(title: "",modificationDate: nowReferenceDateTimeInterval())
    @State private var newItineraryEditableData = Itinerary.EditableData()
    @State private var fileImporterShown: Bool = false
    
    @State private var presentedItineraryID: [String] = []
    @State private var showSettingsView: Bool = false
    
    
    func textColourForID(_ itineraryID: String) -> Color {
        return itineraryStore.itineraryForIDisRunning(id: itineraryID, uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? (appStorageStageRunningTextDark == true ? .black : .white) : .black
    }
    func backgroundColourForID(_ itineraryID: String) -> Color? {
        return itineraryStore.itineraryForIDisRunning(id: itineraryID, uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? appStorageColourStageRunning.rgbaColor : Color.clear
    }

    
    var body: some View {
        NavigationStack(path: $presentedItineraryID) {
            List {
                ForEach(itineraryStore.itineraryUUIDStrs, id:\.self) { itineraryID in
                    NavigationLink(value: itineraryID) {
                        VStack(alignment: .leading, spacing: 5.0) {
                            Text(itineraryStore.itineraryTitleForID(id: itineraryID))
                                .font(.system(.title, design: .rounded, weight: .semibold))
                            Label(itineraryStore.itineraryFileNameForID(id: itineraryID), systemImage: "doc")
                                .labelStyle(.titleAndIcon)
                                .italic()
                                .font(.subheadline)
                        }
                        .foregroundColor(textColourForID(itineraryID))
                  }
                    .listRowBackground(backgroundColourForID(itineraryID))
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
                ItineraryActionView(itinerary: itineraryStore.itineraryForID(id: id) ?? Itinerary.errorItinerary(), uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates)
           }
            .navigationTitle("Itineraries")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showSettingsView = true
                    }) {
                        Label("Settings…", systemImage: "gear")
                    }
                }
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
            .sheet(isPresented: $showSettingsView, content: {
                NavigationStack {
                    SettingsView(showSettingsView: $showSettingsView/*, appStorageColourStageActive: $appStorageColourStageActive, appStorageColourStageRunning: $appStorageColourStageRunning*/)
                }
            })
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
        Text("yo")
    }
}
