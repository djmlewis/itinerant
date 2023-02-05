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
        
    var body: some Scene {
        WindowGroup {
            ItineraryStoreView()
            // environmentObject are accessed by Type so only 1 of any type can go in environment
                .environmentObject(appDelegate.itineraryStore)
            /* .environmentObject(appDelegate) NOT NEEDED auto put in environment by Adaptor above */
                .onAppear() {
                    /* !!! This gets called every time a sheet or dialog gets called in WKItineraryStoreView !!! */

                }
        } /* WindowGroup */
    }
}






