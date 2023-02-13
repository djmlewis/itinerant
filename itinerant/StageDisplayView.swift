//
//  StageDisplayView.swift
//  itinerant
//
//  Created by David JM Lewis on 15/01/2023.
//


// a StageActionView but without the actionable elements, displayed in Itinerary Edit View

import SwiftUI


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

    @Environment(\.editMode) private var editMode
    @EnvironmentObject var appDelegate: AppDelegate

    @State private var isPresentingStageEditView = false
    @State private var stageEditableData = Stage.EditableData()

    //@State private var newStage: Stage = Stage()
    @State private var newStageEditableData: Stage.EditableData = Stage.EditableData()
    @State private var isPresentingNewStageEditView = false

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: stage.durationSymbolName)
                    if stage.isCommentOnly == false {
                        if stage.isCountUp == false {
                            Text(Stage.stageDurationStringFromDouble(Double(stage.durationSecsInt)))
                                .font(.title3)
                                .lineLimit(1)
                                .allowsTightening(true)
                                .minimumScaleFactor(0.5)
                        }
                        if stage.isPostingSnoozeAlerts {
                            // Snooze Alarms time duration
                            HStack {
                                Image(systemName: "bell.and.waves.left.and.right")
                                Text(Stage.stageDurationStringFromDouble(Double(stage.snoozeDurationSecs)))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .allowsTightening(true)
                                    .minimumScaleFactor(0.5)
                            }
                            .frame(maxWidth: .infinity)
                            .opacity(0.5)
                        }
                    }
                }
                Text(stage.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                if !stage.details.isEmpty {
                    Text(stage.details)
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1...2)
                }
            } /* VStack */
            .frame(maxWidth: .infinity, alignment: .leading)
            //editMode is the global for when the Edit buton is tapped
            if editMode?.wrappedValue.isEditing == false {
                VStack(alignment: .trailing) {
                    Button(action: {
                        stageEditableData = stage.editableData
                        isPresentingStageEditView = true
                    }) {
                        Image(systemName: "square.and.pencil")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor( .accentColor)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .frame(width: 24, alignment: .trailing)
                    Spacer()
                    Button(action: {
                        newStageMeta = nil
                        newStageMeta = NewStageMeta(stageInitiatingIDstr: stage.idStr, duplicate: true, newStage: stage.duplicateWithNewID)
                    }) {
                        Image(systemName: "doc.on.doc")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor( .accentColor)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .frame(width: 24, alignment: .trailing)
                    Spacer()
                    Button(action: {
                        //newStage = Stage()
                        newStageEditableData = Stage.EditableData()
                        newStageMeta = nil
                        isPresentingNewStageEditView = true
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor( .accentColor)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .frame(width: 24, alignment: .trailing)
                }
            }
        } /* HStack */
        .padding()
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


struct StageDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Yo")
    }
}
