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
          .padding([.top,.bottom], 2)
          .background(Color("ColourAdditionalAlarmsBackground"))
          .cornerRadius(6)

  }
}
