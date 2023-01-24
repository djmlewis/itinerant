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

//struct iCloudStore {
//    public var containerUrl: URL! {
//        return fileManager.url(forUbiquityContainerIdentifier: nil)!
//    }
//
//    public var documents: URL! {
//        return containerUrl.appendingPathComponent("Documents", isDirectory: true)
//    }
//
//    private let fileManager: FileManager = FileManager.default
//
//    func store(url: URL) {
//      // move ulr into the documents folder as a file
// let fileID = "\(UUID().uuidString)" //extension etc
//        let icloudFile = documents.appendingPathComponent(fileID, isDirectory: false)
//        do {
//            try fileManager.copyItem(at: url, to: icloudFile)
//        } catch let error {
//            debugPrint(error.localizedDescription)
//        }
//
//    }
//}
