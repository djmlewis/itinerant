//
//  ItineraryStoreViewNavTitleToolBar.swift
//  itinerant
//
//  Created by David JM Lewis on 19/02/2023.
//

import SwiftUI
import UniformTypeIdentifiers.UTType
import UIKit.UIDevice


extension ItineraryStoreView {
    
    struct ItineraryStoreViewNavTitleToolBar: ViewModifier {
        @Binding var showSettingsView: Bool
        var itineraryStore: ItineraryStore
        @Binding var fileImporterShown: Bool
        @Binding var fileImportFileType: [UTType]
        @Binding var newItineraryEditableData: Itinerary.EditableData
        @Binding var isPresentingItineraryEditView: Bool
        @Binding var openRequestURL: URL?
        @Binding var isPresentingConfirmOpenURL: Bool

        @EnvironmentObject var appDelegate: AppDelegate
        
        let uidevice = UIDevice.current.userInterfaceIdiom

        func body(content: Content) -> some View {
            content
                .navigationTitle("Itineraries")
                .toolbar {
                    if ProcessInfo().isiOSAppOnMac || uidevice == .mac {
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
                .confirmationDialog("File Open Request", isPresented: $isPresentingConfirmOpenURL, titleVisibility: .visible) {
                    Button("Open") {
                        if let validurl = openRequestURL {
                            switch validurl.pathExtension {
                            case ItineraryFileExtension.dataFile.rawValue:
                                _ = appDelegate.itineraryStore.loadItinerary(atPath: validurl.path(percentEncoded: false), externalLocation: false)
                                openRequestURL = nil
                            case ItineraryFileExtension.textFile.rawValue:
                                appDelegate.itineraryStore.importItinerary(atPath: validurl.path(percentEncoded: false))
                                openRequestURL = nil
                            case ItineraryFileExtension.settingsFile.rawValue:
                                openRequestURL = validurl
                                // setting view will nil it
                                showSettingsView = true
                            default:
                                openRequestURL = nil
                                break
                            }
                            // do not nil openRequestURL here as its needed when settings opens
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        openRequestURL = nil
                    }
                } message: {
                    let filename = openRequestURL?.lastPathComponent ?? "this file"
                    Text("Do you want to open \(filename) ?")
                        .font(.body)
                }
                .confirmationDialog(
                    "Invalid File\(appDelegate.fileDeletePathArray != nil && appDelegate.fileDeletePathArray!.count > 1 ? "s" : "")",
                    isPresented: $appDelegate.fileDeleteDialogShow,
                    titleVisibility: .visible) {
                        Button("Delete File\(appDelegate.fileDeletePathArray != nil && appDelegate.fileDeletePathArray!.count > 1 ? "s" : "")", role: .destructive) {
                            appDelegate.fileDeletePathArray?.forEach({ fileDeletePath in
                                do {
                                    try FileManager.default.removeItem(atPath: fileDeletePath)
                                    debugPrint("Removed: \(fileDeletePath)")
                                } catch let error {
                                    debugPrint("Remove failure for: \(fileDeletePath)", error.localizedDescription)
                                }
                            })
                        }
                    } message: {
                        if let filesString = appDelegate.fileDeletePathArray?.compactMap({ path in (path as NSString).lastPathComponent }).joined(separator: ", ") {
                            Text("File\(appDelegate.fileDeletePathArray != nil && appDelegate.fileDeletePathArray!.count > 1 ? "s" : "") “\(filesString)” \(appDelegate.fileDeletePathArray != nil && appDelegate.fileDeletePathArray!.count > 1 ? "are" : "is") invalid.\nDeletion cannot be undone.")
                        } else {
                            Text("Deleting *Unknown files* cannot be undone.")
                        }
                    }
            
        }
    }
    
}
