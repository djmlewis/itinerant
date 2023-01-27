//
//  itinerantApp.swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import SwiftUI


@main
struct ItinerantApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // App creates the itineraryStore and sets it as an environmentObject for subviews to access as required
    @StateObject private var itineraryStore = ItineraryStore()
    
    
    var body: some Scene {
        WindowGroup {
            ItineraryStoreView()
                .environmentObject(itineraryStore)
                .environmentObject(appDelegate)
                .onAppear() {
                    itineraryStore.requestNotificationPermissions()
                }
                .task {
                    // MUST load itineraries from App othewise other views will reload each time they appear
                    itineraryStore.tryToLoadItineraries()
                }
        } /* WindowGroup */
    }
}






