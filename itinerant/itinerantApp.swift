//
//  itinerantApp.swift
//  itinerant
//
//  Created by David JM Lewis on 30/12/2022.
//

import SwiftUI


let kSnoozeIntervalSecs = 10.0

let kNotificationActionOpenApp = "OPEN_APP_ACTION"
let kNotificationActionSnooze = "SNOOZE_ACTION"
let kNotificationCategoryStageCompleted = "STAGE_COMPLETED"

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
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        
        // Define the custom actions.
        let openAppAction = UNNotificationAction(identifier: kNotificationActionOpenApp,
                                                 title: "Open Itinerary",
                                                 options: [.foreground])
        let snoozeAction = UNNotificationAction(identifier: kNotificationActionSnooze,
                                                title: "Snooze",
                                                options: [])
        // Define the notification type
        let stageCompletedCategory =
        UNNotificationCategory(identifier: kNotificationCategoryStageCompleted,
                               actions: [openAppAction, snoozeAction],
                               intentIdentifiers: [],
                               hiddenPreviewsBodyPlaceholder: "",
                               options: .customDismissAction)
        // Register the notification type.
        notificationCenter.setNotificationCategories([stageCompletedCategory])
        
        
        
        
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // The method will be called on the delegate only if the application is in the foreground.
        guard let notifiedItineraryID = notification.request.content.userInfo[kItineraryUUIDStr]
        else { completionHandler([.banner, .sound]); return }
        // we have to clear the previous IDs so we log an onChange with the newValue - in case the new value was used before
        unnItineraryID = nil
        unnStageID = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.unnItineraryID = notifiedItineraryID as? String
            self.unnStageID = notification.request.identifier
        }
        // So we call the completionHandler telling that the notification should display a banner and play the notification sound - this will happen while the app is in foreground
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction.         debugPrint("Notification received with identifier \(response.notification.request.identifier)")
        guard let notifiedItineraryID = response.notification.request.content.userInfo[kItineraryUUIDStr]
        else { completionHandler(); return }
        
        if response.notification.request.content.categoryIdentifier ==  kNotificationCategoryStageCompleted {
            switch response.actionIdentifier {
            case kNotificationActionOpenApp, UNNotificationDefaultActionIdentifier: // UNNotificationDismissActionIdentifier user opened the application from the notification
              // we have to clear the previous IDs so we log an onChange with the newValue - in case the new value was used before
                unnItineraryID = nil
                unnStageID = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.unnItineraryID = notifiedItineraryID as? String
                    self.unnStageID = response.notification.request.identifier
                }
                break
                
            case kNotificationActionSnooze:
                let center = UNUserNotificationCenter.current()
                center.removeDeliveredNotifications(withIdentifiers: [response.notification.request.identifier])
                let content = UNMutableNotificationContent()
                let userinfo = response.notification.request.content.userInfo
                content.title = userinfo[kItineraryTitle] as! String
                content.body = "\(userinfo[kStageTitle] as! String) is snoozing"
                content.userInfo = userinfo
                content.categoryIdentifier = kNotificationCategoryStageCompleted
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (kSnoozeIntervalSecs), repeats: false)
                let request = UNNotificationRequest(identifier: userinfo[kStageUUIDStr] as! String, content: content, trigger: trigger)
                center.add(request) { (error) in
                    if error != nil {  debugPrint(error!.localizedDescription) }
                }

                break
                
            case UNNotificationDismissActionIdentifier:
                // * user dismissed the notification
                break
                
            default:
               break
            }
        }
        else {
            // Handle other notification types...
        }
        
        // Always call the completion handler when done.
        completionHandler()
        
    }
}
