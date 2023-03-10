//
//  StageActionCommonView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI
import Combine
import UserNotifications

#if os(watchOS)
let kHaltButtonWidth = 42.0
#else
let kHaltButtonWidth = 48.0
#endif


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
    @State var fullSizeUIImage: UIImage?
    @State var showFullSizeUIImage: Bool = false

    @State var durationDate: Date = validFutureDate()
    @State var presentDatePicker: Bool = false
    
    @EnvironmentObject var itineraryStore: ItineraryStore
    @EnvironmentObject var appSettingsObject: SettingsColoursObject

    @State var timeDifferenceAtUpdate: Double = 0.0
    @State var timeAccumulatedAtUpdate: Double = 0.0
    @State var uiFastUpdateTimer: Timer.TimerPublisher = Timer.publish(every: kUIUpdateTimerFrequency, on: .main, in: .common)
    @State var uiFastUpdateTimerCancellor: Cancellable?
    @State var presentUnableToNotifyAlert: Bool = false
    @State var presentUnableToPostDateNotification: Bool = false
    @State private var updateFrequency: TimeInterval = kUISlowUpdateTimerFrequency

    @AppStorage(kAppStorageShowUnableToNotifyWarning) var showUnableToNotifyWarning: Bool = true
    
    @EnvironmentObject var appDelegate: AppDelegate
    
    func getSetStageFullSizeImageData() -> Data? {
        if stage.imageDataFullActual == nil {
            let data = itinerary.loadStageImageDataFromPackage(imageSizeType: .fullsize, stageIDstr: stage.idStr)
            stage.imageDataFullActual = data
            debugPrint("stage getSetFullSizeImageData disc")
        }
        return stage.imageDataFullActual
    }

    
    // MARK: - body
    var body: some View {
        body_
            .padding(0)
            .gesture(gestureActivateStage())
            .onAppear() { handleOnAppear() }
            .onDisappear() { handleOnDisappear() }
            .onReceive(uiFastUpdateTimer) { handleReceive_uiFastUpdateTimer(newDate: $0) }
//            .onReceive(uiSlowUpdateTimer) { handleReceive_uiSlowUpdateTimer(newDate: $0) }
            .onChange(of: resetStageElapsedTime) { resetStage(newValue: $0) }
            .onChange(of: uuidStrStagesActiveStr) { if stage.isActive(uuidStrStagesActiveStr: $0) { scrollToStageID = stage.idStr} }
            .onChange(of: stageToHandleSkipActionID) {  handleReceive_stageToHandleSkipActionID(idstrtotest: $0)  }
            .onChange(of: stageToHandleHaltActionID) {  handleReceive_stageToHandleHaltActionID(idstrtotest: $0)  }
            .onChange(of: stageToStartRunningID) { handleReceive_stageToStartRunningID(idstrtotest: $0) }
            .alert("Invalid Date", isPresented: $presentUnableToPostDateNotification) {
            } message: {
                Text("The end date must be at least 1 minute into the future for the stage to be started")
            }
            .alert("Unable To Post Notifications", isPresented: $presentUnableToNotifyAlert) {
                Button("Do Not Show This Warning Again") { showUnableToNotifyWarning = false }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Permission to show Notifications must be granted to this App in Settings or you will not be notified when stages complete")
            }
            .onChange(of: durationDate, perform: {
                if stage.isCountDownToDate {
                    // the bindings are flakey or slow so we have to set all copies of stage everywhere to be sure we get the views aligned
                    stage.setDurationFromDate($0)
                    itineraryStore.updateStageDurationFromDate(stageUUID: stage.id, itineraryUUID: itinerary.id, durationDate: $0)
                }
            })
        
    } /* body */
} /* struct */

extension StageActionCommonView {
    
