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
    

    var body_: some View {

        VStack(spacing: 0.0) {
            HStack {
                Text(itinerary.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .padding(0)
                if let imagedata = itinerary.imageDataThumbnailActual,
                   let uiImage = UIImage(data: imagedata) {
                    Button(action: {
                        if let imagedata = itinerary.getSetFullSizeImageData(),
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
                    ForEach($itinerary.stages) { $stage in
                        StageActionCommonView(stage: $stage, itinerary: $itinerary, uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates, dictStageEndDates: $dictStageEndDates, resetStageElapsedTime: $resetStageElapsedTime, scrollToStageID: $scrollToStageID, stageToHandleSkipActionID: $stageToHandleSkipActionID, stageToHandleHaltActionID: $stageToHandleHaltActionID, stageToStartRunningID: $stageToStartRunningID, toggleDisclosureDetails: $toggleDisclosureDetails)
                            .id(stage.idStr)
                            .listRowInsets(.init(top: stage.idStr == itinerary.firstStageUUIDstr ? 0.0 : 4.0,
                                                 leading: 0,
                                                 bottom: stage.idStr == itinerary.lastStageUUIDstr ? 0.0 : 4.0,
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
                    ItineraryDurationUpdatingView(itinerary: itinerary)
                        .padding(.trailing,0)
                        .padding(.leading,0)
                        .font(.system(.subheadline, design: .rounded, weight: .regular))
                }
                FileNameModDateTextView(itineraryOptional: itinerary)
                .font(.system(.caption, design: .rounded, weight: .regular))
                .opacity(0.5)
            }
            .font(.caption)
            .lineSpacing(1.0)
        } /* VStack */
//        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            // set the first active stage unless we are already active or running
            guard let firstActindx = itinerary.firstIndexActivableStage else { return }
            if !itinerary.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) && !itinerary.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) {
                // i think this should be resetItineraryStages
                let stageuuid = itinerary.stages[firstActindx].idStr
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
        .onChange(of: itinerary, perform: {
            // after edit iiOS only
            _ = itineraryStore.updateItinerary(itinerary: $0) })
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
                    if itinerary.settingsColoursStruct != nil {
                        Button(role: .destructive, action: {
                            itineraryStore.deleteSettingsForItineraryWithID(itinerary.idStr)
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
                   .disabled(itinerary.packageFilePath == nil)
                   Button(action: {
                        // Export text file
                        fileSaveDocument = ItineraryFile(exportText: itinerary.exportString)
                        fileSaveType = .itineraryTextFile
                        fileSaveName = itinerary.title
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
                    itineraryData = itinerary.itineraryEditableData
                    isPresentingItineraryEditView = true
                }) {
                    Image(systemName: "square.and.pencil")
                }
                .disabled(itinerary.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr))
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
            FilePickerUIRepresentable(path: itinerary.packageFilePath!)
        }
        .fullScreenCover(isPresented: $isPresentingItineraryEditView, content: {
            NavigationStack {
                // pass a BOUND COPY of itineraryData to amend and use to update if necessary
                ItineraryEditView(itineraryEditableData: $itineraryData, stageIDsToDelete: $stageIDsToDelete)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingItineraryEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                itinerary.removeAllSupportFilesForStageIDs(stageIDsToDelete)
                                DispatchQueue.main.async {
                                    itinerary.updateItineraryEditableData(from: itineraryData)
                                    isPresentingItineraryEditView = false
                                    resetItineraryStages()
                                }
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
                SettingsView(/*showSettingsView: $showSettingsView,*/ urlToOpen: $openRequestURL, itinerary: itinerary)
            }
        })

    } /* View */
    

#endif
}



