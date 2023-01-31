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
    
    
    private var stageRunningOvertime: Bool { timeDifferenceAtUpdate >= 0 }
    
    var body: some View {
        Grid (alignment: .center, horizontalSpacing: 0.0, verticalSpacing: 0.0) {
            GridRow {
                HStack(spacing: 0.0) {
                    Image(systemName: stage.durationSecsInt == 0 ? "stopwatch" : "timer")
                        .padding(.leading, 2.0)
                    Text(Stage.stageDurationStringFromDouble(Double(stage.durationSecsInt)))
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .lineLimit(1)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.5)
                        .padding(.trailing, 2.0)
                    Button(action: {
                        handleStartStopButtonTapped()
                    }) {
                        Image(systemName: stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? "stop.circle" : "play.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderless)
                    .frame(idealWidth: 42, maxWidth: 42, minHeight: 42, alignment: .trailing)
                    .padding(.trailing, 4.0)
                    .disabled(!stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr))
                    .opacity(stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) ? 1.0 : 0.0)
                }
                .gridCellColumns(2)
            }
            .padding(0)
            GridRow {
                Text(stage.title)
                    .padding(0)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                //.font(.headline)
                //.font(Font.custom("SF Pro Rounded", size: 32, relativeTo: .headline))
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .gridCellColumns(2)
            }
            .padding(0)
            if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)  || dictStageStartDates[stage.id.uuidString] != nil {
                GridRow {
                    Text("\(stageRunningOvertime ? "" : "+" )" + Stage.stageDurationStringFromDouble(fabs((timeDifferenceAtUpdate))))
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(stageRunningOvertime ? Color("ColourRemainingFont") : Color("ColourOvertimeFont"))
                        .background(stageRunningOvertime ? Color("ColourRemainingBackground") : Color("ColourOvertimeBackground"))
                        .opacity(timeDifferenceAtUpdate == 0.0 || stage.durationSecsInt == 0  ? 0.0 : 1.0)
                        .gridCellColumns(1)
                        .lineLimit(1)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.5)
                        .border(timeDifferenceAtUpdate < 0.0 ? .white : .clear, width: 1.0)
                        .padding(.leading,2.0)
                        .padding(.trailing,2.0)
                        .gridCellColumns(2)
                }
                .padding(.top,3.0)
                GridRow {
                    Text(Stage.stageDurationStringFromDouble(fabs(timeAccumulatedAtUpdate)))
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                        .background(.white)
                        .opacity(timeAccumulatedAtUpdate == 0.0  ? 0.0 : 1.0)
                        .gridCellColumns(1)
                        .lineLimit(1)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.5)
                        .border(timeAccumulatedAtUpdate > 0.0 ? .black : .clear, width: 1.0)
                        .padding(.leading,2.0)
                        .padding(.trailing,2.0)
                        .gridCellColumns(2)
                }
                .padding(.top,3.0)
            }
        } /* Grid */
        .padding(0)
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
            if(stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)) {
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
            if(stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)) {
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
            if stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) { scrollToStageID = stage.id.uuidString}
        }
        /* Grid mods */
    } /* body */
} /* struct */



extension WKStageActionView {
    
    
    func  timeStartedRunning() -> TimeInterval {
        floor(Double(dictStageStartDates[stage.id.uuidString] ?? "\(Date.timeIntervalSinceReferenceDate)")!)
    }
    
    func setTimeStartedRunning(_ newValue: Double?) {
        // only set to nil when we must do that, like on RESET all stages
        // dont do it just on stopping so we can still see the elapsed times
        dictStageStartDates[stage.id.uuidString] = newValue == nil ? nil : String(format: "%.0f", floor(newValue!))
    }
    
}


extension WKStageActionView {
    
    func removeAllActiveRunningItineraryStageIDsAndNotifcations() {
        (uuidStrStagesActiveStr,uuidStrStagesRunningStr,dictStageStartDates) = itinerary.removeAllStageIDsAndNotifcations(from: uuidStrStagesActiveStr, andFrom: uuidStrStagesRunningStr, andFromDict: dictStageStartDates)
    }
    
    func handleStartStopButtonTapped() {
        if(stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)){ handleHaltRunning() }
        else { handleStartRunning() }
        
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
    
    func handleHaltRunning() {
        uiUpdateTimerCancellor?.cancel()
        removeNotification()
        // remove ourselves from active and running
        uuidStrStagesRunningStr = uuidStrStagesRunningStr.replacingOccurrences(of: stage.id.uuidString, with: "")
        uuidStrStagesActiveStr = uuidStrStagesActiveStr.replacingOccurrences(of: stage.id.uuidString, with: "")
        //setTimeStartedRunning(nil) <== dont do this or time disappear
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
            
            let request = requestStageCompleted(stage: stage, itinerary: itinerary)
            center.add(request) { (error) in
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
