//
//  SettingsView.swift
//  itinerant
//
//  Created by David JM Lewis on 30/01/2023.
//

import SwiftUI



struct SettingsView: View {
    @Binding var showSettingsView: Bool
//    @Binding var appStorageColourStageActive: String
//    @Binding var appStorageColourStageRunning: String
    @State private var prefColourActive: Color = kAppStorageDefaultColourStageActive.rgbaColor!
    @State private var prefColourRunning: Color = kAppStorageDefaultColourStageRunning.rgbaColor!

    @State private var prefColourTextActiveDark = true
    @State private var prefColourTextRunningDark = true

    @AppStorage(kAppStorageColourStageActive) var appStorageColourStageActive: String = kAppStorageDefaultColourStageActive
    @AppStorage(kAppStorageColourStageRunning) var appStorageColourStageRunning: String = kAppStorageDefaultColourStageRunning
    @AppStorage(kAppStorageStageActiveTextDark) var appStorageStageActiveTextDark: Bool = true
    @AppStorage(kAppStorageStageRunningTextDark) var appStorageStageRunningTextDark: Bool = true

    func setupPrefsFromAppStore() {
        prefColourActive = appStorageColourStageActive.rgbaColor!
        prefColourRunning = appStorageColourStageRunning.rgbaColor!
        prefColourTextActiveDark = appStorageStageActiveTextDark
        prefColourTextRunningDark = appStorageStageRunningTextDark

    }
    var body: some View {
        List {
            Section("Colours") {
                HStack {
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
                        .border(.black, width: prefColourTextActiveDark == true ? 2 : 0)
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
                        .border(.black, width: prefColourTextActiveDark == false ? 2 : 0)
                        .cornerRadius(4)

                    }
                }
                HStack {
                    ColorPicker("Stage Running", selection: $prefColourRunning)
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
                        .border(.black,width: prefColourTextRunningDark == true ? 3 : 0)
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
                        .border(.black,width: prefColourTextRunningDark == false ? 3 : 0)
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
                    if let rgbaActive = prefColourActive.rgbaString { appStorageColourStageActive = rgbaActive }
                    if let rgbaRun = prefColourRunning.rgbaString  { appStorageColourStageRunning = rgbaRun }
                    appStorageStageActiveTextDark = prefColourTextActiveDark
                    appStorageStageRunningTextDark = prefColourTextRunningDark
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
