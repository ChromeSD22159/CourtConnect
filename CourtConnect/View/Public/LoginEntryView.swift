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
        VStack(spacing: 50) {
            Image(.appBadgeEntryViewLight)
                .shadow(radius: 10)
            
            if viewModel.isTextShowing {
                textRow()
                    .opacity(viewModel.isTextShowing ? 1 : 0)
                    .animation(.easeInOut.delay(0.5), value: viewModel.isTextShowing)
                
                buttonRow()
                    .opacity(viewModel.isTextShowing ? 1 : 0)
                    .animation(.easeInOut.delay(1.5), value: viewModel.isTextShowing)
            }
            
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
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
