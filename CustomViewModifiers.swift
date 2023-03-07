//
//  CustomViewModifiers.swift
//  itinerant
//
//  Created by David JM Lewis on 18/02/2023.
//

import SwiftUI
import UIKit


struct WKStageAlertslBackground: ViewModifier {
    
  func body(content: Content) -> some View {
    content
          .padding(6)
          .background(Color("ColourAdditionalAlarmsBackground"))
          .cornerRadius(6)

  }
}

struct TextInvalidDate: View {
    var date: Date
    
    var body: some View {
        
        Text("\(Image(systemName: "exclamationmark.triangle.fill")) Invalid Date")
            .foregroundColor(Color("ColourInvalidDate"))
            .opacity(date < validFutureDate() ? 1.0 : 0)
    }
    
    
}


/*
struct SizeMeasuringPreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        // this reduce function just supplies the nextValue as-is to replace the existing value which passes back inout
        // reduce could append a value instead, but should return a single value result
        value = nextValue()
    }
}

struct SizeMeasuringModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader { geometry in
            // Color in a background is a fill shape the size of the view. so this invisibly measures the view it is in from the INSIDE
            // GeometryReaders workd from OUTSIDE the MEASURED view using its PARENT view to propose a size (the parent views fullsize)
            // which the child reads and may then modify for its own view sizes
            // so we have to put the GR INSIDE the view to be measured and just accept its full size proposal which we then record in the preference
            // we accept its fullzize because Color is a fill size subview. So just record geometry.size as the newValue for the SizePreferenceKey
            // as the parent view to which this SizeMeasuringModifier is attached changes size it will update the SizePreferenceKey
            // us an onChange on any other view with access to the environment to detect the change and act accordingly
            // PreferenceKeys are auto-inserted into the environment
            // the preference(key:, value:) is called each time the view runs down the modifiers chain and just allows any value in scope to be applied to that preference which is held in the Environment
            Color.clear.preference(key: SizeMeasuringPreferenceKey.self, value: geometry.size)
        }
    }

    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}
*/

struct FileNameModDateTextView: View {
    var itineraryOptional: Itinerary?
    
    var itineraryActual: Itinerary { itineraryOptional ?? Itinerary.errorItinerary()}
    var filename: String { itineraryActual.filename ?? "---"}
    var modDateStr: String {
        Date(timeIntervalSinceReferenceDate: itineraryActual.modificationDate).formatted(date: .numeric, time: .shortened)
    }
    var body: some View {
        Text("\(Image(systemName: "doc")) \(filename)") +
        Text(" \(Image(systemName: "square.and.pencil")) \(modDateStr)")
    }
}

