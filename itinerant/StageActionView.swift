//
//  StageRowView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI
import Combine

struct StageActionView: View {
    
    @Binding var stage: Stage
    @Binding var itinerary: Itinerary
    @Binding var uuidStrStagesActiveStr: String
    @Binding var uuidStrStagesRunningStr: String
    @Binding var dictStageStartDates: [String:String]
    @Binding var dictStageEndDates: [String:String]
    @Binding var resetStageElapsedTime: Bool?
    @Binding var scrollToStageID: String?
    @Binding var stageToHandleSkipActionID: String?
    @Binding var stageToStartRunningID: String?
    @Binding var toggleDisclosureDetails: Bool

    @State private var timeDifferenceAtUpdate: Double = 0.0
    @State private var timeAccumulatedAtUpdate: Double = 0.0
    @State private var uiUpdateTimer: Timer.TimerPublisher = Timer.publish(every: kUIUpdateTimerFrequency, on: .main, in: .common)
    @State private var uiUpdateTimerCancellor: Cancellable?
    @State private var disclosureDetailsExpanded: Bool = true
    
    private var stageRunningOvertime: Bool { timeDifferenceAtUpdate <= 0 }
        
    @AppStorage(kAppStorageColourStageInactive) var appStorageColourStageInactive: String = kAppStorageDefaultColourStageInactive
    @AppStorage(kAppStorageColourStageActive) var appStorageColourStageActive: String = kAppStorageDefaultColourStageActive
    @AppStorage(kAppStorageColourStageRunning) var appStorageColourStageRunning: String = kAppStorageDefaultColourStageRunning
    @AppStorage(kAppStorageStageInactiveTextDark) var appStorageStageInactiveTextDark: Bool = true
    @AppStorage(kAppStorageStageActiveTextDark) var appStorageStageActiveTextDark: Bool = true
    @AppStorage(kAppStorageStageRunningTextDark) var appStorageStageRunningTextDark: Bool = true

    @EnvironmentObject private var appDelegate: AppDelegate

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
                // alarm duration and button
                Image(systemName: stage.durationSecsInt == 0 ? "stopwatch" : "timer")
                // Timer type icon
                    .foregroundColor(stageTextColour())
                if stage.durationSecsInt > 0 {
                    Text(Stage.stageDurationStringFromDouble(Double(stage.durationSecsInt)))
                    // Alarm time duration
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(stageTextColour())
                }
                Spacer()
                if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) || stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) {
                    Button(action: {
                        // Start Stop
                        handleStartStopButtonTapped()
                    }) {
                        Image(systemName: stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? "stop.circle" : "play.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .foregroundColor(.white)
                    .buttonStyle(BorderlessButtonStyle())
                    .frame(width: 46, alignment: .leading)
                }
            }
            if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)  || dictStageStartDates[stage.id.uuidString] != nil {
                Grid (horizontalSpacing: 3.0, verticalSpacing: 0.0) {
                    // Times elapsed
                    GridRow {
                        HStack {
                            Image(systemName: "hourglass")
                            // elapsed time
                            Text(Stage.stageDurationStringFromDouble(fabs(timeAccumulatedAtUpdate)))
                                .bold()
                        }
                        .padding(4.0)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                        .background(.white)
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke( .black, lineWidth: 1.0)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        .opacity(timeAccumulatedAtUpdate == 0.0  ? 0.0 : 1.0)
                       HStack {
                            Image(systemName: stageRunningOvertime ?  "bell.and.waves.left.and.right" : "bell")
                            // time remaining or overtime
                            Text("\(stageRunningOvertime ? "+" : "" )" +
                                 Stage.stageDurationStringFromDouble(fabs(timeDifferenceAtUpdate)))
                            .bold()
                        }
                        .padding(4.0)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(stageRunningOvertime ? Color("ColourOvertimeFont") : Color("ColourRemainingFont"))
                        .background(stageRunningOvertime ? Color("ColourOvertimeBackground") : Color("ColourRemainingBackground"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke( .black, lineWidth: 1.0)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        .opacity(timeDifferenceAtUpdate == 0.0 || stage.durationSecsInt == 0  ? 0.0 : 1.0)
                    } /* GridRow */
                    .padding(0.0)
                } /* Grid */
                .padding(0.0)
            }
            HStack {
            // title and expand details
                Button(action: {
                    disclosureDetailsExpanded = !disclosureDetailsExpanded
                }) {
                    Image(systemName: disclosureDetailsExpanded == true ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Text(stage.title)
                // Stage title
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(stageTextColour())
                    .scenePadding(.minimum, edges: .horizontal)
            }
            .padding(0.0)
            if !stage.details.isEmpty && disclosureDetailsExpanded == true{
                Text(stage.details)
                // Details
                    .font(.body)
                    .foregroundColor(stageTextColour())
                    .multilineTextAlignment(.leading)
                    .padding(0.0)
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
            } else {
                // use dictStageEndDates[stage.id.uuidString] != nil to detect we have run and to update the updateTimes
                updateUpdateTimes(forUpdateDate: dictStageEndDates[stage.id.uuidString]?.dateFromDouble)
            }
        }
        .onDisappear() {
            uiUpdateTimerCancellor?.cancel()
        }
        .onReceive(uiUpdateTimer) {// we initialise at head and never set to nil, so never nil and can use !
            //debugPrint($0)
            if(stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)) {
                updateUpdateTimes(forUpdateDate: $0)
            } else {
                // we may have been skipped so cancel at the next opportunity
                uiUpdateTimerCancellor?.cancel()
            }
        }
        .onChange(of: resetStageElapsedTime) { resetStage(newValue: $0) }
        .onChange(of: uuidStrStagesActiveStr) { newValue in
            if stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) { scrollToStageID = stage.id.uuidString }
        }
       .onChange(of: toggleDisclosureDetails) { newValue in
           // iOS only
            disclosureDetailsExpanded = toggleDisclosureDetails
        }
       .onChange(of: stageToHandleSkipActionID) { // handle notifications to skip to next stage
           if $0 != nil  && $0 == stage.id.uuidString {
               handleHaltRunning(andSkip: true)
           }
       }
       .onChange(of: stageToStartRunningID) { // handle notifications to be skipped to this stage
           if $0 != nil && $0 == stage.id.uuidString {
               handleStartRunning()
           }
       }
        /* VStack mods */
    } /* body */
} /* struct */


