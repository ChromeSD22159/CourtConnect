//
//  ConfirmButton.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 02.02.25.
//
import SwiftUI

struct ConfirmButton: View {
    @State private var isClicked = false
    let confirmButtonDialog: ConfirmButtonDialog
    let action: () -> Void
    var body: some View {
        Button(confirmButtonDialog.buttonText) {
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
