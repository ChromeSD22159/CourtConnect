//
//  Login.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
import SwiftUI 

struct LoginView: View {
    @State var viewModel: LoginViewModel
    @ObservedObject var userViewModel: SharedUserViewModel
    @FocusState var focus: LoginViewModel.Field?
    
    let navigate: (LoginNavigationView) -> Void
    
    init(
        @ObservedObject userViewModel: SharedUserViewModel,
        navigate: @escaping (LoginNavigationView) -> Void = {_ in }
    ) {
        self.viewModel = LoginViewModel(repository: userViewModel.repository)
        self.userViewModel = userViewModel
        self.navigate = navigate
        self.focus = nil 
    }
    
    var body: some View {
        VStack(spacing: 15) {
            TitleText("Welcome Back!")
            BodyText("Welcome Back!")
            
            TitleText("CourtConnect")
            Spacer()
            VStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 5) {
                    SmallText("E-Mail")
                    TextField("E-Mail", text: $viewModel.email, prompt: Text("Enter your E-Mail"))
                        .keyboardType(.emailAddress)
                        .focused($focus, equals: .email)
                        .submitLabel(.next)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    SmallText("Password")
                    if viewModel.showPassword {
                        TextField("Password", text: $viewModel.password, prompt: Text("Enter your Password"))
                            .keyboardType(.default)
                            .focused($focus, equals: .password)
                            .submitLabel(.done)
                            .textFieldStyle(.roundedBorder)
                            .overlay(alignment: .trailing) {
                                ShowPasswordButton(showPassword: $viewModel.showPassword)
                            }
                    } else {
                        SecureField("Password", text: $viewModel.password, prompt: Text("Enter your Password"))
                            .keyboardType(.default)
                            .focused($focus, equals: .password)
                            .submitLabel(.done)
                            .textFieldStyle(.roundedBorder)
                            .overlay(alignment: .trailing) {
                                ShowPasswordButton(showPassword: $viewModel.showPassword)
                            }
                    }
                    
                }
                
                Toggle(isOn: $viewModel.keepSignededIn) {
                    Text("Keep me signed in")
                }
                .tint(Theme.accentColor)
            }
            
            BodyText("Forgot password")
                .foregroundStyle(Theme.accentColor)
                .onTapGesture {
                    self.navigate(.forget)
                }
            
            HStack {
                Text("Sign in")
                    .foregroundStyle(Theme.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .background(Theme.accentColor)
            .clipShape(.rect(cornerRadius: 10))
            .onTapGesture {
                Task {
                    do {
                        let (user, userProfile) = try await viewModel.signIn()
                        
                        userViewModel.user = user
                        userViewModel.userProfile = userProfile
                    } catch {
                        
                    }
                }
            }
          
            HStack {
                BodyText("Don`t have an account?")
                BodyText("SignUp here")
                    .foregroundStyle(Theme.accentColor)
                    .onTapGesture {
                        self.navigate(.register)
                    }
            }
            .foregroundStyle(Theme.gray)
            
            Spacer()
        }
        .padding()
        .onSubmit {
            viewModel.changeFocus()
        }
    }
} 
 
#Preview {
    let repo = Repository(type: .preview)
    LoginView(userViewModel: SharedUserViewModel(repository: repo))
}
