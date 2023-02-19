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
    
    struct ItineraryStoreViewNavTitleToolBar: ViewModifier {
        var editButton: Bool
        @Binding var showSettingsView: Bool
        var itineraryStore: ItineraryStore
        @Binding var fileImporterShown: Bool
        @Binding var fileImportFileType: [UTType]
        @Binding var newItineraryEditableData: Itinerary.EditableData
        @Binding var isPresentingItineraryEditView: Bool

        @EnvironmentObject var appDelegate: AppDelegate

        func body(content: Content) -> some View {
            content
                .navigationTitle("Itineraries")
                .toolbar {
                    if editButton == true {
                        ToolbarItem(placement: .navigationBarLeading) {
                            EditButton()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(action: {
                                showSettingsView = true
                            }) {
                                Label("Settings…", systemImage: "gear")
                            }
                            Divider()
                            Button(action: {
                                fileImportFileType = [.itineraryDataFile]
                                fileImporterShown = true
                            }) {
                                Label("Open…", systemImage: "doc")
                            }
                            Button(action: {
                                fileImportFileType = [.itineraryTextFile]
                                fileImporterShown = true
                            }) {
                                Label("Import…", systemImage: "doc.plaintext")
                            }
                            Divider()
                            Button(action: {
                                let filesToDeleteArray = itineraryStore.reloadItineraries()
                                if !filesToDeleteArray.isEmpty {
                                    appDelegate.fileDeletePathArray = filesToDeleteArray
                                    appDelegate.fileDeleteDialogShow = true
                                }
                            }) {
                                Label("Refresh…", systemImage: "arrow.counterclockwise.circle.fill")
                            }
                        } label: {
                            Label("", systemImage: "ellipsis.circle")
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            newItineraryEditableData = Itinerary.EditableData()
                            isPresentingItineraryEditView = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }

        }
    }

    var body_stack: some View {
        NavigationStack(path: $presentedItineraryID) {
            List {
                ForEach(itineraryStore.itineraryUUIDStrs, id:\.self) { itineraryID in
                    let itineraryActual = itineraryStore.itineraryForID(id: itineraryID)
                    NavigationLink(value: itineraryID) {
                        HStack(spacing: 0) {
                            if (itineraryActual?.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ?? false) {
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
                        }
                        .id(itineraryID)
                        .padding(0)
                    }
                    .foregroundColor(textColourForID(itineraryID))
                    .listRowBackground(backgroundColourForID(itineraryID))
                    .listRowInsets(.init(top: 10,
                                         leading: (itineraryActual?.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ?? false) ? 2 : 10,
                                         bottom: 10, trailing: 10))
                } /* ForEach */
                .onDelete(perform: { offsets in
                    // remove all references to any stage ids for these itineraries first. offsets is the indexset
                    offsets.forEach { index in
                        (uuidStrStagesActiveStr,uuidStrStagesRunningStr,dictStageStartDates,dictStageEndDates) = itineraryStore.itineraries[index].removeAllStageIDsAndNotifcationsFrom(str1: uuidStrStagesActiveStr, str2: uuidStrStagesRunningStr, dict1: dictStageStartDates, dict2: dictStageEndDates)
                    }
                    // now its safe to delete those Itineraries
                    itineraryStore.removeItinerariesAtOffsets(offsets: offsets)
                })
            } /* List */
            .navigationDestination(for: String.self) { id in
                ItineraryActionCommonView(itinerary: itineraryStore.itineraryForID(id: id) ?? Itinerary.errorItinerary(), uuidStrStagesActiveStr: $uuidStrStagesActiveStr, uuidStrStagesRunningStr: $uuidStrStagesRunningStr, dictStageStartDates: $dictStageStartDates, dictStageEndDates: $dictStageEndDates)
            }
            .modifier(ItineraryStoreViewNavTitleToolBar(editButton: false, showSettingsView: $showSettingsView, itineraryStore: itineraryStore, fileImporterShown: $fileImporterShown, fileImportFileType: $fileImportFileType, newItineraryEditableData: $newItineraryEditableData, isPresentingItineraryEditView: $isPresentingItineraryEditView))

        } /* NavStack */
    } /* body */

    
}
