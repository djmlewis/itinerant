//
//  StageRowView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI

struct StageActionView: View {
    
    @Binding var stage: Stage
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(stage.title)
                .font(.title3)
                .foregroundColor(.accentColor)
                .fontWeight(.bold)
            Text(Stage.stageDurationFormatter.string(from: Double(stage.durationSecsInt))!)
        }
    }
}

struct StageView_Previews: PreviewProvider {
    static var previews: some View {
        StageActionView(stage: .constant(Stage.templateStage()))
    }
}
