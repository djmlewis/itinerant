//
//  SettingsView.swift
//  itinerant
//
//  Created by David JM Lewis on 30/01/2023.
//

import SwiftUI
import WatchConnectivity

struct SettingsViewStageColours: View {
    var title: String
    var imageName: String
    @Binding var colourBackground: Color
    @Binding var colourForeground: Color

    var body: some View {
        VStack {
            Label(title, systemImage: imageName)
            HStack {
                Spacer()
                Image(systemName: "character.textbox")
                ColorPicker("", selection: $colourBackground)
                    .frame(maxWidth: 28)
                Spacer()
                    .frame(maxWidth: 32)
                ColorPicker("", selection: $colourForeground)
                    .frame(maxWidth: 28)
                Image(systemName: "textformat")
                    .padding(.leading, 8)
                Spacer()
            }
        }
        .settingsColours(background: colourBackground, foreground: colourForeground)
    }
}


struct SettingsView: View {
    @Binding var urlToOpen: URL?
    @Binding var itinerary: Itinerary?
    
    var settingGlobals: Bool { itinerary == nil }
    
    @EnvironmentObject var itineraryStore: ItineraryStore


    @State private var prefColourInactive: Color = kAppStorageDefaultColourStageInactive.rgbaColor!
    @State private var prefColourActive: Color = kAppStorageDefaultColourStageActive.rgbaColor!
    @State private var prefColourRunning: Color = kAppStorageDefaultColourStageRunning.rgbaColor!
    @State private var prefColourComment: Color = kAppStorageDefaultColourStageComment.rgbaColor!

    @State private var prefColourFontInactive: Color = kAppStorageDefaultColourFontInactive.rgbaColor!
    @State private var prefColourFontActive: Color = kAppStorageDefaultColourFontActive.rgbaColor!
    @State private var prefColourFontRunning: Color = kAppStorageDefaultColourFontRunning.rgbaColor!
    @State private var prefColourFontComment: Color = kAppStorageDefaultColourFontComment.rgbaColor!

    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var appSettingsObject: SettingsColoursObject
    @Environment(\.dismiss) var dismiss

    @State var fileSaverShown: Bool = false
    @State var settingsSaveDocument: ItineraryFile?
    @State var fileImporterShown: Bool = false

    @State var progressViewShown: Bool = false

    
    var body: some View {
        if progressViewShown {
            ProgressView()
        }
        List {
            Section {
                SettingsViewStageColours(title: "Comments", imageName: "bubble.left", colourBackground: $prefColourComment, colourForeground: $prefColourFontComment)
                SettingsViewStageColours(title: "Active", imageName: "play.circle.fill", colourBackground: $prefColourActive, colourForeground: $prefColourFontActive)
                SettingsViewStageColours(title: "Running", imageName: "stop.circle", colourBackground: $prefColourRunning, colourForeground: $prefColourFontRunning)
                SettingsViewStageColours(title: "Inactive", imageName: "zzz", colourBackground: $prefColourInactive, colourForeground: $prefColourFontInactive)
            } header: {
                HStack {
                    Text("Background & Text Colours")
                }
            }
            /* Section */
        } /* List */
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(settingGlobals ? "Global Settings" : "Itinerary Settings")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem() {
                Menu {
                    if !deviceIsIpadOrMac() && !watchConnectionUnusable() {
                        Button(action: {
                            sendSettingsToWatch()
                        }) {
                            Label("Send To Watch…", systemImage: "square.and.arrow.down.fill")
                        }
                        .disabled(watchConnectionUnusable())
                        Button(action: {
                            getSendSettingsFromWatch()
                        }) {
                            Label("Get from Watch…", systemImage: "square.and.arrow.up.fill")
                        }
                        .disabled(watchConnectionUnusable())
                        Divider()
                   }
                    Button(action: {
                        settingsSaveDocument = ItineraryFile(settingsDict: self.settingsDictWithTypeKey(nil))
                        fileSaverShown = true
                    }) {
                        Label("Export…", systemImage: "square.and.arrow.up")
                    }
                    Button(action: {
                        fileImporterShown = true
                    }) {
                        Label("Import…", systemImage: "square.and.arrow.down")
                    }
                    Divider()
                    if !settingGlobals {
                        Button(role: .destructive, action: {
                            resetColoursToAppCurrentValues()
                        }) {
                            Label("Apply Global Settings", systemImage: "gear")
                        }
                    } else {
                        Button(role: .destructive, action: {
                            resetColoursToStaticDefaults()
                        }) {
                            Label("Reset To Defaults", systemImage: "xmark.circle")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Apply") {
                    saveChangedSettings()
                    dismiss()
                }
            }
        }
        .onAppear {
            handleOnAppear()
        }
        .fileExporter(isPresented: $fileSaverShown,
                      document: settingsSaveDocument,
                      contentType: .itinerarySettingsFile,
                      defaultFilename: "Settings") { result in
            switch result {
            case .success:
                break
            case .failure:
                break
            }
        } /* fileExporter */
      .fileImporter(isPresented: $fileImporterShown, allowedContentTypes: [.itinerarySettingsFile], onCompletion: { (result) in
          // fileImporter in single file selection mode
          switch result {
          case .success(let selectedFileURL):
              if selectedFileURL.startAccessingSecurityScopedResource() {
                  readSettingsFromFileAtPath(selectedFileURL.path)
              }
              selectedFileURL.stopAccessingSecurityScopedResource()
          case .failure://(let error):
              break
          }
      }) /* fileImporter */
    } /* body */
} /* struct */


extension SettingsView {
    
