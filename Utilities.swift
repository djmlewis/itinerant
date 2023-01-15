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

