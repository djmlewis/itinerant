//
//  ItineraryEditView.swift
//  itinerant
//
//  Created by David JM Lewis on 04/01/2023.
//

import SwiftUI

struct ItineraryEditView: View {
    
    @Binding var itineraryData: Itinerary.EditableData
    
    @State private var itineraryName: String = ""
    @State private var isPresentingStageEditView = false
    @State private var newStage = Stage.templateStage()
    @FocusState private var focusedFieldTag: FieldFocusTag?
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Itinerary title", text: $itineraryData.title)
                    .focused($focusedFieldTag, equals: .title)
            }
            Section(header: HStack(){
                Text("Stages")
                Spacer()
                Button(action: {
                    newStage = Stage.templateStage()
                    isPresentingStageEditView = true

                }) {
                    Image(systemName: "plus")
                }
                Spacer()
                EditButton()
                    .textCase(nil)
            }) {
                List {
                    ForEach($itineraryData.stages) { $stage in
                        NavigationLink(destination: StageEditView(stage: $stage)) {
                            // stageUuidEnabled set to "" to make all disabled, activeStageUuid ignored during edit
                            StageActionView(stage: $stage, stageUuidEnabled: .constant(""), inEditingMode: true)
                        }
                    }
                    .onDelete(perform: { itineraryData.stages.remove(atOffsets: $0) })
                    .onMove { itineraryData.stages.move(fromOffsets: $0, toOffset: $1) }
                    
                }
            }
        }
        .onAppear() {
            focusedFieldTag = .title
        }
        .sheet(isPresented: $isPresentingStageEditView) {
            NavigationView {
                StageEditView(stage: $newStage)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingStageEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                itineraryData.stages.append(newStage)
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
        ItineraryEditView(itineraryData: .constant(Itinerary.templateItinerary().itineraryEditableData))
    }
}
