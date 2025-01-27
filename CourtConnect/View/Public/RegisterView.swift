//
//  Register.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
import SwiftUI 

struct RegisterView: View {
    @State var viewModel: RegisterViewModel
    @State var errorHanler = ErrorHandlerViewModel.shared
    
    @ObservedObject var userViewModel: SharedUserViewModel
    @FocusState var focus: RegisterViewModel.Field?
    
    let navigate: (LoginNavigationView) -> Void
    
    init(
        @ObservedObject userViewModel: SharedUserViewModel,
        navigate: @escaping (LoginNavigationView) -> Void = {_ in }
    ) {
        self.viewModel = RegisterViewModel(repository: userViewModel.repository)
        self.userViewModel = userViewModel
        self.navigate = navigate
        self.focus = nil 
    }
    
    var body: some View {
        VStack(spacing: 15) {
            TitleText("Welcome!")
            BodyText("Welcome!")
            
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
                    SmallText("Firstname")
                    TextField("Firstname", text: $viewModel.firstName, prompt: Text("Enter your Firstname"))
                        .focused($focus, equals: .firstName)
                        .submitLabel(.next)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    SmallText("Lastname")
                    TextField("Lastname", text: $viewModel.lastName, prompt: Text("Enter your Lastname"))
                        .focused($focus, equals: .lastName)
                        .submitLabel(.next)
                        .textFieldStyle(.roundedBorder)
                }
                
                DatePicker("Your Birthday", selection: $viewModel.birthday, displayedComponents: .date)
                    .datePickerStyle(.compact)
                
                VStack(alignment: .leading, spacing: 5) {
                    SmallText("Password")
                    if viewModel.showPassword {
                        TextField("Password", text: $viewModel.password, prompt: Text("Enter your Password"))
                            .focused($focus, equals: .password)
                            .submitLabel(.done)
                            .textFieldStyle(.roundedBorder)
                            .overlay(alignment: .trailing) {
                                ShowPasswordButton(showPassword: $viewModel.showPassword)
                            }
                    } else {
                        SecureField("Password", text: $viewModel.password, prompt: Text("Enter your Password"))
                            .focused($focus, equals: .password)
                            .submitLabel(.done)
                            .textFieldStyle(.roundedBorder)
                            .overlay(alignment: .trailing) {
                                ShowPasswordButton(showPassword: $viewModel.showPassword)
                            }
                    }
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    SmallText("Repeat password")
                    if viewModel.showPassword {
                        TextField("Repeat password", text: $viewModel.repeatPassword, prompt: Text("Repeat your password"))
                            .focused($focus, equals: .repeatPassword)
                            .submitLabel(.done)
                            .textFieldStyle(.roundedBorder)
                            .overlay(alignment: .trailing) {
                                ShowPasswordButton(showPassword: $viewModel.showRepeatPassword)
                            }
                    } else {
                        SecureField("Repeat password", text: $viewModel.repeatPassword, prompt: Text("Repeat your password"))
                            .focused($focus, equals: .repeatPassword)
                            .submitLabel(.done)
                            .textFieldStyle(.roundedBorder)
                            .overlay(alignment: .trailing) {
                                ShowPasswordButton(showPassword: $viewModel.showRepeatPassword)
                            }
                    }
                }
            }
            
            BodyText("Forgot password")
                .onTapGesture {
                    self.navigate(.forget)
                }
            
            Button("Sign up") {
                Task {
                    do {
                        let (user, profile) = try await viewModel.signUp()
                        
                        if let user = user {
                            userViewModel.user = user
                        }
                        
                        userViewModel.userProfile = profile
                    } catch {
                        errorHanler.handleError(error: error)
                    }
                }
            }
            .foregroundStyle(Theme.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .background(Theme.darkOrange)
            .clipShape(.rect(cornerRadius: 10))
            
            HStack {
                BodyText("You have an account?")
                BodyText("Sign In here")
                    .foregroundStyle(Theme.darkOrange)
                    .onTapGesture {
                        self.navigate(.login)
                    }
            }
            .foregroundStyle(Theme.gray)
            
            Spacer()
        }
        .errorPopover()
        .padding()
        .onSubmit {
            viewModel.changeFocus()
        }
    }
}
 
#Preview {
    let repo = Repository(type: .preview)
    RegisterView(userViewModel: SharedUserViewModel(repository: repo))
}
