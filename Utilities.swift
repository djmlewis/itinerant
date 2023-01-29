//
//  Utilities.swift
//  itinerant
//
//  Created by David JM Lewis on 02/01/2023.
//




import Foundation
import SwiftUI
import Combine

let SEC_MIN = 60
let SEC_HOUR = 3600

func hmsToSecsInt(hours: Int, mins: Int, secs: Int) -> Int {
    return hours * SEC_HOUR + mins * SEC_MIN + secs
}

func hmsToSecsDouble(hours: Int, mins: Int, secs: Int) -> Double {
    return Double(hmsToSecsInt(hours: hours, mins: mins, secs: secs))
}


enum FieldFocusTag {
    case noneFocused
    case title
}

extension Dictionary: RawRepresentable where Key == String, Value == String {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),  // convert from String to Data
            let result = try? JSONDecoder().decode([String:String].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),   // data is  Data type
              let result = String(data: data, encoding: .utf8) // coerce NSData to String
        else {
            return "{}"  // empty Dictionary resprenseted as String
        }
        return result
    }

}

class CancellingTimer {
    var cancellor: AnyCancellable?
    
    func cancelTimer() {
        cancellor?.cancel()
    }
}

extension String {
    
    func fileNameWithoutExtensionFromPath() -> String? {
        self.components(separatedBy: "/").last?.components(separatedBy: ".").first
    }
    
    func uniqueifiedDataFileNameWithoutExtension() -> String {
        if let files = try? FileManager.default.contentsOfDirectory(atPath: ItineraryStore.appDataFilesFolderPath()).filter({ $0.hasSuffix(kItineraryPerststentDataFileDotSuffix)}),
           files.count > 0 {
            let filenames = files.map { $0.components(separatedBy: ".").first }
            return self.uniqueifiedStringForArray(filenames)
        }
        return self
    }

    func uniqueifiedStringForArray(_ array:[String?]) -> String {
        if array.count > 0 {
            var index = 1
            var modifiedSelf = self
            while array.first(where: { $0 == modifiedSelf }) != nil {
                modifiedSelf = self + " \(index)"
                index += 1
            }
            return modifiedSelf
        }
        return self
    }
}

struct TextSubtitle: ViewModifier {
    var text: String
    var stackAlignment: HorizontalAlignment
    var subtitleAlignment: TextAlignment

    func body(content: Content) -> some View {
        VStack(alignment: stackAlignment) {
            content
            Text(text)
                .styleSubtitle(alignment: subtitleAlignment)
        }
    }
}

struct LabelSubtitle: ViewModifier {
    var text: String
    var iconName: String
    var stackAlignment: HorizontalAlignment
    var subtitleAlignment: TextAlignment

    func body(content: Content) -> some View {
        VStack(alignment: stackAlignment) {
            content
            Label(text, systemImage: iconName)
                .labelStyle(.titleAndIcon)
                .styleSubtitle(alignment: subtitleAlignment)
        }
    }
}


extension View {
    func subtitledText(with text: String, stackAlignment: HorizontalAlignment, subtitleAlignment: TextAlignment) -> some View {
        modifier(TextSubtitle(text: text, stackAlignment: stackAlignment, subtitleAlignment: subtitleAlignment))
    }
    func subtitledLabel(with text: String, iconName: String, stackAlignment: HorizontalAlignment, subtitleAlignment: TextAlignment) -> some View {
        modifier(LabelSubtitle(text: text, iconName: iconName, stackAlignment: stackAlignment, subtitleAlignment: subtitleAlignment))
    }

}

struct StyleSubtitle: ViewModifier {
    var alignment: TextAlignment
    func body(content: Content) -> some View {
        content
            .italic()
           .font(.subheadline)
            .foregroundColor(Color("ColourFontGrey"))
            .multilineTextAlignment(alignment)
    }
}

extension View {
    func styleSubtitle(alignment: TextAlignment) -> some View {
        modifier(StyleSubtitle(alignment: alignment))
    }
    func styleSubtitleLabel(alignment: TextAlignment) -> some View {
        modifier(StyleSubtitle(alignment: alignment))
            .labelStyle(.titleAndIcon)
    }
}