extension StageActionView {
    
    func updateUpdateTimes(forUpdateDate optDate: Date?) {
        if let date = optDate {
            // we have a dateStarted date either from a timer update or onAppear when we havve/had run since reset
            timeAccumulatedAtUpdate = floor(date.timeIntervalSinceReferenceDate - timeStartedRunning())
            timeDifferenceAtUpdate = floor(Double(stage.durationSecsInt) - timeAccumulatedAtUpdate)
        } else {
            timeDifferenceAtUpdate = 0.0
            timeAccumulatedAtUpdate = 0.0
        }
    }
    
    func  timeStartedRunning() -> TimeInterval {
        floor(Double(dictStageStartDates[stage.id.uuidString] ?? "\(Date.timeIntervalSinceReferenceDate)")!)
    }
    
    func setTimeStartedRunning(_ newValue: Double?) {
        // only set to nil when we must do that, like on RESET all stages
        // dont do it just on stopping so we can still see the elapsed times
        dictStageStartDates[stage.id.uuidString] = newValue == nil ? nil : String(format: "%.0f", floor(newValue!))
    }
    
    func setTimeEndedRunning(_ newValue: Double?) {
        // only set to nil when we must do that, like on RESET all stages
        // dont do it just on stopping so we can still see the elapsed times
        dictStageEndDates[stage.id.uuidString] = newValue == nil ? nil : String(format: "%.0f", floor(newValue!))
    }
    
}



extension StageActionView {
    
    func resetStage(newValue: Bool?) {
        DispatchQueue.main.async {
            if newValue == true {
                timeDifferenceAtUpdate = 0.0
                timeAccumulatedAtUpdate = 0.0
                resetStageElapsedTime = nil
                setTimeStartedRunning(nil)
                setTimeEndedRunning(nil)
          }
        }
    }

    func removeAllActiveRunningItineraryStageIDsAndNotifcations() {
        (uuidStrStagesActiveStr,uuidStrStagesRunningStr,dictStageStartDates,dictStageEndDates) = itinerary.removeAllStageIDsAndNotifcationsFrom(str1: uuidStrStagesActiveStr, str2: uuidStrStagesRunningStr, dict1: dictStageStartDates, dict2: dictStageEndDates)
    }
    
    func handleStartStopButtonTapped() {
        if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) { handleHaltRunning(andSkip: false) }
        else { handleStartRunning() }
        
    }
    
    func handleStartRunning() {
        setTimeStartedRunning(Date().timeIntervalSinceReferenceDate)
        timeDifferenceAtUpdate = Double(stage.durationSecsInt)
        timeAccumulatedAtUpdate = 0.0
        uuidStrStagesRunningStr.append(stage.id.uuidString)
        // if duration == 0 it is not counted down, no notification
        if stage.durationSecsInt > 0 { postNotification(stage: stage, itinerary: itinerary) }
        // need to reset the timer to reattach the cancellor
        uiUpdateTimer = Timer.publish(every: kUIUpdateTimerFrequency, on: .main, in: .common)
        uiUpdateTimerCancellor = uiUpdateTimer.connect()
    }
    
    func handleHaltRunning(andSkip: Bool) {
        setTimeEndedRunning(Date().timeIntervalSinceReferenceDate)
        uiUpdateTimerCancellor?.cancel()
        removeNotification(stageUuidstr:stage.id.uuidString)
        // remove ourselves from active and running
        uuidStrStagesRunningStr = uuidStrStagesRunningStr.replacingOccurrences(of: stage.id.uuidString, with: "")
        uuidStrStagesActiveStr = uuidStrStagesActiveStr.replacingOccurrences(of: stage.id.uuidString, with: "")
        //setTimeStartedRunning(nil) <== dont do this or time disappear
        // set the next stage to active if there is one above us
        if let ourindex = itinerary.stageIndex(forUUIDstr: stage.id.uuidString) {
            if itinerary.stages.count > ourindex + 1 {
                let nextStageUUIDstr = itinerary.stages[ourindex + 1].id.uuidString
                uuidStrStagesActiveStr.append(nextStageUUIDstr)
                if andSkip {
                    stageToStartRunningID = nil
                    // reset the stageToHandleSkipActionID as we handled it
                    stageToHandleSkipActionID = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        stageToStartRunningID = nextStageUUIDstr
                    }
                }
            } else {
                // do nothing, we have completed
            }
        }
    }
    
}


// MARK: - Timer


// MARK: - Preview
struct StageView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Ho")
    }
}

