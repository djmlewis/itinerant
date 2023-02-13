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
    
    // @FocusState private var focusedFieldTag: FieldFocusTag?
    
    /* *** REMEMBER to EDIT ONLY the var itineraryEditableData and NOT the var itinerary */
    /* *** var itinerary is passed-in binding for the StageActionView */
    var body: some View {
        ScrollViewReader { svrproxy in
            Form {
                Section(header: Text("Title")) {
                    TextField("Itinerary title", text: $itineraryEditableData.title)
                }
                Section(header: HStack(){
                    Text("Stages")
                    Spacer()
                    EditButton()
                        .textCase(nil)
                    Spacer()
                }) {
                    List {
                        ForEach($itineraryEditableData.stages) { $stage in
                            StageDisplayView(stage: $stage, newStageMeta: $newStageMeta)
                                .id(stage.idStr)
                        }
                        .onDelete { itineraryEditableData.stages.remove(atOffsets: $0) }
                        .onMove { itineraryEditableData.stages.move(fromOffsets: $0, toOffset: $1) }
                    } /* List */
                    .onChange(of: newStageMeta) { newValue in
                        // must reference itineraryEditableData NOT itinerary which is not edited !!!
                        if let newstagemeta = newValue, let indx = itineraryEditableData.stageIndex(forUUIDstr: newstagemeta.stageInitiatingIDstr) {
                            DispatchQueue.main.async {
                                withAnimation {
                                    itineraryEditableData.stages.insert(newstagemeta.newStage, at: min(indx + 1,itineraryEditableData.stages.endIndex))
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
                }  /* Section */
            } /* Form */
        } /* SVR */
    } /* body */
    
} /* struct */
struct ItineraryEditView_Previews: PreviewProvider {
    static var previews: some View {
        ItineraryEditView(itineraryEditableData: .constant(Itinerary.templateItinerary().itineraryEditableData))
    }
}


