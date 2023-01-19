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
            NavigationView {
                // we also pass a copy of itineraries to allow the preview of ItineraryStoreView to work nicely
                ItineraryStoreView()
            }
            .environmentObject(itineraryStore)
            .onAppear() {
                requestNotificationPermissions()
            }
            .task {
                // MUST load itineraries from App othewise other views will reload each time they appear
                itineraryStore.isLoadingItineraries = true
                itineraryStore.loadItineraries(isLoadingItineraries: &itineraryStore.isLoadingItineraries)
            }

        }
    }
}


extension ItinerantApp {
    
    func requestNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    debugPrint(error.localizedDescription)
                }
                itineraryStore.permissionToNotify = granted
            }
        }
        
    }
    
    
}



// AppDelegate.swift
class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    
    @Published var unnItineraryID: String?
    @Published var unnStageID: String?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Here we actually handle the notification
        debugPrint("Notification willPresent with identifier \(notification.request.identifier)")
        guard let notifiedItineraryID = notification.request.content.userInfo[kItineraryUUIDStr]
        else { completionHandler([.banner, .sound]); return }
        unnItineraryID = notifiedItineraryID as? String
        unnStageID = notification.request.identifier
       // So we call the completionHandler telling that the notification should display a banner and play the notification sound - this will happen while the app is in foreground
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        debugPrint("Notification received with identifier \(response.notification.request.identifier)")
        guard let notifiedItineraryID = response.notification.request.content.userInfo[kItineraryUUIDStr]
        else { completionHandler(); return }
        unnItineraryID = notifiedItineraryID as? String
        unnStageID = response.notification.request.identifier
        // Always call the completion handler when done.
        completionHandler()

    }
}
