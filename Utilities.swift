//
//  Utilities.swift
//  itinerant
//
//  Created by David JM Lewis on 02/01/2023.
//




import Foundation
import SwiftUI

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

extension String {
    
    func fileNameWithoutExtensionFromPath() -> String? {
        self.components(separatedBy: "/").last?.components(separatedBy: ".").first
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

extension View {
    func subtitled(with text: String, stackAlignment: HorizontalAlignment, subtitleAlignment: TextAlignment) -> some View {
        modifier(TextSubtitle(text: text, stackAlignment: stackAlignment, subtitleAlignment: subtitleAlignment))
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
}