    func updateUpdateTimes(forUpdateDate optDate: Date?) {
        if let date = optDate {
            // we have a dateStarted date either from a timer update or onAppear when we havve/had run since reset
            timeAccumulatedAtUpdate = floor(date.timeIntervalSinceReferenceDate - timeStartedRunning())
            // if its a count-up timer we ignore timeDifferenceAtUpdate
            // countDownEnd just use durationSecsInt  - timeAccumulatedAtUpdate
            // countDownDate stage.durationSecsIntCorrected(atDate: date) already calculates time remaining between date and the end and goes negative
            if stage.isCountDownType {
                switch stage.durationCountType {
                case .countDownEnd:
                    timeDifferenceAtUpdate =  floor(Double(stage.durationSecsInt) - timeAccumulatedAtUpdate)
                case .countDownToDate:
                    timeDifferenceAtUpdate = Double(stage.durationSecsIntCorrected(atDate: date))
                default:
                    timeDifferenceAtUpdate = 0.0
                }
            } else {
                timeDifferenceAtUpdate = 0.0
            }
        }
    }
        
    var stageRunningOvertime: Bool { timeDifferenceAtUpdate <= 0 }
    
    func timeStartedRunning() -> TimeInterval {
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
        .frame(idealWidth: kHaltButtonWidth, idealHeight: kHaltButtonWidth, alignment: .trailing)
        .fixedSize(horizontal: true, vertical: true)
//#if os(watchOS)
//        .padding(.trailing, 4.0)
//#endif
    }
    
    func stageBackgroundColour(stage: Stage) -> Color {
        return itineraryStore.stageBackgroundColour(stageUUID: stage.id, itinerary: itinerary, uuidStrStagesRunningStr: uuidStrStagesRunningStr, uuidStrStagesActiveStr: uuidStrStagesActiveStr, appSettingsObject: appDelegate.settingsColoursObject)
    }
    
    
    func stageTextColour() -> Color {
        return itineraryStore.stageTextColour(stageUUID: stage.id, itinerary: itinerary, uuidStrStagesRunningStr: uuidStrStagesRunningStr, uuidStrStagesActiveStr: uuidStrStagesActiveStr, appSettingsObject: appDelegate.settingsColoursObject)
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
    
    func alertIfUnableToPostNotifications() {
        // user may have silenced these warnings
        guard showUnableToNotifyWarning == true else { return }
        UNUserNotificationCenter.current().getNotificationSettings { notificationSettings in
            if (notificationSettings.authorizationStatus != .authorized)  {
                presentUnableToNotifyAlert = true
            }
        }
    }
    
    func handleStartRunning() {
        alertIfUnableToPostNotifications()
        
        if stage.isCountDownToDate && stage.validDurationForCountDownTypeAtDate(Date()) == false {
            presentUnableToPostDateNotification = true
            return
        }
        
        setTimeStartedRunning(Date().timeIntervalSinceReferenceDate)
        timeDifferenceAtUpdate = Double(stage.durationSecsIntCorrected(atDate: Date()))
        timeAccumulatedAtUpdate = 0.0
        uuidStrStagesRunningStr.append(stage.idStr)
        // request countdown & snooze notification if needed
        // alertIfUnableToPostNotifications() above protects
        if stage.isCountDown { postNotification(stage: stage, itinerary: itinerary, intervalType: .countDownEnd) }
        if stage.isCountDownToDate { postNotification(stage: stage, itinerary: itinerary, intervalType: .countDownToDate) }
        if stage.isPostingRepeatingSnoozeAlerts { // give countdown a head start
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                postNotification(stage: stage, itinerary: itinerary, intervalType: .snoozeRepeatingIntervals)
            }
        }
        postAllAdditionalAlertNotifications(stage: stage, itinerary: itinerary)
        // need to reset the timer to reattach the cancellor
        uiFastUpdateTimer = Timer.publish(every: kUIUpdateTimerFrequency, on: .main, in: .common)
        uiFastUpdateTimerCancellor = uiFastUpdateTimer.connect()
    }
    
