//
//  ViewExtensions.swift
//  Dux
//
//  Created by Jake Heiser on 9/22/21.
//

import SwiftUI
import Combine

extension View {
    public func dux<Tags: DuxTags>(isActive: Bool, tags: Tags.Type, delegate: DuxDelegate? = nil) -> some View {
        GuidableView(isActive: isActive, tags: tags, delegate: delegate) {
            self
        }
    }

    public func duxTag<T: DuxTags>(_ tag: T) -> some View {
        anchorPreference(key: DuxTagPreferenceKey.self, value: .bounds, transform: { anchor in
            return [tag.key(): DuxTagInfo(anchor: anchor, callout: tag.makeCallout())]
        })
    }
    
    public func duxExtensionTag<T: DuxTags>(_ tag: T, edge: Edge, size: CGFloat = 100) -> some View {
        let width: CGFloat? = (edge == .leading || edge == .trailing) ? size : nil
        let height: CGFloat? = (edge == .top || edge == .bottom) ? size : nil
        
        let alignment: Alignment
        switch edge {
        case .top: alignment = .top
        case .leading: alignment = .leading
        case .trailing: alignment = .trailing
        case .bottom: alignment = .bottom
        }
        
        let overlayView = Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(width: width, height: height)
            .duxTag(tag)
            .padding(Edge.Set(edge), -size)
        
        return overlay(overlayView, alignment: alignment)
    }
    
    public func stopDux(_ dux: Dux, onLink navigationLink: Bool) -> some View {
        valueChanged(value: navigationLink) { shown in
            if shown {
                dux.stop()
            }
        }
    }
    
    public func stopDux<V: Hashable>(_ dux: Dux, onTag navigationTag: V, selection: V) -> some View {
        valueChanged(value: selection) { value in
            if navigationTag == value {
                dux.stop()
            }
        }
    }
    
    @ViewBuilder func valueChanged<T: Equatable>(value: T, onChange: @escaping (T) -> Void) -> some View {
        if #available(iOS 14.0, *) {
            self.onChange(of: value, perform: onChange)
        } else {
            self.onReceive(Just(value)) { (value) in
                onChange(value)
            }
        }
    }
}

extension UIColor {
    convenience init(hex: String) {
        let stringRepresentation = hex.replacingOccurrences(of: "#", with: "")

        guard let hexInt = Int(stringRepresentation, radix: 16) else {
            self.init(white: 0, alpha: 0)

            return
        }

        let red = CGFloat((hexInt >> 16) & 0xFF) / 255.0
        let green = CGFloat((hexInt >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hexInt & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

extension Color {
    static let cutoutBorder = Color(UIColor(hex: "#32FD9C"))
}
