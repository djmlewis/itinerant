//
//  CustomViewModifiers.swift
//  itinerant
//
//  Created by David JM Lewis on 18/02/2023.
//

import SwiftUI

struct AdditionalAlarmsFontBackgroundColour: ViewModifier {
  func body(content: Content) -> some View {
    content
          .foregroundColor(Color("ColourAdditionalAlarmsText"))
          .padding([.leading,.trailing], 6)
          .padding([.top,.bottom], 6)
          .background(Color("ColourAdditionalAlarmsBackground"))
          .cornerRadius(6)

  }
}

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
          .foregroundColor(.white)
          .padding(6)
          .background(.black)
          .opacity(0.6)
          .cornerRadius(6)

  }
}

