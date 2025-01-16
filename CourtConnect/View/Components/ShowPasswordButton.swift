//
//  ShowPasswordButton.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
import SwiftUI

struct ShowPasswordButton: View {
    @Binding var showPassword: Bool
    var body: some View {
        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
            .onTapGesture {
                withAnimation {
                    showPassword.toggle()
                }
            }
    }
}
