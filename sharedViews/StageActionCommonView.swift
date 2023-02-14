//
//  StageActionCommonView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI
import Combine

struct StageActionCommonView: View {
    
    @Binding var stage: Stage
    @Binding var itinerary: Itinerary
    @Binding var uuidStrStagesActiveStr: String
    @Binding var uuidStrStagesRunningStr: String
    @Binding var dictStageStartDates: [String:String]
    @Binding var dictStageEndDates: [String:String]
    @Binding var resetStageElapsedTime: Bool?
    @Binding var scrollToStageID: String?
    @Binding var stageToHandleSkipActionID: String?
    @Binding var stageToHandleHaltActionID: String?
    @Binding var stageToStartRunningID: String?
    
#if !os(watchOS)
    @Binding var toggleDisclosureDetails: Bool
    @State var disclosureDetailsExpanded: Bool = true
#endif
    @State var timeDifferenceAtUpdate: Double = 0.0
    @State var timeAccumulatedAtUpdate: Double = 0.0
    @State var uiUpdateTimer: Timer.TimerPublisher = Timer.publish(every: kUIUpdateTimerFrequency, on: .main, in: .common)
    @State var uiUpdateTimerCancellor: Cancellable?
    

    
    
    var stageRunningOvertime: Bool { timeDifferenceAtUpdate <= 0 }
        
    @AppStorage(kAppStorageColourStageInactive) var appStorageColourStageInactive: String = kAppStorageDefaultColourStageInactive
    @AppStorage(kAppStorageColourStageActive) var appStorageColourStageActive: String = kAppStorageDefaultColourStageActive
    @AppStorage(kAppStorageColourStageRunning) var appStorageColourStageRunning: String = kAppStorageDefaultColourStageRunning
    @AppStorage(kAppStorageColourStageComment) var appStorageColourStageComment: String = kAppStorageDefaultColourStageComment
    
    @AppStorage(kAppStorageColourFontInactive) var appStorageColourFontInactive: String = kAppStorageDefaultColourFontInactive
    @AppStorage(kAppStorageColourFontActive) var appStorageColourFontActive: String = kAppStorageDefaultColourFontActive
    @AppStorage(kAppStorageColourFontRunning) var appStorageColourFontRunning: String = kAppStorageDefaultColourFontRunning
    @AppStorage(kAppStorageColourFontComment) var appStorageColourFontComment: String = kAppStorageDefaultColourFontComment

    
    @EnvironmentObject var appDelegate: AppDelegate

    // MARK: - body
    var body: some View {
        body_
            .gesture(gestureActivateStage())
            .onAppear() { handleOnAppear() }
            .onDisappear() { handleOnDisappear() }
            .onReceive(uiUpdateTimer) { handleReceive_uiUpdateTimer(newDate: $0) }
            .onChange(of: resetStageElapsedTime) { resetStage(newValue: $0) }
            .onChange(of: uuidStrStagesActiveStr) { if stage.isActive(uuidStrStagesActiveStr: $0) { scrollToStageID = stage.idStr} }
            .onChange(of: stageToHandleSkipActionID) {  handleReceive_stageToHandleSkipActionID(idstrtotest: $0)  }
            .onChange(of: stageToHandleHaltActionID) {  handleReceive_stageToHandleHaltActionID(idstrtotest: $0)  }
            .onChange(of: stageToStartRunningID) { handleReceive_stageToStartRunningID(idstrtotest: $0) }

    } /* body */
} /* struct */

extension StageActionCommonView {
    

    func updateUpdateTimes(forUpdateDate optDate: Date?) {
        if let date = optDate {
            // we have a dateStarted date either from a timer update or onAppear when we havve/had run since reset
            timeAccumulatedAtUpdate = floor(date.timeIntervalSinceReferenceDate - timeStartedRunning())
            // if its a count-up timer we ignore timeDifferenceAtUpdate 
            timeDifferenceAtUpdate = stage.isCountUp ? 0.0 : (floor(Double(stage.durationSecsInt) - timeAccumulatedAtUpdate))
        } else {
            timeDifferenceAtUpdate = 0.0
            timeAccumulatedAtUpdate = 0.0
        }
    }
    
    func  timeStartedRunning() -> TimeInterval {
        floor(Double(dictStageStartDates[stage.idStr] ?? "\(Date.timeIntervalSinceReferenceDate)")!)
    }
    
    func setTimeStartedRunning(_ newValue: Double?) {
        // only set to nil when we must do that, like on RESET all stages
        // dont do it just on stopping so we can still see the elapsed times
        dictStageStartDates[stage.idStr] = newValue == nil ? nil : String(format: "%.0f", floor(newValue!))
    }
    
    func setTimeEndedRunning(_ newValue: Double?) {
        // only set to nil when we must do that, like on RESET all stages
        // dont do it just on stopping so we can still see the elapsed times
        dictStageEndDates[stage.idStr] = newValue == nil ? nil : String(format: "%.0f", floor(newValue!))
    }
    
}



extension StageActionCommonView {
    
