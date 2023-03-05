//
//  StageDisplayView.swift
//  itinerant
//
//  Created by David JM Lewis on 15/01/2023.
//


// a StageActionView but without the actionable elements, displayed in Itinerary Edit View

import SwiftUI
import Combine

struct NewStageMeta: Equatable {
    internal init(stageInitiatingIDstr: String, duplicate: Bool, newStage: Stage) {
        self.stageInitiatingIDstr = stageInitiatingIDstr
        self.duplicate = duplicate
        self.newStage = newStage
    }
    
    let stageInitiatingIDstr: String
    let duplicate: Bool
    let newStage: Stage
    
}

struct StageDisplayView: View {
    @Binding var stage: Stage
    @Binding var newStageMeta: NewStageMeta?
    @Binding var isEditing: Bool
    @Binding var stageIDtoDelete: String?
    
    
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appDelegate: AppDelegate

    @State private var isPresentingStageEditView = false
    @State private var stageEditableData = Stage()

    @State private var newStageEditableData: Stage = Stage()
    @State private var isPresentingNewStageEditView = false

    @State var stageDurationDateInvalid: Bool = false
    @State var uiSlowUpdateTimer: Timer.TimerPublisher = Timer.publish(every: kUISlowUpdateTimerFrequency, on: .main, in: .common)
    @State var uiSlowUpdateTimerCancellor: Cancellable?

    @State var fullSizeUIImage: UIImage?
    @State var showFullSizeUIImage: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 0.0) {
            if isEditing == true {
                VStack {
                    Button {
                        stageIDtoDelete = stage.idStr
                    } label: {
                        Image(systemName: "trash")
                    }
                    .font(.system(.title2, design: .rounded, weight: .regular))
                    .foregroundColor(.white)
                    .buttonStyle(.borderless)
                    .controlSize(.large)
                }
                .frame(maxHeight: .infinity)
                .padding()
                .background(.red)
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 0.0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(stage.title)
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, kiOSStageViewsRowPad)
                            .padding(.top, 6)
                        if !stage.details.isEmpty {
                            Text(stage.details)
                                .font(.system(.footnote, design: .rounded, weight: .regular))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, kiOSStageViewsRowPad)
                                .multilineTextAlignment(.leading)
                                .lineLimit(1...2)
                        }
                    } /* VStack */
                    if let selectedImageData = stage.imageDataThumbnailActual,
                       let uiImage = UIImage(data: selectedImageData) {
                        Button(action: {
                            if let imagedata = stage.imageDataFullActual,
                               let uiImage = UIImage(data: imagedata) {
                                fullSizeUIImage = uiImage
                                showFullSizeUIImage = true
                            }
                        }, label: {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(idealWidth: kImageColumnWidthHalf, alignment: .trailing)
                                .fixedSize(horizontal: true, vertical: false)
                                .padding(0)
                        })
                        .buttonStyle(.borderless)
                   }

                } /* HStack */
                Spacer()
                HStack {
                    Image(systemName: stage.durationSymbolName)
                        .frame(alignment: .leading)
                    if stage.isCommentOnly == false {
                        if stage.isCountDownType {
                            Text(stage.durationString)
                                .foregroundColor(stageDurationDateInvalid ?  Color("ColourInvalidDate") : textColourForScheme(colorScheme: colorScheme))
                                .lineLimit(1...2)
                                .allowsTightening(true)
                                .minimumScaleFactor(0.5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                       }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading,.bottom], kiOSStageViewsRowPad)
                .font(.system(.title3, design: .rounded, weight: .bold))
                Stage.additionalAndSnoozeAlertsHStackForStage(stage)
            } /* VStack */
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(0)
            //.padding(.leading, 12)
            if isEditing == false {
                    VStack(alignment: .trailing) {
                        Button(action: {
                            stageEditableData = stage.editableData
                            isPresentingStageEditView = true
                        }) {
                            Image(systemName: "square.and.pencil")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .frame(width: 24, alignment: .trailing)
                        .padding([.top,.bottom], kiOSStageViewsRowPad)
                        Spacer()
                        Button(action: {
                            newStageMeta = nil
                            newStageMeta = NewStageMeta(stageInitiatingIDstr: stage.idStr, duplicate: true, newStage: stage.duplicateWithNewID)
                        }) {
                            Image(systemName: "doc.on.doc")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .frame(width: 24, alignment: .trailing)
                        .padding([.top,.bottom], kiOSStageViewsRowPad)
                       Spacer()
                        Button(action: {
                            newStageEditableData = Stage()
                            newStageMeta = nil
                            isPresentingNewStageEditView = true
                        }) {
                            Image(systemName: "plus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .frame(width: 24, alignment: .trailing)
                        .padding([.top,.bottom], kiOSStageViewsRowPad)
                   } /* VStack buttons */
                    .padding([.leading,.trailing], kiOSStageViewsRowPad)
                    .foregroundColor( .accentColor)
                    .background(Color("ColourControlsBackground"))
            } /* if isEditing == false */
            else {
                VStack {
                    Image(systemName: "line.3.horizontal")
                }
                .font(.system(.title2, design: .rounded, weight: .regular))
                .frame(maxHeight: .infinity)
                .padding()
            }
        } /* HStack */
        .frame(maxWidth: .infinity)
        .animation(.linear(duration: 0.1), value: isEditing)
        .onAppear() { checkUIupdateSlowTimerStatus() }
        .onDisappear() { uiSlowUpdateTimerCancellor?.cancel() }
        .onReceive(uiSlowUpdateTimer) { stageDurationDateInvalid = !stage.validDurationForCountDownTypeAtDate($0) }
        .onChange(of: stage.flags) { _ in checkUIupdateSlowTimerStatus() }
        .sheet(isPresented: $isPresentingStageEditView) {
            NavigationStack {
                StageEditView(stageEditableData: $stageEditableData)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingStageEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                DispatchQueue.main.async {
                                    stage.updateEditableData(from: stageEditableData)
                                    isPresentingStageEditView = false
                                }
                            }
                        }
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
                                newStageMeta = NewStageMeta(stageInitiatingIDstr: stage.idStr, duplicate: false, newStage: newStage)
                                isPresentingNewStageEditView = false
                            }
                        }
                    }
            }
        }
        .fullScreenCover(isPresented: $showFullSizeUIImage, content: {
            FullScreenImageView(fullSizeUIImage: $fullSizeUIImage, showFullSizeUIImage: $showFullSizeUIImage)
        }) /* fullScreenCover */

    } /* body */
    
}

extension StageDisplayView {
    
    func checkUIupdateSlowTimerStatus() {
        uiSlowUpdateTimerCancellor?.cancel()
        if stage.isCountDownToDate {
            uiSlowUpdateTimer = Timer.publish(every: kUISlowUpdateTimerFrequency, on: .main, in: .common)
            uiSlowUpdateTimerCancellor = uiSlowUpdateTimer.connect()
        }
    }

}

struct StageDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Yo")
    }
}
