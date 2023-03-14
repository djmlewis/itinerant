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
    //@Binding var stageIDsToDelete: [String]

    @State private var newStageMeta: NewStageMeta?
    @State private var newStageEditableData: Stage = Stage()
    @State private var isPresentingNewStageEditView = false
    
    @State private var isEditing: Bool = false
    @State var stageIDtoScrollTo: String?
    
    @Environment(\.colorScheme) var colorScheme

    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State var fullSizeUIImage: UIImage?
    @State var showFullSizeUIImage: Bool = false

    @State var showRightColumn: Bool = true

    
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
                Button {
                    newStageEditableData = Stage()
                    newStageMeta = nil
                    isPresentingNewStageEditView = true
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.borderless)
                .controlSize(.regular)
            }
            .padding([.leading,.trailing],24)
/* *********        STAGES       ************* */
            ScrollViewReader { svrproxy in
                List {
                    if deviceIsIpadOrMac() {
                        ForEach($itineraryEditableData.stages, id: \.self) { $stage in
                            StageEditCommonView(stageEditableData: $stage, showRightColumn: $showRightColumn)
                                .background(Color("ColourStageDisplayBackground"))
                                .listRowInsets(.init(top: stage.idStr == itineraryEditableData.firstStageUUIDstr ? 0.0 : 4.0,
                                                     leading: 0,
                                                     bottom: stage.idStr == itineraryEditableData.lastStageUUIDstr ? 0.0 : 4.0,
                                                     trailing: 0))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .cornerRadius(12)
                                .id(stage.idStr)
                        }
                        .onMove { (from,to) in
                            DispatchQueue.main.async { itineraryEditableData.stages.move(fromOffsets: from, toOffset: to) }
                        }
                        .onDelete { offsets in
                            DispatchQueue.main.async {
                                withAnimation {
                                    itineraryEditableData.stages.remove(atOffsets: offsets)
                                }
                            }
                        }
                    } else {
                        ForEach($itineraryEditableData.stages, id: \.self) { $stage in
                            StageDisplayView(stage: $stage, newStageMeta: $newStageMeta, isEditing: $isEditing)
                                .background(Color("ColourStageDisplayBackground"))
                                .listRowInsets(.init(top: stage.idStr == itineraryEditableData.firstStageUUIDstr ? 0.0 : 4.0,
                                                     leading: 0,
                                                     bottom: stage.idStr == itineraryEditableData.lastStageUUIDstr ? 0.0 : 4.0,
                                                     trailing: 0))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .cornerRadius(12)
                                .id(stage.idStr)
                        }
                        .onMove { (from,to) in
                            DispatchQueue.main.async { itineraryEditableData.stages.move(fromOffsets: from, toOffset: to) }
                        }
                        .onDelete { offsets in
                            DispatchQueue.main.async {
                                withAnimation {
                                    itineraryEditableData.stages.remove(atOffsets: offsets)
                                }
                            }
                        }
                    }
                } /* List */
            } /* SVR */
/* *********        STAGES       ************* */
            .onAppear {
                selectedImageData = itineraryEditableData.imageDataThumbnailActual
            }
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
            .fullScreenCover(isPresented: $isPresentingNewStageEditView) {
                NavigationStack {
                    StageEditCommonView(stageEditableData: $newStageEditableData, showRightColumn: .constant(true))
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



