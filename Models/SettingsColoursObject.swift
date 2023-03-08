//
//  SettingsObject.swift
//  itinerant
//
//  Created by David JM Lewis on 08/03/2023.
//

import SwiftUI


struct SettingsColoursStruct {
    var colourStageInactive: Color
    var colourStageActive:   Color
    var colourStageRunning:  Color
    var colourStageComment:  Color
    var colourFontInactive:  Color
    var colourFontActive:    Color
    var colourFontRunning:   Color
    var colourFontComment:   Color
    
}

class SettingsColoursObject: ObservableObject {
    @AppStorage(kAppStorageColourStageInactive) var appStorageColourStageInactive: String = kAppStorageDefaultColourStageInactive
    @AppStorage(kAppStorageColourStageActive) var appStorageColourStageActive: String = kAppStorageDefaultColourStageActive
    @AppStorage(kAppStorageColourStageRunning) var appStorageColourStageRunning: String = kAppStorageDefaultColourStageRunning
    @AppStorage(kAppStorageColourStageComment) var appStorageColourStageComment: String = kAppStorageDefaultColourStageComment

    @AppStorage(kAppStorageColourFontInactive) var appStorageColourFontInactive: String = kAppStorageDefaultColourFontInactive
    @AppStorage(kAppStorageColourFontActive) var appStorageColourFontActive: String = kAppStorageDefaultColourFontActive
    @AppStorage(kAppStorageColourFontRunning) var appStorageColourFontRunning: String = kAppStorageDefaultColourFontRunning
    @AppStorage(kAppStorageColourFontComment) var appStorageColourFontComment: String = kAppStorageDefaultColourFontComment

    @Published var colourStageInactive: Color = kAppStorageDefaultColourStageInactive.rgbaColor!
    @Published var colourStageActive:   Color = kAppStorageDefaultColourStageActive.rgbaColor!
    @Published var colourStageRunning:  Color = kAppStorageDefaultColourStageRunning.rgbaColor!
    @Published var colourStageComment:  Color = kAppStorageDefaultColourStageComment.rgbaColor!
    @Published var colourFontInactive:  Color = kAppStorageDefaultColourFontInactive.rgbaColor!
    @Published var colourFontActive:    Color = kAppStorageDefaultColourFontActive.rgbaColor!
    @Published var colourFontRunning:   Color = kAppStorageDefaultColourFontRunning.rgbaColor!
    @Published var colourFontComment:   Color = kAppStorageDefaultColourFontComment.rgbaColor!
    

    func resetToStaticDefaultValues() {
        colourStageInactive = kAppStorageDefaultColourStageInactive.rgbaColor!
        colourStageActive = kAppStorageDefaultColourStageActive.rgbaColor!
        colourStageRunning = kAppStorageDefaultColourStageRunning.rgbaColor!
        colourStageComment = kAppStorageDefaultColourStageComment.rgbaColor!
        
        colourFontInactive = kAppStorageDefaultColourFontInactive.rgbaColor!
        colourFontActive = kAppStorageDefaultColourFontActive.rgbaColor!
        colourFontRunning = kAppStorageDefaultColourFontRunning.rgbaColor!
        colourFontComment = kAppStorageDefaultColourFontComment.rgbaColor!
    }

    func resetToAppStorageValues() {
        colourStageInactive = appStorageColourStageInactive.rgbaColor!
        colourStageActive = appStorageColourStageActive.rgbaColor!
        colourStageRunning = appStorageColourStageRunning.rgbaColor!
        colourStageComment = appStorageColourStageComment.rgbaColor!
        
        colourFontInactive = appStorageColourFontInactive.rgbaColor!
        colourFontActive = appStorageColourFontActive.rgbaColor!
        colourFontRunning = appStorageColourFontRunning.rgbaColor!
        colourFontComment = appStorageColourFontComment.rgbaColor!
    }


    func updateFromSettingsColoursStruct(_ settingsStruct: SettingsColoursStruct, andUpdateAppStorage: Bool) {
        self.colourStageInactive = settingsStruct.colourStageInactive
        self.colourStageActive = settingsStruct.colourStageActive
        self.colourStageRunning = settingsStruct.colourStageRunning
        self.colourStageComment = settingsStruct.colourStageComment
        self.colourFontInactive = settingsStruct.colourFontInactive
        self.colourFontActive = settingsStruct.colourFontActive
        self.colourFontRunning = settingsStruct.colourFontRunning
        self.colourFontComment = settingsStruct.colourFontComment
        if andUpdateAppStorage { updateAppStorage() }
    }

    func updateAppStorage() {
        // place the new colours in AppStorage
        self.appStorageColourStageInactive = self.colourStageInactive.rgbaString!
        self.appStorageColourStageActive = self.colourStageActive.rgbaString!
        self.appStorageColourStageRunning = self.colourStageRunning.rgbaString!
        self.appStorageColourStageComment = self.colourStageComment.rgbaString!
        self.appStorageColourFontInactive = self.colourFontInactive.rgbaString!
        self.appStorageColourFontActive = self.colourFontActive.rgbaString!
        self.appStorageColourFontRunning = self.colourFontRunning.rgbaString!
        self.appStorageColourFontComment = self.colourFontComment.rgbaString!
    }
    
    
    func writeSettingsToPath(_ path:String?) {
//        if let overidePath = path {
//
//        } else if let storedPath = filePath {
//
//        }
        
    }
    
    func readSettingsFromPath(_ path:String?) {
//        if let overidePath = path {
//
//        } else if let storedPath = filePath {
//
//        }
    }
    

    
}
