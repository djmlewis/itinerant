//
//  ContentView.swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import SwiftUI
import UniformTypeIdentifiers.UTType
import UIKit.UIDevice


struct ItineraryStoreView: View {

    @SceneStorage(kSceneStoreUuidStrStageActive) var uuidStrStagesActiveStr: String = ""
    @SceneStorage(kSceneStoreUuidStrStageRunning) var uuidStrStagesRunningStr: String = ""
    @SceneStorage(kSceneStoreDictStageStartDates) var dictStageStartDates: [String:String] = [:]
    @SceneStorage(kSceneStoreDictStageEndDates) var dictStageEndDates: [String:String] = [:]

    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var itineraryStore: ItineraryStore

    @State  var isPresentingItineraryEditView = false
    @State  var isPresentingNewItineraryView = false
    @State  var newItineraryEditableData = Itinerary.EditableData()
    @State  var fileImporterShown: Bool = false
    @State  var fileImportFileType: [UTType] = [.itineraryDataPackage]
    
    @State  var showSettingsView: Bool = false
    @State  var openRequestURL: URL?
    @State  var isPresentingConfirmOpenURL: Bool = false
    @State  var showInvalidFileAlert: Bool = false
    @State  var invalidFileName: String = ""
    @State  var stageIDsToDelete: [String] = [String]()
    
    // NavStack
    @State  var presentedItineraryIDsStackArray: [String] = []

    // split nav
    @State var itineraryIDselected: String?
    @State var columnVisibility = NavigationSplitViewVisibility.all

    
    
   @ViewBuilder  var body_: some View {
        if deviceIsIpadOrMac() {
            body_split
        } else {
            body_stack
        }

    }
    
    var body: some View {
        body_
            .sheet(isPresented: $showSettingsView, content: {
                NavigationStack {
                    SettingsView(showSettingsView: $showSettingsView, urlToOpen: $openRequestURL)
                }
            })
            .sheet(isPresented: $isPresentingItineraryEditView) {
                NavigationStack {
                    ItineraryEditView(itineraryEditableData: $newItineraryEditableData, stageIDsToDelete: $stageIDsToDelete)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    isPresentingItineraryEditView = false
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Save") {
                                    //$stageIDsToDelete can be ignored as no support files were written until now
                                    DispatchQueue.main.async {
                                        var newItinerary = Itinerary(packageFilePath: dataPackagesDirectoryPathAddingUniqueifiedFileNameWithoutExtension(newItineraryEditableData.title))
                                        newItinerary.updateItineraryEditableData(from: newItineraryEditableData)
                                        itineraryStore.itineraries.append(newItinerary)
                                        itineraryStore.sortItineraries()
                                        isPresentingItineraryEditView = false
                                    }
                                }
                            }
                        }
                }
            }
            .onChange(of: appDelegate.syncItineraries) { doSync in
                guard doSync == true else { return }
                itineraryStore.itineraries.forEach { appDelegate.sendItineraryDataToWatch($0.watchDataKeepingUUID) }
                appDelegate.syncItineraries = false
            }
            .onChange(of: appDelegate.unnItineraryToOpenID) { newValue in
                // handle notifications to switch itinerary
                guard newValue != nil && itineraryStore.hasItineraryWithID(newValue!) else { return }
                // pop back
                DispatchQueue.main.async {
                    presentedItineraryIDsStackArray = []
                    itineraryIDselected = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                        presentedItineraryIDsStackArray = [newValue!] // stack
                        itineraryIDselected = newValue // split
                   }
                }
            }
            .fileImporter(isPresented: $fileImporterShown, allowedContentTypes: fileImportFileType, onCompletion: { (result) in
                // fileImporter in single file selection mode
                switch result {
                case .success(let selectedFileURL):
                    if selectedFileURL.startAccessingSecurityScopedResource() {
                        switch selectedFileURL.pathExtension {
                        case ItineraryFileExtension.dataPackage.rawValue:
                            let pathDelete = itineraryStore.loadItineraryPackage(atPath: selectedFileURL.path)
                            itineraryStore.sortItineraries()
                            if pathDelete != nil {
                                appDelegate.fileDeletePathArray = [pathDelete!]
                                appDelegate.fileDeleteDialogShow = true
                            }
                        case ItineraryFileExtension.textFile.rawValue:
                            if let _ = itineraryStore.importItineraryAtPath(selectedFileURL.path) {
                                invalidFileName = selectedFileURL.path(percentEncoded: false).fileNameWithoutExtensionFromPath
                                showInvalidFileAlert = true
                            }
                        default:
                            break
                        }
                    }
                    selectedFileURL.stopAccessingSecurityScopedResource()
                case .failure(let error):
                    debugPrint(error)
                }
            }) /* fileImporter */
            .alert("Invalid File", isPresented: $showInvalidFileAlert, actions: { }, message: {
                Text(" “\(invalidFileName)” is invalid and cannot be opened")
            })
            .onOpenURL {
                guard ItineraryFileExtension.validExtension($0.pathExtension) else {
                    openRequestURL = nil
                    return
                }
                openRequestURL = $0
                isPresentingConfirmOpenURL = true
            }

    } /* body */
} /* View */

