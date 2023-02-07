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
class AppDelegate: NSObject,  ObservableObject, UNUserNotificationCenterDelegate, WCSessionDelegate     {
    
    @Published var unnItineraryToOpenID: String?
    @Published var unnStageToStopAndStartNextID: String?
    @Published var unnStageToHaltID: String?
    @Published var permissionToNotify: Bool = false
    @Published var itineraryStore = ItineraryStore()
    
    @Published var newItinerary: Itinerary? /* watchOS only */
  
    @AppStorage(kAppStorageColourStageInactive) var appStorageColourStageInactive: String = kAppStorageDefaultColourStageInactive
    @AppStorage(kAppStorageColourStageActive) var appStorageColourStageActive: String = kAppStorageDefaultColourStageActive
    @AppStorage(kAppStorageColourStageRunning) var appStorageColourStageRunning: String = kAppStorageDefaultColourStageRunning
    @AppStorage(kAppStorageColourStageComment) var appStorageColourStageComment: String = kAppStorageDefaultColourStageComment
    
    @AppStorage(kAppStorageColourFontInactive) var appStorageColourFontInactive: String = kAppStorageDefaultColourFontInactive
    @AppStorage(kAppStorageColourFontActive) var appStorageColourFontActive: String = kAppStorageDefaultColourFontActive
    @AppStorage(kAppStorageColourFontRunning) var appStorageColourFontRunning: String = kAppStorageDefaultColourFontRunning
    @AppStorage(kAppStorageColourFontComment) var appStorageColourFontComment: String = kAppStorageDefaultColourFontComment

}


#if os(watchOS)
extension AppDelegate: WKApplicationDelegate {
    func applicationDidFinishLaunching() {
        handleFinishLaunching()
    }
}
#else
extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        handleFinishLaunching()
        return true
    }
}
#endif
// MARK: - UserNotifications
extension AppDelegate {
    
    func handleFinishLaunching() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        // Register the notification type.
        notificationCenter.setNotificationCategories([kUNNStageCompletedCategory, kUNNCountUpSnoozeCompletedCategory])
        requestNotificationPermission()
        initiateWatchConnectivity()
        DispatchQueue.main.async {
            self.itineraryStore.tryToLoadItineraries()
        }
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // The method will be called on the delegate only if the application is in the foreground.
        /* This is always called when the app is open - wait for the user to tap the notification and call didReceive to jump to itinerary etc  */
        // Always call the completionHandler
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction.
        //debugPrint("Notification received with identifier \(response.notification.request.identifier)")
        guard let notifiedItineraryID = response.notification.request.content.userInfo[kItineraryUUIDStr]
        else { completionHandler(); return }
        
        switch response.notification.request.content.categoryIdentifier  {
        case kNotificationCategoryStageCompleted,kNotificationCategoryCountUpSnoozeCompleted:
            switch response.actionIdentifier {
            case kNotificationActionOpenAppToItinerary: // UNNotificationDismissActionIdentifier user opened the application from the notification
                // we have to clear the previous IDs so we log an onChange with the newValue - in case the new value was used before
                unnItineraryToOpenID = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.unnItineraryToOpenID = notifiedItineraryID as? String
                }
            case kNotificationActionStageStartNext:
                // we have to clear the previous IDs so we log an onChange with the newValue - in case the new value was used before
                unnItineraryToOpenID = nil
                unnStageToStopAndStartNextID = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.unnItineraryToOpenID = notifiedItineraryID as? String
                    self.unnStageToStopAndStartNextID = response.notification.request.identifier
                }
            case kNotificationActionStageHalt:
                // we have to clear the previous IDs so we log an onChange with the newValue - in case the new value was used before
                unnItineraryToOpenID = nil
                unnStageToHaltID = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.unnItineraryToOpenID = notifiedItineraryID as? String
                    self.unnStageToHaltID = response.notification.request.identifier
                }
            case kNotificationActionSnooze:
                let center = UNUserNotificationCenter.current()
                let request = requestStageCompletedSnooze(toResponse: response)
                center.add(request) { (error) in
                    if error != nil {  debugPrint(error!.localizedDescription) }
                }
            case UNNotificationDismissActionIdentifier:
                // * user dismissed the notification
                break
            case UNNotificationDefaultActionIdentifier:
                //user just tapped the notification
                // this just opens the app wherever it was left as the erquest has foreground
                break
            default:
                break
            }
        default:
            // Handle other notification categories...
            break
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
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // for multi watch support
        session.activate()
    }
