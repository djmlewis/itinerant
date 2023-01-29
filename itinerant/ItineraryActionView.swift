//
//  ItineraryActionView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI



struct ItineraryActionView: View {
    
    @State var itinerary: Itinerary // not sure why thgis is a State not a Binding
    @Binding var uuidStrStagesActiveStr: String
    @Binding var uuidStrStagesRunningStr: String
    @Binding var dictStageStartDates: [String:String]
    
    @State private var itineraryData = Itinerary.EditableData()
    @State private var isPresentingItineraryEditView: Bool = false
    @State private var toggleDisclosureDetails: Bool = true
    @State private var fileExporterShown: Bool = false
    @State private var fileSaveDocument: ItineraryDocument?

    @State private var resetStageElapsedTime: Bool?
    @State private var scrollToStageID: String?
    var lastStageID: String  { if itinerary.stages.last  != nil { return itinerary.stages.last!.id.uuidString } else { return "" } }

    
    @EnvironmentObject var itineraryStore: ItineraryStore
    @EnvironmentObject var appDelegate: AppDelegate

        
    var body: some View {
        VStack(alignment: .leading) {
            ScrollViewReader { scrollViewReader in
                List {
                    ForEach($itinerary.stages) { $stage in
                        StageActionView(stage: $stage, itinerary: $itinerary, uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates, resetStageElapsedTime: $resetStageElapsedTime,
                                        scrollToStageID: $scrollToStageID,
                                        toggleDisclosureDetails: $toggleDisclosureDetails)
                        .id(stage.id.uuidString)
                        .listRowBackground(Color(stage.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? "ColourBackgroundRunning" :
                                                    stage.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) ? "ColourBackgroundActive" :
                                                    "ColourBackgroundInactive" )
                            .cornerRadius(6)
                            .padding(.bottom, stage.id.uuidString == lastStageID ? 0.0 : 4.0))
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
            }
        } /* VStack */
        VStack(alignment: .center) {
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
            HStack(alignment: .top) {
                Label(itinerary.filename ?? "---", systemImage: "doc")
                Text(Date(timeIntervalSinceReferenceDate: itinerary.modificationDate).formatted(date: .numeric, time: .shortened))
            }
            .styleSubtitleLabel(alignment: .center)
        }
        .navigationTitle(itinerary.title)
        .onAppear() {
            if !itinerary.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) && !itinerary.isActive(uuidStrStagesActiveStr: uuidStrStagesActiveStr) && !itinerary.stages.isEmpty {
                uuidStrStagesActiveStr.append(itinerary.stages[0].id.uuidString)
            }
        }
        .onChange(of: itinerary, perform: {
            // after edit iiOS only
            itinerary.filename = itineraryStore.updateItinerary(itinerary: $0) })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
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
                        Label("Export File…", systemImage: "folder")
                    }
                } label: {
                    Label("Export…", systemImage: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    resetItineraryStages()
                }) {
                    Image(systemName: "arrow.counterclockwise")
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
            NavigationView {
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



extension ItineraryActionView {
    
    func removeAllActiveRunningItineraryStageIDsAndNotifcations() {
        (uuidStrStagesActiveStr,uuidStrStagesRunningStr,dictStageStartDates) = itinerary.removeAllStageIDsAndNotifcations(from: uuidStrStagesActiveStr, andFrom: uuidStrStagesRunningStr, andFromDict: dictStageStartDates)
    }
    
    func resetItineraryStages() {
        removeAllActiveRunningItineraryStageIDsAndNotifcations()
        resetStageElapsedTime = true
        // need a delay or we try to change ui too soon
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if !itinerary.stages.isEmpty {
                uuidStrStagesActiveStr.append(itinerary.stages[0].id.uuidString)
            }
        }
        
    }
    
    func sendItineraryToWatch()  {
        if let watchdata = itinerary.watchDataNewUUID {
            appDelegate.send(dict: [kMessageItineraryData : watchdata], data: nil)
        }
    }
}

struct ItineraryActionView_Previews: PreviewProvider {
    static var previews: some View {
        Text("k")
        //ItineraryActionView(itinerary: .constant(Itinerary.templateItinerary()))
    }
}
