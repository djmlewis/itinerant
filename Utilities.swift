//
//  Utilities.swift
//  itinerant
//
//  Created by David JM Lewis on 02/01/2023.
//




import Foundation

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
