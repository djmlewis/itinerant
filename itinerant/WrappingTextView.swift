//
//  WrappingTextView.swift
//  itinerant
//
//  Created by David JM Lewis on 10/03/2023.
//

import SwiftUI
import UIKit


struct UITextViewWrapper: UIViewRepresentable {
    typealias UIViewType = UITextView

    @State var text: String
    @Binding var calculatedHeight: CGFloat
    @Binding var fontColor: Color // MUST be a binding to be dynamic
    @Binding var imageMeasuredSize: CGSize
    
    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
        let uiView = UITextView()
        let systemFont = UIFont.preferredFont(forTextStyle: .body)
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            uiView.font = UIFont(descriptor: descriptor, size: systemFont.pointSize)
        } else { uiView.font = systemFont }

        uiView.isEditable = false
        uiView.isSelectable = false
        uiView.isUserInteractionEnabled = false
        uiView.isScrollEnabled = false
        uiView.backgroundColor = UIColor.clear
        uiView.textAlignment = NSTextAlignment.justified
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        uiView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        uiView.textColor = UIColor(fontColor)
//        if imageMeasuredSize != .zero {
//            uiView.textContainer.exclusionPaths = [UIBezierPath(rect: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: imageMeasuredSize.width, height: imageMeasuredSize.height - 12 )))]
//        }
        return uiView
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
        if uiView.text != self.text { uiView.text = self.text }
        uiView.textColor = UIColor(fontColor)
        if imageMeasuredSize != .zero {
            uiView.textContainer.exclusionPaths = [UIBezierPath(rect: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: imageMeasuredSize.width, height: imageMeasuredSize.height - 12.0 )))]
        } else {
            uiView.textContainer.exclusionPaths = []
        }
        UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
    }

    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = newSize.height // !! must be called asynchronously
            }
        }
    }

}

