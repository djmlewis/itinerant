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
    
    @Environment(\.editMode) private var editMode

    @State private var isPresentingStageEditView = false
    @State private var stageEditableData = Stage.EditableData()

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(stage.title)
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .fontWeight(.bold)
                if !stage.details.isEmpty {
                    Text(stage.details)
                        .font(.body)
                }
                Text(Stage.stageDurationFormatter.string(from: Double(stage.durationSecsInt))!)
                    .font(.title3)
            }
            Spacer()
            if editMode?.wrappedValue.isEditing == false {
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
                .frame(width: 32, alignment: .trailing)
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
        StageDisplayView(stage: .constant(Stage(title: "Untitled", durationSecsInt: 30)))
    }
}
