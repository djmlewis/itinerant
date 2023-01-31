//
//  Utilities.swift
//  itinerant
//
//  Created by David JM Lewis on 02/01/2023.
//




import Foundation
import SwiftUI
import Combine

// MARK: Time formatting & second-min
let SEC_MIN = 60
let SEC_HOUR = 3600

func hmsToSecsInt(hours: Int, mins: Int, secs: Int) -> Int {
    return hours * SEC_HOUR + mins * SEC_MIN + secs
}

func hmsToSecsDouble(hours: Int, mins: Int, secs: Int) -> Double {
    return Double(hmsToSecsInt(hours: hours, mins: mins, secs: secs))
}


// MARK: enum
enum FieldFocusTag {
    case noneFocused
    case title
}

// MARK: Dictionary extension
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

// MARK: CancellingTimer
class CancellingTimer {
    var cancellor: AnyCancellable?
    
    func cancelTimer() {
        cancellor?.cancel()
    }
}

// MARK: Color extension
extension Color {
    var rgbaString: String? {
        guard let components = self.cgColor?.components, self.cgColor?.colorSpace?.model == .rgb else { return nil }
        return components.map({ String(format: "%f",$0) }).joined(separator:kColorStringSeparator)
    }
    
}


// MARK: String extension
extension String {
    
    var rgbaColor: Color? {
        let components = self.components(separatedBy: kColorStringSeparator).map({ Double($0) })
        // no nils allowed
        if components.first(where: { $0 == nil }) != nil { return nil }
        switch components.count {
        case 3:
            return Color(red: components[0]!, green: components[1]!, blue: components[2]!)
        case 4:
            return Color(red: components[0]!, green: components[1]!, blue: components[2]!, opacity: components[3]!)
        default:
            return nil
        }
    }

    var fileNameWithoutExtensionFromPath: String? {
        self.components(separatedBy: "/").last?.components(separatedBy: ".").first
    }
    
    var uniqueifiedDataFileNameWithoutExtension: String {
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

// MARK: Text modifiers
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

// MARK: View extension
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

