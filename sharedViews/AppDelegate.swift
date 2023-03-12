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
    @AppStorage(kAppStorageColourStageInactive) var appStorageColourStageInactive: String = kAppStorageDefaultColourStageInactive
    @AppStorage(kAppStorageColourStageActive)   var appStorageColourStageActive: String = kAppStorageDefaultColourStageActive
    @AppStorage(kAppStorageColourStageRunning)  var appStorageColourStageRunning: String = kAppStorageDefaultColourStageRunning
    @AppStorage(kAppStorageColourStageComment)  var appStorageColourStageComment: String = kAppStorageDefaultColourStageComment
    @AppStorage(kAppStorageColourFontInactive) var appStorageColourFontInactive: String = kAppStorageDefaultColourFontInactive
    @AppStorage(kAppStorageColourFontActive)   var appStorageColourFontActive: String = kAppStorageDefaultColourFontActive
    @AppStorage(kAppStorageColourFontRunning)  var appStorageColourFontRunning: String = kAppStorageDefaultColourFontRunning
    @AppStorage(kAppStorageColourFontComment)  var appStorageColourFontComment: String = kAppStorageDefaultColourFontComment


    @Published var unnItineraryToOpenID: String?
    @Published var unnStageToStopAndStartNextID: String?
    @Published var unnStageToHaltID: String?
    @Published var permissionToNotify: Bool = false
    @Published var itineraryStore = ItineraryStore()
    @Published var fileDeleteDialogShow = false
    @Published var fileDeletePathArray: [String]?
    @Published var watchConnectionProblem: String?
    @Published var syncItineraries: Bool = false
    @Published var settingsColoursObject: SettingsColoursObject = SettingsColoursObject()

    @Published var newItinerary: Itinerary? /* watchOS only */
    
  
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
        // must return true if we handle opening files from Finder
        return true
    }
    
    func application( _ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil ) -> Bool {
        // must return true if we handle opening files from Finder
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
        notificationCenter.setNotificationCategories([kUNNStageCompletedCategory,kUNNSingleSnoozeCompletedCategory, kUNNAdditionalAlertCompletedCategory, kUNNCountUpSnoozeCompletedCategory])
        requestNotificationPermission()
        initiateWatchConnectivity()
        DispatchQueue.main.async {
            // settingsColoursObject is init with static colours, load our appstorage colours
            self.settingsColoursObject.resetToAppStorageValues()
            let filesToDeleteArray = self.itineraryStore.tryToLoadItineraries()
            if !filesToDeleteArray.isEmpty {
                self.fileDeletePathArray = filesToDeleteArray
                self.fileDeleteDialogShow = true
            }
        }
    }

    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
