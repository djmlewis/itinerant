//
//  ItineraryStoreItineraryRowView.swift
//  itinerant
//
//  Created by David JM Lewis on 07/03/2023.
//

import SwiftUI

struct ItineraryStoreItineraryRowView: View {
    var itineraryID: String
    var uuidStrStagesRunningStr: String
    
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var itineraryStore: ItineraryStore
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage(kAppStorageColourStageRunning) var appStorageColourStageRunning: String = kAppStorageDefaultColourStageRunning
    @AppStorage(kAppStorageColourFontRunning) var appStorageColourFontRunning: String = kAppStorageDefaultColourFontRunning
    
    @State var lineHeight: CGFloat = 0.0
    
    var body: some View {
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
                                .frame(maxWidth: kImageColumnWidthThird, maxHeight: lineHeight)
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
                .background(GeometryReader { Color.clear.preference(key: TitleMeasuringPreferenceKey.self, value: $0.size) } )
                .onPreferenceChange(TitleMeasuringPreferenceKey.self) { lineHeight = $0.height }
            }
            //.id(itineraryID)
            .padding(0)
        }
        .foregroundColor(textColourForID(itineraryID))
        .listRowBackground(backgroundColourForID(itineraryID))
        .listRowInsets(.init(top: 10,
                             leading: (itineraryOptional?.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ?? false) ? 2 : 10,
                             bottom: 10, trailing: 10))
    } /* body */
} /* struct */
    
    
    
extension ItineraryStoreItineraryRowView {
    
    func textColourForID(_ itineraryID: String) -> Color {
        return itineraryStore.textColourIfItineraryForIDisRunning(id: itineraryID, uuidStrStagesRunningStr: uuidStrStagesRunningStr, appSettingsObject: appDelegate.settingsColoursObject) ?? (textColourForScheme(colorScheme: colorScheme))
    }
    func backgroundColourForID(_ itineraryID: String) -> Color {
        return itineraryStore.backgroundColourIfItineraryForIDisRunning(id: itineraryID, uuidStrStagesRunningStr: uuidStrStagesRunningStr, appSettingsObject: appDelegate.settingsColoursObject) ?? Color.clear
    }

    
    func buttonStartHalt(forItineraryID itineraryID: String) -> some View {
        Button(action: {
            // Only Stop
            if let itinerary = itineraryStore.itineraryForID(id: itineraryID),
                let stageRunning = itinerary.stageRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) {
                appDelegate.unnItineraryToOpenID = nil
                appDelegate.unnStageToHaltID = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    appDelegate.unnItineraryToOpenID = itinerary.idStr
                    appDelegate.unnStageToHaltID = stageRunning.idStr
                }
            }
        })
        {
            Image(systemName: "stop.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color.red)
                .background(.white)
                .padding(3)
                .border(.white, width: 3)
                .clipShape(Circle())
                .padding(0)

        }
        .buttonStyle(BorderlessButtonStyle())
        .frame(width: 46, alignment: .leading)
        .padding(4)
    }

    struct TitleMeasuringPreferenceKey: PreferenceKey {
        typealias Value = CGSize
        static var defaultValue: Value = .zero
        static func reduce(value: inout Value, nextValue: () -> Value) { value = nextValue() }
    }

}

