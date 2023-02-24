//
//  WKStageActionView.swift
//  itinerant Watch App
//
//  Created by David JM Lewis on 05/02/2023.
//

import SwiftUI
import Combine

let yearsAheadBlock = 5

extension StageActionCommonView {
#if os(watchOS)
    var body_: some View {
        Grid (alignment: .center, horizontalSpacing: 0.0, verticalSpacing: 0.0) {
            GridRow {
                HStack(spacing: 0.0) {
                    Text(stage.title)
                        .padding(0)
                        .gridCellColumns(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                        .foregroundColor(stageTextColour())
                    if stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) || stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) {
                        buttonStartHalt()
                    }
                } /* HStack */
                .frame(maxWidth: .infinity)
                .gridCellColumns(2)
            }
            if stage.isCommentOnly == false {
                GridRow {
                        VStack {
                            HStack(alignment: .firstTextBaseline) {
                                Image(systemName: stage.durationSymbolName)
                                    .padding(.leading, 2.0)
                                if stage.isCountDownType {
                                    Button(action: {
                                        presentDatePicker = true
                                    }, label: {
                                        Text(stage.durationString)
                                            .font(.system(.title3, design: .rounded, weight: .semibold))
                                            .lineLimit(2)
                                            .allowsTightening(true)
                                            .minimumScaleFactor(0.5)
                                    })
                                    .disabled(!stage.isCountDownToDate ||
                                              stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr))
                                    .buttonStyle(.bordered)
                                    .controlSize(.regular)
                                    .foregroundColor(stageDurationDateInvalid && !stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ?  Color.accentColor : stageTextColour())
                                    .tint(stage.isCountDownToDate && !stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? Color.black : Color.clear)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding([.top], 6)
                                }
                            } /* HStack */
                            .frame(maxWidth: .infinity, alignment: .leading)
                            if stage.isPostingRepeatingSnoozeAlerts {
                                // Snooze Alarms time duration
                                HStack {
                                    Image(systemName: "bell.and.waves.left.and.right")
                                    Text(Stage.stageFormattedDurationStringFromDouble(Double(stage.snoozeDurationSecs)))
                                        .lineLimit(1)
                                        .allowsTightening(true)
                                        .minimumScaleFactor(0.5)
                                }
                                .font(.system(.subheadline, design: .rounded, weight: .regular))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .modifier(WKStageAlertslBackground())
                            }
                            if !stage.additionalDurationsArray.isEmpty {
                                    //HStack {
                                        Text("\(Image(systemName: "alarm.waves.left.and.right")) \(stage.additionalAlertsDurationsString)")
                                            .allowsTightening(true)
                                            .minimumScaleFactor(0.5)
                                    //}
                                    .font(.system(.subheadline, design: .rounded, weight: .regular))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .modifier(WKStageAlertslBackground())
                            } /* if !stage.additionalDurationsArray.isEmpty */
                        } /* VStack */
                        .frame(maxWidth: .infinity)
                        .foregroundColor(stageTextColour())
                        .gridCellColumns(2)
                } /* GridRow */
                .padding(0)
            } /* isCommentOnly */
            if stage.isCommentOnly == false && (stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)  || dictStageStartDates[stage.idStr] != nil) {
                if timeDifferenceAtUpdate != 0.0 && stage.isCountDownType {
                    GridRow {
                        HStack(spacing:0.0) {
                            Image(systemName: stageRunningOvertime ? "bell.and.waves.left.and.right" : "timer")
                            Text("\(stageRunningOvertime ? "+" : " -" )" + Stage.stageFormattedDurationStringFromDouble(fabs((timeDifferenceAtUpdate))))
                        }
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(stageRunningOvertime ? Color("ColourOvertimeFont") : Color("ColourRemainingFont"))
                        .background(stageRunningOvertime ? Color("ColourOvertimeBackground") : Color("ColourRemainingBackground"))
                        .lineLimit(1)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.5)
                        .border(timeDifferenceAtUpdate < 0.0 ? .white : .clear, width: 1.0)
                        .padding(.leading,2.0)
                        .padding(.trailing,2.0)
                        .gridCellColumns(2)
                    }  /* GridRow */
                    .padding(.top,3.0)
                }
                GridRow {
                    HStack(spacing:0.0) {
                        Image(systemName: "hourglass")
                        Text(Stage.stageFormattedDurationStringFromDouble(fabs(timeAccumulatedAtUpdate)))
                    }
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.black)
                    .background(.white)
                    .opacity(timeAccumulatedAtUpdate == 0.0  ? 0.0 : 1.0)
                    .lineLimit(1)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.5)
                    .border(timeAccumulatedAtUpdate > 0.0 ? .black : .clear, width: 1.0)
                    .padding(.leading,2.0)
                    .padding(.trailing,2.0)
                    .gridCellColumns(2)
                }  /* GridRow */
                .padding(.top,3.0)
            } /* if nonComment, running OR ran*/
        } /* Grid */
        .padding(0)
        /* Grid mods */
        .onChange(of: durationDate, perform: {
            if stage.isCountDownToDate {
                // the bindings are flakey or slow so we have to set all copies of stage everywhere to be sure we get the views aligned
                stage.setDurationFromDate($0)
                itineraryStore.updateStageDurationFromDate(stageUUID: stage.id, itineraryUUID: itinerary.id, durationDate: $0)
            }
            
        })
        .sheet(isPresented: $presentDatePicker, content: {
            VStack {
                WKStageActionDatePickerView(durationDate: $durationDate, presentDatePicker: $presentDatePicker)
            }
        })
    } /* body */
    

    struct WKStageActionDatePickerView: View {
        @Binding var durationDate: Date
        @Binding var presentDatePicker: Bool
        
        
        @State var year: Int = 2023
        @State var yearStarting: Int = 2023
        @State var yearsAhead: Int = yearsAheadBlock
        @State var month: Int = 0 // 1! months zero indexed
        @State var day: Int = 1
        @State var daysInMonth: Int = 31
        @State var hour: Int = 0
        @State var minute: Int = 0
        @State var selectedDateInvalid = false
        @State var uiSlowUpdateTimer: Timer.TimerPublisher = Timer.publish(every: kUISlowUpdateTimerFrequency, on: .main, in: .common)
        @State var uiSlowUpdateTimerCancellor: Cancellable?

        let monthNames = Calendar.autoupdatingCurrent.shortMonthSymbols
                
        var body: some View {
            VStack{
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

                HStack {
                    Picker("Hour", selection: $hour, content: {
                        ForEach(0...23, id: \.self) { Text(String(format: "%02i",$0)).tag($0) }
                    })
                    Picker("Minute", selection: $minute, content: {
                        ForEach(0...59, id: \.self) { Text(String(format: "%02i",$0)).tag($0) }
                    })
                }
                Text("\(Image(systemName: "exclamationmark.triangle.fill")) Invalid Date")
                        .foregroundColor(.red)
                        .opacity(selectedDateInvalid ? 1.0 : 0.0)
                Button( action: {
                    if let validnewdate = dateFromComponents() {
                        durationDate = validnewdate
                    }
                    presentDatePicker = false
                }, label: {
                    Text("Save")
                })
                .buttonStyle(.bordered)
                .foregroundColor(.accentColor)
                
            }
            .onAppear {
                let startdate = max(durationDate,validFutureDate())
                let components = Calendar.autoupdatingCurrent.dateComponents(kPickersDateComponents, from: startdate)
                DispatchQueue.main.async {
                    yearStarting = components.year!
                    year = components.year!
                    month = components.month!
                    day = components.day!
                    hour = components.hour!
                    minute = components.minute! + 1 // tweak or date starts invalid even when validFutureDate()
                }
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
        
    } /* struct */
#endif
}
