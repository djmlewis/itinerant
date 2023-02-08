//
//  ItineraryActionView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI



extension  ItineraryActionCommonView {
     
    var body_ios: some View {
        VStack {
            ScrollViewReader { scrollViewReader in
                List {
                    ForEach($itinerary.stages) { $stage in
                        StageActionCommonView(stage: $stage, itinerary: $itinerary, uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates, dictStageEndDates: $dictStageEndDates, resetStageElapsedTime: $resetStageElapsedTime, scrollToStageID: $scrollToStageID, stageToHandleSkipActionID: $stageToHandleSkipActionID, stageToHandleHaltActionID: $stageToHandleHaltActionID, stageToStartRunningID: $stageToStartRunningID, toggleDisclosureDetails: $toggleDisclosureDetails)
                            .id(stage.idStr)
                            .listRowBackground(stageBackgroundColour(stage: stage))
                            .cornerRadius(6)
                            .padding(.bottom, stage.idStr == itinerary.lastStageUUIDstr ? 0.0 : 4.0)
                    } /* ForEach */
                } /* List */
                .onChange(of: scrollToStageID) { stageid in
                    if stageid != nil {
                        DispatchQueue.main.async {
                            withAnimation {
                                scrollViewReader.scrollTo(stageid!)
                            }
                        }
                    }
                }
                /* List mods */
            } /* ScrollViewReader */
            VStack(alignment: .center, spacing: 0.0) {
                HStack(alignment: .firstTextBaseline) {
                    Group {
                        Text("Total")
                            .font(.title2)
                        Image(systemName: "timer")
                            .resizable()
                            .frame(width: 16, height: 16)
                        Text(Stage.stageDurationStringFromDouble(itinerary.totalDuration) + (itinerary.someStagesAreCountUp ? " +" : ""))
                            .font(.title2)
                        if(itinerary.someStagesAreCountUp) {
                            Image(systemName: "stopwatch")
                                .resizable()
                                .frame(width: 16, height: 16)
                        }
                    }
                    .padding(.trailing,0)
                    .padding(.leading,0)
                }
                    HStack(alignment: .center) {
                        Spacer()
                       Image(systemName: "doc")
                        Text(itinerary.filename ?? "---")
                        Image(systemName:"square.and.pencil")
                        Text(Date(timeIntervalSinceReferenceDate: itinerary.modificationDate).formatted(date: .numeric, time: .shortened))
                        Spacer()
                   }
                .font(.caption)
            }
            .lineSpacing(1.0)
        } /* VStack */
        .navigationTitle(itinerary.title)
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
            itinerary.filename = itineraryStore.updateItinerary(itinerary: $0) })
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Button(action: {
                        sendItineraryToWatch()
                    }) {
                        Label("Send to Watch…", systemImage: "applewatch")
                    }
                    
                    Button(action: {
                        // ItineraryDocument always inits with now mod date
                        fileSaveDocument = ItineraryDocument(editableData: itinerary.itineraryEditableData)
                        fileExporterShown = true
                    }) {
                        Label("Export…", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Label("", systemImage: "ellipsis.circle")
                }
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
        .sheet(isPresented: $isPresentingItineraryEditView) {
            NavigationStack {
                // pass a BOUND COPY of itineraryData to amend and use to update if necessary
                ItineraryEditView(itinerary: $itinerary, itineraryEditableData: $itineraryData)
                    .navigationTitle(itinerary.title)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingItineraryEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                itinerary.updateItineraryEditableData(from: itineraryData)
                                isPresentingItineraryEditView = false
                            }
                        }
                    }
            }
        } /* sheet */
        .fileExporter(isPresented: $fileExporterShown,
                      document: fileSaveDocument,
                      contentType: .itineraryDataFile,
                      defaultFilename: fileSaveDocument?.itineraryPersistentData.title) { result in
            switch result {
            case .success:
                itineraryStore.reloadItineraries()
            case .failure(let error):
                debugPrint(error.localizedDescription)
            }
        } /* fileExporter */
    } /* View */
    
}



