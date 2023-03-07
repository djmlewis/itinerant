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
        NavigationStack(path: $presentedItineraryIDsStackArray) {
            List {
                ForEach(itineraryStore.itineraryUUIDStrs, id:\.self) { itineraryID in
                    ItineraryStoreItineraryRowView(itineraryID: itineraryID, uuidStrStagesRunningStr: uuidStrStagesRunningStr)
                        .id(itineraryID)
                } /* ForEach */
                .onDelete(perform: { offsets in deleteItinerariesAtOffsets(offsets) })
            } /* List */
            .navigationDestination(for: String.self) { id in
                ItineraryActionCommonView(itinerary: itineraryStore.itineraryForID(id: id) ?? Itinerary.errorItinerary(), uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates, dictStageEndDates: $dictStageEndDates)
            }
            .modifier(ItineraryStoreViewNavTitleToolBar(showSettingsView: $showSettingsView, itineraryStore: itineraryStore, fileImporterShown: $fileImporterShown, fileImportFileType: $fileImportFileType, newItineraryEditableData: $newItineraryEditableData, isPresentingItineraryEditView: $isPresentingItineraryEditView, openRequestURL: $openRequestURL, isPresentingConfirmOpenURL: $isPresentingConfirmOpenURL))
        } /* NavStack */
    } /* body */

    
}