//                if let error = error {
//                    //debugPrint(error.localizedDescription)
//                }
                self.permissionToNotify = granted
            }
        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // The method will be called on the delegate only if the application is in the foreground.
        /* This is always called when the app is open - wait for the user to tap the notification and call didReceive to jump to itinerary etc  */
        // Always call the completionHandler
        //debugPrint("willPresent",notification.request.content.categoryIdentifier)
        
        //let stageID = notification.request.content.userInfo[kStageUUIDStr] as! String
        switch notification.request.content.categoryIdentifier  {
        case kNotificationCategoryStageCompleted:
            break
            //removeAllPendingAndDeliveredStageNotifications(forUUIDstr: stageID)
        case kNotificationCategoryPostStageSingleSnoozeIntervalCompleted:
            break
            //removeAllPendingAndDeliveredStageNotifications(forUUIDstr: stageID)
        case kNotificationCategoryRepeatingSnoozeIntervalCompleted:
            // allow repeating, dont remove
            break
        default:
            // Handle other notification categories...
            break
        }

        
        
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // NOT CALLED when app is in background (or foreground) but ONLY when:
        // the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction.
        //debugPrint("Notification received with identifier \(response.notification.request.identifier)")
        guard let notifiedItineraryID = response.notification.request.content.userInfo[kItineraryUUIDStr], let stageID = response.notification.request.content.userInfo[kStageUUIDStr] as? String
        else { completionHandler(); return }
        
        //debugPrint("didReceive", response.notification.request.content.categoryIdentifier)
        
        switch response.notification.request.content.categoryIdentifier  {
        case kNotificationCategoryStageCompleted:
            break
            //removeAllPendingAndDeliveredStageNotifications(forUUIDstr: stageID)
        case kNotificationCategoryPostStageSingleSnoozeIntervalCompleted:
            break
            //removeAllPendingAndDeliveredStageNotifications(forUUIDstr: stageID)
        case kNotificationCategoryRepeatingSnoozeIntervalCompleted:
            // allow repeating, dont remove
            break
        default:
            // Handle other notification categories...
            break
        }
        
        // whatever the category, respond to the action
        // NEVER use response.notification.request.identifier for stageID as this has flags!!!
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
                self.unnStageToStopAndStartNextID = stageID
            }
        case kNotificationActionStageHalt:
            // we have to clear the previous IDs so we log an onChange with the newValue - in case the new value was used before
            unnItineraryToOpenID = nil
            unnStageToHaltID = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.unnItineraryToOpenID = notifiedItineraryID as? String
                self.unnStageToHaltID = stageID
            }
        case kNotificationActionSingleSnooze:
            let center = UNUserNotificationCenter.current()
            let request = requestStageCompletedSingleSnoozeNotification(toResponse: response)
            center.add(request) { (error) in
                if error != nil {
                    //debugPrint(error!.localizedDescription)
                }
            }
        case UNNotificationDismissActionIdentifier:
            // * user dismissed the notification
            break
        case UNNotificationDefaultActionIdentifier:
            //user just tapped the notification
            // this just opens the app wherever it was left as the request has foreground
            break
        default:
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
            //debugPrint("WCSession.isSupported false")
        }
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //debugPrint("WCSession activationDidCompleteWith", activationState.rawValue.description, error?.localizedDescription ?? "No error")
        
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

    func sendMessageOrData(dict: [String : Any]?, data: Data? ) {
        let message = watchConnectionUnusableMessage()
        guard message == nil else {
            //debugPrint(message!)
            return
        }
        if let messageDict = dict {
            if WCSession.default.isReachable {
                //debugPrint("sending by message")
                WCSession.default.sendMessage(messageDict, replyHandler: nil) { error in
                    //print("Cannot send messageString: \(String(describing: error))")
                }
            } else {
                //debugPrint("sending by transferUserInfo")
                WCSession.default.transferUserInfo(messageDict)
            }
            
        }
        if let messageData = data {
            WCSession.default.sendMessageData(messageData, replyHandler: nil) { error in
                //print("Cannot send messageData: \(String(describing: error))")
            }
            
        }
    }


    // iOS handlers ===>
