//
//  Notifications.swift
//  itinerant
//
//  Created by David JM Lewis on 28/01/2023.
//

import Foundation
import UserNotifications

let kSnoozeIntervalSecs = 10.0
let kNotificationActionOpenAppToItinerary = "OPEN_APP_TO_ITINERARY_ACTION"
let kNotificationActionSnooze = "SNOOZE_ACTION"
let kNotificationActionStageStartNext = "STAGE_START_NEXT_ACTION"
let kNotificationCategoryStageCompleted = "CATEGORY_STAGE_COMPLETED"



// Define the custom actions.
let kUNNActionOpenApp = UNNotificationAction(identifier: kNotificationActionOpenAppToItinerary,
                                         title: "Open Itinerary",
                                         options: [.foreground])
let kUNNActionNextStage = UNNotificationAction(identifier: kNotificationActionStageStartNext,
                                         title: "Start Next Stage",
                                         options: [.foreground])
let kUNNActionEndStage = UNNotificationAction(identifier: kNotificationActionStageStartNext,
                                         title: "Stop stage",
                                         options: [.foreground])
let kUNNActionSnooze = UNNotificationAction(identifier: kNotificationActionSnooze,
                                        title: "Snooze",
                                        options: [])
// Define the notification type
let kUNNStageCompletedCategory =
UNNotificationCategory(identifier: kNotificationCategoryStageCompleted,
                       actions: [kUNNActionNextStage, kUNNActionSnooze, kUNNActionOpenApp],
                       intentIdentifiers: [],
                       options: .customDismissAction)


func requestStageCompletedSnooze(toResponse response: UNNotificationResponse) -> UNNotificationRequest{
    let center = UNUserNotificationCenter.current()
    center.removeDeliveredNotifications(withIdentifiers: [response.notification.request.identifier])
    let content = UNMutableNotificationContent()
    let userinfo = response.notification.request.content.userInfo
    content.title = userinfo[kItineraryTitle] as! String
    content.subtitle = "\(userinfo[kStageTitle] as! String) was snoozing"
    content.userInfo = userinfo
    content.interruptionLevel = .timeSensitive
    content.sound = .default
    content.categoryIdentifier = kNotificationCategoryStageCompleted
    let snoozeInterval = Double(userinfo[kStageSnoozeDurationSecs] as! Int)
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: snoozeInterval, repeats: false)
    let request = UNNotificationRequest(identifier: userinfo[kStageUUIDStr] as! String, content: content, trigger: trigger)

    return request
}

func requestStageCompleted(stage: Stage, itinerary: Itinerary) -> UNNotificationRequest {
    let content = UNMutableNotificationContent()
    content.title = itinerary.title
    content.subtitle = "\(stage.title) has completed"
    content.userInfo = [kItineraryUUIDStr : itinerary.id.uuidString,
                            kStageUUIDStr : stage.id.uuidString,
                              kStageTitle : stage.title,
                     kStageSnoozeDurationSecs : stage.snoozeDurationSecs,
                          kItineraryTitle : itinerary.title,
                     kNotificationDueTime : Date.now.timeIntervalSinceReferenceDate + Double(stage.snoozeDurationSecs)
    ]
    content.categoryIdentifier = kNotificationCategoryStageCompleted
    content.interruptionLevel = .timeSensitive
    content.sound = .default
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (Double(stage.durationSecsInt)), repeats: false)
    let request = UNNotificationRequest(identifier: stage.id.uuidString, content: content, trigger: trigger)
    return request
}

func postNotification(stage: Stage, itinerary: Itinerary) -> Void {
    let center = UNUserNotificationCenter.current()
    center.getNotificationSettings { notificationSettings in
        guard (notificationSettings.authorizationStatus == .authorized) else { debugPrint("unable to alert in any way"); return }
        var allowedAlerts = [UNAuthorizationOptions]()
        if notificationSettings.alertSetting == .enabled { allowedAlerts.append(.alert) }
        if notificationSettings.soundSetting == .enabled { allowedAlerts.append(.sound) }
        
        let request = requestStageCompleted(stage: stage, itinerary: itinerary)
        center.add(request) { (error) in
            if error != nil {  debugPrint(error!.localizedDescription) }
        }
    }
}

func removeNotification(stageUuidstr: String) {
    let center = UNUserNotificationCenter.current()
    center.removePendingNotificationRequests(withIdentifiers: [stageUuidstr])
}