    func handleHaltRunning(andSkip: Bool) {
        setTimeEndedRunning(Date().timeIntervalSinceReferenceDate)
        uiFastUpdateTimerCancellor?.cancel()
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
        // its handled so clear it
        appDelegate.unnStageToHaltID = nil
        appDelegate.unnStageToStopAndStartNextID = nil
    }
    
}



extension StageActionCommonView {
    func checkUIupdateSlowTimerStatus() {
        //uiSlowUpdateTimerCancellor?.cancel()
        if stage.isCountDownToDate {
            updateFrequency = itinerary.someStagesAreCountDownToDate ? kUISlowUpdateTimerFrequency : kUISlowUpdateTimerFrequencyInfinite
            //uiSlowUpdateTimer = Timer.publish(every: kUISlowUpdateTimerFrequency, on: .main, in: .common)
            //uiSlowUpdateTimerCancellor = uiSlowUpdateTimer.connect()
        }
    }
    
    func handleOnAppear() {
        handleTimersOnAppearActive()
        if(!stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)) {
            // use dictStageEndDates[stage.idStr] != nil to detect we have run and to update the updateTimes
            updateUpdateTimes(forUpdateDate: dictStageEndDates[stage.idStr]?.dateFromDouble)
        }
    }
    
    func handleTimersOnAppearActive() {
        checkUIupdateSlowTimerStatus()
        if(stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)) {
            // need to reset the timer to reattach the cancellor
            uiFastUpdateTimer = Timer.publish(every: kUIUpdateTimerFrequency, on: .main, in: .common)
            uiFastUpdateTimerCancellor = uiFastUpdateTimer.connect()
        }
    }
    
    func handleOnDisappear() {
        handleTimesOnDisappearInactive()
    }
    
    func handleTimesOnDisappearInactive() {
        uiFastUpdateTimerCancellor?.cancel()
        //uiSlowUpdateTimerCancellor?.cancel()
    }
    
    func handleReceive_uiFastUpdateTimer(newDate: Date) {
        // we initialise at head and never set to nil, so never nil and can use !
        if(stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)) {
            updateUpdateTimes(forUpdateDate: newDate)
        } else {
            // we may have been skipped so cancel at the next opportunity
            uiFastUpdateTimerCancellor?.cancel()
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
                if !stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) {
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
                }
            })
    }
    
    
}

extension StageActionCommonView {
    struct StageActionDatePickerCommonView: View {
        @Binding var durationDate: Date
        @Binding var presentDatePicker: Bool
        @State var selectedDurationDate: Date = validFutureDate()
        @State var selectedDateInvalid = false
        @State var uiSlowUpdateTimer: Timer.TimerPublisher = Timer.publish(every: kUISlowUpdateTimerFrequency, on: .main, in: .common)
        @State var uiSlowUpdateTimerCancellor: Cancellable?
        
        @Environment(\.scenePhase) var scenePhase
        
        let monthNames = Calendar.autoupdatingCurrent.shortMonthSymbols
        var initialDurationDate: Date
        
#if os(watchOS)
        @State var year: Int = 2023
        @State var yearStarting: Int = 2023
        @State var yearsAhead: Int = yearsAheadBlock
        @State var month: Int = 0 // 1! months zero indexed
        @State var day: Int = 1
        @State var daysInMonth: Int = 31
        @State var hour: Int = 0
        @State var minute: Int = 0
#endif
        
