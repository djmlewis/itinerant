//
//  WKAppDelegate.swift
//  itinerant Watch App
//
//  Created by David JM Lewis on 26/01/2023.
//

import SwiftUI
import WatchConnectivity
import UserNotifications



class WKAppDelegate: NSObject, WKApplicationDelegate, ObservableObject, UNUserNotificationCenterDelegate, WCSessionDelegate     {
    
    @Published var newItinerary: Itinerary?
    @Published var unnItineraryID: String?
    @Published var unnStageID: String?

    
    func applicationDidFinishLaunching() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        // Register the notification type.
        notificationCenter.setNotificationCategories([kUNNStageCompletedCategory])

        initiateWatchConnectivity()
        
    }
    
    
}

// MARK: - UserNotifications
extension WKAppDelegate {
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
extension WKAppDelegate {
    
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
    
    // MARK: - Messages
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        debugPrint("didReceiveMessage")

        if let messageData = message[kMessageItineraryData] as? Data {
            if let itinerary = Itinerary(messageItineraryData: messageData) {
                DispatchQueue.main.async {
                    self.newItinerary = itinerary
                }
            }
        }
    }
    
    
    func send(_ message: String) {
        guard WCSession.default.activationState == .activated else {
            debugPrint("WCSession.activationState not activated", WCSession.default.activationState)
            return
        }
        guard WCSession.default.isCompanionAppInstalled else {
            debugPrint("isCompanionAppInstalled false")
            return
        }
        
        debugPrint("WK WCSession.default.sendMessage")
        WCSession.default.sendMessage([kMessageKey : message], replyHandler: nil) { error in
            print("Cannot send message: \(String(describing: error))")
        }
    }
    
    
}