extension ItineraryStoreView {
    var body_stack: some View {
        NavigationStack(path: $presentedItineraryIDsStackArray) {
            List {
                ForEach(itineraryStore.itineraryUUIDStrs, id:\.self) { itineraryID in
                    ItineraryStoreItineraryRowView(itineraryID: itineraryID, uuidStrStagesRunningStr: uuidStrStagesRunningStr)
                        .id(itineraryID)
                } /* ForEach */
                .onDelete(perform: { offsets in deleteItinerariesAtOffsets(offsets) })
            } /* List */
            .navigationDestination(for: String.self) { id in
                ItineraryActionCommonView(itinerary: itineraryStore.itineraryForID(id: id) ?? Itinerary.errorItinerary(), uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates, dictStageEndDates: $dictStageEndDates)
            }
            .modifier(ItineraryStoreViewNavTitleToolBar(showSettingsView: $showSettingsView, itineraryStore: itineraryStore, fileImporterShown: $fileImporterShown, fileImportFileType: $fileImportFileType, newItineraryEditableData: $newItineraryEditableData, isPresentingItineraryEditView: $isPresentingItineraryEditView, openRequestURL: $openRequestURL, isPresentingConfirmOpenURL: $isPresentingConfirmOpenURL))
        } /* NavStack */
    } /* body */

    var body_split: some View {
        NavigationSplitView() {
            List(selection: $itineraryIDselected) {
                ForEach(itineraryStore.itineraryUUIDStrs, id:\.self) { itineraryID in
                    ItineraryStoreItineraryRowView(itineraryID: itineraryID, uuidStrStagesRunningStr: uuidStrStagesRunningStr)
                        .id(itineraryID)
                } /* ForEach */
                .onDelete(perform: { offsets in deleteItinerariesAtOffsets(offsets) })
            } /* List */
            .modifier(ItineraryStoreViewNavTitleToolBar(showSettingsView: $showSettingsView, itineraryStore: itineraryStore, fileImporterShown: $fileImporterShown, fileImportFileType: $fileImportFileType, newItineraryEditableData: $newItineraryEditableData, isPresentingItineraryEditView: $isPresentingItineraryEditView, openRequestURL: $openRequestURL, isPresentingConfirmOpenURL: $isPresentingConfirmOpenURL))
            
        } detail: {
            if let itineraryidselected = itineraryIDselected {
                if let itin = itineraryStore.itineraryForID(id: itineraryidselected) {
                    ItineraryActionCommonView(itinerary: itin, uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates, dictStageEndDates: $dictStageEndDates)
                        .id(itin.idStr)
                }
            }
        } /* detail */
        /* NavSplitView*/
    } /* body */

}

extension ItineraryStoreView {
    
    
    func deleteItinerariesAtOffsets(_ offsets: IndexSet) {
        // remove all references to any stage ids for these itineraries first. offsets is the indexset
        offsets.forEach { index in
            (uuidStrStagesActiveStr,uuidStrStagesRunningStr,dictStageStartDates,dictStageEndDates) = itineraryStore.itineraries[index].removeAllStageIDsAndNotifcationsFrom(str1: uuidStrStagesActiveStr, str2: uuidStrStagesRunningStr, dict1: dictStageStartDates, dict2: dictStageEndDates)
        }
        // now its safe to delete those Itineraries
        itineraryStore.removeItinerariesAtOffsets(offsets: offsets)
        itineraryIDselected = nil
        presentedItineraryIDsStackArray = []
    }
    
}


