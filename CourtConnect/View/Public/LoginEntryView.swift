//
//  LoginEntryView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 28.01.25.
//
import SwiftUI
import Auth

struct LoginEntryView: View {
    @State var viewModel = LoginEntryViewModel()
    
    let onUserChange: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                AppIcon()
                
                if viewModel.isTextShowing {
                    textRow()
                        .opacity(viewModel.isTextShowing ? 1 : 0)
                        .animation(.easeInOut.delay(0.5), value: viewModel.isTextShowing)
                    
                    buttonRow()
                        .opacity(viewModel.isTextShowing ? 1 : 0)
                        .animation(.easeInOut.delay(1.5), value: viewModel.isTextShowing)
                    
                    /*
                    resetPasswordRow()
                        .opacity(viewModel.isTextShowing ? 1 : 0)
                        .animation(.easeInOut.delay(1.8), value: viewModel.isTextShowing)
                     */
                }
            }
        }
        .contentMargins(.horizontal, 30)
        .contentMargins(.vertical, 100)
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appBackground()
        .onAppear {
            viewModel.toogleText()
            viewModel.inizializeAuth()
        }
        .sheet(isPresented: $viewModel.isSignInSheet, onDismiss: {
            DispatchQueue.main.async {
                viewModel.inizializeAuth()
                onUserChange()
            }
        }) {
            SignInSheet()
        }
        .sheet(isPresented: $viewModel.isSignUpSheet, onDismiss: {
            viewModel.inizializeAuth()
            onUserChange()
        }) {
            SignUpSheet()
        }
        .sheet(isPresented: $viewModel.isResetPassword) {
            ResetPasswordSheet()
        }
    }
    
    @ViewBuilder func buttonRow() -> some View {
        HStack {
            Button("SignIn") {
                viewModel.isSignInSheet.toggle()
            }
            .buttonStyle(DarkButtonStlye())
            
            Spacer()
            
            Button("SignUp") {
                viewModel.isSignUpSheet.toggle()
            }
            .buttonStyle(TransparentButtonStyle())
        }
    }
    
    @ViewBuilder func resetPasswordRow() -> some View {
        HStack {
            Spacer()
            
            Button("Reset Password") {
                viewModel.isResetPassword.toggle()
            }
            .font(.caption2)
            .buttonStyle(TransparentButtonStyle())
            
            Spacer()
        }
    }
    
    @ViewBuilder func textRow() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your Team. \nYour connection. \nYour success.")
                .font(.title.bold())
                .foregroundStyle(Theme.darkOrange)
                 
            Text("Ready for the jump? Let's start! Register to get started and become part of the community.") 
                .foregroundStyle(Theme.myGray)
                .lineSpacing(5)
        }
        .lineSpacing(5)
    }
}

struct ResetPasswordSheet: View {
    @Environment(\.dismiss) var dismiss
    @State var viewModel = ResetPasswordSheetViewModel()
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    TextField("E-Mail:", text: $viewModel.email, prompt: Text("Enter your E-Mail"))
                        .keyboardType(.emailAddress)
                        .padding()
                }
                .saveSize(in: $viewModel.containerSize)
                
                LoadingCard(isLoading: $viewModel.isLoadingAnimation)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.primary)
                })
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button("Request New Passwort") {
                        do {
                            try viewModel.sendRequest()
                            dismiss()
                        } catch {
                            
                        }
                    }
                    .foregroundStyle(.primary)
                })
            }
            .errorAlert()
            .saveSize(in: $viewModel.containerSize)
            .presentationDetents([.height(viewModel.containerSize.height + 100)])
            .presentationDragIndicator(.visible)
            .presentationBackground(Material.ultraThinMaterial)
            .shadow(radius: 20)
        }
    }
}

@Observable @MainActor class ResetPasswordSheetViewModel {
    let repository = Repository.shared
    var containerSize: CGSize = .zero
    var email = ""
    var isLoadingAnimation = false
    
    func sendRequest() throws {
        Task {
            isLoadingAnimation = true
            defer {
                isLoadingAnimation = false
            }
            do {
                guard !email.isEmpty else { throw UserError.emailIsEmptry }
                try await repository.authRepository.resetPasswordForEmail(email: email)
            } catch {
                ErrorHandlerViewModel.shared.handleError(error: error)
                throw error
            }
        }
    }
}
                   
#Preview("Light") {
    LoginEntryView(viewModel: LoginEntryViewModel(), onUserChange: {})
    .preferredColorScheme(.light)
    .previewEnvirments()
}

#Preview("Dark") {
    LoginEntryView(viewModel: LoginEntryViewModel(), onUserChange: {})
    .preferredColorScheme(.dark)
    .previewEnvirments()
}
