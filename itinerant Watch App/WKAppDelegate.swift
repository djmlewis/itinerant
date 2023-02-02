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
    @Published var unnItineraryToOpenID: String?
    @Published var unnStageToStopAndStartNextID: String?
    @Published var permissionToNotify: Bool = false
    @Published var itineraryStore = ItineraryStore()

    
    func applicationDidFinishLaunching() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        // Register the notification type.
        notificationCenter.setNotificationCategories([kUNNStageCompletedCategory])
        requestNotificationPermission()
        initiateWatchConnectivity()
        itineraryStore.tryToLoadItineraries()

    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    debugPrint(error.localizedDescription)
                }
                self.permissionToNotify = granted
            }
        }
        
    }

}

// MARK: - UserNotifications
extension WKAppDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // The method will be called on the delegate only if the application is in the foreground.
//        guard let notifiedItineraryID = notification.request.content.userInfo[kItineraryUUIDStr]
//        else { completionHandler([.banner, .sound]); return }
//        // we have to clear the previous IDs or a repeat of this one so we log an onChange with the newValue - in case the new value was used before
//        // this may be called multiple times so avoid overloading the UI by using delays
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            self.unnItineraryToOpenID = nil
//            self.unnStageToStopAndStartNextID = nil
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                self.unnItineraryToOpenID = notifiedItineraryID as? String
//                self.unnStageToStopAndStartNextID = notification.request.identifier
//            }
//        }
        // So we call the completionHandler telling that the notification should display a banner and play the notification sound - this will happen while the app is in foreground
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction.
        debugPrint(Date.now.description,"didReceive \(response.notification.request.identifier)",
                   Date(timeIntervalSinceReferenceDate: response.notification.request.content.userInfo[kNotificationDueTime] as! Double).description)
        guard let notifiedItineraryID = response.notification.request.content.userInfo[kItineraryUUIDStr]
        else { completionHandler(); return }
        if response.notification.request.content.categoryIdentifier ==  kNotificationCategoryStageCompleted {
            switch response.actionIdentifier {
            case kNotificationActionOpenAppToItinerary, UNNotificationDefaultActionIdentifier:
                // UNNotificationDismissActionIdentifier user opened the application from the notification
                // we have to clear the previous IDs so we log an onChange with the newValue - in case the new value was used before
                // this appears to be called only once
                unnItineraryToOpenID = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.unnItineraryToOpenID = notifiedItineraryID as? String
                }
                break
            case kNotificationActionStageStartNext:
              // we have to clear the previous IDs so we log an onChange with the newValue - in case the new value was used before
                unnItineraryToOpenID = nil
                unnStageToStopAndStartNextID = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.unnItineraryToOpenID = notifiedItineraryID as? String
                    self.unnStageToStopAndStartNextID = response.notification.request.identifier
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
            debugPrint("Cannot send message: \(String(describing: error))")
        }
    }
    
    // MARK: - UserInfo
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        debugPrint("didReceiveUserInfo", userInfo[kUserInfoMessageTypeKey] as Any)
        if let messageData = userInfo[kMessageItineraryData] as? Data {
            if let itinerary = Itinerary(messageItineraryData: messageData) {
                DispatchQueue.main.async {
                    self.newItinerary = itinerary
                }
            }
        }

        
    }

}
