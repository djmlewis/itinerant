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
let kNotificationActionStageHalt = "STAGE_HALT_ACTION"
let kNotificationCategoryStageCompleted = "CATEGORY_STAGE_COMPLETED"
let kNotificationCategoryRepeatingSnoozeIntervalCompleted = "CATEGORY_REPEATING_SNOOZE_COMPLETED"
let kNotificationCategoryPostCompletedSnoozeIntervalCompleted = "CATEGORY_POSTCOMPLETED_SNOOZE_COMPLETED"



// Define the custom actions.
let kUNNActionOpenApp = UNNotificationAction(identifier: kNotificationActionOpenAppToItinerary,
                                         title: "Open Itinerary",
                                         options: [.foreground])
let kUNNActionNextStage = UNNotificationAction(identifier: kNotificationActionStageStartNext,
                                         title: "Start Next Stage",
                                         options: [.foreground])
let kUNNActionEndStage = UNNotificationAction(identifier: kNotificationActionStageHalt,
                                         title: "Halt this stage",
                                         options: [.foreground])
let kUNNActionSnooze = UNNotificationAction(identifier: kNotificationActionSnooze,
                                        title: "Snooze",
                                        options: [])
// Define the notification type
let kUNNStageCompletedCategory =
UNNotificationCategory(identifier: kNotificationCategoryStageCompleted,
                       actions: [kUNNActionEndStage, kUNNActionNextStage, kUNNActionSnooze, kUNNActionOpenApp],
                       intentIdentifiers: [],
                       options: .customDismissAction)
let kUNNCountUpSnoozeCompletedCategory =
UNNotificationCategory(identifier: kNotificationCategoryRepeatingSnoozeIntervalCompleted,
                       actions: [kUNNActionEndStage, kUNNActionNextStage, kUNNActionOpenApp],
                       intentIdentifiers: [],
                       options: .customDismissAction)

func removeAllPendingAndDeliveredStageNotifications(forUUIDstr uuidStr: String) {
    removeAllPendingStageNotifications(forUUIDstr: uuidStr)
    removeAllDeliveredStageNotifications(forUUIDstr: uuidStr)
}
func removeAllPendingStageNotifications(forUUIDstr uuidStr: String) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: StageNotificationInterval.allSuffixedStrings(forString: uuidStr))
}
func removeAllDeliveredStageNotifications(forUUIDstr uuidStr: String) {
    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: StageNotificationInterval.allSuffixedStrings(forString: uuidStr))
}

func requestStageCompletedSingleSnoozeNotification(toResponse response: UNNotificationResponse) -> UNNotificationRequest{
    let userinfo = response.notification.request.content.userInfo
    removeAllPendingAndDeliveredStageNotifications(forUUIDstr: userinfo[kStageUUIDStr] as! String)

    let content = UNMutableNotificationContent()
    content.title = userinfo[kItineraryTitle] as! String
    content.subtitle = "\(userinfo[kStageTitle] as! String) is snoozing"
    content.userInfo = userinfo
    content.interruptionLevel = .active
    content.sound = .default
    content.categoryIdentifier = kNotificationCategoryPostCompletedSnoozeIntervalCompleted
    let snoozeInterval = Double(userinfo[kStageSnoozeDurationSecs] as! Int)
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: snoozeInterval, repeats: false)
    let request = UNNotificationRequest(identifier: userinfo[kStageUUIDStr] as! String, content: content, trigger: trigger)

    return request
}

func requestStageCompletedOrSnoozeIntervalRepeat(stage: Stage, itinerary: Itinerary, intervalType: StageNotificationInterval) -> UNNotificationRequest {
    let content = UNMutableNotificationContent()
    content.title = itinerary.title
    content.subtitle = "\(stage.title) " + (intervalType == .countDownEnd ? "has completed" : "is running")
    content.userInfo = [kItineraryUUIDStr : itinerary.idStr,
                            kStageUUIDStr : stage.idStr,
                              kStageTitle : stage.title,
                     kStageSnoozeDurationSecs : stage.snoozeDurationSecs,
                          kItineraryTitle : itinerary.title,
                     kNotificationDueTime : Date.now.timeIntervalSinceReferenceDate + Double(stage.snoozeDurationSecs)
    ]
    let categoryIdentifier: String, duration: Double, repeats: Bool, interruption: UNNotificationInterruptionLevel
    switch intervalType {
    case .countDownEnd:
        categoryIdentifier = kNotificationCategoryStageCompleted
        duration = Double(stage.durationSecsInt)
        repeats = false
        interruption = .timeSensitive
    case .snoozeIntervals:
        categoryIdentifier = kNotificationCategoryRepeatingSnoozeIntervalCompleted
        duration = Double(stage.snoozeDurationSecs)
        repeats = true
        interruption = .active
    }
    content.categoryIdentifier = categoryIdentifier
    content.interruptionLevel = interruption
    content.sound = .default
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: repeats)
    /* !!! We suffix our request.identifier with intervalType.string This must be accounted for when removing notifications !!!   */
    let request = UNNotificationRequest(identifier: stage.idStr + intervalType.string, content: content, trigger: trigger)
    return request
}

func postNotification(stage: Stage, itinerary: Itinerary, intervalType: StageNotificationInterval ) -> Void {
    let center = UNUserNotificationCenter.current()
    center.getNotificationSettings { notificationSettings in
        guard (notificationSettings.authorizationStatus == .authorized) else { debugPrint("unable to alert in any way"); return }
        var allowedAlerts = [UNAuthorizationOptions]()
        if notificationSettings.alertSetting == .enabled { allowedAlerts.append(.alert) }
        if notificationSettings.soundSetting == .enabled { allowedAlerts.append(.sound) }
        let request = requestStageCompletedOrSnoozeIntervalRepeat(stage: stage, itinerary: itinerary, intervalType: intervalType)
        center.add(request) { (error) in
            if error != nil {  debugPrint(error!.localizedDescription) }
        }
    }
}


