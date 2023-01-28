//
//  AppDelegate.swift
//  itinerant
//
//  Created by David JM Lewis on 26/01/2023.
//

import SwiftUI
import WatchConnectivity
import UserNotifications


// MARK: - AppDelegate.swift
class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject, UNUserNotificationCenterDelegate, WCSessionDelegate     {
    
    @Published var unnItineraryID: String?
    @Published var unnStageID: String?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        // Register the notification type.
        notificationCenter.setNotificationCategories([kUNNStageCompletedCategory])
        
        
        // Watch Connectivity
        initiateWatchConnectivity()
        
        return true
    }
}

// MARK: - UserNotifications
extension AppDelegate {
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
                let request = requestStageCompletedSnooze(toResponse: response)
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

// MARK: - WCSessionDelegate
extension AppDelegate {

    func initiateWatchConnectivity() {
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        } else {
            debugPrint("WCSession.isSupported false")
        }

    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugPrint("WCSession activationDidCompleteWith", activationState.rawValue.description, error?.localizedDescription ?? "No error")

    }

    // iOS only -->
    func sessionDidBecomeInactive(_ session: WCSession) {

    }

    func sessionDidDeactivate(_ session: WCSession) {
        // for multi watch support
        session.activate()
    }
    // <--- iOS only

// MARK: - Messages
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        debugPrint("iphone didReceiveMessage")
        if let notificationText = message[kMessageKey] as? String {
            debugPrint(notificationText)
        }
    }

    
    func send(dict: [String : Any]?, data: Data? ) {
        guard WCSession.default.activationState == .activated else {
            debugPrint("WCSession.activationState not activated", WCSession.default.activationState)
          return
        }
        guard WCSession.default.isWatchAppInstalled else {
            debugPrint("isCompanionAppInstalled false")
            return
        }
        guard WCSession.default.isReachable else {
            debugPrint("isReachable false")
            return
        }

        if let messageDict = dict {
            WCSession.default.sendMessage(messageDict, replyHandler: nil) { error in
                print("Cannot send messageString: \(String(describing: error))")
            }
        }
        if let messageData = data {
            WCSession.default.sendMessageData(messageData, replyHandler: nil) { error in
                print("Cannot send messageData: \(String(describing: error))")
            }
        }
    }

}
