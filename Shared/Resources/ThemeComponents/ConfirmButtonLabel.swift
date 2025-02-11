//
//  ConfirmButtonLabel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 04.02.25.
//
import SwiftUI

struct ConfirmButtonLabel: View {
    @State private var isClicked = false
    let confirmButtonDialog: ConfirmButtonDialog
    let color: Color?
    let material: Material?
    let action: () -> Void
    var body: some View {
        if let color = color {
            RowLabelButton(text: confirmButtonDialog.buttonText, systemImage: confirmButtonDialog.systemImage ?? "person", color: color) {
                isClicked.toggle()
            }
            .confirmationDialog(confirmButtonDialog.question, isPresented: $isClicked) {
                Button(confirmButtonDialog.action, role: .destructive) { action() }
                Button(confirmButtonDialog.cancel, role: .cancel) { isClicked.toggle() }
            } message: {
                Text(confirmButtonDialog.message)
            }
        }
        
        if let material = material {
            RowLabelButton(text: confirmButtonDialog.buttonText, systemImage: confirmButtonDialog.systemImage ?? "person", material: material) {
                isClicked.toggle()
            }
            .confirmationDialog(confirmButtonDialog.question, isPresented: $isClicked) {
                Button(confirmButtonDialog.action, role: .destructive) { action() }
                Button(confirmButtonDialog.cancel, role: .cancel) { isClicked.toggle() }
            } message: {
                Text(confirmButtonDialog.message)
            }
        }
        
    }
}

extension ConfirmButtonLabel {
    init(isClicked: Bool = false, confirmButtonDialog: ConfirmButtonDialog, color: Color?, action: @escaping () -> Void) {
        self.isClicked = isClicked
        self.confirmButtonDialog = confirmButtonDialog
        self.color = color
        self.material = nil
        self.action = action
    }
    
    init(isClicked: Bool = false, confirmButtonDialog: ConfirmButtonDialog, material: Material?, action: @escaping () -> Void) {
        self.isClicked = isClicked
        self.confirmButtonDialog = confirmButtonDialog
        self.color = nil
        self.material = material
        self.action = action
    }
}

#Preview {
    let dialog = ConfirmButtonDialog(
        systemImage: "trash",
        buttonText: "Delete Player Account",
        question: "Delete your Account",
        message: "Are you sure you want to delete your account? This action cannot be undone.",
        action: "Delete",
        cancel: "Cancel"
    )
    
    ConfirmButtonLabel(confirmButtonDialog: dialog, material: .ultraThinMaterial) { }
}