    func handleOnAppear() {
        if urlToOpen == nil {
            if settingGlobals || itinerary?.settingsColoursStruct == nil { setupPrefsFromSettingsColoursStruct(appSettingsObject.settingsColoursStruct) }
            else { // itinerary is non-nil if not settingGlobals, so itinerary!.settingsColoursStruct must be non-nil too
                setupPrefsFromSettingsColoursStruct((itinerary?.settingsColoursStruct)!)
            }
        } else {
            readSettingsFromFileAtPath(urlToOpen!.path(percentEncoded: false))
            urlToOpen = nil
       }
    }
    
    func saveChangedSettings() {
        let settingsStruct = SettingsColoursStruct(colourStageInactive: prefColourInactive, colourStageActive: prefColourActive, colourStageRunning: prefColourRunning, colourStageComment: prefColourComment, colourFontInactive: prefColourFontInactive, colourFontActive: prefColourFontActive, colourFontRunning: prefColourFontRunning, colourFontComment: prefColourFontComment)
        DispatchQueue.main.async {
            if settingGlobals { appDelegate.updateSettingsFromSettingsStructColours(settingsStruct) }
            else {
                // the local itinerary is not bound to the itineraryStore so we must update both entities
                if let idstr = itinerary?.idStr { itineraryStore.updateItineraryWithID(idstr, withSettingsColoursStruct: settingsStruct) }
                itinerary?.updateSettingsColourStruct(newStruct: settingsStruct)
            }
        }
    }
    
    func setupPrefsFromSettingsColoursStruct(_ csstruct: SettingsColoursStruct) {
        DispatchQueue.main.async {
            prefColourInactive = csstruct.colourStageInactive
            prefColourActive = csstruct.colourStageActive
            prefColourRunning = csstruct.colourStageRunning
            prefColourComment = csstruct.colourStageComment
            
            prefColourFontInactive = csstruct.colourFontInactive
            prefColourFontActive = csstruct.colourFontActive
            prefColourFontRunning = csstruct.colourFontRunning
            prefColourFontComment = csstruct.colourFontComment
        }
    }
    
    func resetAllSettingsToStaticDefaults() {
        resetColoursToStaticDefaults()
    }
    
    func resetColoursToStaticDefaults() {
       DispatchQueue.main.async {
            prefColourInactive = kAppStorageDefaultColourStageInactive.rgbaColor!
            prefColourActive = kAppStorageDefaultColourStageActive.rgbaColor!
            prefColourRunning = kAppStorageDefaultColourStageRunning.rgbaColor!
            prefColourComment = kAppStorageDefaultColourStageComment.rgbaColor!

            prefColourFontInactive = kAppStorageDefaultColourFontInactive.rgbaColor!
            prefColourFontActive = kAppStorageDefaultColourFontActive.rgbaColor!
            prefColourFontRunning = kAppStorageDefaultColourFontRunning.rgbaColor!
            prefColourFontComment = kAppStorageDefaultColourFontComment.rgbaColor!
        }
    }
    
    func resetColoursToAppCurrentValues() {
        DispatchQueue.main.async {
            prefColourInactive = appSettingsObject.colourStageInactive
            prefColourActive = appSettingsObject.colourStageActive
            prefColourRunning = appSettingsObject.colourStageRunning
            prefColourComment = appSettingsObject.colourStageComment

            prefColourFontInactive = appSettingsObject.colourFontInactive
            prefColourFontActive = appSettingsObject.colourFontActive
            prefColourFontRunning = appSettingsObject.colourFontRunning
            prefColourFontComment = appSettingsObject.colourFontComment
        }
    }
    
    func resetColoursToItineraryCurrentValues() {
        if let itinerarySettings = itinerary?.settingsColoursStruct {
            DispatchQueue.main.async {
                prefColourInactive = itinerarySettings.colourStageInactive
                prefColourActive = itinerarySettings.colourStageActive
                prefColourRunning = itinerarySettings.colourStageRunning
                prefColourComment = itinerarySettings.colourStageComment
                
                prefColourFontInactive = itinerarySettings.colourFontInactive
                prefColourFontActive = itinerarySettings.colourFontActive
                prefColourFontRunning = itinerarySettings.colourFontRunning
                prefColourFontComment = itinerarySettings.colourFontComment
            }
        }
    }
    
// MARK: Settings Dict Export Import
    
