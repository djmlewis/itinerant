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
    
    @State var durationDate: Date = validFutureDate()
    @State var presentDatePicker: Bool = false
    
    @EnvironmentObject var itineraryStore: ItineraryStore
    
    @State var timeDifferenceAtUpdate: Double = 0.0
    @State var timeAccumulatedAtUpdate: Double = 0.0
    @State var uiUpdateTimer: Timer.TimerPublisher = Timer.publish(every: kUIUpdateTimerFrequency, on: .main, in: .common)
    @State var uiUpdateTimerCancellor: Cancellable?
    @State var presentUnableToNotifyAlert: Bool = false
    @State var presentUnableToPostDateNotification: Bool = false
    @State var stageDurationDateInvalid: Bool = false
    @State var uiSlowUpdateTimer: Timer.TimerPublisher = Timer.publish(every: kUISlowUpdateTimerFrequency, on: .main, in: .common)
    @State var uiSlowUpdateTimerCancellor: Cancellable?
    
    @AppStorage(kAppStorageColourStageInactive) var appStorageColourStageInactive: String = kAppStorageDefaultColourStageInactive
    @AppStorage(kAppStorageColourStageActive) var appStorageColourStageActive: String = kAppStorageDefaultColourStageActive
    @AppStorage(kAppStorageColourStageRunning) var appStorageColourStageRunning: String = kAppStorageDefaultColourStageRunning
    @AppStorage(kAppStorageColourStageComment) var appStorageColourStageComment: String = kAppStorageDefaultColourStageComment
    
    @AppStorage(kAppStorageColourFontInactive) var appStorageColourFontInactive: String = kAppStorageDefaultColourFontInactive
    @AppStorage(kAppStorageColourFontActive) var appStorageColourFontActive: String = kAppStorageDefaultColourFontActive
    @AppStorage(kAppStorageColourFontRunning) var appStorageColourFontRunning: String = kAppStorageDefaultColourFontRunning
    @AppStorage(kAppStorageColourFontComment) var appStorageColourFontComment: String = kAppStorageDefaultColourFontComment
    
    @AppStorage(kAppStorageShowUnableToNotifyWarning) var showUnableToNotifyWarning: Bool = true
    
    @EnvironmentObject var appDelegate: AppDelegate
    
    
    // MARK: - body
    var body: some View {
        body_
            .padding(0)
            .gesture(gestureActivateStage())
            .onAppear() { handleOnAppear() }
            .onDisappear() { handleOnDisappear() }
            .onReceive(uiUpdateTimer) { handleReceive_uiUpdateTimer(newDate: $0) }
            .onReceive(uiSlowUpdateTimer) { handleReceive_uiSlowUpdateTimer(newDate: $0) }
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
#if os(watchOS)
        .padding(.trailing, 4.0)
#endif
    }
    
    func stageBackgroundColour(stage: Stage) -> Color {
        if stage.isCommentOnly {
            return appStorageColourStageComment.rgbaColor!
        }
        if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) {
            return appStorageColourStageRunning.rgbaColor!
        }
        if stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) {
            return appStorageColourStageActive.rgbaColor!
        }
        return appStorageColourStageInactive.rgbaColor!
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
    
    func alertIfUnableToPostNotifications() {
        guard showUnableToNotifyWarning == true else { return }
        UNUserNotificationCenter.current().getNotificationSettings { notificationSettings in
            if (notificationSettings.authorizationStatus != .authorized)  {
                debugPrint("unable to alert in any way"); return
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
        if stage.isCountDown { postNotification(stage: stage, itinerary: itinerary, intervalType: .countDownEnd) }
        if stage.isCountDownToDate { postNotification(stage: stage, itinerary: itinerary, intervalType: .countDownToDate) }
        if stage.isPostingRepeatingSnoozeAlerts { // give countdown a head start
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
        // its handled so clear it
        appDelegate.unnStageToHaltID = nil
        appDelegate.unnStageToStopAndStartNextID = nil
    }
    
}



extension StageActionCommonView {
    func checkUIupdateSlowTimerStatus() {
        uiSlowUpdateTimerCancellor?.cancel()
        if stage.isCountDownToDate {
            uiSlowUpdateTimer = Timer.publish(every: kUISlowUpdateTimerFrequency, on: .main, in: .common)
            uiSlowUpdateTimerCancellor = uiSlowUpdateTimer.connect()
        }
    }
    
    func handleOnAppear() {
        stageDurationDateInvalid = !stage.validDurationForCountDownTypeAtDate(Date.now)
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
            uiUpdateTimer = Timer.publish(every: kUIUpdateTimerFrequency, on: .main, in: .common)
            uiUpdateTimerCancellor = uiUpdateTimer.connect()
        }
    }
    
    func handleOnDisappear() {
        handleTimesOnDisappearInactive()
    }
    
    func handleTimesOnDisappearInactive() {
        uiUpdateTimerCancellor?.cancel()
        uiSlowUpdateTimerCancellor?.cancel()
    }
    
    func handleReceive_uiUpdateTimer(newDate: Date) {
        // we initialise at head and never set to nil, so never nil and can use !
        if(stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)) {
            updateUpdateTimes(forUpdateDate: newDate)
        } else {
            // we may have been skipped so cancel at the next opportunity
            uiUpdateTimerCancellor?.cancel()
        }
    }
    func handleReceive_uiSlowUpdateTimer(newDate: Date) {
        //debugPrint(newDate)
        stageDurationDateInvalid = !stage.validDurationForCountDownTypeAtDate(newDate)
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
#else
        @State var selectedDurationDate: Date = validFutureDate()
#endif
        
        @State var selectedDateInvalid = false
        @State var uiSlowUpdateTimer: Timer.TimerPublisher = Timer.publish(every: kUISlowUpdateTimerFrequency, on: .main, in: .common)
        @State var uiSlowUpdateTimerCancellor: Cancellable?
        
        @Environment(\.scenePhase) var scenePhase
        
        let monthNames = Calendar.autoupdatingCurrent.shortMonthSymbols
        
        var body: some View {
            VStack{
                Text("\(Image(systemName: "exclamationmark.triangle.fill")) Invalid Date")
                    .foregroundColor(Color("ColourInvalidDate"))
                    .opacity(selectedDateInvalid ? 1.0 : 0.0)
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
                    selectedDateInvalid = isInvalidDate()
                }
                .onChange(of: year) {
                    correctDaysInMonth(month: month, year: $0)
                    if year == yearStarting + yearsAhead { yearsAhead += yearsAheadBlock
                        selectedDateInvalid = isInvalidDate()
                    }
                }
                .onChange(of: day) { _ in selectedDateInvalid = isInvalidDate() }
                .onChange(of: hour) {  _ in selectedDateInvalid = isInvalidDate() }
                .onChange(of: minute) {  _ in selectedDateInvalid = isInvalidDate() }
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
                let startdate = max(initialDurationDate,validFutureDate())
#if os(watchOS)
                let components = Calendar.autoupdatingCurrent.dateComponents(kPickersDateComponents, from: startdate)
                DispatchQueue.main.async {
                    yearStarting = components.year!
                    year = components.year!
                    month = components.month!
                    day = components.day!
                    hour = components.hour!
                    minute = components.minute! + 1 // tweak or date starts invalid even when validFutureDate()
                }
#else
                selectedDurationDate = startdate
#endif
                uiSlowUpdateTimerCancellor?.cancel()
                uiSlowUpdateTimer = Timer.publish(every: kUISlowUpdateTimerFrequency, on: .main, in: .common)
                uiSlowUpdateTimerCancellor = uiSlowUpdateTimer.connect()
            }
            .onDisappear {
                uiSlowUpdateTimerCancellor?.cancel()
            }
            .onReceive(uiSlowUpdateTimer) { _ in
                selectedDateInvalid = isInvalidDate()
            }
            /* VStack */
        } /* body */
        
        func handleSave() {
#if os(watchOS)
            if let validnewdate = dateFromComponents() {
                durationDate = validnewdate
            }
#else
            durationDate = selectedDurationDate
#endif
            presentDatePicker = false
        }
        
#if os(watchOS)
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
        
        func isInvalidDate() -> Bool {
            if let validdate = dateFromComponents() {
                if validdate >= validFutureDate() { return false }
            }
            return true
        }
#else
        func isInvalidDate() -> Bool {
            if selectedDurationDate >= validFutureDate() { return false }
            return true
        }
#endif
        
    } /* struct */
    
}

// MARK: - Preview
struct StageActionCommonView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Ho")
    }
}

