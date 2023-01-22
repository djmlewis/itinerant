//
//  StageRowView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI
import Combine

let kSceneStoreStageTimeStartedRunning = "timeStartedRunning"
let kUIUpdateTimerFrequency = 0.2

class CancellingTimer {
    var cancellor: AnyCancellable?
    
    func cancelTimer() {
        cancellor?.cancel()
    }
}



struct StageActionView: View {
    
    @Binding var stage: Stage
    @Binding var itinerary: Itinerary
    @Binding var uuidStrStagesActiveStr: String
    @Binding var uuidStrStagesRunningStr: String

    @State private var timeElapsedAtUpdate: Double = 0.0
    @SceneStorage(kSceneStoreStageTimeStartedRunning) var timeStartedRunning: TimeInterval = Date().timeIntervalSinceReferenceDate
    @State private var uiUpdateTimer: Timer.TimerPublisher = Timer.publish(every: kUIUpdateTimerFrequency, on: .main, in: .common)
    @State private var uiUpdateTimerCancellor: Cancellable?
    
    private var stageIsActive: Bool { uuidStrStagesActiveStr.contains(stage.id.uuidString) }
    private var stageIsRunning: Bool { uuidStrStagesRunningStr.contains(stage.id.uuidString) }
    private var stageRunningOvertime: Bool { floor(timeElapsedAtUpdate) >= 0 }
    
    // MARK: - body
    var body: some View {
            VStack(alignment: .leading) {
                Text(stage.title)
                    .font(.title3)
                    .fontWeight(.bold)
                if !stage.details.isEmpty {
                    Text(stage.details)
                        .font(.body)
                }
                HStack {
                    Button(action: {
                        handleStartStopButtonTapped()
                    }) {
                        Image(systemName: stageIsRunning ? "stop.circle.fill" : "play.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(stageIsRunning ? .red : .accentColor)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .frame(width: 52, alignment: .leading)
                    .disabled(!stageIsActive)
                    Spacer()
                    Text(Stage.stageDurationFormatter.string(from: Double(stage.durationSecsInt))!)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("ColourDuration"))
                    Spacer()
                    Text("\(stageRunningOvertime ? "" : "+" )" + (Stage.stageDurationFormatter.string(from: fabs(floor(timeElapsedAtUpdate))) ?? ""))
                        .padding(4.0)
                        .foregroundColor(stageRunningOvertime ? Color("ColourRemainingFont") : Color("ColourOvertimeFont"))
                        .background(stageRunningOvertime ? Color("ColourRemainingBackground") : Color("ColourOvertimeBackground"))
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        .opacity(stageIsRunning ? 1.0 : 0.0)
                        .onReceive(uiUpdateTimer) {// we initialise at head and never set to nil, so never nil and can use !
                            //debugPrint($0)
                            if(stageIsRunning) {
                                timeElapsedAtUpdate = Double(stage.durationSecsInt) - ($0.timeIntervalSinceReferenceDate - timeStartedRunning)
                            }
                        }
                }
            } /* VStack */
            .padding(6.0)
            .background(stageIsRunning ? Color("ColourBackgroundRunning") : (stageIsActive ? Color.clear : Color("ColourBackgroundInactive")))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
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
        
    }
    
//    internal init(stage: Binding<Stage>, itinerary: Binding<Itinerary>, uuidStrStageActiveDict: Binding<[String:String]>, uuidStrStageRunningDict: Binding<[String:String]>) {
//        self._stage = stage
//        self._itinerary = itinerary
//        self._uuidStrStageActiveDict = uuidStrStageActiveDict
//        self._uuidStrStageRunningDict = uuidStrStageRunningDict
//    }
    
}


extension StageActionView {
    
    func handleStartStopButtonTapped() {
        if(stageIsRunning){ handleHaltRunning() }
        else { handleStartRunning() }
        
    }
    
    func handleHaltRunning() {
        removeNotification()
        uuidStrStagesRunningStr = uuidStrStagesRunningStr.replacingOccurrences(of: stage.id.uuidString, with: "")
        uiUpdateTimerCancellor?.cancel()
    }
    
    func handleStartRunning() {
        timeStartedRunning = Date().timeIntervalSinceReferenceDate
        timeElapsedAtUpdate = Double(stage.durationSecsInt)
        uuidStrStagesRunningStr.append(stage.id.uuidString)
        postNotification()
        // need to reset the timer to reattach the cancellor
        uiUpdateTimer = Timer.publish(every: kUIUpdateTimerFrequency, on: .main, in: .common)
        uiUpdateTimerCancellor = uiUpdateTimer.connect()
    }
    
}

// MARK: - Notification
extension StageActionView {
    
    func postNotification() -> Void {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) else { debugPrint("unable to alert in any way"); return }
            var allowedAlerts = [UNAuthorizationOptions]()
            if settings.alertSetting == .enabled { allowedAlerts.append(.alert) }
            if settings.soundSetting == .enabled { allowedAlerts.append(.sound) }
            
            let content = UNMutableNotificationContent()
            content.title = itinerary.title
            content.body = "\(stage.title) has completed"
            content.userInfo = [kItineraryUUIDStr : itinerary.id.uuidString,
                                    kStageUUIDStr : stage.id.uuidString,
                                      kStageTitle : stage.title,
                                  kItineraryTitle : itinerary.title
            ]
            content.categoryIdentifier = kNotificationCategoryStageCompleted
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


// MARK: - Timer


// MARK: - Preview
struct StageView_Previews: PreviewProvider {
    static var previews: some View {
        StageActionView(stage: .constant(Stage()), itinerary: .constant(Itinerary.templateItinerary()), uuidStrStagesActiveStr: .constant(""), uuidStrStagesRunningStr: .constant(""))
    }
}