#endif
    // <--- iOS only
    
    // MARK: - Messages
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let messageData = message[kMessageFromPhoneWithItineraryData] as? Data { handleItineraryDataFromPhone(messageData) }
        else if message[kUserInfoMessageTypeKey] as! String == kMessageFromPhoneWithSettingsData { handleSettingsDictFromPhone(message as! [String:String])}
        else if let iphoneMessage = message[kMessageFromWatchKey] as? String {
            debugPrint(iphoneMessage)
        }
    }
    
    
    func sendMessageOrData(dict: [String : Any]?, data: Data? ) {
#if os(iOS)
        guard WCSession.default.isWatchAppInstalled else {
            debugPrint("isCompanionAppInstalled false")
            return
        }
#endif
        guard WCSession.default.activationState == .activated else {
            debugPrint("WCSession.activationState not activated", WCSession.default.activationState)
            return
        }
        if let messageDict = dict {
            if WCSession.default.isReachable {
                print("sending by message")
                WCSession.default.sendMessage(messageDict, replyHandler: nil) { error in
                    print("Cannot send messageString: \(String(describing: error))")
                }
            } else {
                print("sending by transferUserInfo")
                WCSession.default.transferUserInfo(messageDict)
            }
            
        }
        if let messageData = data {
            WCSession.default.sendMessageData(messageData, replyHandler: nil) { error in
                print("Cannot send messageData: \(String(describing: error))")
            }
            
        }
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        /** Called on the sending side after the user info transfer has successfully completed or failed with an error.
         Will be called on next launch if the sender was not running when the user info finished. */
        //debugPrint("didFinish userInfoTransfer", error?.localizedDescription ?? "No error")
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        //debugPrint("didReceiveUserInfo")
        if let itineraryData = userInfo[kMessageFromPhoneWithItineraryData] as? Data { handleItineraryDataFromPhone(itineraryData) }
        else if userInfo[kUserInfoMessageTypeKey] as! String == kMessageFromPhoneWithSettingsData { handleSettingsDictFromPhone(userInfo as! [String:String])}
        
    }
    

    // watchOS handlers ===>
    func handleItineraryDataFromPhone(_ messageData: Data) {
        if let itinerary = Itinerary(messageItineraryData: messageData) {
            DispatchQueue.main.async {
                self.newItinerary = itinerary
            }
        }
    }
    
    func handleSettingsDictFromPhone(_ settingsDict: [String : String ]) {
        DispatchQueue.main.async {
            if let rgbaInactive = settingsDict[kAppStorageColourStageInactive] {self.appStorageColourStageInactive  = rgbaInactive }
            if let rgbaActive = settingsDict[kAppStorageColourStageActive] { self.appStorageColourStageActive = rgbaActive }
            if let rgbaRun = settingsDict[kAppStorageColourStageRunning]  { self.appStorageColourStageRunning = rgbaRun }
            if let rgbaComm = settingsDict[kAppStorageColourStageComment]  { self.appStorageColourStageComment = rgbaComm }
            
            if let frgbaInactive = settingsDict[kAppStorageColourFontInactive] { self.appStorageColourFontInactive = frgbaInactive }
            if let frgbaActive = settingsDict[kAppStorageColourFontActive] { self.appStorageColourFontActive = frgbaActive }
            if let frgbaRun = settingsDict[kAppStorageColourFontRunning]  { self.appStorageColourFontRunning = frgbaRun }
            if let frgbaComm = settingsDict[kAppStorageColourFontComment]  { self.appStorageColourFontComment = frgbaComm }
        }
        debugPrint("handled settings")
    }

    // <=== watchOS handlers

    
} /* extension */



