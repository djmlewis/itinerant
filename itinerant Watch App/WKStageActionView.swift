//
//  WKStageActionView.swift
//  itinerant Watch App
//
//  Created by David JM Lewis on 27/01/2023.
//

import SwiftUI
import Combine
import UserNotifications



struct WKStageActionView: View {
    @Binding var stage: Stage
    @Binding var itinerary: Itinerary
    @Binding var uuidStrStagesActiveStr: String
    @Binding var uuidStrStagesRunningStr: String
    @Binding var dictStageStartDates: [String:String]
    @Binding var resetStageElapsedTime: Bool?
    @Binding var scrollToStageID: String?

    
    @State private var timeDifferenceAtUpdate: Double = 0.0
    @State private var timeAccumulatedAtUpdate: Double = 0.0
    @State private var uiUpdateTimer: Timer.TimerPublisher = Timer.publish(every: kUIUpdateTimerFrequency, on: .main, in: .common)
    @State private var uiUpdateTimerCancellor: Cancellable?
    @State private var disclosureDetailsExpanded: Bool = true
    
    private var stageIsActive: Bool { uuidStrStagesActiveStr.contains(stage.id.uuidString) }
    private var stageIsRunning: Bool { uuidStrStagesRunningStr.contains(stage.id.uuidString) }
    private var stageRunningOvertime: Bool { (timeDifferenceAtUpdate) >= 0 }

    var body: some View {
        VStack(alignment: .center) {
            Text(stage.title)
                .padding(0)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
            HStack {
                Image(systemName: stage.durationSecsInt == 0 ? "stopwatch" : "timer")
                    //.foregroundColor(Color("ColourDuration"))
                if stage.durationSecsInt > 0 {
                    Text(Stage.stageDurationStringFromDouble(Double(stage.durationSecsInt)))
                    .fontWeight(.bold)
                    .foregroundColor(Color("ColourDuration"))
                    .padding(0)
                }
                Spacer()
                Button(action: {
                    handleStartStopButtonTapped()
                }) {
                    Image(systemName: stageIsRunning ? "stop.circle.fill" : "play.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(0)
                        .foregroundColor(stageIsRunning ? Color("ColourOvertimeBackground") : .accentColor)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(0)
                .frame(width: 56, alignment: .trailing)
                .disabled(!stageIsActive)
                .opacity(stageIsActive ? 1.0 : 0.0)

            }
            Grid {
                GridRow {
                    Text(Stage.stageDurationStringFromDouble(fabs((timeAccumulatedAtUpdate))))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.black)
                        .background(.white)
                        .cornerRadius(4)
                        .opacity(timeAccumulatedAtUpdate == 0.0  ? 0.0 : 1.0)
                        .gridCellColumns(1)
                    Text("\(stageRunningOvertime ? "" : "+" )" +
                         Stage.stageDurationStringFromDouble(fabs((timeDifferenceAtUpdate))))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .cornerRadius(4)
                        .foregroundColor(stageRunningOvertime ? Color("ColourRemainingFont") : Color("ColourOvertimeFont"))
                        .background(stageRunningOvertime ? Color("ColourRemainingBackground") : Color("ColourOvertimeBackground"))
                        .cornerRadius(4)
                        .opacity(timeDifferenceAtUpdate == 0.0 || stage.durationSecsInt == 0  ? 0.0 : 1.0)
                        .gridCellColumns(1)

                }
            }
            .padding()
            
        } /* VStack */
        .gesture(
            TapGesture(count: 2)
                .onEnded({ _ in
                    removeAllActiveRunningItineraryStageIDsAndNotifcations()
                    // make ourself active
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        uuidStrStagesActiveStr.append(stage.id.uuidString)
                    }
                })
        )
        .onAppear() {
            if(stageIsRunning) {
                // need to reset the timer to reattach the cancellor
                uiUpdateTimer = Timer.publish(every: kUIUpdateTimerFrequency, on: .main, in: .common)
                uiUpdateTimerCancellor = uiUpdateTimer.connect()
            }
        }
        .onDisappear() {
            uiUpdateTimerCancellor?.cancel()
        }
        .onReceive(uiUpdateTimer) {// we initialise at head and never set to nil, so never nil and can use !
            //debugPrint($0)
            if(stageIsRunning) {
                timeAccumulatedAtUpdate = floor($0.timeIntervalSinceReferenceDate - timeStartedRunning())
                timeDifferenceAtUpdate = floor(Double(stage.durationSecsInt) - timeAccumulatedAtUpdate)
            } else {
                // we may have been skipped so cancel at the next opportunity
                uiUpdateTimerCancellor?.cancel()
            }
        }
        .onChange(of: resetStageElapsedTime) { newValue in
            DispatchQueue.main.async {
                if newValue == true {
                    timeDifferenceAtUpdate = 0.0
                    timeAccumulatedAtUpdate = 0.0
                    resetStageElapsedTime = nil
                }
            }
        }
        .onChange(of: uuidStrStagesActiveStr) { newValue in
            if stageIsActive { scrollToStageID = stage.id.uuidString}
        }
    }
}



