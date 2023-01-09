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
    //@Binding var stageUuidEnabled: String
    var inEditingMode: Bool
    
    @State private var stageIsRunning = false
    
    var body: some View {
        HStack(alignment: .center) {
            if !inEditingMode {
                Button(action: {
                    stageIsRunning = !stageIsRunning
                    postNotification()
                }) {
                    Image(systemName: stageIsRunning == false ? "play.circle.fill" : "stop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(stageIsRunning == false ? .accentColor : .red)
                }
                .buttonStyle(BorderlessButtonStyle())
                .frame(width: 52, alignment: .leading)
                .disabled(stage.id.uuidString != itinerary.uuidActiveStage)
            }
            VStack(alignment: .leading) {
                Text(stage.title)
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .fontWeight(.bold)
                Text(Stage.stageDurationFormatter.string(from: Double(stage.durationSecsInt))!)
            }
        }
    }
}

struct StageView_Previews: PreviewProvider {
    static var previews: some View {
        StageActionView(stage: .constant(Stage.templateStage()), itinerary: .constant(Itinerary.templateItinerary()), inEditingMode: false)
    }
}

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
