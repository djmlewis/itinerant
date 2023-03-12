//
//  SettingsObject.swift
//  itinerant
//
//  Created by David JM Lewis on 08/03/2023.
//

import SwiftUI

typealias RGBAString = String

struct SettingsColoursStruct: Equatable, Hashable {
    var colourStageInactive: Color
    var colourStageActive:   Color
    var colourStageRunning:  Color
    var colourStageComment:  Color
    var colourFontInactive:  Color
    var colourFontActive:    Color
    var colourFontRunning:   Color
    var colourFontComment:   Color
    
    internal init(colourStageInactive: Color, colourStageActive: Color, colourStageRunning: Color, colourStageComment: Color, colourFontInactive: Color, colourFontActive: Color, colourFontRunning: Color, colourFontComment: Color) {
        self.colourStageInactive = colourStageInactive
        self.colourStageActive = colourStageActive
        self.colourStageRunning = colourStageRunning
        self.colourStageComment = colourStageComment
        self.colourFontInactive = colourFontInactive
        self.colourFontActive = colourFontActive
        self.colourFontRunning = colourFontRunning
        self.colourFontComment = colourFontComment
    }
    
    init?(settingsColourStringsStruct coloursStruct: SettingsColourStringsStruct?) {
        if let coloursStruct {
            self.colourStageInactive = coloursStruct.colourStageInactive.rgbaColor!
            self.colourStageActive = coloursStruct.colourStageActive.rgbaColor!
            self.colourStageRunning = coloursStruct.colourStageRunning.rgbaColor!
            self.colourStageComment = coloursStruct.colourStageComment.rgbaColor!
            self.colourFontInactive = coloursStruct.colourFontInactive.rgbaColor!
            self.colourFontActive = coloursStruct.colourFontActive.rgbaColor!
            self.colourFontRunning = coloursStruct.colourFontRunning.rgbaColor!
            self.colourFontComment = coloursStruct.colourFontComment.rgbaColor!
        } else { return nil }
    }

    // makes a SettingsColourStringsStruct from self
    var settingsColourStringsStruct: SettingsColourStringsStruct {
        SettingsColourStringsStruct(settingsColoursStruct: self)
    }

}

struct SettingsColourStringsStruct: Codable, Equatable, Hashable {
    var colourStageInactive: RGBAString
    var colourStageActive:   RGBAString
    var colourStageRunning:  RGBAString
    var colourStageComment:  RGBAString
    var colourFontInactive:  RGBAString
    var colourFontActive:    RGBAString
    var colourFontRunning:   RGBAString
    var colourFontComment:   RGBAString

    init(settingsColoursStruct coloursStruct: SettingsColoursStruct) {
        self.colourStageInactive = coloursStruct.colourStageInactive.rgbaString!
        self.colourStageActive = coloursStruct.colourStageActive.rgbaString!
        self.colourStageRunning = coloursStruct.colourStageRunning.rgbaString!
        self.colourStageComment = coloursStruct.colourStageComment.rgbaString!
        self.colourFontInactive = coloursStruct.colourFontInactive.rgbaString!
        self.colourFontActive = coloursStruct.colourFontActive.rgbaString!
        self.colourFontRunning = coloursStruct.colourFontRunning.rgbaString!
        self.colourFontComment = coloursStruct.colourFontComment.rgbaString!
    }
        


}

class SettingsColoursObject: ObservableObject, Hashable, Equatable {
    let id: UUID
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
    
    
    init(uuid: UUID = UUID()) {
        self.id = uuid
    }
     
    // makes a SettingsColoursStruct from our SettingsColoursObject
    var settingsColoursStruct: SettingsColoursStruct {
        SettingsColoursStruct(
            colourStageInactive: colourStageInactive,
            colourStageActive: colourStageActive,
            colourStageRunning: colourStageRunning,
            colourStageComment: colourStageComment,
            colourFontInactive: colourFontInactive,
            colourFontActive: colourFontActive,
            colourFontRunning: colourFontRunning,
            colourFontComment: colourFontComment
        )
    }

    // makes a SettingsColourStringsStruct from our SettingsColoursObject via a SettingsColoursStruct
    var settingsColourStringsStruct: SettingsColourStringsStruct {
        SettingsColourStringsStruct(settingsColoursStruct: settingsColoursStruct)
    }

    // conform to Hashable. fudge as the hash value does not really cover everything
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    // conform to Equatable. fudge as the comparison does not really cover everything
    static func ==(lhs: SettingsColoursObject, rhs: SettingsColoursObject) -> Bool { return lhs.id == rhs.id }
    
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
