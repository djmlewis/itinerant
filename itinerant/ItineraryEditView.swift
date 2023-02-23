//
//  ItineraryEditView.swift
//  itinerant
//
//  Created by David JM Lewis on 04/01/2023.
//

import SwiftUI


struct ItineraryEditView: View {
    @Binding var itineraryEditableData: Itinerary.EditableData
    
    @State private var newStageMeta: NewStageMeta?
    @State private var newStageEditableData: Stage = Stage()
    @State private var isPresentingNewStageEditView = false
    
    @State private var isEditing: Bool = false
    @State var stageIDtoDelete: String?
    @State var stageIDtoScrollTo: String?
    
    @FocusState private var titleFocused: Bool
    @State var titleFocuseState: Bool = false
    
    /* *** REMEMBER to EDIT ONLY the var itineraryEditableData and NOT the var itinerary */
    /* *** var itinerary is passed-in binding for the StageActionView */
    var body: some View {
        NavigationStack {
            VStack {
                Text("Title")
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .padding(0)
                TextField("Itinerary title", text: $itineraryEditableData.title)
                    .textFieldStyle(.roundedBorder)
                    .padding([.leading,.trailing],12)
                    .multilineTextAlignment(.center)
                    .focused($titleFocused)
            }
            .padding(.bottom, 12)
            HStack {
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                }
                .padding(.leading,12)
                .buttonStyle(.borderless)
                .controlSize(.regular)
                Spacer()
                Text("Stages")
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                Spacer()
                Button {
                    newStageEditableData = Stage()
                    newStageMeta = nil
                    titleFocused = false
                    isPresentingNewStageEditView = true
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
                .padding(.trailing,12)
            }
            ScrollViewReader { svrproxy in
                ScrollView {
                    VStack {
                        ForEach($itineraryEditableData.stages) { $stage in
                            StageDisplayView(stage: $stage, newStageMeta: $newStageMeta, isEditing: $isEditing, stageIDtoDelete: $stageIDtoDelete, itineraryTitleFocused: $titleFocuseState)
                            Divider()
                                .id(stage.idStr)
                        }
                        .onMove(perform: isEditing ? { itineraryEditableData.stages.move(fromOffsets: $0, toOffset: $1) } : nil)
                    }
                    .onChange(of: titleFocuseState, perform: { newValue in
                        // respond to a toggle with false
                        titleFocused = false
                    })
                    .onChange(of: stageIDtoScrollTo, perform: {
                        if let id = $0 {
                            withAnimation {
                                svrproxy.scrollTo(id)
                            }
                        }
                    })
                } /* ScrollView */
            } /* SVR */
            .onChange(of: stageIDtoDelete, perform: {
                guard let idtodelete = $0, let indx = itineraryEditableData.stageIndex(forUUIDstr: idtodelete) else { return }
                DispatchQueue.main.async {
                    withAnimation {
                        itineraryEditableData.stages.remove(atOffsets: IndexSet(integer: indx))
                    }
                }
            })
            .onChange(of: newStageMeta) { newValue in
                // must reference itineraryEditableData NOT itinerary which is not edited !!!
                if let newstagemeta = newValue {
                    DispatchQueue.main.async {
                        let id = newstagemeta.newStage.idStr
                        if let indx = itineraryEditableData.stageIndex(forUUIDstr: newstagemeta.stageInitiatingIDstr) {
                            itineraryEditableData.stages.insert(newstagemeta.newStage, at: min(indx + 1,itineraryEditableData.stages.endIndex))
                        } else {
                            // top level + tapped, not a stage
                            itineraryEditableData.stages.append(newstagemeta.newStage)
                        }
                        stageIDtoScrollTo = id
                        newStageMeta = nil
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
                                    let lastStageID = itineraryEditableData.stages.last?.idStr ?? ""
                                    newStageMeta = NewStageMeta(stageInitiatingIDstr: lastStageID, duplicate: false, newStage: newStage)
                                    isPresentingNewStageEditView = false
                                }
                            }
                        }
                }
            }
            
        } /* NavView */
    } /* body */
} /* struct */



struct ItineraryEditView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
    }
}


