//
//  FullScreenImageView.swift
//  itinerant
//
//  Created by David JM Lewis on 04/03/2023.
//

import SwiftUI

struct FullScreenImageView: View {
    @Binding var fullSizeUIImage: UIImage?
    @Binding var showFullSizeUIImage: Bool

#if os(watchOS)
    var body: some View {
        NavigationStack {
            if let validimage = fullSizeUIImage {
                Image(uiImage: validimage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .fixedSize(horizontal: true, vertical: true)
            }
        }
    }
#else
    var body: some View {
        NavigationStack {
            if let validimage = fullSizeUIImage {
                Image(uiImage: validimage)
                    .resizable()
                    .scaledToFit()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                fullSizeUIImage = nil
                                showFullSizeUIImage = false
                            }, label: {
                                Image(systemName:"xmark")
                            })
                        }
                    }
            }
        }
    }
#endif
}
