//
//  SettingsView.swift
//  itinerant
//
//  Created by David JM Lewis on 30/01/2023.
//

import SwiftUI



struct SettingsView: View {
    @Binding var showSettingsView: Bool
    @Binding var urlToOpen: URL?

    @State private var prefColourInactive: Color = kAppStorageDefaultColourStageInactive.rgbaColor!
    @State private var prefColourActive: Color = kAppStorageDefaultColourStageActive.rgbaColor!
    @State private var prefColourRunning: Color = kAppStorageDefaultColourStageRunning.rgbaColor!
    @State private var prefColourComment: Color = kAppStorageDefaultColourStageComment.rgbaColor!

    @State private var prefColourFontInactive: Color = kAppStorageDefaultColourFontInactive.rgbaColor!
    @State private var prefColourFontActive: Color = kAppStorageDefaultColourFontActive.rgbaColor!
    @State private var prefColourFontRunning: Color = kAppStorageDefaultColourFontRunning.rgbaColor!
    @State private var prefColourFontComment: Color = kAppStorageDefaultColourFontComment.rgbaColor!

    @AppStorage(kAppStorageColourStageInactive) var appStorageColourStageInactive: String = kAppStorageDefaultColourStageInactive
    @AppStorage(kAppStorageColourStageActive) var appStorageColourStageActive: String = kAppStorageDefaultColourStageActive
    @AppStorage(kAppStorageColourStageRunning) var appStorageColourStageRunning: String = kAppStorageDefaultColourStageRunning
    @AppStorage(kAppStorageColourStageComment) var appStorageColourStageComment: String = kAppStorageDefaultColourStageComment
    
    @AppStorage(kAppStorageColourFontInactive) var appStorageColourFontInactive: String = kAppStorageDefaultColourFontInactive
    @AppStorage(kAppStorageColourFontActive) var appStorageColourFontActive: String = kAppStorageDefaultColourFontActive
    @AppStorage(kAppStorageColourFontRunning) var appStorageColourFontRunning: String = kAppStorageDefaultColourFontRunning
    @AppStorage(kAppStorageColourFontComment) var appStorageColourFontComment: String = kAppStorageDefaultColourFontComment

    @EnvironmentObject var appDelegate: AppDelegate

    @State var fileSaverShown: Bool = false
    @State var settingsSaveDocument: ItineraryFile?
    @State var fileImporterShown: Bool = false

    
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "bubble.left")
                    ColorPicker("Comments", selection: $prefColourComment)
                    Image(systemName: "character.textbox")
                    Spacer()
                    ColorPicker("", selection: $prefColourFontComment)
                        .frame(maxWidth: 48)
                    Image(systemName: "textformat")
                }
                .settingsColours(background: prefColourComment, foreground: prefColourFontComment)
                HStack {
                    Image(systemName: "play.circle.fill")
                    ColorPicker("Active", selection: $prefColourActive)
                    Image(systemName: "character.textbox")
                    ColorPicker("", selection: $prefColourFontActive)
                        .frame(maxWidth: 48)
                    Image(systemName: "textformat")
                }
                .settingsColours(background: prefColourActive, foreground: prefColourFontActive)
                HStack {
                    Image(systemName: "stop.circle")
                    ColorPicker("Running", selection: $prefColourRunning)
                    Image(systemName: "character.textbox")
                    Spacer()
                    ColorPicker("", selection: $prefColourFontRunning)
                        .frame(maxWidth: 48)
                    Image(systemName: "textformat")
                }
                .settingsColours(background: prefColourRunning, foreground: prefColourFontRunning)
                HStack {
                    Image(systemName: "zzz")
                    ColorPicker("Inactive", selection: $prefColourInactive)
                    Image(systemName: "character.textbox")
                    Spacer()
                    ColorPicker("", selection: $prefColourFontInactive)
                        .frame(maxWidth: 48)
                    Image(systemName: "textformat")
                }
                .settingsColours(background: prefColourInactive, foreground: prefColourFontInactive)
            } header: {
                HStack {
                    Text("Background & Text Colours")
                    Spacer()
                    Button("Reset", role: .destructive) {
                        resetColoursToDefaults()
                    }
                    .controlSize(.mini)
                    .buttonStyle(.bordered)
                }
            }
            /* Section */
        } /* List */
        .padding()
        .buttonStyle(.borderedProminent)
        //.background(.green)
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { showSettingsView.toggle() }
            }
            ToolbarItem() {
                Menu {
                    Button(action: {
                        sendSettingsToWatch()
                    }) {
                        Label("Send To Watch…", systemImage: "applewatch")
                    }
                    .disabled(watchConnectionUnusable())
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
                    Button(role: .destructive, action: {
                        resetColoursToDefaults()
                    }) {
                        Label("Reset All To Defaults", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { saveChangedSettings() }
            }
        }
        .onAppear {
            if urlToOpen == nil {
                setupPrefsFromAppStore()
            } else {
                loadSettings(atPath: urlToOpen!.path(percentEncoded: false))
                urlToOpen = nil
            }
        }
        .fileExporter(isPresented: $fileSaverShown,
                      document: settingsSaveDocument,
                      contentType: .itinerarySettingsFile,
                      defaultFilename: "Settings") { result in
            switch result {
            case .success:
                break
                //debugPrint("saved settings")
            case .failure(let error):
                debugPrint(error.localizedDescription)
            }
        } /* fileExporter */
      .fileImporter(isPresented: $fileImporterShown, allowedContentTypes: [.itinerarySettingsFile], onCompletion: { (result) in
          // fileImporter in single file selection mode
          switch result {
          case .success(let selectedFileURL):
              if selectedFileURL.startAccessingSecurityScopedResource() {
                  loadSettings(atPath: selectedFileURL.path)
              }
              selectedFileURL.stopAccessingSecurityScopedResource()
          case .failure(let error):
              debugPrint(error)
          }
      }) /* fileImporter */
    } /* body */
} /* struct */


