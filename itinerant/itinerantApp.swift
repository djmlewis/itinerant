//
//  itinerantApp.swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import SwiftUI

@main
struct ItinerantApp: App {
    
    @StateObject private var itineraryStore = ItineraryStore()

    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ItinerariesView(itineraries: $itineraryStore.itineraries) {
                    // this is a trailing closure (outside the () params) to store in let = saveAction to save
                    Task {
                        do { try await ItineraryStore.initiateSaveAsync(itineraries: itineraryStore.itineraries) }
                        catch { fatalError("Error saving itineraries") }
                    }
                }
            }
            .task {
                // Adds an asynchronous task to initiate before this navview appears
                do { itineraryStore.itineraries = try await ItineraryStore.initiateLoadAsync() }
                catch { fatalError("Error loading itineraries") }
            }
        }
    }    
}

