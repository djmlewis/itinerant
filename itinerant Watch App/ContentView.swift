//
//  ContentView.swift
//  itinerant Watch App
//
//  Created by David JM Lewis on 30/12/2022.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var wkAppDelegate: WKAppDelegate
    
    
    
    var body: some View {
        VStack {
            Button("Phone Home") {
                wkAppDelegate.send("Hello there")
            }

        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello World")
    }
}
