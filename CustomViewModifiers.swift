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





