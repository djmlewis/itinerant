//
//  ItineraryStoreItineraryRowView.swift
//  itinerant
//
//  Created by David JM Lewis on 07/03/2023.
//

import SwiftUI

struct ItineraryStoreItineraryRowView: View {
    var itinerary: Itinerary
    //var itineraryID: String
    var uuidStrStagesRunningStr: String
    
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var itineraryStore: ItineraryStore
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage(kAppStorageColourStageRunning) var appStorageColourStageRunning: String = kAppStorageDefaultColourStageRunning
    @AppStorage(kAppStorageColourFontRunning) var appStorageColourFontRunning: String = kAppStorageDefaultColourFontRunning
    
    @State var lineHeight: CGFloat = 0.0
    
    var body: some View {
        let isRunning = itinerary.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr)
        let hasThumbnail = itinerary.imageDataThumbnailActual != nil
        NavigationLink(value: itinerary.idStr) {
            HStack(alignment: .center, spacing: 0) {
                if isRunning || hasThumbnail {
                    ZStack(alignment: .center) {
                        if let imagedata = itineraryStore.itineraryThumbnailForID(id: itinerary.idStr), let uiImage = UIImage(data: imagedata) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(maxWidth: kHaltButtonWidth, maxHeight: lineHeight)
                                .padding(0)
                        }
                        if isRunning {
                            buttonStartHalt(forItineraryID: itinerary.idStr)
                        }
                    }
              }
                VStack(alignment: .leading) {
                    Text(itineraryStore.itineraryTitleForID(id: itinerary.idStr))
                        .font(.system(.title, design: .rounded, weight: .semibold))
                        .multilineTextAlignment(.leading)
                    FileNameModDateTextView(itineraryOptional: itinerary)
                        .font(.system(.subheadline, design: .rounded, weight: .regular))
                        .lineLimit(1)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.8)
                        .opacity(0.6)
                }
                .padding(.leading,12)
                .background(GeometryReader { Color.clear.preference(key: TitleMeasuringPreferenceKey.self, value: $0.size) } )
                .onPreferenceChange(TitleMeasuringPreferenceKey.self) {
                    lineHeight = $0.height
                    debugPrint($0.width)
                }
            }
            //.id(itinerary.idStr)
            .padding(0)
        }
        .foregroundColor(textColourForItinerary(itinerary))
        .listRowBackground(backgroundColourForItinerary(itinerary))
        .listRowInsets(.init(top: 10,
                             leading: itinerary.isRunning(uuidStrStagesRunningStr: uuidStrStagesRunningStr) ? 2 : 10,
                             bottom: 10, trailing: 10))
    } /* body */
} /* struct */
    
    
    
extension ItineraryStoreItineraryRowView {
    
    func textColourForItinerary(_ itinerary: Itinerary) -> Color {
        return itineraryStore.textColourIfItineraryisRunning(itinerary: itinerary, uuidStrStagesRunningStr: uuidStrStagesRunningStr, appSettingsObject: appDelegate.settingsColoursObject) ?? (textColourForScheme(colorScheme: colorScheme))
    }
    func backgroundColourForItinerary(_ itinerary: Itinerary) -> Color {
        return itineraryStore.backgroundColourIfItineraryisRunning(itinerary: itinerary, uuidStrStagesRunningStr: uuidStrStagesRunningStr, appSettingsObject: appDelegate.settingsColoursObject) ?? Color.clear
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
                .background(Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.7))
                .foregroundColor(Color.red)
                .padding(3)
                .border(Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.7), width: 3)
                .clipShape(Circle())
                .padding(0)

        }
        .buttonStyle(BorderlessButtonStyle())
        .frame(width: kHaltButtonWidth, alignment: .leading)
        .padding(4)
    }

    struct TitleMeasuringPreferenceKey: PreferenceKey {
        typealias Value = CGSize
        static var defaultValue: Value = .zero
        static func reduce(value: inout Value, nextValue: () -> Value) { value = nextValue() }
    }

}

