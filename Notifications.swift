//
//  Notifications.swift
//  itinerant
//
//  Created by David JM Lewis on 28/01/2023.
//

import Foundation
import UserNotifications

let kSnoozeIntervalSecs = 10.0
let kNotificationActionOpenApp = "OPEN_APP_ACTION"
let kNotificationActionSnooze = "SNOOZE_ACTION"
let kNotificationCategoryStageCompleted = "STAGE_COMPLETED"



// Define the custom actions.
let kUNNOpenAppAction = UNNotificationAction(identifier: kNotificationActionOpenApp,
                                         title: "Open Itinerary",
                                         options: [.foreground])
let kUNNSnoozeAction = UNNotificationAction(identifier: kNotificationActionSnooze,
                                        title: "Snooze",
                                        options: [])
// Define the notification type
let kUNNStageCompletedCategory =
UNNotificationCategory(identifier: kNotificationCategoryStageCompleted,
                       actions: [kUNNOpenAppAction, kUNNSnoozeAction],
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