#if !os(watchOS)
    func sendItineraryDataToWatch(_ watchdata: Data?)  {
        if let data = watchdata {
            sendMessageOrData(dict: [
                kUserInfoMessageTypeKey : kMessageFromPhoneWithItineraryData,
                kMessageFromPhoneWithItineraryData : data
            ], data: nil)
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        //debugPrint(message)
        if message[kUserInfoMessageTypeKey] as! String == kMessageFromWatchInitiateSyncNow {
            DispatchQueue.main.async {
                self.syncItineraries = true
            }
        }
    }
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void ) {
        debugPrint(message)
        if let messageTypekey: String = message[kUserInfoMessageTypeKey] as? String {
            switch messageTypekey {
            case kMessageFromWatchRequestingItinerariesSync:
                replyHandler([kUserInfoMessageTypeKey : kMessageFromPhoneStandingByToSync])
                
            default:
                break
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
        
    }
    
    
    
    #endif
// <=== iOS handlers

// watchOS handlers ===>
#if os(watchOS)
    func handleItineraryDataFromPhone(_ messageData: Data?) {
        if let messageData, let watchMessageStruct = try? JSONDecoder().decode(Itinerary.WatchMessageStruct.self, from: messageData) {
            let itinerary = Itinerary(watchMessageStruct: watchMessageStruct)
            DispatchQueue.main.async {
                self.newItinerary = itinerary
            }
        }
    }

    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        //debugPrint(message)
        if let messageTypekey: String = message[kUserInfoMessageTypeKey] as? String {
            switch messageTypekey {
            case kMessageFromPhoneWithItineraryData:
                handleItineraryDataFromPhone(message[kMessageFromPhoneWithItineraryData] as? Data)
                
            case kMessageFromPhoneWithSettingsData:
                handleSettingsDictFromPhone(message as? [String:String])
                
            default:
                break
            }
        }

    }
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void ) {
        //debugPrint(message)
        if let messageTypekey: String = message[kUserInfoMessageTypeKey] as? String {
            switch messageTypekey {
            case kMessageFromPhoneRequestingSettingsData:
                replyHandler(settingsDictWithTypeKey(kMessageFromWatchWithSettingsData))
                
            default:
                break
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
        if let messageTypekey: String = userInfo[kUserInfoMessageTypeKey] as? String {
            switch messageTypekey {
            case kMessageFromPhoneWithItineraryData:
                handleItineraryDataFromPhone(userInfo[kMessageFromPhoneWithItineraryData] as? Data)

            case kMessageFromPhoneWithSettingsData:
                handleSettingsDictFromPhone(userInfo as? [String:String])

            default:
                break
            }
        }
    }
    

#endif
// <=== watchOS handlers

// MARK: - Settings
    
    func updateSettingsFromSettingsStructColours(_ settingsStruct: SettingsColoursStruct) {
        self.settingsColoursObject.updateFromSettingsColoursStruct(settingsStruct, andUpdateAppStorage: true)
        
    }
    
    
    func settingsDictWithTypeKey(_ typekey: String?) -> [String:String] {
        //debugPrint("settingsDictWithTypeKey")
        var settingsDict = [String:String]()
        if let rgbaInactive = settingsColoursObject.colourStageInactive.rgbaString { settingsDict[kAppStorageColourStageInactive] = rgbaInactive }
        if let rgbaActive = settingsColoursObject.colourStageActive.rgbaString { settingsDict[kAppStorageColourStageActive] = rgbaActive }
        if let rgbaRun = settingsColoursObject.colourStageRunning.rgbaString  { settingsDict[kAppStorageColourStageRunning] = rgbaRun }
        if let rgbaComm = settingsColoursObject.colourStageComment.rgbaString  { settingsDict[kAppStorageColourStageComment] = rgbaComm }

        if let frgbaInactive = settingsColoursObject.colourFontInactive.rgbaString { settingsDict[kAppStorageColourFontInactive] = frgbaInactive }
        if let frgbaActive = settingsColoursObject.colourFontActive.rgbaString { settingsDict[kAppStorageColourFontActive] = frgbaActive }
        if let frgbaRun = settingsColoursObject.colourFontRunning.rgbaString  { settingsDict[kAppStorageColourFontRunning] = frgbaRun }
        if let frgbaComm = settingsColoursObject.colourFontComment.rgbaString  { settingsDict[kAppStorageColourFontComment] = frgbaComm }
        
        guard typekey != nil else { return settingsDict }
        settingsDict[kUserInfoMessageTypeKey] = typekey!
        return settingsDict
    }

    
    
// watchOS handlers ===>
#if os(watchOS)
    func handleSettingsDictFromPhone(_ settingsDict: [String : String]?) {
        if let settingsDict {
            DispatchQueue.main.async {
                let newColourStruct = SettingsColoursStruct(
                    // use dict if available or else remain the same
                    colourStageInactive: settingsDict[kAppStorageColourStageInactive]?.description.rgbaColor ?? self.settingsColoursObject.colourStageInactive,
                    colourStageActive: settingsDict[kAppStorageColourStageActive]?.description.rgbaColor ?? self.settingsColoursObject.colourStageActive,
                    colourStageRunning: settingsDict[kAppStorageColourStageRunning]?.description.rgbaColor ?? self.settingsColoursObject.colourStageRunning,
                    colourStageComment: settingsDict[kAppStorageColourStageComment]?.description.rgbaColor ?? self.settingsColoursObject.colourStageComment,
                    
                    colourFontInactive: settingsDict[kAppStorageColourFontInactive]?.description.rgbaColor ?? self.settingsColoursObject.colourFontInactive,
                    colourFontActive: settingsDict[kAppStorageColourFontActive]?.description.rgbaColor ?? self.settingsColoursObject.colourFontActive,
                    colourFontRunning: settingsDict[kAppStorageColourFontRunning]?.description.rgbaColor ?? self.settingsColoursObject.colourFontRunning,
                    colourFontComment: settingsDict[kAppStorageColourFontComment]?.description.rgbaColor ?? self.settingsColoursObject.colourFontComment)
                self.settingsColoursObject.updateFromSettingsColoursStruct(newColourStruct, andUpdateAppStorage: true)
            }
            //debugPrint("handled settings")
       }
    }
    
#endif
// <=== watchOS handlers

    
    
    func stageTextColour(stage: Stage, uuidStrStagesRunningStr: String, uuidStrStagesActiveStr: String ) -> Color {
        if stage.isCommentOnly {
            return appStorageColourFontComment.rgbaColor!
        }
        if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) {
            return appStorageColourFontRunning.rgbaColor!
        }
        if stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) {
            return appStorageColourFontActive.rgbaColor!
        }
        return appStorageColourFontInactive.rgbaColor!
    }

} /* extension */