extension SettingsView {
    
    func saveChangedSettings() {
        if let rgbaInactive = prefColourInactive.rgbaString { appStorageColourStageInactive = rgbaInactive }
        if let rgbaActive = prefColourActive.rgbaString { appStorageColourStageActive = rgbaActive }
        if let rgbaRun = prefColourRunning.rgbaString  { appStorageColourStageRunning = rgbaRun }
        if let rgbaComm = prefColourComment.rgbaString  { appStorageColourStageComment = rgbaComm }
        
        if let frgbaInactive = prefColourFontInactive.rgbaString { appStorageColourFontInactive = frgbaInactive }
        if let frgbaActive = prefColourFontActive.rgbaString { appStorageColourFontActive = frgbaActive }
        if let frgbaRun = prefColourFontRunning.rgbaString  { appStorageColourFontRunning = frgbaRun }
        if let frgbaComm = prefColourFontComment.rgbaString  { appStorageColourFontComment = frgbaComm }
        
        showSettingsView.toggle()
    }
    
    func loadSettings(atPath filePath:String) {
        if let fileData = FileManager.default.contents(atPath: filePath) {
            if let dict: [String:String] = try? JSONDecoder().decode([String:String].self, from: fileData) {
                applySettingsFromDict(dict)
            } else {
                debugPrint("Decode failure for: \(filePath)")
            }
        } else {
            debugPrint("No fileData for: \(filePath)")
        }

    }

    func applySettingsFromDict(_ settingsDict: [String:String]) {
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
    
    func setupPrefsFromAppStore() {
        DispatchQueue.main.async {
            prefColourInactive = appStorageColourStageInactive.rgbaColor!
            prefColourActive = appStorageColourStageActive.rgbaColor!
            prefColourRunning = appStorageColourStageRunning.rgbaColor!
            prefColourComment = appStorageColourStageComment.rgbaColor!
            
            prefColourFontInactive = appStorageColourFontInactive.rgbaColor!
            prefColourFontActive = appStorageColourFontActive.rgbaColor!
            prefColourFontRunning = appStorageColourFontRunning.rgbaColor!
            prefColourFontComment = appStorageColourFontComment.rgbaColor!
        }

    }
    
    func resetAllSettingsTodefaults() {
        resetColoursToDefaults()
    }
    
    func resetColoursToDefaults() {
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
    
    func settingsDictWithTypeKey(_ typekey: String?) -> [String:String] {
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
    
    func sendSettingsToWatch()  {
        appDelegate.sendMessageOrData(dict: self.settingsDictWithTypeKey(kMessageFromPhoneWithSettingsData), data: nil)
    }


}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
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
