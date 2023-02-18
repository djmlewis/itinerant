//
//  ItineraryEditView.swift
//  itinerant
//
//  Created by David JM Lewis on 04/01/2023.
//

import SwiftUI


struct ItineraryEditView: View {
    //@Binding var itinerary: Itinerary
    @Binding var itineraryEditableData: Itinerary.EditableData
    
    @State private var newStageMeta: NewStageMeta?
    @State private var newStageEditableData: Stage.EditableData = Stage.EditableData()
    @State private var isPresentingNewStageEditView = false

    //@State private var isEditing: Bool = true
    @Environment(\.editMode) private var editMode

    // @FocusState private var focusedFieldTag: FieldFocusTag?
    
    /* *** REMEMBER to EDIT ONLY the var itineraryEditableData and NOT the var itinerary */
    /* *** var itinerary is passed-in binding for the StageActionView */
    var body: some View {
        ScrollViewReader { svrproxy in
            Form {
                Section("Title") {
                    TextField("Itinerary title", text: $itineraryEditableData.title)
                }
                Section {
                    List {
                        ForEach($itineraryEditableData.stages) { $stage in
                            StageDisplayView(stage: $stage, newStageMeta: $newStageMeta)
                                .id(stage.idStr)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        }
                        .onDelete{ itineraryEditableData.stages.remove(atOffsets: $0) }
                        .onMove { itineraryEditableData.stages.move(fromOffsets: $0, toOffset: $1) }
                    } /* List */
                    .onChange(of: newStageMeta) { newValue in
                        // must reference itineraryEditableData NOT itinerary which is not edited !!!
                        if let newstagemeta = newValue {
                            DispatchQueue.main.async {
                                withAnimation {
                                    if let indx = itineraryEditableData.stageIndex(forUUIDstr: newstagemeta.stageInitiatingIDstr) {
                                        itineraryEditableData.stages.insert(newstagemeta.newStage, at: min(indx + 1,itineraryEditableData.stages.endIndex))
                                    } else {
                                        // top level + tapped, not a stage
                                        itineraryEditableData.stages.append(newstagemeta.newStage)
                                    }
                                    newStageMeta = nil
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    // always on main and after a delay
                                    svrproxy.scrollTo(newstagemeta.newStage.idStr)
                                }
                            }
                        }
                    }
                    /* List mods */
                } header: {
                    HStack {
                        Text("Stages")
                        Spacer()
                        //if ProcessInfo().isiOSAppOnMac {
                            //EditButton()
                        //}
                        Button {
                            newStageEditableData = Stage.EditableData()
                            newStageMeta = nil
                            isPresentingNewStageEditView = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .padding(0)
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                
                /* Section */
            } /* Form */
        } /* SVR */
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
                                let lastStageID = itineraryEditableData.stages.last?.idStr ?? ""
                                newStageMeta = NewStageMeta(stageInitiatingIDstr: lastStageID, duplicate: false, newStage: newStage)
                                isPresentingNewStageEditView = false
                            }
                        }
                    }
            }
        }

    } /* body */
    
} /* struct */
struct ItineraryEditView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
    }
}


