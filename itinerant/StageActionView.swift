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
    @Binding var uuidStrStageActive: String
    @Binding var uuidStrStageRunning: String
    @State private var timeElapsedAtUpdate: Double = 0.0
    @SceneStorage(kSceneStoreStageTimeStartedRunning) var timeStartedRunning: TimeInterval = Date().timeIntervalSinceReferenceDate
    @State private var uiUpdateTimer: Timer.TimerPublisher = Timer.publish(every: kUIUpdateTimerFrequency, on: .main, in: .common)
    @State private var uiUpdateTimerCancellor: Cancellable?
    
    private var stageIsRunning: Bool { uuidStrStageRunning == stage.id.uuidString }
    private var stageRunningOvertime: Bool { floor(timeElapsedAtUpdate) >= 0 }
    
    // MARK: - body
    var body: some View {
        HStack(alignment: .center) {
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
            .disabled(stage.id.uuidString != uuidStrStageActive)
            VStack(alignment: .leading) {
                Text(stage.title)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(Stage.stageDurationFormatter.string(from: Double(stage.durationSecsInt))!)
                    .foregroundColor(Color("ColourDarkGrey"))
            }
            Spacer()
            Text("\(stageRunningOvertime ? "" : "+" )" + (Stage.stageDurationFormatter.string(from: fabs(floor(timeElapsedAtUpdate))) ?? ""))
                .padding(4.0)
                .foregroundColor(stageRunningOvertime ? Color.black : Color.white)
                .background(stageRunningOvertime ? Color.clear : Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .opacity(stageIsRunning ? 1.0 : 0.0)
                .onReceive(uiUpdateTimer) {// we initialise at head and never set to nil, so never nil and can use !
                    //debugPrint($0)
                    if(stageIsRunning) {
                        timeElapsedAtUpdate = Double(stage.durationSecsInt) - ($0.timeIntervalSinceReferenceDate - timeStartedRunning)
                    }
                }
            
        }
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
    
    internal init(stage: Binding<Stage>, itinerary: Binding<Itinerary>, uuidStrStageActive: Binding<String>, uuidStrStageRunning: Binding<String>) {
        self._stage = stage
        self._itinerary = itinerary
        self._uuidStrStageActive = uuidStrStageActive
        self._uuidStrStageRunning = uuidStrStageRunning
        
    }
    
}


extension StageActionView {
    
    func handleStartStopButtonTapped() {
        if(stageIsRunning){ handleHaltRunning() }
        else { handleStartRunning() }
        
    }
    
    func handleHaltRunning() {
        removeNotification()
        uuidStrStageRunning = ""
        uiUpdateTimerCancellor?.cancel()
    }
    
    func handleStartRunning() {
        timeStartedRunning = Date().timeIntervalSinceReferenceDate
        timeElapsedAtUpdate = Double(stage.durationSecsInt)
        uuidStrStageRunning = stage.id.uuidString
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
            content.userInfo = [kItineraryUUIDStr : itinerary.id.uuidString, kStageUUIDStr : stage.id.uuidString]
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
        StageActionView(stage: .constant(Stage()), itinerary: .constant(Itinerary.templateItinerary()), uuidStrStageActive: .constant(""), uuidStrStageRunning: .constant(""))
    }
}

