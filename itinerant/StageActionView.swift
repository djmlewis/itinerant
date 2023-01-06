//
//  StageRowView.swift
//  itinerant
//
//  Created by David JM Lewis on 03/01/2023.
//

import SwiftUI

struct StageActionView: View {
    
    @Binding var stage: Stage
    @Binding var stageUuidEnabled: String
    var inEditingMode: Bool
    
    @State private var stageIsRunning = false
    
    var body: some View {
        HStack(alignment: .center) {
            if !inEditingMode {
                Button(action: {
                    stageIsRunning = !stageIsRunning
                }) {
                    Image(systemName: stageIsRunning == false ? "play.circle.fill" : "stop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(stageIsRunning == false ? .accentColor : .red)
                }
                .buttonStyle(BorderlessButtonStyle())
                .frame(width: 52, alignment: .leading)
                .disabled(stage.id.uuidString != stageUuidEnabled)
            }
            VStack(alignment: .leading) {
                Text(stage.title)
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .fontWeight(.bold)
                Text(Stage.stageDurationFormatter.string(from: Double(stage.durationSecsInt))!)
            }
        }
    }
}

struct StageView_Previews: PreviewProvider {
    static var previews: some View {
        StageActionView(stage: .constant(Stage.templateStage()), stageUuidEnabled: .constant(UUID().uuidString), inEditingMode: false)
    }
}
