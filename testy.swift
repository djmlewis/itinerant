//
//  testy.swift
//  itinerant
//
//  Created by David JM Lewis on 09/03/2023.
//

    import SwiftUI

    struct SomePickerView: View {
        
        @State var colourBackground: Color = .clear
        @Environment(\.dismiss) var dismiss
        
        var body: some View {
            ColorPicker("", selection: $colourBackground)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") {
                            dismiss()
                        }
                    }
                }
        }
    }

    struct SomeParentView: View {
        @State var showSomePickerView: Bool = false
        
        var body: some View {
            Button("Pick a colour") {
                showSomePickerView = true
            }
            .sheet(isPresented: $showSomePickerView, content: {
                NavigationStack {
                    SomePickerView()
                }
            })
        }
    }
