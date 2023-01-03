//
//  StageActionView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI

struct StageActionView: View {
    
    @Binding var stage: Stage

    
    
    var body: some View {
        VStack {
            Text(stage.id.uuidString)
            Text(stage.title)
            Text("\(stage.durationSecsInt) secs")
        }
    }
}

struct StageActionView_Previews: PreviewProvider {
    static var previews: some View {
        StageActionView(stage: .constant(Stage.templateStage()))
    }
}
