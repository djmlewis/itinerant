//
//  ItineraryEditView.swift
//  itinerant
//
//  Created by David JM Lewis on 04/01/2023.
//

import SwiftUI
import PhotosUI


struct ItineraryEditView: View {
    @Binding var itineraryEditableData: Itinerary.EditableData
    @Binding var stageIDsToDelete: [String]

    @State private var newStageMeta: NewStageMeta?
    @State private var newStageEditableData: Stage = Stage()
    @State private var isPresentingNewStageEditView = false
    
    @State private var isEditing: Bool = false
    @State var stageIDtoDelete: String?
    @State var stageIDtoScrollTo: String?
    
    @Environment(\.colorScheme) var colorScheme

    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State var fullSizeUIImage: UIImage?
    @State var showFullSizeUIImage: Bool = false

    
    
    /* *** REMEMBER to EDIT ONLY the var itineraryEditableData and NOT the var itinerary */
    /* *** var itinerary is passed-in binding for the StageActionView */
    var body: some View {
        NavigationStack {
            HStack {
                Button {
                    DispatchQueue.main.async {
                        selectedImageData = nil
                        selectedItem = nil
                        itineraryEditableData.imageDataFullActual = nil
                        itineraryEditableData.imageDataThumbnailActual = nil
                    }
                } label: {
                    Image(systemName:"trash")
                        .font(.title3)
                }
                .disabled(selectedImageData == nil)
                Text("Image")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.system(.headline, design: .rounded, weight: .semibold).lowercaseSmallCaps())
                    .opacity(0.5)
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Image(systemName:"photo.on.rectangle.angled")
                            .font(.title3)
                        
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            // Retrieve selected asset in the form of Data
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                // make a thumbnail
                                if let uiImage = UIImage(data: data) {
                                    uiImage.prepareThumbnail(of: CGSize(width: kImageColumnWidth, height:uiImage.size.height * (kImageColumnWidth/uiImage.size.width))) { thumbnailImage in
                                        let thumbnaildata = thumbnailImage?.jpegData(compressionQuality: 0.5)
                                        DispatchQueue.main.async {
                                            selectedImageData = thumbnaildata
                                            itineraryEditableData.imageDataFullActual = data
                                            itineraryEditableData.imageDataThumbnailActual = thumbnaildata
                                        }
                                    }
                                }
                            }
                        }
                    }
            }
            .frame(idealWidth: kImageColumnWidth)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.bottom,4)
            HStack(alignment: .top) {
                if let selectedImageData,
                   let uiImage = UIImage(data: selectedImageData) {
                    Button(action: {
                        if let imagedata = itineraryEditableData.imageDataFullActual,
                           let uiImage = UIImage(data: imagedata) {
                            fullSizeUIImage = uiImage
                            showFullSizeUIImage = true
                        }
                    }, label: {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(idealWidth: kImageColumnWidth, alignment: .trailing)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(0)
                    })
                    .buttonStyle(.borderless)
                } else {
                    Text("Tap \(Image(systemName:"photo.on.rectangle.angled")) to add image")
                        .font(.system(.subheadline, design: .rounded, weight: .regular))
                        .frame(alignment: .center)
                        .padding(0)
                        .opacity(0.5)
                        .italic()
                }
            }
            .padding(.bottom, kiOSStageViewsRowPad)
            Text("Title")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(.headline, design: .rounded, weight: .semibold).lowercaseSmallCaps())
                .opacity(0.5)
                .padding(.leading,24)
            TextField("", text: $itineraryEditableData.title, axis: .vertical)
                .labelsHidden()
                .textFieldStyle(.roundedBorder)
                .padding([.leading,.trailing],24)
                .multilineTextAlignment(.leading)
                .padding(.bottom, kiOSStageViewsRowPad)
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
                            StageDisplayView(stage: $stage, newStageMeta: $newStageMeta, isEditing: $isEditing, stageIDtoDelete: $stageIDtoDelete)
                                .background(Color("ColourStageDisplayBackground"))
                                .cornerRadius(12)
                                .id(stage.idStr)
                        }
                        .onMove(perform: isEditing ? { itineraryEditableData.stages.move(fromOffsets: $0, toOffset: $1) } : nil)
                    }
                    .padding([.leading,.trailing], 24)
                    .onChange(of: stageIDtoScrollTo, perform: {
                        if let id = $0 {
                            withAnimation {
                                svrproxy.scrollTo(id)
                            }
                        }
                    })
                } /* ScrollView */
            } /* SVR */
            .onAppear {
                selectedImageData = itineraryEditableData.imageDataThumbnailActual
            }
            .onChange(of: stageIDtoDelete, perform: {
                guard let idtodelete = $0, let indx = itineraryEditableData.stageIndex(forUUIDstr: idtodelete) else { return }
                // dont delete any files let itineraryactionview do that if we tap save
                stageIDsToDelete.append(idtodelete)
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
                                    var newStage = Stage()
                                    newStage.updateEditableData(from: newStageEditableData)
                                    let lastStageID = itineraryEditableData.stages.last?.idStr ?? ""
                                    newStageMeta = NewStageMeta(stageInitiatingIDstr: lastStageID, duplicate: false, newStage: newStage)
                                    isPresentingNewStageEditView = false
                                }
                            }
                        }
                }
            } /* newstageedit sheet*/
            .fullScreenCover(isPresented: $showFullSizeUIImage, content: {
                FullScreenImageView(fullSizeUIImage: $fullSizeUIImage, showFullSizeUIImage: $showFullSizeUIImage)
            }) /* fullScreenCover */
            
        } /* NavView */
    } /* body */
} /* struct */



struct ItineraryEditView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
    }
}


