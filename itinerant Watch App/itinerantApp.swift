//
//  itinerantApp.swift
//  itinerant Watch App
//
//  Created by David JM Lewis on 30/12/2022.
//

import SwiftUI



@main
struct itinerant_Watch_AppApp: App {
    
    @WKApplicationDelegateAdaptor(WKAppDelegate.self) var wkAppDelegate

    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}



