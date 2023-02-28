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
                    HStack(spacing: 0) {
                        if (itineraryStore.itineraryForID(id: itineraryID)?.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ?? false) {
                            buttonStartHalt(forItineraryID: itineraryID)
                        }
                        VStack(alignment: .leading, spacing: 5.0) {
                            Text(itineraryStore.itineraryTitleForID(id: itineraryID))
                                .font(.system(.title, design: .rounded, weight: .semibold))
                                .multilineTextAlignment(.leading)
                            HStack(alignment: .center) {
                                Image(systemName: "doc")
                                Text(itineraryStore.itineraryFileNameForID(id: itineraryID))
                                if let date = itineraryStore.itineraryModificationDateForID(id: itineraryID) {
                                    Image(systemName:"square.and.pencil")
                                    Text(date.formatted(date: .numeric, time: .shortened))
                                }
                                Spacer()
                            }
                            .font(.system(.subheadline, design: .rounded, weight: .regular))
                            .lineLimit(1)
                            .allowsTightening(true)
                            .minimumScaleFactor(0.5)
                            .opacity(0.6)
                        }
                        .padding(0)
                    } /* HStack */
                    .id(itineraryID)
                    .padding(0)
                    .listRowInsets(.init(top: 10,
                                         leading: (itineraryStore.itineraryForID(id: itineraryID)?.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ?? false) ? 2 : 10,
                                         bottom: 10, trailing: 10))
                } /* ForEach */
                .onDelete(perform: { offsets in
                    // remove all references to any stage ids for these itineraries first. offsets is the indexset
                    offsets.forEach { index in
                        (uuidStrStagesActiveStr,uuidStrStagesRunningStr,dictStageStartDates,dictStageEndDates) = itineraryStore.itineraries[index].removeAllStageIDsAndNotifcationsFrom(str1: uuidStrStagesActiveStr, str2: uuidStrStagesRunningStr, dict1: dictStageStartDates, dict2: dictStageEndDates)
                    }
                    // now its safe to delete those Itineraries
                    itineraryStore.removeItinerariesAtOffsets(offsets: offsets)
                    itineraryIDselected = nil
                })
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


