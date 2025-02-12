//
//  SignInSheet.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.02.25.
//
import SwiftUI

struct SignInSheet: View {
    @Environment(\.dismiss) var dismiss
    @State var loginViewModel = LoginViewModel()
    @FocusState var focus: LoginViewModel.Field?
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        SmallText("E-Mail")
                        TextField("E-Mail", text: $loginViewModel.email, prompt: Text("Enter your E-Mail"))
                            .keyboardType(.emailAddress)
                            .focused($focus, equals: .email)
                            .submitLabel(.next)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        SmallText("Password")
                        if loginViewModel.showPassword {
                            TextField("Password", text: $loginViewModel.password, prompt: Text("Enter your Password"))
                                .focused($focus, equals: .password)
                                .submitLabel(.done)
                                .textFieldStyle(.roundedBorder)
                                .overlay(alignment: .trailing) {
                                    ShowPasswordButton(showPassword: $loginViewModel.showPassword)
                                }
                        } else {
                            SecureField("Password", text: $loginViewModel.password, prompt: Text("Enter your Password"))
                                .keyboardType(.default)
                                .focused($focus, equals: .password)
                                .submitLabel(.done)
                                .textFieldStyle(.roundedBorder)
                                .overlay(alignment: .trailing) {
                                    ShowPasswordButton(showPassword: $loginViewModel.showPassword)
                                }
                        }
                    }
                    
                    Toggle(isOn: $loginViewModel.keepSignededIn) {
                        Text("Keep me signed in")
                    }
                    .tint(Theme.darkOrange)
                }
                .saveSize(in: $loginViewModel.containerSize)
                .blur(radius: loginViewModel.isLoadingAnimation ? 2.5 : 0)
                .animation(.easeInOut, value: loginViewModel.isLoadingAnimation)
                
                LoadingCard(isLoading: $loginViewModel.isLoadingAnimation)
            }
            .errorAlert()
            .padding()
            .navigationTitle(title: "SignIn")
            .presentationDetents([.height(loginViewModel.containerSize.height + 100)])
            .presentationCornerRadius(20)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.primary)
                })
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button("SignIn") {
                        Task {
                            await loginViewModel.signIn()
                            dismiss()
                        }
                    }
                    .foregroundStyle(.primary)
                })
            }
        }
        .errorAlert()
        .presentationDragIndicator(.visible)
        .presentationBackground(Material.ultraThinMaterial)
        .shadow(radius: 20)
    }
}

#Preview("Light") {
    AppBackground {
        LoginEntryView(viewModel: LoginEntryViewModel(), onUserChange: {})
            .preferredColorScheme(.light)
            .previewEnvirments()
    }
}

#Preview("Dark") {
    AppBackground {
        LoginEntryView(viewModel: LoginEntryViewModel(), onUserChange: {})
            .preferredColorScheme(.dark)
            .previewEnvirments()
    }
}