    func readSettingsFromFileAtPath(_ filePath:String) {
        if let fileData = FileManager.default.contents(atPath: filePath) {
            if let dict: [String:String] = try? JSONDecoder().decode([String:String].self, from: fileData) {
                loadSettingsFromDict(dict)
            } else {
                debugPrint("readSettingsFromFileAtPath Decode failure for: \(filePath)")
            }
        } else {
            debugPrint("No fileData for: \(filePath)")
        }

    }

    func settingsDictWithTypeKey(_ typekey: String?) -> [String:String] {
        //debugPrint("settingsDictWithTypeKey")
        var settingsDict = [String:String]()
        if let rgbaInactive = prefColourInactive.rgbaString { settingsDict[kAppStorageColourStageInactive] = rgbaInactive }
        if let rgbaActive = prefColourActive.rgbaString { settingsDict[kAppStorageColourStageActive] = rgbaActive }
        if let rgbaRun = prefColourRunning.rgbaString  { settingsDict[kAppStorageColourStageRunning] = rgbaRun }
        if let rgbaComm = prefColourComment.rgbaString  { settingsDict[kAppStorageColourStageComment] = rgbaComm }

        if let frgbaInactive = prefColourFontInactive.rgbaString { settingsDict[kAppStorageColourFontInactive] = frgbaInactive }
        if let frgbaActive = prefColourFontActive.rgbaString { settingsDict[kAppStorageColourFontActive] = frgbaActive }
        if let frgbaRun = prefColourFontRunning.rgbaString  { settingsDict[kAppStorageColourFontRunning] = frgbaRun }
        if let frgbaComm = prefColourFontComment.rgbaString  { settingsDict[kAppStorageColourFontComment] = frgbaComm }
        
        guard typekey != nil else { return settingsDict }
        settingsDict[kUserInfoMessageTypeKey] = typekey!
        return settingsDict
    }

    func loadSettingsFromDict(_ settingsDict: [String:String]) {
        // applies to this view only
        DispatchQueue.main.async {
            if let rgbaInactive = settingsDict[kAppStorageColourStageInactive]?.rgbaColor { prefColourInactive = rgbaInactive }
            if let rgbaActive = settingsDict[kAppStorageColourStageActive]?.rgbaColor { prefColourActive = rgbaActive }
            if let rgbaRun = settingsDict[kAppStorageColourStageRunning]?.rgbaColor  { prefColourRunning = rgbaRun }
            if let rgbaComm = settingsDict[kAppStorageColourStageComment]?.rgbaColor  { prefColourComment = rgbaComm }
            
            if let frgbaInactive = settingsDict[kAppStorageColourFontInactive]?.rgbaColor { prefColourFontInactive = frgbaInactive }
            if let frgbaActive = settingsDict[kAppStorageColourFontActive]?.rgbaColor { prefColourFontActive = frgbaActive }
            if let frgbaRun = settingsDict[kAppStorageColourFontRunning]?.rgbaColor  { prefColourFontRunning = frgbaRun }
            if let frgbaComm = settingsDict[kAppStorageColourFontComment]?.rgbaColor  { prefColourFontComment = frgbaComm }
        }
    }
    
    func sendSettingsToWatch()  {
        appDelegate.sendMessageOrData(dict: self.settingsDictWithTypeKey(kMessageFromPhoneWithSettingsData), data: nil)
    }

    func getSendSettingsFromWatch() {
        DispatchQueue.main.async {
            progressViewShown = true
        }
        WCSession.default.sendMessage([kUserInfoMessageTypeKey : kMessageFromPhoneRequestingSettingsData]) { replyDict in
            debugPrint("inside getSendSettingsFromWatch replyHandler")
            if replyDict[kUserInfoMessageTypeKey] as! String == kMessageFromWatchWithSettingsData {
                DispatchQueue.main.async {
                    self.loadSettingsFromDict(replyDict as! [String:String])
                    progressViewShown = false
                }
            } else {
                DispatchQueue.main.async {
                    progressViewShown = false
                }
            }
        }
    }

}

struct SettingsColours: ViewModifier {
    let background: Color
    let foreground: Color

    func body(content: Content) -> some View {
        content
            .padding(6)
            .background(background)
            .foregroundColor(foreground)
            .cornerRadius(4)
    }
}
extension View {
    func settingsColours(background: Color, foreground: Color) -> some View {
        modifier(SettingsColours(background: background, foreground: foreground))
    }
}
