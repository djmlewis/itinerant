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
    @Binding var stageDuplicate: Stage?

    @Environment(\.editMode) private var editMode

    @State private var isPresentingStageEditView = false
    @State private var stageEditableData = Stage.EditableData()

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(stage.title)
                    .font(.title3)
                    .fontWeight(.bold)
                HStack {
                    Image(systemName: stage.durationSecsInt == 0 ? "stopwatch" : "timer")
                    if stage.durationSecsInt > 0 {
                        Text(Stage.stageDurationStringFromDouble(Double(stage.durationSecsInt))
                        )
                            .font(.title3)
                    }
                    Spacer()
                    // editMode is the global for when the Edit buton is tapped
                    if editMode?.wrappedValue.isEditing == false {
                        HStack {
                            Button(action: {
                                stageDuplicate = stage.duplicateWithNewID
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor( .accentColor)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .frame(width: 24, alignment: .trailing)
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
                        }
                    }
                }
                if !stage.details.isEmpty {
                    Text(stage.details)
                        .font(.body)
                }
            }
        }
        .padding()
        .sheet(isPresented: $isPresentingStageEditView) {
            NavigationView {
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