extension WKStageActionView {
    
    
    func  timeStartedRunning() -> TimeInterval {
        floor(Double(dictStageStartDates[stage.id.uuidString] ?? "\(Date.timeIntervalSinceReferenceDate)")!)
    }
    
    func setTimeStartedRunning(_ newValue: Double?) {
        dictStageStartDates[stage.id.uuidString] = newValue == nil ? nil : String(format: "%.0f", floor(newValue!))
    }
    
}


extension WKStageActionView {
    
    func removeAllActiveRunningItineraryStageIDsAndNotifcations() {
        (uuidStrStagesActiveStr,uuidStrStagesRunningStr,dictStageStartDates) = itinerary.removeAllStageIDsAndNotifcations(from: uuidStrStagesActiveStr, andFrom: uuidStrStagesRunningStr, andFromDict: dictStageStartDates)
    }
    
    func handleStartStopButtonTapped() {
        if(stageIsRunning){ handleHaltRunning() }
        else { handleStartRunning() }
        
    }
    
    func handleHaltRunning() {
        uiUpdateTimerCancellor?.cancel()
        removeNotification()
        // remove ourselves from active and running
        uuidStrStagesRunningStr = uuidStrStagesRunningStr.replacingOccurrences(of: stage.id.uuidString, with: "")
        uuidStrStagesActiveStr = uuidStrStagesActiveStr.replacingOccurrences(of: stage.id.uuidString, with: "")
        setTimeStartedRunning(nil)
        // set the next stage to active if there is one above us
        if let ourindex = itinerary.stages.firstIndex(where: { $0.id == stage.id }) {
            if itinerary.stages.count > ourindex+1 {
                uuidStrStagesActiveStr.append(itinerary.stages[ourindex+1].id.uuidString)
            } else {
                if itinerary.stages.count > 0 {
                    uuidStrStagesActiveStr.append(itinerary.stages[0].id.uuidString)
                }
            }
        }
    }
    
    func handleStartRunning() {
        setTimeStartedRunning(Date().timeIntervalSinceReferenceDate)
        timeDifferenceAtUpdate = Double(stage.durationSecsInt)
        timeAccumulatedAtUpdate = 0.0
        uuidStrStagesRunningStr.append(stage.id.uuidString)
        // if duration == 0 it is not counted down, no notification
        if stage.durationSecsInt > 0 { postNotification() }
        // need to reset the timer to reattach the cancellor
        uiUpdateTimer = Timer.publish(every: kUIUpdateTimerFrequency, on: .main, in: .common)
        uiUpdateTimerCancellor = uiUpdateTimer.connect()
    }
    
}

// MARK: - Notification
extension WKStageActionView {
    
    func postNotification() -> Void {
        
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { notificationSettings in
            guard (notificationSettings.authorizationStatus == .authorized) else { debugPrint("unable to alert in any way"); return }
            var allowedAlerts = [UNAuthorizationOptions]()
            if notificationSettings.alertSetting == .enabled { allowedAlerts.append(.alert) }
            if notificationSettings.soundSetting == .enabled { allowedAlerts.append(.sound) }
            
            let content = UNMutableNotificationContent()
            content.title = itinerary.title
            content.subtitle = "\(stage.title) has completed"
            content.userInfo = [kItineraryUUIDStr : itinerary.id.uuidString,
                                    kStageUUIDStr : stage.id.uuidString,
                                      kStageTitle : stage.title,
                             kStageSnoozeDurationSecs : stage.snoozeDurationSecs,
                                  kItineraryTitle : itinerary.title
            ]
            content.categoryIdentifier = kNotificationCategoryStageCompleted
            content.interruptionLevel = .timeSensitive
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (Double(stage.durationSecsInt)), repeats: false)
            let request = UNNotificationRequest(identifier: stage.id.uuidString, content: content, trigger: trigger)
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if error != nil {  debugPrint(error!.localizedDescription) }
            }
        }
        
    }
    
    func removeNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [stage.id.uuidString])
    }
}



struct WKStageActionView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello, World!")
    }
}