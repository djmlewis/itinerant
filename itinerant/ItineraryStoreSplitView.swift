//
//  ItineraryStoreSplitView.swift
//  itinerant
//
//  Created by David JM Lewis on 19/02/2023.
//

import SwiftUI

extension ItineraryStoreView {
    var body_split: some View {
        NavigationSplitView() {
            List(selection: $itineraryIDselected) {
                ForEach(itineraryStore.itineraryUUIDStrs, id:\.self) { itineraryID in
                    ItineraryStoreItineraryRowView(itineraryID: itineraryID, uuidStrStagesRunningStr: uuidStrStagesRunningStr)
                        .id(itineraryID)
                } /* ForEach */
                .onDelete(perform: { offsets in deleteItinerariesAtOffsets(offsets) })
            } /* List */
            .modifier(ItineraryStoreViewNavTitleToolBar(showSettingsView: $showSettingsView, itineraryStore: itineraryStore, fileImporterShown: $fileImporterShown, fileImportFileType: $fileImportFileType, newItineraryEditableData: $newItineraryEditableData, isPresentingItineraryEditView: $isPresentingItineraryEditView, openRequestURL: $openRequestURL, isPresentingConfirmOpenURL: $isPresentingConfirmOpenURL))
            
        } detail: {
            if let itineraryidselected = itineraryIDselected {
                if let itin = itineraryStore.itineraryForID(id: itineraryidselected) {
                    ItineraryActionCommonView(itinerary: itin, uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates, dictStageEndDates: $dictStageEndDates)
                        .id(itin.idStr)
                }
            }
        } /* detail */
        /* NavSplitView*/
    } /* body */
    
    
} /* ext */


