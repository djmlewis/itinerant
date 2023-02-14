//
//  Notifications.swift
//  itinerant
//
//  Created by David JM Lewis on 28/01/2023.
//

import Foundation
import UserNotifications

// UNN ACTIONS
let kNotificationActionOpenAppToItinerary = "OPEN_APP_TO_ITINERARY_ACTION"
let kNotificationActionSingleSnooze = "SINGLE_SNOOZE_ACTION"
let kNotificationActionStageStartNext = "STAGE_START_NEXT_ACTION"
let kNotificationActionStageHalt = "STAGE_HALT_ACTION"
// UNN CATEGORIES
let kNotificationCategoryUnknown = "CATEGORY_UNKNOWN"
let kNotificationCategoryStageCompleted = "CATEGORY_STAGE_COMPLETED"
let kNotificationCategoryStageAdditionalAlertCompleted = "CATEGORY_ADDITIONAL_ALERT_COMPLETED"
let kNotificationCategoryRepeatingSnoozeIntervalCompleted = "CATEGORY_REPEATING_SNOOZE_COMPLETED"
let kNotificationCategoryPostStageSingleSnoozeIntervalCompleted = "CATEGORY_POSTSTAGE_SINGLE_SNOOZE_COMPLETED"



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
let kUNNActionSnooze = UNNotificationAction(identifier: kNotificationActionSingleSnooze,
                                        title: "Snooze",
                                        options: [])
// Define the notification type
let kUNNStageCompletedCategory =
UNNotificationCategory(identifier: kNotificationCategoryStageCompleted,
                       actions: [kUNNActionEndStage, kUNNActionNextStage, kUNNActionSnooze, kUNNActionOpenApp],
                       intentIdentifiers: [],
                       options: .customDismissAction)
let kUNNSingleSnoozeCompletedCategory =
UNNotificationCategory(identifier: kNotificationCategoryPostStageSingleSnoozeIntervalCompleted,
                       actions: [kUNNActionEndStage, kUNNActionNextStage, kUNNActionSnooze, kUNNActionOpenApp],
                       intentIdentifiers: [],
                       options: .customDismissAction)
let kUNNAdditionalAlertCompletedCategory =
UNNotificationCategory(identifier: kNotificationCategoryStageAdditionalAlertCompleted,
                       actions: [kUNNActionEndStage, kUNNActionNextStage, kUNNActionOpenApp],
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
    UNUserNotificationCenter.current().getPendingNotificationRequests { requestsArray in
        let identifiersToRemove = requestsArray.filter( { $0.identifier.contains(uuidStr) } ).map( { $0.identifier })
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
    }
}
func removeAllDeliveredStageNotifications(forUUIDstr uuidStr: String) {
    UNUserNotificationCenter.current().getDeliveredNotifications { notificationssArray in
        let identifiersToRemove = notificationssArray.filter( { $0.request.identifier.contains(uuidStr) } ).map( { $0.request.identifier })
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiersToRemove)
    }
}

func requestStageCompletedSingleSnoozeNotification(toResponse response: UNNotificationResponse) -> UNNotificationRequest{
    let userinfo = response.notification.request.content.userInfo
    // requesting a post completed snooze cancels all other pending alarms
    removeAllPendingAndDeliveredStageNotifications(forUUIDstr: userinfo[kStageUUIDStr] as! String)

    let content = UNMutableNotificationContent()
    content.title = userinfo[kItineraryTitle] as! String
    content.subtitle = "\(userinfo[kStageTitle] as! String) is snoozing"
    content.userInfo = userinfo
    content.interruptionLevel = .active
    content.sound = .default
    content.categoryIdentifier = kNotificationCategoryPostStageSingleSnoozeIntervalCompleted
    let snoozeInterval = Double(userinfo[kStageSnoozeDurationSecs] as! Int)
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: snoozeInterval, repeats: false)
    let request = UNNotificationRequest(identifier: (userinfo[kStageUUIDStr] as! String) + StageNotificationInterval.snoozeSingleInterval.string, content: content, trigger: trigger)

    return request
}

func requestAdditionalAlertCompleted(stage: Stage, itinerary: Itinerary, intervalToAlarmSecs: Int, index: Int) -> UNNotificationRequest {
    let content = UNMutableNotificationContent()
    content.title = itinerary.title
    content.subtitle = "\(stage.title) " +  "has run for " + Stage.stageDurationStringFromDouble(Double(intervalToAlarmSecs))
    content.userInfo = [kItineraryUUIDStr : itinerary.idStr,
                            kStageUUIDStr : stage.idStr,
                              kStageTitle : stage.title,
                     kStageSnoozeDurationSecs : stage.snoozeDurationSecs,
                          kItineraryTitle : itinerary.title,
                     kNotificationDueTime : Date.now.timeIntervalSinceReferenceDate + Double(intervalToAlarmSecs)
    ]
    content.categoryIdentifier = kNotificationCategoryStageAdditionalAlertCompleted
    content.interruptionLevel = .active
    content.sound = .default
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(intervalToAlarmSecs), repeats: false)
    let request = UNNotificationRequest(identifier: stage.additionalAlertNotificationString(index: index), content: content, trigger: trigger)
    return request
}

func postAllAdditionalAlertNotifications(stage: Stage, itinerary: Itinerary) {
    for (indx, duration) in stage.additionalDurationsArray.enumerated() {
        postAdditionalAlertNotification(stage: stage, itinerary: itinerary, intervalToAlarmSecs: duration, index: indx)
    }
}

func postAdditionalAlertNotification(stage: Stage, itinerary: Itinerary, intervalToAlarmSecs: Int, index: Int ) -> Void {
    let center = UNUserNotificationCenter.current()
    center.getNotificationSettings { notificationSettings in
        guard (notificationSettings.authorizationStatus == .authorized) else { debugPrint("unable to alert in any way"); return }
        var allowedAlerts = [UNAuthorizationOptions]()
        if notificationSettings.alertSetting == .enabled { allowedAlerts.append(.alert) }
        if notificationSettings.soundSetting == .enabled { allowedAlerts.append(.sound) }
        let request = requestAdditionalAlertCompleted(stage: stage, itinerary: itinerary, intervalToAlarmSecs: intervalToAlarmSecs, index: index)
        center.add(request) { (error) in
            if error != nil {  debugPrint(error!.localizedDescription) }
        }
    }
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
    case .snoozeRepeatingIntervals:
        categoryIdentifier = kNotificationCategoryRepeatingSnoozeIntervalCompleted
        duration = Double(stage.snoozeDurationSecs)
        repeats = true
        interruption = .active
    default:
        categoryIdentifier = kNotificationCategoryUnknown
        duration = 0.0
        repeats = false
        interruption = .passive
        debugPrint("!! kNotificationCategoryUnknown ")
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


