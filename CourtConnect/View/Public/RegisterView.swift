//
//  Register.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.01.25.
//
import SwiftUI
import Supabase

struct RegisterView: View {
    @State var vm: RegisterViewModel
    @ObservedObject var userViewModel: SharedUserViewModel
    @FocusState var focus: LoginViewModel.Field?
    
    let navigate: (LoginNavigationView) -> Void
    
    init(
        @ObservedObject userViewModel: SharedUserViewModel,
        navigate: @escaping (LoginNavigationView) -> Void = {_ in }
    ) {
        self.vm = RegisterViewModel(repository: userViewModel.repository)
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
                    TextField("E-Mail", text: $vm.email, prompt: Text("Enter your E-Mail"))
                        .keyboardType(.emailAddress)
                        .focused($focus, equals: .email)
                        .submitLabel(.next)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    SmallText("Firstname")
                    TextField("Firstname", text: $vm.firstName, prompt: Text("Enter your Firstname"))
                        .keyboardType(.emailAddress)
                        .focused($focus, equals: .email)
                        .submitLabel(.next)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    SmallText("Lastname")
                    TextField("Lastname", text: $vm.lastName, prompt: Text("Enter your Lastname"))
                        .keyboardType(.emailAddress)
                        .focused($focus, equals: .email)
                        .submitLabel(.next)
                        .textFieldStyle(.roundedBorder)
                }
                
                DatePicker("Your Birthday", selection: $vm.birthday, displayedComponents: .date)
                    .datePickerStyle(.compact)
                
                VStack(alignment: .leading, spacing: 5) {
                    SmallText("Which position?")
                    Picker("UserRole", selection: $vm.role) {
                        ForEach(UserRole.registerRoles) { role in
                            Text(role.rawValue).tag(role)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    SmallText("Password")
                    if vm.showPassword {
                        TextField("Password", text: $vm.password, prompt: Text("Enter your Password"))
                            .keyboardType(.default)
                            .focused($focus, equals: .password)
                            .submitLabel(.done)
                            .textFieldStyle(.roundedBorder)
                            .overlay(alignment: .trailing) {
                                ShowPasswordButton(showPassword: $vm.showPassword)
                            }
                    } else {
                        SecureField("Password", text: $vm.password, prompt: Text("Enter your Password"))
                            .keyboardType(.default)
                            .focused($focus, equals: .password)
                            .submitLabel(.done)
                            .textFieldStyle(.roundedBorder)
                            .overlay(alignment: .trailing) {
                                ShowPasswordButton(showPassword: $vm.showPassword)
                            }
                    }
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    SmallText("Repeat password")
                    if vm.showPassword {
                        TextField("Repeat password", text: $vm.repeatPassword, prompt: Text("Repeat your password"))
                            .keyboardType(.default)
                            .focused($focus, equals: .password)
                            .submitLabel(.done)
                            .textFieldStyle(.roundedBorder)
                            .overlay(alignment: .trailing) {
                                ShowPasswordButton(showPassword: $vm.showRepeatPassword)
                            }
                    } else {
                        SecureField("Repeat password", text: $vm.repeatPassword, prompt: Text("Repeat your password"))
                            .keyboardType(.default)
                            .focused($focus, equals: .password)
                            .submitLabel(.done)
                            .textFieldStyle(.roundedBorder)
                            .overlay(alignment: .trailing) {
                                ShowPasswordButton(showPassword: $vm.showRepeatPassword)
                            }
                    }
                }
            }
            
            BodyText("Forgot password")
                .onTapGesture {
                    self.navigate(.forget)
                }
            
            HStack {
                Text("Sign Up")
                    .foregroundStyle(Theme.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .background(Theme.accentColor)
            .clipShape(.rect(cornerRadius: 10))
            .onTapGesture {
                Task {
                    await vm.signUp() { (user: User?, profile: UserProfile?) in
                        userViewModel.user = user
                        userViewModel.userProfile = profile
                    }
                }
            }
           
            
            HStack {
                BodyText("You have an account?")
                BodyText("Sign In here")
                    .foregroundStyle(Theme.accentColor)
                    .onTapGesture {
                        self.navigate(.login)
                    }
            }
            .foregroundStyle(Theme.gray)
            
            Spacer()
        }
        .padding()
        .onSubmit {
            vm.changeFocus()
        }
    }
}
 
#Preview {
    let repo = Repository(type: .preview)
    RegisterView(userViewModel: SharedUserViewModel(repository: repo))
}
