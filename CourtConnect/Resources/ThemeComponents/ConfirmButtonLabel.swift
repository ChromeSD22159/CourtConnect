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
    let action: () -> Void
    var body: some View {
        RowLabelButton(text: confirmButtonDialog.buttonText, systemImage: confirmButtonDialog.systemImage ?? "person") {
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

#Preview {
    let dialog = ConfirmButtonDialog(
        systemImage: "trash",
        buttonText: "Delete Player Account",
        question: "Delete your Account",
        message: "Are you sure you want to delete your account? This action cannot be undone.",
        action: "Delete",
        cancel: "Cancel"
    )
    
    ConfirmButtonLabel(confirmButtonDialog: dialog) { }
}
