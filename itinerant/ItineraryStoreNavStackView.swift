//
//  ItineraryStoreNavStackView.swift
//  itinerant
//
//  Created by David JM Lewis on 19/02/2023.
//

import SwiftUI
import UniformTypeIdentifiers.UTType
import UIKit.UIDevice


extension ItineraryStoreView {
    

    var body_stack: some View {
        NavigationStack(path: $presentedItineraryID) {
            List {
                ForEach(itineraryStore.itineraryUUIDStrs, id:\.self) { itineraryID in
                    let itineraryOptional = itineraryStore.itineraryForID(id: itineraryID)
                    let isRunning = (itineraryOptional?.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ?? false)
                    let hasThumbnail = itineraryOptional?.imageDataThumbnailActual != nil
                    NavigationLink(value: itineraryID) {
                        HStack(alignment: .center, spacing: 0) {
                            if isRunning || hasThumbnail {
                                ZStack(alignment: .center) {
                                    if let imagedata = itineraryStore.itineraryThumbnailForID(id: itineraryID), let uiImage = UIImage(data: imagedata) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .frame(maxWidth: kImageColumnWidthThird, maxHeight: lineHeights[itineraryID])
                                            .padding(0)
                                    }
                                    if isRunning {
                                        buttonStartHalt(forItineraryID: itineraryID)
                                    }
                                }
                           }
                            VStack(alignment: .leading) {
                                Text(itineraryStore.itineraryTitleForID(id: itineraryID))
                                    .font(.system(.title, design: .rounded, weight: .semibold))
                                    .multilineTextAlignment(.leading)
                                FileNameModDateTextView(itineraryOptional: itineraryOptional)
                                    .font(.system(.subheadline, design: .rounded, weight: .regular))
                                    .lineLimit(1)
                                    .allowsTightening(true)
                                    .minimumScaleFactor(0.8)
                                    .opacity(0.6)
                            }
                            .padding(.leading,12)
                            .modifier(TitleMeasuringModifier())
                            .onPreferenceChange(TitleMeasuringPreferenceKey.self) { lineHeights[itineraryID] = $0.height }
                        }
                        .id(itineraryID)
                        .padding(0)
                    }
                    .foregroundColor(textColourForID(itineraryID))
                    .listRowBackground(backgroundColourForID(itineraryID))
                    .listRowInsets(.init(top: 10,
                                         leading: (itineraryOptional?.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ?? false) ? 2 : 10,
                                         bottom: 10, trailing: 10))
                } /* ForEach */
                .onDelete(perform: { offsets in
                    // remove all references to any stage ids for these itineraries first. offsets is the indexset
                    // keep record of ids to clean up lineHeights
                    var ids = [String]()
                    offsets.forEach { index in
                        (uuidStrStagesActiveStr,uuidStrStagesRunningStr,dictStageStartDates,dictStageEndDates) = itineraryStore.itineraries[index].removeAllStageIDsAndNotifcationsFrom(str1: uuidStrStagesActiveStr, str2: uuidStrStagesRunningStr, dict1: dictStageStartDates, dict2: dictStageEndDates)
                        ids.append(itineraryStore.itineraries[index].idStr)
                    }
                    // now its safe to delete those Itineraries
                    itineraryStore.removeItinerariesAtOffsets(offsets: offsets)
                    // now its safe to clean up lineHeights
                    ids.forEach { lineHeights[$0] = nil }
                    itineraryIDselected = nil
                })
            } /* List */
            .navigationDestination(for: String.self) { id in
                ItineraryActionCommonView(itinerary: itineraryStore.itineraryForID(id: id) ?? Itinerary.errorItinerary(), uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates, dictStageEndDates: $dictStageEndDates)
            }
            .modifier(ItineraryStoreViewNavTitleToolBar(showSettingsView: $showSettingsView, itineraryStore: itineraryStore, fileImporterShown: $fileImporterShown, fileImportFileType: $fileImportFileType, newItineraryEditableData: $newItineraryEditableData, isPresentingItineraryEditView: $isPresentingItineraryEditView, openRequestURL: $openRequestURL, isPresentingConfirmOpenURL: $isPresentingConfirmOpenURL))

        } /* NavStack */
    } /* body */

    
}
