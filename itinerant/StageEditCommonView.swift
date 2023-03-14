//
//  StageRowEditView.swift
//  itinerant
//
//  Created by David JM Lewis on 04/01/2023.
//

import SwiftUI
import PhotosUI


struct StageEditCommonView: View {
    @Binding var stageEditableData: Stage
    // quickview
    @Binding var showRightColumn: Bool
    @Binding var collapseForMoving: Bool
    @Binding var newStageMeta: NewStageMeta?
    @Binding var stageUUIDToDelete: UUID?
    var itineraryEditableData: Itinerary.EditableData?
    
    @State var showConfirmDeleteStage: Bool =  false
    @State var untimedComment: Bool =  false
    @State var snoozeAlertsOn: Bool =  false
    
    @State var hours: Int = 0
    @State var mins: Int = 0
    @State var secs: Int = 0
    @State var timerDirection: TimerDirection = .countDownEnd
    @State var durationDate: Date = validFutureDate()

    @State var snoozehours: Int = 0
    @State var snoozemins: Int = 0

    @Environment(\.colorScheme) var colorScheme

    @State var additionaldurationsDictKeys = [Int]()
    @State var showingAddAlertSheet = false
    @State var addedhours: Int = 0
    @State var addedmins: Int = 0
    @State var addedsecs: Int = 0
    @State var addedMessage: String = ""

    @State var selectedItem: PhotosPickerItem? = nil
    @State var selectedImageData: Data? = nil
    @State var fullSizeUIImage: UIImage?
    @State var showFullSizeUIImage: Bool = false
    @State var showFullSizeUIImageAlert: Bool = false


    @ViewBuilder  var bodyForDevice: some View {
        if deviceIsIpadOrMac() {
            body_quick
        } else {
            body_slow
        }
    }

    
    var body: some View {

        bodyForDevice
        
    }
    
    
}

extension StageEditCommonView {
    
    
    func durationFromHMS() -> Int {
        Int(hours) * SEC_HOUR + Int(mins) * SEC_MIN + Int(secs)
    }
    func durationFromAdditionalHMS() -> Int {
        Int(addedhours) * SEC_HOUR + Int(addedmins) * SEC_MIN + Int(addedsecs)
    }

    func updateDuration() {
        switch stageEditableData.durationCountType {
        case .countDownEnd:
            stageEditableData.durationSecsInt = durationFromHMS()
        case .countDownToDate:
            stageEditableData.setDurationFromDate(durationDate)//durationSecsInt = Int(dateYMDHM(fromDate: durationDate).timeIntervalSinceReferenceDate)
        default:
            stageEditableData.durationSecsInt = 0
        }
    }
    
    func updateSnoozeDuration() {
        var newValue = Int(snoozehours) * SEC_HOUR + Int(snoozemins) * SEC_MIN
        if newValue < kSnoozeMinimumDurationSecs {
            newValue = kSnoozeMinimumDurationSecs
        }
        stageEditableData.snoozeDurationSecs = newValue
    }
    
    func rebuidAdditionalDurationsDictKeys() {
        additionaldurationsDictKeys = stageEditableData.additionalDurationsDict.map({ $0.key }).sorted()
    }
}


