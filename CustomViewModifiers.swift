//
//  CustomViewModifiers.swift
//  itinerant
//
//  Created by David JM Lewis on 18/02/2023.
//

import SwiftUI
import UIKit

struct StageInvalidDurationSymbolBackground: ViewModifier {
    var stageDurationDateInvalid: Bool
    var stageTextColour: Color
    
  func body(content: Content) -> some View {
    content
          .foregroundColor(stageDurationDateInvalid ? Color.accentColor /*Color(red: 1.0, green: 0.149, blue: 0.0)*/ : stageTextColour)
          .padding(stageDurationDateInvalid ? 3 : 0)
          .background(stageDurationDateInvalid ? .gray : .clear)
          .cornerRadius(stageDurationDateInvalid ? 3 : 0)
          .padding(stageDurationDateInvalid ? 1 : 0)
          .background(stageDurationDateInvalid ? Color.accentColor : .clear)
          .cornerRadius(stageDurationDateInvalid ? 3 : 0)
          .padding(stageDurationDateInvalid ? 2 : 0)
          .background(.clear)

  }
}

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





