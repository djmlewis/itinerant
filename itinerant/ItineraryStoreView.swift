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
    @SceneStorage(kSceneStoreDictStageEndDates) var dictStageEndDates: [String:String] = [:]

    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var itineraryStore: ItineraryStore

    @State private var isPresentingItineraryEditView = false
    @State private var isPresentingNewItineraryView = false
    @State private var newItinerary = Itinerary(title: "",modificationDate: nowReferenceDateTimeInterval())
    @State private var newItineraryEditableData = Itinerary.EditableData()
    @State private var fileImporterShown: Bool = false
    
    @State private var presentedItineraryID: [String] = []
    @State private var showSettingsView: Bool = false
    
    
    @AppStorage(kAppStorageColourStageRunning) var appStorageColourStageRunning: String = kAppStorageDefaultColourStageRunning
    @AppStorage(kAppStorageColourFontRunning) var appStorageColourFontRunning: String = kAppStorageDefaultColourFontRunning
    @Environment(\.colorScheme) var colorScheme
    func textColourForID(_ itineraryID: String) -> Color? {
        return itineraryStore.itineraryForIDisRunning(id: itineraryID, uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? appStorageColourFontRunning.rgbaColor : (colorScheme == .dark ? .white : .black)
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
                            HStack(alignment: .center) {
                                Image(systemName: "doc")
                                Text(itineraryStore.itineraryFileNameForID(id: itineraryID))
                                Spacer()
                                if let date = itineraryStore.itineraryModificationDateForID(id: itineraryID) {
                                    Image(systemName:"square.and.pencil")
                                    Text(date.formatted(date: .numeric, time: .shortened))
                                }
                            }
                            .font(.system(.subheadline, design: .rounded, weight: .regular))
                            .lineLimit(1)
                            .allowsTightening(true)
                            .minimumScaleFactor(0.5)
                            .opacity(0.6)
                        }
                        .foregroundColor(textColourForID(itineraryID))
                  }
                    .listRowBackground(backgroundColourForID(itineraryID))
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            //fileImportFileType = .itineraryImportFile
                            fileImporterShown = true
                        }) {
                            Label("Import…", systemImage: "square.and.arrow.down")
                        }
                        Button(action: {
                            itineraryStore.reloadItineraries()
                        }) {
                            Label("Refresh…", systemImage: "arrow.counterclockwise.circle.fill")
                        }
                        Button(action: {
                            showSettingsView = true
                        }) {
                            Label("Settings…", systemImage: "gear")
                        }
                    } label: {
                        Label("", systemImage: "ellipsis.circle")
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
                NavigationStack {
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
        .onChange(of: appDelegate.unnItineraryToOpenID) { newValue in
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
