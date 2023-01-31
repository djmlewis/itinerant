//
//  StageRowView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI
import Combine

func outlinesText(text: String) -> AttributedString {
    var title = AttributedString(text)
    title.strokeColor = .blue
    title.strokeWidth = -3
    title.foregroundColor = .red
    return title
}

struct StageActionView: View {
    
    @Binding var stage: Stage
    @Binding var itinerary: Itinerary
    @Binding var uuidStrStagesActiveStr: String
    @Binding var uuidStrStagesRunningStr: String
    @Binding var dictStageStartDates: [String:String]
    @Binding var resetStageElapsedTime: Bool?
    @Binding var scrollToStageID: String?

    @Binding var toggleDisclosureDetails: Bool

    @State private var timeDifferenceAtUpdate: Double = 0.0
    @State private var timeAccumulatedAtUpdate: Double = 0.0
    @State private var uiUpdateTimer: Timer.TimerPublisher = Timer.publish(every: kUIUpdateTimerFrequency, on: .main, in: .common)
    @State private var uiUpdateTimerCancellor: Cancellable?
    @State private var disclosureDetailsExpanded: Bool = true
    
    private var stageRunningOvertime: Bool { timeDifferenceAtUpdate >= 0 }
    
    
    @AppStorage(kAppStorageColourStageInactive) var appStorageColourStageInactive: String = kAppStorageDefaultColourStageInactive
    @AppStorage(kAppStorageColourStageActive) var appStorageColourStageActive: String = kAppStorageDefaultColourStageActive
    @AppStorage(kAppStorageColourStageRunning) var appStorageColourStageRunning: String = kAppStorageDefaultColourStageRunning
    @AppStorage(kAppStorageStageInactiveTextDark) var appStorageStageInactiveTextDark: Bool = true
    @AppStorage(kAppStorageStageActiveTextDark) var appStorageStageActiveTextDark: Bool = true
    @AppStorage(kAppStorageStageRunningTextDark) var appStorageStageRunningTextDark: Bool = true


    func stageTextColour() -> Color {
        if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) {
            return appStorageStageRunningTextDark == true ? .black : .white
        }
        if stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) {
            return appStorageStageActiveTextDark == true ? .black : .white
        }
        return appStorageStageInactiveTextDark == true ? .black : .white
    }

    // MARK: - body
    var body: some View {
        
        
        VStack(alignment: .leading) {
            HStack {
                Text(stage.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(stageTextColour())
                    .scenePadding(.minimum, edges: .horizontal)
                Spacer()
                Button(action: {
                    disclosureDetailsExpanded = !disclosureDetailsExpanded
                }) {
                    Image(systemName: disclosureDetailsExpanded == true ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            HStack {
                Image(systemName: stage.durationSecsInt == 0 ? "stopwatch" : "timer")
                    .foregroundColor(stageTextColour())
                if stage.durationSecsInt > 0 {
                    Text(Stage.stageDurationStringFromDouble(Double(stage.durationSecsInt)))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(stageTextColour())
                }
                Spacer()
                Text(Stage.stageDurationStringFromDouble(fabs((timeAccumulatedAtUpdate))))
                    .padding(4.0)
                    .foregroundColor(.black)
                    .background(.white)
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke( .black, lineWidth: 1.0)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .opacity(timeAccumulatedAtUpdate == 0.0  ? 0.0 : 1.0)
                Spacer()
                Text("\(stageRunningOvertime ? "" : "+" )" +
                     Stage.stageDurationStringFromDouble(fabs((timeDifferenceAtUpdate))))
                    .bold(stageRunningOvertime)
                    .padding(4.0)
                    .foregroundColor(stageRunningOvertime ? Color("ColourRemainingFont") : Color("ColourOvertimeFont"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke( .black, lineWidth: 1.0)
                    )
                    .background(stageRunningOvertime ? Color("ColourRemainingBackground") : Color("ColourOvertimeBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .opacity(timeDifferenceAtUpdate == 0.0 || stage.durationSecsInt == 0  ? 0.0 : 1.0)
                Button(action: {
                    handleStartStopButtonTapped()
                }) {
                    Image(systemName: stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? "stop.circle" : "play.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .foregroundColor(.white)
                .buttonStyle(BorderlessButtonStyle())
                .frame(width: 32, alignment: .leading)
                .disabled(!stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr))
                .opacity(stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) ? 1.0 : 0.0)
            }
            if !stage.details.isEmpty && disclosureDetailsExpanded == true{
                Text(stage.details)
                    .font(.body)
            }
        } /* VStack */
        .padding(0)
        .cornerRadius(8) /// make the background rounded
        .gesture(
            TapGesture(count: 2)
                .onEnded({ _ in
                    removeAllActiveRunningItineraryStageIDsAndNotifcations()
                    // make ourself active
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        uuidStrStagesActiveStr.append(stage.id.uuidString)
                        // scrollTo managed by onChange uuidStrStagesActiveStr
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
            if stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) { scrollToStageID = stage.id.uuidString }
        }
       .onChange(of: toggleDisclosureDetails) { newValue in
           // iOS only
            disclosureDetailsExpanded = toggleDisclosureDetails
        }

    }
    
}


extension StageActionView {
    
    
    func  timeStartedRunning() -> TimeInterval {
        floor(Double(dictStageStartDates[stage.id.uuidString] ?? "\(Date.timeIntervalSinceReferenceDate)")!)
    }
    
    func setTimeStartedRunning(_ newValue: Double?) {
        dictStageStartDates[stage.id.uuidString] = newValue == nil ? nil : String(format: "%.0f", floor(newValue!))
    }
    
}



extension StageActionView {
    
    func removeAllActiveRunningItineraryStageIDsAndNotifcations() {
        (uuidStrStagesActiveStr,uuidStrStagesRunningStr,dictStageStartDates) = itinerary.removeAllStageIDsAndNotifcations(from: uuidStrStagesActiveStr, andFrom: uuidStrStagesRunningStr, andFromDict: dictStageStartDates)
    }
    
    func handleStartStopButtonTapped() {
        if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) { handleHaltRunning() }
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
extension StageActionView {
    
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


// MARK: - Timer


// MARK: - Preview
struct StageView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Ho")
    }
}

