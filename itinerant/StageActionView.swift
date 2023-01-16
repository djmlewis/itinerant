//
//  StageRowView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI
import Combine

let kSceneStoreStageTimeStartedRunning = "timeStartedRunning"

struct StageActionView: View {
    
    @Binding var stage: Stage
    @Binding var itinerary: Itinerary
    @Binding var uuidStrStageActive: String
    @Binding var uuidStrStageRunning: String
    @State private var timeElapsedAtUpdate: Double = 0.0
    @SceneStorage(kSceneStoreStageTimeStartedRunning) var timeStartedRunning: TimeInterval = Date().timeIntervalSinceReferenceDate
    @State private var localtimer = Timer.publish(every: 0.33, on: .main, in: .common)
    @State private var localTimerCancellor: AnyCancellable?
    
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
                    .foregroundColor(.accentColor)
                    .fontWeight(.bold)
                Text(Stage.stageDurationFormatter.string(from: Double(stage.durationSecsInt))!)
            }
            Spacer()
            Text("\(stageRunningOvertime ? "" : "+" )" + (Stage.stageDurationFormatter.string(from: fabs(floor(timeElapsedAtUpdate))) ?? ""))
                .padding(4.0)
                .foregroundColor(stageRunningOvertime ? Color.black : Color.white)
                .background(stageRunningOvertime ? Color.clear : Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .onReceive(localtimer) {
                    if(stageIsRunning) {
                        timeElapsedAtUpdate = Double(stage.durationSecsInt) - ($0.timeIntervalSinceReferenceDate - timeStartedRunning)
                    }
                }
            
        }
        .onAppear() {
            if(stageIsRunning) {
                localTimerCancellor = localtimer.connect() as? AnyCancellable
            }
        }
        .onDisappear() {
            localTimerCancellor?.cancel()
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
        uuidStrStageRunning = ""
        localTimerCancellor?.cancel()
    }
    
    func handleStartRunning() {
        timeStartedRunning = Date().timeIntervalSinceReferenceDate
        timeElapsedAtUpdate = 0.0
        uuidStrStageRunning = stage.id.uuidString
        postNotification()
        localTimerCancellor = localtimer.connect() as? AnyCancellable
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
            content.userInfo = ["stageuuid":stage.id.uuidString]
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (Double(stage.durationSecsInt)), repeats: false)
            let request = UNNotificationRequest(identifier: itinerary.id.uuidString, content: content, trigger: trigger)
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if error != nil {  debugPrint(error!.localizedDescription) }
            }
        }
        
    }
}


// MARK: - Timer


// MARK: - Preview
struct StageView_Previews: PreviewProvider {
    static var previews: some View {
        StageActionView(stage: .constant(Stage()), itinerary: .constant(Itinerary.templateItinerary()), uuidStrStageActive: .constant(""), uuidStrStageRunning: .constant(""))
    }
}

