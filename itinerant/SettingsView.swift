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

    @State private var prefColourTextInactiveDark = true
    @State private var prefColourTextActiveDark = true
    @State private var prefColourTextRunningDark = true
    @State private var prefColourTextCommentDark = false

    @AppStorage(kAppStorageColourStageInactive) var appStorageColourStageInactive: String = kAppStorageDefaultColourStageInactive
    @AppStorage(kAppStorageColourStageActive) var appStorageColourStageActive: String = kAppStorageDefaultColourStageActive
    @AppStorage(kAppStorageColourStageRunning) var appStorageColourStageRunning: String = kAppStorageDefaultColourStageRunning
    @AppStorage(kAppStorageColourStageComment) var appStorageColourStageComment: String = kAppStorageDefaultColourStageComment
    @AppStorage(kAppStorageStageInactiveTextDark) var appStorageStageInactiveTextDark: Bool = true
    @AppStorage(kAppStorageStageActiveTextDark) var appStorageStageActiveTextDark: Bool = true
    @AppStorage(kAppStorageStageRunningTextDark) var appStorageStageRunningTextDark: Bool = true
    @AppStorage(kAppStorageStageCommentTextDark) var appStorageStageCommentTextDark: Bool = false

    func setupPrefsFromAppStore() {
        prefColourInactive = appStorageColourStageInactive.rgbaColor!
        prefColourActive = appStorageColourStageActive.rgbaColor!
        prefColourRunning = appStorageColourStageRunning.rgbaColor!
        prefColourComment = appStorageColourStageComment.rgbaColor!
        prefColourTextActiveDark = appStorageStageActiveTextDark
        prefColourTextRunningDark = appStorageStageRunningTextDark
        prefColourTextInactiveDark = appStorageStageRunningTextDark
        prefColourTextCommentDark = appStorageStageCommentTextDark
    }
    var body: some View {
        List {
            Section("Colours") {
                HStack {
                    Image(systemName: "bubble.left")
                    ColorPicker("Comments", selection: $prefColourComment)
                    HStack(spacing: 4.0) {
                        Button("Text", action: {
                            prefColourTextCommentDark = true
                        })
                        .padding(4)
                        .buttonStyle(.borderless)
                        .foregroundColor(.black)
                        .background(prefColourComment)
                        .background(.white)
                        .padding(prefColourTextCommentDark == true ? 4 : 0)
                        .border(Color.accentColor, width: prefColourTextCommentDark == true ? 2 : 0)
                        .cornerRadius(4)
                        Button("Text", action: {
                            prefColourTextCommentDark = false
                        })
                        .padding(4)
                        .buttonStyle(.borderless)
                        .foregroundColor(.white)
                        .background(prefColourComment)
                        .background(.white)
                        .padding(prefColourTextCommentDark == false ? 4 : 0)
                        .border(Color.accentColor, width: prefColourTextCommentDark == false ? 2 : 0)
                        .cornerRadius(4)
                    }
                }
                HStack {
                    Image(systemName: "play.circle.fill")
                    ColorPicker("Active Stages", selection: $prefColourActive)
                    HStack(spacing: 4.0) {
                        Button("Text", action: {
                            prefColourTextActiveDark = true
                        })
                        .padding(4)
                        .buttonStyle(.borderless)
                        .foregroundColor(.black)
                        .background(prefColourActive)
                        .background(.white)
                        .padding(prefColourTextActiveDark == true ? 4 : 0)
                        .border(Color.accentColor, width: prefColourTextActiveDark == true ? 2 : 0)
                        .cornerRadius(4)
                        Button("Text", action: {
                            prefColourTextActiveDark = false
                        })
                        .padding(4)
                        .buttonStyle(.borderless)
                        .foregroundColor(.white)
                        .background(prefColourActive)
                        .background(.white)
                        .padding(prefColourTextActiveDark == false ? 4 : 0)
                        .border(Color.accentColor, width: prefColourTextActiveDark == false ? 2 : 0)
                        .cornerRadius(4)
                    }
                }
                HStack {
                    Image(systemName: "stop.circle")
                    ColorPicker("Running Stages", selection: $prefColourRunning)
                    HStack(spacing: 4.0) {
                        Button("Text", action: {
                            prefColourTextRunningDark = true
                        })
                        .padding(4)
                        .buttonStyle(.borderless)
                        .foregroundColor(.black)
                        .background(prefColourRunning)
                        .background(.white)
                        .padding(prefColourTextRunningDark == true ? 4 : 0)
                        .border(Color.accentColor,width: prefColourTextRunningDark == true ? 2 : 0)
                        .cornerRadius(4)
                        Button("Text", action: {
                            prefColourTextRunningDark = false
                        })
                        .padding(4)
                        .buttonStyle(.borderless)
                        .foregroundColor(.white)
                        .background(prefColourRunning)
                        .background(.white)
                        .padding(prefColourTextRunningDark == false ? 4 : 0)
                        .border(Color.accentColor,width: prefColourTextRunningDark == false ? 2 : 0)
                        .cornerRadius(4)

                    }
                }
                HStack {
                    ColorPicker("Inactive Stages", selection: $prefColourInactive)
                    HStack(spacing: 4.0) {
                        Button("Text", action: {
                            prefColourTextInactiveDark = true
                        })
                        .padding(4)
                        .buttonStyle(.borderless)
                        .foregroundColor(.black)
                        .background(prefColourInactive)
                        .background(.white)
                        .padding(prefColourTextInactiveDark == true ? 4 : 0)
                        .border(Color.accentColor, width: prefColourTextInactiveDark == true ? 2 : 0)
                        .cornerRadius(4)
                        Button("Text", action: {
                            prefColourTextInactiveDark = false
                        })
                        .padding(4)
                        .buttonStyle(.borderless)
                        .foregroundColor(.white)
                        .background(prefColourInactive)
                        .background(.white)
                        .padding(prefColourTextInactiveDark == false ? 4 : 0)
                        .border(Color.accentColor, width: prefColourTextInactiveDark == false ? 2 : 0)
                        .cornerRadius(4)
                    }
                }

            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    showSettingsView.toggle()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if let rgbaInactive = prefColourInactive.rgbaString { appStorageColourStageActive = rgbaInactive }
                    if let rgbaActive = prefColourActive.rgbaString { appStorageColourStageActive = rgbaActive }
                    if let rgbaRun = prefColourRunning.rgbaString  { appStorageColourStageRunning = rgbaRun }
                    if let rgbaComm = prefColourComment.rgbaString  { appStorageColourStageComment = rgbaComm }
                    appStorageStageInactiveTextDark = prefColourTextInactiveDark
                    appStorageStageActiveTextDark = prefColourTextActiveDark
                    appStorageStageRunningTextDark = prefColourTextRunningDark
                    appStorageStageCommentTextDark = prefColourTextCommentDark

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
