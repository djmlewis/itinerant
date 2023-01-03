//
//  StageRowView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI

struct StageRowView: View {
    
    @Binding var stage: Stage
    
    
    
    var body: some View {
        VStack {
            Text(stage.id.uuidString)
            Text(stage.title)
            Text("\(stage.durationSecsInt) secs")
        }
    }
}

struct StageRowView_Previews: PreviewProvider {
    static var previews: some View {
        StageRowView(stage: .constant(Stage.templateStage()))
    }
}
