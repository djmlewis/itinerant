//
//  StageDisplayView.swift
//  itinerant
//
//  Created by David JM Lewis on 15/01/2023.
//


// a StageActionView but without the actionable elements, displayed in Itinerary Edit View

import SwiftUI

struct StageDisplayView: View {
    @Binding var stage: Stage
    @Binding var stageDuplicate: [String:Stage]?

    @Environment(\.editMode) private var editMode
    @EnvironmentObject var appDelegate: AppDelegate

    @State private var isPresentingStageEditView = false
    @State private var stageEditableData = Stage.EditableData()

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: stage.durationSymbolName)
                    if stage.isCountUp == false && stage.isCommentOnly == false {
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
                    } else {
                        // these is needed to push views against leading edge!! it also pulls views below... 
                        Spacer()
                    }
                }
                Text(stage.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                if !stage.details.isEmpty {
                    Text(stage.details)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                }
            } /* VStack */
            .frame(maxWidth: .infinity)
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
                        stageDuplicate = [stage.idStr : stage.duplicateWithNewID]
                    }) {
                        Image(systemName: "doc.on.doc")
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
    } /* body */
    
}


struct StageDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Yo")
    }
}
