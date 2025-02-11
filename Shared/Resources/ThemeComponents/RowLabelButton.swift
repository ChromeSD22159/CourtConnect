//
//  RowLabelButton.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 04.02.25.
//
import SwiftUI

struct RowLabelButton: View {
    let text: LocalizedStringKey
    let systemImage: String
    let color: Color?
    let material: Material?
    let onComplete: () -> Void
    
    init(text: LocalizedStringKey, systemImage: String, material: Material? = Material.ultraThinMaterial, onComplete: @escaping () -> Void) {
        self.text = text
        self.systemImage = systemImage
        self.color = nil
        self.material = material
        self.onComplete = onComplete
    }
    
    var body: some View {
        if let color = color {
            HStack {
                Label(text, systemImage: systemImage)
                Spacer()
            }
            .onTapGesture {
                onComplete()
            }
            .padding()
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        if let material = material {
            HStack {
                Label(text, systemImage: systemImage)
                Spacer()
            }
            .onTapGesture {
                onComplete()
            }
            .padding()
            .background(material)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        
    }
}

extension RowLabelButton {
    init(text: LocalizedStringKey, systemImage: String, color: Color? = Theme.lightOrange, onComplete: @escaping () -> Void) {
        self.text = text
        self.systemImage = systemImage
        self.color = color
        self.material = nil
        self.onComplete = onComplete
    }
}

#Preview {
    RowLabelButton(text: "Label", systemImage: "trash", material: .ultraThinMaterial) {}
}
