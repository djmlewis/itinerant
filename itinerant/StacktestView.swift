//
//  StacktestView.swift
//  itinerant
//
//  Created by David JM Lewis on 18/01/2023.
//

import SwiftUI


struct Otinerary: Identifiable, Codable, Hashable {
    let id: UUID //Immutable property will not be decoded if it is declared with an initial value which cannot be overwritten
    var title: String
    var stages: [String]
    
    static func dummyOtinerary() -> Otinerary {
        return Otinerary(id: UUID(), title: "Title", stages: ["One","Two","Three"])
    }
    
    static func dummyOtineraryArray() -> [Otinerary] {
        return [Otinerary(id: UUID(), title: "Title", stages: ["One","Two","Three"]),
                Otinerary(id: UUID(), title: "Totle", stages: ["Ay","Bee","See"]),
                Otinerary(id: UUID(), title: "Tutle", stages: ["Monkey","Marney","Mo"]),
                Otinerary(id: UUID(), title: "Tatle", stages: ["Ib","Dib","Dubbin"])]
    }
}

var itinArray = [Itinerary(title: "one"), Itinerary(title: "two"), Itinerary(title: "three")]

struct StacktestView: View {
    @State private var presentedNumbers: [Itinerary] = [Itinerary(title: "two")]

    var body: some View {
        NavigationStack(path: $presentedNumbers) {
            List {
                ForEach(itinArray) { otin in
                    NavigationLink(value: otin) {
                        Label(otin.title, systemImage: "circle")
                    }
                }
            }
            .navigationDestination(for: Itinerary.self) { otin in
                Text(otin.title + otin.id.uuidString)
            }
            .navigationTitle("Navigation")
        }
    }
}

struct StacktestView_Previews: PreviewProvider {
    static var previews: some View {
        StacktestView()
    }
}
