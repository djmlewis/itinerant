//
//  itinerantApp.swift
//  itinerant Watch App
//
//  Created by David JM Lewis on 30/12/2022.
//

import SwiftUI



@main
struct Itinerant_Watch_AppApp: App {
    
    @WKApplicationDelegateAdaptor(WKAppDelegate.self) var wkAppDelegate
    
    @StateObject private var itineraryStore = ItineraryStore()


    
    var body: some Scene {
        WindowGroup {
            WKItinerantStoreView()
                .environmentObject(itineraryStore)
                .environmentObject(wkAppDelegate)
                .onAppear() {
                    itineraryStore.requestNotificationPermissions()
                    itineraryStore.tryToLoadItineraries()
                }
        }
    }
}



