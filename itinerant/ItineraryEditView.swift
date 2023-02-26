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
    
    @Environment(\.colorScheme) var colorScheme

    @FocusState private var titleFocused: Bool
    @State var titleFocuseState: Bool = false
    
    /* *** REMEMBER to EDIT ONLY the var itineraryEditableData and NOT the var itinerary */
    /* *** var itinerary is passed-in binding for the StageActionView */
    var body: some View {
        NavigationStack {
            VStack {
                Text("Title")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(.headline, design: .rounded, weight: .semibold).lowercaseSmallCaps())
                    .opacity(0.5)
                    .padding(.leading,24)
                TextField("", text: $itineraryEditableData.title)
                    .labelsHidden()
                    .textFieldStyle(.roundedBorder)
                    .padding([.leading,.trailing],24)
                    .multilineTextAlignment(.leading)
                    .focused($titleFocused)
            }
            .padding(.bottom, 12)
            HStack {
                Text("Stages")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(.headline, design: .rounded, weight: .semibold).lowercaseSmallCaps())
                    .opacity(0.5)
                    .padding(.leading,24)
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                }
                .padding(.trailing,36)
                .buttonStyle(.borderless)
                .controlSize(.regular)
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
                .padding(.trailing,24)
            }
            ScrollViewReader { svrproxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach($itineraryEditableData.stages) { $stage in
                            StageDisplayView(stage: $stage, newStageMeta: $newStageMeta, isEditing: $isEditing, stageIDtoDelete: $stageIDtoDelete, itineraryTitleFocused: $titleFocuseState)
                                .background(Color("ColourStageDisplayBackground"))
                                .cornerRadius(12)
                                .id(stage.idStr)
                        }
                        .onMove(perform: isEditing ? { itineraryEditableData.stages.move(fromOffsets: $0, toOffset: $1) } : nil)
                    }
                    .padding([.leading,.trailing], 24)
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


