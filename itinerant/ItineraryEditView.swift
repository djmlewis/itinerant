//
//  ItineraryEditView.swift
//  itinerant
//
//  Created by David JM Lewis on 04/01/2023.
//

import SwiftUI

struct ItineraryEditView: View {
    
    @Binding var itinerary: Itinerary
    @Binding var itineraryEditableData: Itinerary.EditableData
    @State private var itineraryName: String = ""
    @State private var isPresentingStageEditView = false
    @State private var newStage: Stage = Stage()
    @State private var newStageEditableData: Stage.EditableData = Stage.EditableData()
    @FocusState private var focusedFieldTag: FieldFocusTag?
    
    
    /* *** REMEMBER to EDIT ONLY the var itineraryEditableData and NOT the var itinerary */
    /* *** var itinerary is passed-in binding for the StageActionView */
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Itinerary title", text: $itineraryEditableData.title)
                    .focused($focusedFieldTag, equals: .title)
            }
            Section(header: HStack(){
                Text("Stages")
                Spacer()
                EditButton()
                    .textCase(nil)
                Spacer()
                Button(action: {
                    newStage = Stage()
                    newStageEditableData = Stage.EditableData()
                    isPresentingStageEditView = true
                    
                }) {
                    Image(systemName: "plus")
                }
            }) {
                List {
                    ForEach($itineraryEditableData.stages) { $stage in
                        StageDisplayView(stage: $stage)
                    }
                    .onDelete { itineraryEditableData.stages.remove(atOffsets: $0) }
                    .onMove { itineraryEditableData.stages.move(fromOffsets: $0, toOffset: $1) }
                }
            }
        }
        .onAppear() {
            focusedFieldTag = .title
            newStage = Stage(title: "", durationSecsInt: 0)
        }
        .onDisappear() {
            focusedFieldTag = .noneFocused
        }
        .sheet(isPresented: $isPresentingStageEditView) {
            NavigationView {
                StageEditView(stageEditableData: $newStageEditableData)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingStageEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                // amend the var itineraryEditableData only
                                newStage.updateEditableData(from: newStageEditableData)
                                itineraryEditableData.stages.append(newStage)
                                isPresentingStageEditView = false
                            }
                        }
                    }
            }
        }
        
    }
}

struct ItineraryEditView_Previews: PreviewProvider {
    static var previews: some View {
        ItineraryEditView(itinerary: .constant(Itinerary.templateItinerary()), itineraryEditableData: .constant(Itinerary.templateItinerary().itineraryEditableData))
    }
}