        var body: some View {
            VStack{
                TextInvalidDate(date: selectedDurationDate)
#if os(watchOS)
                Group {
                    HStack {
                        Picker("Day", selection: $day, content: {
                            ForEach(1...daysInMonth, id: \.self) { Text(String(format: "%i",$0)).tag($0) }
                        })
                        Picker("Month", selection: $month, content: {
                            ForEach(1...monthNames.count, id: \.self) { Text(monthNames[$0-1]).tag($0) }
                        })
                        Picker("Year", selection: $year, content: {
                            ForEach(yearStarting...yearStarting + yearsAhead, id: \.self) { Text(String(format: "%i",$0)).tag($0) }
                        })
                    }
                    HStack {
                        Picker("Hour", selection: $hour, content: {
                            ForEach(0...23, id: \.self) { Text(String(format: "%02i",$0)).tag($0) }
                        })
                        Picker("Minute", selection: $minute, content: {
                            ForEach(0...59, id: \.self) { Text(String(format: "%02i",$0)).tag($0) }
                        })
                    }
                }
                .pickerStyle(.wheel)
                .onChange(of: month) {
                    correctDaysInMonth(month: $0, year: year)
                    updateSelectedDurationDate()
                }
                .onChange(of: year) {
                    correctDaysInMonth(month: month, year: $0)
                    updateSelectedDurationDate()
                    if year == yearStarting + yearsAhead { yearsAhead += yearsAheadBlock }
                }
                .onChange(of: day) { _ in updateSelectedDurationDate() }
                .onChange(of: hour) { _ in updateSelectedDurationDate() }
                .onChange(of: minute) { _ in updateSelectedDurationDate() }
#else
                VStack(alignment: .center){
                    DatePicker(
                        "End On:",
                        selection: $selectedDurationDate,
                        in: validFutureDate()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .labelsHidden()
                    Text("The end time must be at least 1 minute in the future when the stage starts")
                        .font(.system(.subheadline, design: .rounded, weight: .regular))
                        .multilineTextAlignment(.center)
                        .opacity(0.5)
                }
                .frame(maxWidth: .infinity,alignment: .center)
                .padding()
#endif
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel, action: {
                        presentDatePicker = false
                    })
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: {
                        handleSave()
                    })
                }
            }
            .onAppear {
                uiSlowUpdateTimerCancellor?.cancel()
                uiSlowUpdateTimer = Timer.publish(every: kUISlowUpdateTimerFrequency, on: .main, in: .common)
                uiSlowUpdateTimerCancellor = uiSlowUpdateTimer.connect()
                setupStartingDate()
            }
            .onDisappear {
                uiSlowUpdateTimerCancellor?.cancel()
            }
            .onReceive(uiSlowUpdateTimer) { _ in
                selectedDateInvalid = selectedDurationDate < validFutureDate()
            }
            /* VStack */
        } /* body */
        
        func handleSave() {
            durationDate = selectedDurationDate
            presentDatePicker = false
        }
        
#if os(watchOS)
        func updateSelectedDurationDate() {
            if let validdate = dateFromComponents() {
                selectedDurationDate = validdate
            }
        }
        func correctDaysInMonth(month: Int, year: Int) {
            let currentDay = day
            if let daysinmonth = getDaysInIndexedMonth(indexedMonth: month, zeroIndexed: false, year: year) {
                daysInMonth = daysinmonth
                day = min(currentDay, daysinmonth)
            }
        }
        
        func dateFromComponents() -> Date? {
            var dateComponents = DateComponents()
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            return Calendar.autoupdatingCurrent.date(from: dateComponents)
        }
        
        func setupStartingDate() {
            let startdate = max(initialDurationDate,validFutureDate())
            selectedDurationDate = startdate
            let components = Calendar.autoupdatingCurrent.dateComponents(kPickersDateComponents, from: startdate)
            DispatchQueue.main.async {
                yearStarting = components.year!
                year = components.year!
                month = components.month!
                day = components.day!
                hour = components.hour!
                minute = components.minute! + 1 // tweak or date starts invalid even when validFutureDate()
            }
        }
#else
        func setupStartingDate() {
            selectedDurationDate = max(initialDurationDate,validFutureDate())
        }
#endif
        
    } /* struct */
        
} /* extension */

// MARK: - Preview
struct StageActionCommonView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Ho")
    }
}

