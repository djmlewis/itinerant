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
    
    @State  var presentedItineraryID: [String] = []
    @State  var showSettingsView: Bool = false
    @State  var openRequestURL: URL?
    @State  var isPresentingConfirmOpenURL: Bool = false
    @State  var showInvalidFileAlert: Bool = false
    @State  var invalidFileName: String = ""
    @State  var stageIDsToDelete: [String] = [String]()
    @State  var lineHeights: [String:CGFloat] = [String:CGFloat]()

    @AppStorage(kAppStorageColourStageRunning) var appStorageColourStageRunning: String = kAppStorageDefaultColourStageRunning
    @AppStorage(kAppStorageColourFontRunning) var appStorageColourFontRunning: String = kAppStorageDefaultColourFontRunning
    @Environment(\.colorScheme) var colorScheme
    
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
                    presentedItineraryID = []
                    itineraryIDselected = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                        presentedItineraryID = [newValue!] // stack
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
    func textColourForID(_ itineraryID: String) -> Color? {
        return itineraryStore.itineraryForIDisRunning(id: itineraryID, uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? appStorageColourFontRunning.rgbaColor : (textColourForScheme(colorScheme: colorScheme))
    }
    func backgroundColourForID(_ itineraryID: String) -> Color? {
        return itineraryStore.itineraryForIDisRunning(id: itineraryID, uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? appStorageColourStageRunning.rgbaColor : Color.clear
    }

    func buttonStartHalt(forItineraryID itineraryID: String) -> some View {
        Button(action: {
            // Only Stop
            if let itinerary = itineraryStore.itineraryForID(id: itineraryID),
                let stageRunning = itinerary.stageRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) {
                appDelegate.unnItineraryToOpenID = nil
                appDelegate.unnStageToHaltID = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    appDelegate.unnItineraryToOpenID = itinerary.idStr
                    appDelegate.unnStageToHaltID = stageRunning.idStr
                }
            }
        })
        {
            Image(systemName: "stop.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color.red)
                .background(.white)
                .padding(3)
                .border(.white, width: 3)
                .clipShape(Circle())
                .padding(0)

        }
        .buttonStyle(BorderlessButtonStyle())
        .frame(width: 46, alignment: .leading)
        .padding(4)
    }
    
    struct TitleMeasuringPreferenceKey: PreferenceKey {
        static var defaultValue: CGSize = .zero
        static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
    }
    struct TitleMeasuringModifier: ViewModifier {
        private var sizeView: some View { GeometryReader { Color.clear.preference(key: TitleMeasuringPreferenceKey.self, value: $0.size) } }
        func body(content: Content) -> some View {  content.background(sizeView) }
    }


}

struct ItineraryStoreView_Previews: PreviewProvider {
    static var previews: some View {
        Text("yo")
    }
}



