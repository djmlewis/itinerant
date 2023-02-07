//
//  SettingsView.swift
//  itinerant
//
//  Created by David JM Lewis on 30/01/2023.
//

import SwiftUI



struct SettingsView: View {
    @Binding var showSettingsView: Bool

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


    func setupPrefsFromAppStore() {
        prefColourInactive = appStorageColourStageInactive.rgbaColor!
        prefColourActive = appStorageColourStageActive.rgbaColor!
        prefColourRunning = appStorageColourStageRunning.rgbaColor!
        prefColourComment = appStorageColourStageComment.rgbaColor!
        
        prefColourFontInactive = appStorageColourFontInactive.rgbaColor!
        prefColourFontActive = appStorageColourFontActive.rgbaColor!
        prefColourFontRunning = appStorageColourFontRunning.rgbaColor!
        prefColourFontComment = appStorageColourFontComment.rgbaColor!

    }
    
    func sendSettingsToWatch()  {
        var settingsDict: [String : String] = [
            kUserInfoMessageTypeKey : kMessageFromPhoneWithSettingsData
        ]
        if let rgbaInactive = prefColourInactive.rgbaString { settingsDict[kAppStorageColourStageInactive] = rgbaInactive }
        if let rgbaActive = prefColourActive.rgbaString { settingsDict[kAppStorageColourStageActive] = rgbaActive }
        if let rgbaRun = prefColourRunning.rgbaString  { settingsDict[kAppStorageColourStageRunning] = rgbaRun }
        if let rgbaComm = prefColourComment.rgbaString  { settingsDict[kAppStorageColourStageComment] = rgbaComm }

        if let frgbaInactive = prefColourFontInactive.rgbaString { settingsDict[kAppStorageColourFontInactive] = frgbaInactive }
        if let frgbaActive = prefColourFontActive.rgbaString { settingsDict[kAppStorageColourFontActive] = frgbaActive }
        if let frgbaRun = prefColourFontRunning.rgbaString  { settingsDict[kAppStorageColourFontRunning] = frgbaRun }
        if let frgbaComm = prefColourFontComment.rgbaString  { settingsDict[kAppStorageColourFontComment] = frgbaComm }

        appDelegate.sendMessageOrData(dict: settingsDict, data: nil)


    }

    
    var body: some View {
        List {
            Section("Colours") {
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
            } /* Section */
            Button(action: {
                sendSettingsToWatch()
            }) {
                HStack(alignment: .center) {
                    Spacer()
                    Text("Send Settings To Watch…")
                    Image(systemName: "applewatch")
                    Spacer()
                }
            }

        } /* List */
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    showSettingsView.toggle()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
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
            }
        }
        .onAppear {
            setupPrefsFromAppStore()
        }
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
