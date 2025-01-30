//
//  ErrorAlert.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 30.01.25.
//
import SwiftUI

struct ErrorAlert: ViewModifier {
    @Environment(\.errorHandler) var errorHandler
    func body(content: Content) -> some View {
        content.alert(isPresented: .constant(errorHandler.error != nil)) {
            Alert(title: Text("Error"), message: Text(errorHandler.error?.localizedDescription ?? ""), dismissButton: .default(Text("OK")))
        }
    }
}

extension View {
    func errorAlert() -> some View {
        modifier(ErrorAlert())
    }
}
