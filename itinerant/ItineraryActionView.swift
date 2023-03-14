//
//  ItineraryActionView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI
import UniformTypeIdentifiers


extension  ItineraryActionCommonView {
    
#if !os(watchOS)
    func sendItineraryToWatch()  {
        appDelegate.sendItineraryDataToWatch(itineraryLocalCopy.encodedWatchMessageStructKeepingItineraryUUIDWithStagesNewUUIDs)
    }
    

    var body_: some View {

        VStack(spacing: 0.0) {
            HStack {
                Text(itineraryLocalCopy.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .padding(0)
                if let imagedata = itineraryLocalCopy.imageDataThumbnailActual,
                   let uiImage = UIImage(data: imagedata) {
                    Button(action: {
                        if let imagedata = itineraryLocalCopy.getSetFullSizeImageData(),
                           let uiImage = UIImage(data: imagedata) {
                            fullSizeUIImage = uiImage
                            showFullSizeUIImage = true
                        }
                    }, label: {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(idealWidth: kImageColumnWidth)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(0)
                    })
                    .buttonStyle(.borderless)
               }
            }
            .padding([.leading,.trailing], 24)
            .padding([.top], 0)
            .padding([.bottom], 4)
            ScrollViewReader { scrollViewReader in
                List {
                    ForEach($itineraryLocalCopy.stages) { $stage in
                        StageActionCommonView(stage: $stage, itinerary: $itineraryLocalCopy, uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates, dictStageEndDates: $dictStageEndDates, resetStageElapsedTime: $resetStageElapsedTime, scrollToStageID: $scrollToStageID, stageToHandleSkipActionID: $stageToHandleSkipActionID, stageToHandleHaltActionID: $stageToHandleHaltActionID, stageToStartRunningID: $stageToStartRunningID, toggleDisclosureDetails: $toggleDisclosureDetails)
                            .id(stage.idStr)
                            .listRowInsets(.init(top: stage.idStr == itineraryLocalCopy.firstStageUUIDstr ? 0.0 : 4.0,
                                                 leading: 0,
                                                 bottom: stage.idStr == itineraryLocalCopy.lastStageUUIDstr ? 0.0 : 4.0,
                                                 trailing: 0))
                            .listRowBackground(Color.clear)
                            .listRowBackground(stageBackgroundColour(stage: stage))
                            .listRowSeparator(.hidden)
                            .cornerRadius(12)
                    } /* ForEach */
                } /* List */
                .onChange(of: scrollToStageID) { stageid in
                    if stageid != nil {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                // always on main and after a delay
                                scrollViewReader.scrollTo(stageid!)
                            }
                        }
                    }
                }
                /* List mods */
            } /* ScrollViewReader */
            VStack(alignment: .center, spacing: 0.0) {
                HStack(alignment: .center) {
                    ItineraryDurationUpdatingView(itinerary: itineraryLocalCopy)
                        .padding(.trailing,0)
                        .padding(.leading,0)
                        .font(.system(.subheadline, design: .rounded, weight: .regular))
                }
                FileNameModDateTextView(itineraryOptional: itineraryLocalCopy)
                .font(.system(.caption, design: .rounded, weight: .regular))
                .opacity(0.5)
            }
            .font(.caption)
            .lineSpacing(1.0)
        } /* VStack */
//        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            /* *** set the local Itinerary first *** */
            if let itinerary = itineraryStore.itineraryForID(id: itineraryLocalCopyID) { itineraryLocalCopy = itinerary }
            // set the first active stage unless we are already active or running
            guard let firstActindx = itineraryLocalCopy.firstIndexActivableStage else { return }
            if !itineraryLocalCopy.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) && !itineraryLocalCopy.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) {
                // i think this should be resetItineraryStages
                let stageuuid = itineraryLocalCopy.stages[firstActindx].idStr
                uuidStrStagesActiveStr.append(stageuuid)
                scrollToStageID = stageuuid
            }
            // prime the stages for a skip or halt action
            stageToHandleSkipActionID = appDelegate.unnStageToStopAndStartNextID
            stageToHandleHaltActionID = appDelegate.unnStageToHaltID
        }
        .onChange(of: appDelegate.unnStageToStopAndStartNextID, perform: {
            // prime the stages for a skip action
            stageToHandleSkipActionID = $0
        })
        .onChange(of: appDelegate.unnStageToHaltID, perform: {
            // prime the stages for a halt action
            stageToHandleHaltActionID = $0
        })
        .onChange(of: itineraryLocalCopy, perform: { updateLocalCopy in
            // after edit iiOS only
            DispatchQueue.main.async {
                itineraryStore.updateItinerary(itinerary: updateLocalCopy)
            }
        })
        .onChange(of: updatedItineraryEditableData, perform: { updatedData in
            if let updatedData {
                DispatchQueue.main.async {
                    // identify stageIDsTodelete before updating
                    let stageIDsInUpdatedData = updatedData.stagesIDstrs
                    let stageIDsToDelete = itineraryLocalCopy.stagesIDstrs.compactMap({ stageIDstr in
                        stageIDsInUpdatedData.contains(stageIDstr) ? nil : stageIDstr
                    })
                    if !stageIDsToDelete.isEmpty {
                        itineraryLocalCopy.removeAllSupportFilesForStageIDs(stageIDsToDelete)
                    }
                    itineraryLocalCopy.updateItineraryEditableData(from: updatedData)
                    // onChange(of: itineraryLocalCopy will be triggered and itineraryStore notified
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        resetItineraryStages()
                    }
                }
            }
        })
        .fileExporter(isPresented: $fileSaverShown,
                      document: fileSaveDocument,
                      contentType: fileSaveType,
                      defaultFilename: fileSaveName,
                      onCompletion: { result in
            switch result {
            case .success:
                if fileSaveType == .itineraryDataPackage { _ = itineraryStore.reloadItineraries() }
            case .failure (let error):
                debugPrint(error.localizedDescription)
                //break
            }
        }) /* File Saver */
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu( content: {
                    Button(action: {
                        showSettingsView = true
                    }) {
                        Label("Itinerary Settings…", systemImage: "doc.badge.gearshape")
                    }
                    if itineraryLocalCopy.settingsColoursStruct != nil {
                        Button(role: .destructive, action: {
                            itineraryStore.deleteSettingsForItineraryWithID(itineraryLocalCopy.idStr)
                            // itinerary is not bound to itinerary store so we must amend the existing one too
                            // we dont need to mess with any files as itineraryStore has done that
                            itineraryLocalCopy.settingsColoursStruct = nil
                        }) {
                            Label("Delete Itinerary Settings", systemImage: "trash")
                        }
                    }
                    Divider()
                    if !deviceIsIpadOrMac() {
                        Button(action: {
                            sendItineraryToWatch()
                        }) {
                            Label("Send to Watch…", systemImage: "applewatch")
                        }
                        .disabled(watchConnectionUnusable())
                    }
                    Button(action: {
                        showFilePicker = true
                   }) {
                        Label("Duplicate…", systemImage: "doc.on.doc")
                    }
                   .disabled(itineraryLocalCopy.packageFilePath == nil)
                   Button(action: {
                        // Export text file
                        fileSaveDocument = ItineraryFile(exportText: itineraryLocalCopy.exportString)
                        fileSaveType = .itineraryTextFile
                        fileSaveName = itineraryLocalCopy.title
                        fileSaverShown = true
                   }) {
                        Label("Export…", systemImage: "doc.plaintext")
                    }
                }, label: {
                    Label("", systemImage: "ellipsis.circle")
                }) /* Menu */
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    resetItineraryStages()
                }) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .foregroundColor(.red)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    itineraryData = itineraryLocalCopy.itineraryEditableData
                    isPresentingItineraryEditView = true
                }) {
                    Image(systemName: "square.and.pencil")
                }
                .disabled(itineraryLocalCopy.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    toggleDisclosureDetails = !toggleDisclosureDetails
                }) {
                    Image(systemName: toggleDisclosureDetails == true ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
                }
            }
        }
        .sheet(isPresented: $showFilePicker) {
            FilePickerUIRepresentable(path: itineraryLocalCopy.packageFilePath!)
        }
        .fullScreenCover(isPresented: $isPresentingItineraryEditView, content: {
            NavigationStack {
                // pass a BOUND COPY of itineraryData to amend and use to update if necessary
                ItineraryEditView(itineraryEditableData: $itineraryData)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingItineraryEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                updatedItineraryEditableData = nil
                                updatedItineraryEditableData = itineraryData
                                isPresentingItineraryEditView = false

                            }
                        }
                    }
            }
        }) /* sheet */
        .fullScreenCover(isPresented: $showFullSizeUIImage, content: {
            FullScreenImageView(fullSizeUIImage: $fullSizeUIImage, showFullSizeUIImage: $showFullSizeUIImage)
        }) /* fullScreenCover */
        .sheet(isPresented: $showSettingsView, content: {
            NavigationStack {
                SettingsView(urlToOpen: $openRequestURL, itinerary: Binding($itineraryLocalCopy))
            }
        })

    } /* View */
    

#endif
}



