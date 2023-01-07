//
//  itinerantApp.swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import SwiftUI

@main
struct ItinerantApp: App {
    
    // App creates the itineraryStore and sets it as an environmentObject for subviews to access as required
    @StateObject private var itineraryStore = ItineraryStore()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                // we also pass a copy of itineraries to allow the preview of ItineraryStoreView to work nicely
                ItineraryStoreView(itineraries: $itineraryStore.itineraries)
            }
            .environmentObject(itineraryStore)
            .task {
                itineraryStore.loadItineraries()
                // Adds an asynchronous task to initiate before this navview appears
                //debugPrint("ItinerantApp task")
                //do { itineraryStore.itineraries = try await ItineraryStore.initiateLoadAsync() }
                //catch { fatalError("Error loading itineraries") }
            }
        }
    }    
}

