//
//  StageRowView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI

struct StageActionView: View {
    
    @Binding var stage: Stage
    @Binding var itinerary: Itinerary
    @Binding var uuidStrStageActive: String
    @Binding var uuidStrStageRunning: String

    private var updateUITimer: UpdateUITimer!
    private var stageIsRunning: Bool { uuidStrStageRunning == stage.id.uuidString }
    
    
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
    }
    
    func handleStartRunning() {
        uuidStrStageRunning = stage.id.uuidString
        postNotification()
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
extension StageActionView {
    class UpdateUITimer{
        var structRef: StageActionView!
        var timer: Timer!
        
        init(_ structRef: StageActionView){
            self.structRef = structRef;
            self.timer = Timer.scheduledTimer(
                timeInterval: Double(structRef.stage.durationSecsInt),
                target: self,
                selector: #selector(timerTicked),
                userInfo: nil,
                repeats: true)
        }
        
        func stopTimer(){
            self.timer?.invalidate()
            self.structRef = nil
        }
        
        @objc private func timerTicked(){
            self.structRef.updateUITimerTicked()
        }
    }
    
    mutating func startUpdateUITimer(){
        self.updateUITimer = UpdateUITimer(self)
    }
    
    func stopUpdateUITimer() {
        self.updateUITimer.stopTimer()
    }
    func updateUITimerTicked(){
        DispatchQueue.main.async {
            updateUIAfterTimer()
        }
    }
    
    func updateUIAfterTimer() {
        
    }
}

// MARK: - Preview
struct StageView_Previews: PreviewProvider {
    static var previews: some View {
        StageActionView(stage: .constant(Stage()), itinerary: .constant(Itinerary.templateItinerary()), uuidStrStageActive: .constant(""), uuidStrStageRunning: .constant(""))
    }
}

