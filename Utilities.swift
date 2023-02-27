//
//  Utilities.swift
//  itinerant
//
//  Created by David JM Lewis on 02/01/2023.
//

import SwiftUI
import Combine
import WatchConnectivity
#if os(iOS)
import UIKit.UIDevice
#endif

// MARK: Time formatting & second-min
let SEC_MIN = 60
let SEC_HOUR = 3600
let SEC_MIN_DBL = 60.0
let SEC_HOUR_DBL = 3600.0

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

// MARK: - Color extension
extension Color {
    var rgbaString: String? {
        guard let components = self.cgColor?.components, self.cgColor?.colorSpace?.model == .rgb else { return nil }
        return components.map({ String(format: "%f",$0) }).joined(separator:kColorStringSeparator)
    }
    
}

func textColourForScheme(colorScheme: ColorScheme) -> Color {
    #if os(iOS)
    Color(uiColor: UIColor.label) //colorScheme == .dark ? Color(uiColor: UIColor.lightText) : Color(uiColor: UIColor.darkText)
    #else
    colorScheme == .dark ? Color.white : Color.black
    #endif
}


// MARK: - String extension
extension String {
    
    var dateFromDouble: Date? {
        guard let double = Double(self) else { return nil }
        return Date(timeIntervalSinceReferenceDate: double)
    }
    
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


// MARK: - Watch Connectivity
func watchConnectionUnusableMessage() -> String? {
#if os(iOS)
    guard WCSession.default.isWatchAppInstalled else {
        //debugPrint("isCompanionAppInstalled false")
        return "No app installed on Watch"
    }
#endif
    guard WCSession.default.activationState == .activated else {
        //debugPrint("WCSession.activationState not activated", WCSession.default.activationState)
        return "No active session - force quit the app and restart"
    }

    // nil indicates usable
    return nil
}

func watchConnectionUnusable() ->  Bool {
    return watchConnectionUnusableMessage() != nil
}

// MARK: - Dates
func dateYMDHM(fromDate date: Date) -> Date {
    let calendar = Calendar.autoupdatingCurrent
    let components = calendar.dateComponents(
        kPickersDateComponents,
        from: date
    )
    let newdate = calendar.date(from: components) ?? Date()
    //debugPrint("dateYMDHM",date, "-->", newdate)
    return newdate
}

func validFutureDate() -> Date {
    Date().addingTimeInterval(kStageMinimumDurationForFutureDateDbl)
}

func getDaysInIndexedMonth(indexedMonth: Int, zeroIndexed: Bool, year: Int) -> Int? {
        let calendar = Calendar.autoupdatingCurrent
        let month = indexedMonth + (zeroIndexed ? 1 : 0)
        var startComps = DateComponents()
        startComps.day = 1
        startComps.month = month
        startComps.year = year

        var endComps = DateComponents()
        endComps.day = 1
        endComps.month = month == 12 ? 1 : month + 1
        endComps.year = month == 12 ? year + 1 : year

        
        let startDate = calendar.date(from: startComps)!
        let endDate = calendar.date(from:endComps)!

        
        let diff = calendar.dateComponents([Calendar.Component.day], from: startDate, to: endDate)

        return diff.day
    }

// MARK - iOS only
#if os(iOS)

func deviceIsIpadOrMac() -> Bool {
    let uidevice = UIDevice.current.userInterfaceIdiom
    if ProcessInfo().isiOSAppOnMac || uidevice == .pad || uidevice == .mac { return true }
    return false
}

func deviceIsMac() -> Bool {
    let uidevice = UIDevice.current.userInterfaceIdiom
    if ProcessInfo().isiOSAppOnMac || uidevice == .mac { return true }
    return false
}

#endif

