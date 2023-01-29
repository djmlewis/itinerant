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
    
    
    var body: some Scene {
        WindowGroup {
            WKItinerantStoreView()
                // environmentObject are accessed by Type so only 1 of any type can go in environment
                .environmentObject(wkAppDelegate.itineraryStore)
                /* .environmentObject(wkAppDelegate) NOT NEEDED auto put in environment by Adaptor above */
                .onAppear() {
                    /* !!! This gets celled every time a sheet or dialog gets called in WKItineraryStoreView !!! */
                }
        }
    }
}



