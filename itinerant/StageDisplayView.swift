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

    
    
    @Environment(\.scenePhase) var scenePhase
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
        HStack(alignment: .top, spacing: 0.0) {
            if isEditing == true {
                VStack {
                    Button {
                        stageIDtoDelete = stage.idStr
                    } label: {
                        Image(systemName: "trash")
                    }
                    .font(.system(.title2, design: .rounded, weight: .regular))
                    .foregroundColor(.white)
                    .buttonStyle(.borderless)
                    .controlSize(.large)
                }
                .frame(maxHeight: .infinity)
                .padding()
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(stage.title)
                     .font(.system(.title3, design: .rounded, weight: .bold))
                     .multilineTextAlignment(.leading)
                     .frame(maxWidth: .infinity, alignment: .leading)
                     .padding(.leading, kRowPad)
                     .padding(.top, 6)
                if !stage.details.isEmpty {
                     Text(stage.details)
                         .font(.system(.footnote, design: .rounded, weight: .regular))
                         .frame(maxWidth: .infinity, alignment: .leading)
                         .padding(.leading, kRowPad)
                         .multilineTextAlignment(.leading)
                         .lineLimit(1...2)
                }
                Spacer()
                HStack {
                    Image(systemName: stage.durationSymbolName)
                        .frame(alignment: .leading)
                    if stage.isCommentOnly == false {
                        if stage.isCountDownType {
                            Text(stage.durationString)
                                .lineLimit(1...2)
                                .allowsTightening(true)
                                .minimumScaleFactor(0.5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                       }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading,.bottom], kRowPad)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .modifier(StageInvalidDurationSymbolBackground(stageDurationDateInvalid: stageDurationDateInvalid, stageTextColour: textColourForScheme(colorScheme: colorScheme)))
                HStack(spacing: 0.0) {
                    if stage.isPostingRepeatingSnoozeAlerts {
                        HStack {
                            Image(systemName: "bell.and.waves.left.and.right")
                                .foregroundColor(Color("ColourAdditionalAlarmsImage"))
                            Text(Stage.stageFormattedDurationStringFromDouble(Double(stage.snoozeDurationSecs)))
                                .lineLimit(1)
                                .allowsTightening(true)
                                .minimumScaleFactor(0.5)
                                .frame(alignment: .leading)
                                .foregroundColor(Color("ColourAdditionalAlarmsText"))
                       }
                        .font(.system(.subheadline, design: .rounded, weight: .regular))
                        .padding(kRowPad)
                    } /* isPostingRepeatingSnoozeAlerts */
                    if !stage.additionalDurationsArray.isEmpty {
                        VStack(alignment: .center) {
                            HStack {
                                Image(systemName: "alarm.waves.left.and.right")
                                    .foregroundColor(Color("ColourAdditionalAlarmsImage"))
                                Text("\(stage.additionalAlertsDurationsString)")
                                    .foregroundColor(Color("ColourAdditionalAlarmsText"))
                                    .multilineTextAlignment(.leading)
                                    .frame(alignment: .leading)
                           }
                            .font(.system(.subheadline, design: .rounded, weight: .regular))
                            .frame(maxWidth: .infinity, alignment: .center)
                       }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(kRowPad)
                    } /* additionalDurationsArray */
                } /* HStack */
                .frame(maxWidth: .infinity)
                .background(Color("ColourAdditionalAlarmsBackground"))
            } /* VStack */
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(0)
            //.padding(.leading, 12)
            if isEditing == false {
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
                        .padding([.top,.bottom], kRowPad)
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
                        .padding([.top,.bottom], kRowPad)
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
                        .padding([.top,.bottom], kRowPad)
                   } /* VStack buttons */
                    .padding([.leading,.trailing], kRowPad)
                    .foregroundColor( .accentColor)
                    .background(Color("ColourControlsBackground"))
            } /* if isEditing == false */
            else {
                VStack {
                    Image(systemName: "line.3.horizontal")
                }
                .font(.system(.title2, design: .rounded, weight: .regular))
                .frame(maxHeight: .infinity)
                .padding()
            }
        } /* HStack */
        .frame(maxWidth: .infinity)
        .animation(.linear(duration: 0.1), value: isEditing)
        .onAppear() { checkUIupdateSlowTimerStatus() }
        .onDisappear() { uiSlowUpdateTimerCancellor?.cancel() }
        .onReceive(uiSlowUpdateTimer) { stageDurationDateInvalid = !stage.validDurationForCountDownTypeAtDate($0) }
        .onChange(of: stage.flags) { _ in checkUIupdateSlowTimerStatus() }
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
