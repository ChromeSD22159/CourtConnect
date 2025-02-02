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

struct RowLabelButton: View {
    let text: LocalizedStringKey
    let systemImage: String
    let onComplete: () -> Void
    var body: some View {
        HStack {
            Label(text, systemImage: systemImage)
            Spacer()
        }
        .onTapGesture {
            onComplete()
        }
        .padding()
        .background(Material.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.horizontal)
    }
}
