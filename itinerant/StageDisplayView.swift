//
//  StageDisplayView.swift
//  itinerant
//
//  Created by David JM Lewis on 15/01/2023.
//


// a StageActionView but without the actionable elements, displayed in Itinerary Edit View

import SwiftUI
import Combine

struct NewStageMeta: Equatable {
    internal init(stageInitiatingIDstr: String, duplicate: Bool, newStage: Stage) {
        self.stageInitiatingIDstr = stageInitiatingIDstr
        self.duplicate = duplicate
        self.newStage = newStage
    }
    
    let stageInitiatingIDstr: String
    let duplicate: Bool
    let newStage: Stage
    
}

struct StageDisplayView: View {
    @Binding var stage: Stage
    @Binding var newStageMeta: NewStageMeta?
    @Binding var isEditing: Bool
    @Binding var stageIDtoDelete: String?
    @Binding var itineraryTitleFocused: Bool

    
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appDelegate: AppDelegate

    @State private var isPresentingStageEditView = false
    @State private var stageEditableData = Stage()

    @State private var newStageEditableData: Stage = Stage()
    @State private var isPresentingNewStageEditView = false

    @State var stageDurationDateInvalid: Bool = false
    @State var uiSlowUpdateTimer: Timer.TimerPublisher = Timer.publish(every: kUISlowUpdateTimerFrequency, on: .main, in: .common)
    @State var uiSlowUpdateTimerCancellor: Cancellable?

    var body: some View {
        HStack(alignment: .top) {
            if isEditing == true {
                VStack {
                    Button {
                        stageIDtoDelete = stage.idStr
                    } label: {
                        Image(systemName: "trash")
                    }
                    .foregroundColor(.white)
                    .buttonStyle(.borderless)
                    .controlSize(.large)
                }
                .frame(maxHeight: .infinity)
                .padding()
                .background(.red)
            }
            VStack(alignment: .leading, spacing: 2.0) {
                Text(stage.title)
                     .font(.system(.title3, design: .rounded, weight: .bold))
                     .multilineTextAlignment(.leading)
                     .padding(.top, 6.0)
                 if !stage.details.isEmpty {
                     Text(stage.details)
                         .font(.system(.footnote, design: .rounded, weight: .regular))
                         .multilineTextAlignment(.leading)
                         .lineLimit(1...2)
                         .padding(0)
                 }
                HStack {
                    Image(systemName: stage.durationSymbolName)
                    if stage.isCommentOnly == false {
                        if stage.isCountDownType {
                            Text(stage.durationString)
                                .modifier(StageInvalidDurationSymbolBackground(stageDurationDateInvalid: stageDurationDateInvalid, stageTextColour: textColourForScheme(colorScheme: colorScheme)))
                                .lineLimit(1...2)
                                .allowsTightening(true)
                                .minimumScaleFactor(0.5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                       }
                        if stage.isPostingRepeatingSnoozeAlerts {
                            // Snooze Alarms time duration
                            VStack(alignment: .trailing) {
                                HStack {
                                    Image(systemName: "bell.and.waves.left.and.right")
                                    Text(Stage.stageFormattedDurationStringFromDouble(Double(stage.snoozeDurationSecs)))
                                        .lineLimit(1)
                                        .allowsTightening(true)
                                        .minimumScaleFactor(0.5)
                                        .frame(alignment: .center)
                               }
                                .font(.system(.subheadline, design: .rounded, weight: .regular))
                                .frame(alignment: .center)
                                .modifier(AdditionalAlarmsFontBackgroundColour())
                          }
                            .frame(alignment: .trailing)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .font(.system(.title3, design: .rounded, weight: .bold))
                if !stage.additionalDurationsArray.isEmpty {
                    VStack(alignment: .center) {
                        HStack {
                            Image(systemName: "alarm.waves.left.and.right")
                            Text("\(stage.additionalAlertsDurationsString)")
                        }
                        .font(.system(.subheadline, design: .rounded, weight: .regular))
                        .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .modifier(AdditionalAlarmsFontBackgroundColour())
                    .padding(.top, 4.0)
               }
            } /* VStack */
            .padding(.leading, 12)
            .frame(maxWidth: .infinity, alignment: .center)
            if isEditing == false {
                VStack {
                    VStack(alignment: .trailing) {
                        Button(action: {
                            stageEditableData = stage.editableData
                            itineraryTitleFocused.toggle()
                            isPresentingStageEditView = true
                        }) {
                            Image(systemName: "square.and.pencil")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .frame(width: 24, alignment: .trailing)
                        .padding([.bottom], 4)
                        Spacer()
                        Button(action: {
                            newStageMeta = nil
                            newStageMeta = NewStageMeta(stageInitiatingIDstr: stage.idStr, duplicate: true, newStage: stage.duplicateWithNewID)
                        }) {
                            Image(systemName: "doc.on.doc")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .frame(width: 24, alignment: .trailing)
                        .padding([.top,.bottom], 4)
                       Spacer()
                        Button(action: {
                            newStageEditableData = Stage()
                            newStageMeta = nil
                            isPresentingNewStageEditView = true
                        }) {
                            Image(systemName: "plus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .frame(width: 24, alignment: .trailing)
                        .padding([.top], 4)
                   } /* VStack */
                    .padding(.trailing, 12)
                    //.background(Color("ColourControlsBackground"))
                    .foregroundColor( .accentColor)
                } /* VStack buttons*/
                //.background(.clear)
                //.padding([.top,.bottom],1)
            } /* if isEditing == false */
            else {
                VStack {
                    Image(systemName: "line.3.horizontal")
                }
                .frame(maxHeight: .infinity)
                .padding()
            }
        } /* HStack */
        .animation(.linear(duration: 0.1), value: isEditing)
        .onAppear() { checkUIupdateSlowTimerStatus() }
        .onDisappear() { uiSlowUpdateTimerCancellor?.cancel() }
        .onReceive(uiSlowUpdateTimer) { stageDurationDateInvalid = !stage.validDurationForCountDownTypeAtDate($0) }
        .onChange(of: stage.flags) { _ in checkUIupdateSlowTimerStatus() }
        .padding([.top,.bottom],1)
        .sheet(isPresented: $isPresentingStageEditView) {
            NavigationStack {
                StageEditView(stageEditableData: $stageEditableData)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingStageEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                stage.updateEditableData(from: stageEditableData)
                                isPresentingStageEditView = false
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $isPresentingNewStageEditView) {
            NavigationStack {
                StageEditView(stageEditableData: $newStageEditableData)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingNewStageEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                // amend the var itineraryEditableData only
                                let newStage = Stage(editableData: newStageEditableData)
                                //itineraryEditableData.stages.append(newStage)
                                newStageMeta = NewStageMeta(stageInitiatingIDstr: stage.idStr, duplicate: false, newStage: newStage)
                                isPresentingNewStageEditView = false
                            }
                        }
                    }
            }
        }

    } /* body */
    
}

extension StageDisplayView {
    
    func checkUIupdateSlowTimerStatus() {
        uiSlowUpdateTimerCancellor?.cancel()
        if stage.isCountDownToDate {
            uiSlowUpdateTimer = Timer.publish(every: kUISlowUpdateTimerFrequency, on: .main, in: .common)
            uiSlowUpdateTimerCancellor = uiSlowUpdateTimer.connect()
        }
    }

}

struct StageDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Yo")
    }
}