    func buttonStartHalt() -> some View {
        Button(action: {
            // Start Stop
            handleStartStopButtonTapped()
        })
        {
            Image(systemName: stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? "stop.circle" : "play.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? .red : Color.accentColor)
                .background(.white)
                .padding(3)
                .border(.white, width: 3)
                .clipShape(Circle())

        }
        .buttonStyle(BorderlessButtonStyle())
        .frame(width: 46, alignment: .leading)
        #if os(watchOS)
        .padding(.trailing, 4.0)
        #endif
    }
    
    func stageTextColour() -> Color {
        if stage.isCommentOnly {
            return appStorageColourFontComment.rgbaColor!
        }
        if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) {
            return appStorageColourFontRunning.rgbaColor!
        }
        if stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) {
            return appStorageColourFontActive.rgbaColor!
        }
        return appStorageColourFontInactive.rgbaColor!
    }


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
    
    func removeOnlyActiveRunningStatusLeavingStartEndDates() {
        (uuidStrStagesActiveStr,uuidStrStagesRunningStr) = itinerary.removeOnlyAllStageActiveRunningStatusLeavingStartEndDates(str1: uuidStrStagesActiveStr, str2: uuidStrStagesRunningStr)
    }
    
    func handleStartStopButtonTapped() {
        if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) { handleHaltRunning(andSkip: false) }
        else { handleStartRunning() }
        
    }
    
    func handleStartRunning() {
        setTimeStartedRunning(Date().timeIntervalSinceReferenceDate)
        timeDifferenceAtUpdate = Double(stage.durationSecsInt)
        timeAccumulatedAtUpdate = 0.0
        uuidStrStagesRunningStr.append(stage.idStr)
        // request countdown & snooze notification if needed
        if stage.isCountDown { postNotification(stage: stage, itinerary: itinerary, intervalType: .countDownEnd) }
        if stage.isPostingSnoozeAlerts { // give countdown a head start
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                postNotification(stage: stage, itinerary: itinerary, intervalType: .snoozeRepeatingIntervals)
            }
        }
        postAllAdditionalAlertNotifications(stage: stage, itinerary: itinerary)
        // need to reset the timer to reattach the cancellor
        uiUpdateTimer = Timer.publish(every: kUIUpdateTimerFrequency, on: .main, in: .common)
        uiUpdateTimerCancellor = uiUpdateTimer.connect()
    }
    
    func handleHaltRunning(andSkip: Bool) {
        setTimeEndedRunning(Date().timeIntervalSinceReferenceDate)
        uiUpdateTimerCancellor?.cancel()
        removeAllPendingAndDeliveredStageNotifications(forUUIDstr:stage.idStr)
        // remove ourselves from active and running
        uuidStrStagesRunningStr = uuidStrStagesRunningStr.replacingOccurrences(of: stage.idStr, with: "")
        uuidStrStagesActiveStr = uuidStrStagesActiveStr.replacingOccurrences(of: stage.idStr, with: "")
        //setTimeStartedRunning(nil) <== dont do this or time disappear
        // set the next stage to active if there is one ABOVE us otherwise do nothing
        if let nextActIndx = itinerary.indexOfNextActivableStage(fromUUIDstr: stage.idStr) {
            let nextStageUUIDstr = itinerary.stages[nextActIndx].idStr
            uuidStrStagesActiveStr.append(nextStageUUIDstr)
            if andSkip {
                stageToStartRunningID = nil
                // reset the stageToHandleSkipActionID as we handled it
                stageToHandleSkipActionID = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    stageToStartRunningID = nextStageUUIDstr
                }
            } else {
                // reset the stageToHandleHaltActionID as we may have handled that if no skip
                stageToHandleHaltActionID = nil
            }
            
        } else {
            // do nothing we have completed
        }
    }
    
}

extension StageActionCommonView {
    
    func handleOnAppear() {
        if(stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)) {
            // need to reset the timer to reattach the cancellor
            uiUpdateTimer = Timer.publish(every: kUIUpdateTimerFrequency, on: .main, in: .common)
            uiUpdateTimerCancellor = uiUpdateTimer.connect()
        } else {
            // use dictStageEndDates[stage.idStr] != nil to detect we have run and to update the updateTimes
            updateUpdateTimes(forUpdateDate: dictStageEndDates[stage.idStr]?.dateFromDouble)
        }
    }
    
    func handleOnDisappear() {
        uiUpdateTimerCancellor?.cancel()
    }
    
    func handleReceive_uiUpdateTimer(newDate: Date) {
        // we initialise at head and never set to nil, so never nil and can use !
        //$0 is the date of this update
        if(stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)) {
            updateUpdateTimes(forUpdateDate: newDate)
        } else {
            // we may have been skipped so cancel at the next opportunity
            uiUpdateTimerCancellor?.cancel()
        }
    }

    func handleReceive_stageToHandleSkipActionID(idstrtotest: String?) {
        // handle notifications to skip to next stage
        if idstrtotest != nil  && stage.hasIDstr(idstrtotest) {
            handleHaltRunning(andSkip: true)
        }
    }
    
    func handleReceive_stageToHandleHaltActionID(idstrtotest: String?) {
        // handle notifications to skip to next stage
        if idstrtotest != nil  && stage.hasIDstr(idstrtotest) {
            handleHaltRunning(andSkip: false)
        }
    }
    
    func handleReceive_stageToStartRunningID(idstrtotest: String?) {
        // handle notifications to be skipped to this stage
        if idstrtotest != nil && stage.hasIDstr(idstrtotest) {
            handleStartRunning()
        }
    }
    
    func gestureActivateStage() -> _EndedGesture<TapGesture> {
        return TapGesture(count: 2)
            .onEnded({ _ in
                // dont scrub the "has run" details - just deactivate and halt other stages
                removeOnlyActiveRunningStatusLeavingStartEndDates()
                // make ourself active only if we are not a comment
                if stage.isCommentOnly {
                    // just scroll there
                    scrollToStageID = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollToStageID = stage.idStr
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        uuidStrStagesActiveStr.append(stage.idStr)
                        // scrollTo managed by onChange uuidStrStagesActiveStr
                    }
                }
            })
    }
    
        
}


// MARK: - Preview
struct StageActionCommonView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Ho")
    }
}

