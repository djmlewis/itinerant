//
//  SectionHeaderView.swift
//  itinerant
//
//  Created by David JM Lewis on 04/01/2023.
//

import SwiftUI

struct SectionHeaderView: View {
    var imageName: String
    var imageColour: Color = Color.accentColor
    var title: String
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(imageColour)
            Text(title)
            
        }
    }
}

struct SectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeaderView(imageName: "info.circle", title: "Stage Information")
    }
}
