//
//  LoginEntryView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 28.01.25.
//
import SwiftUI

struct LoginEntryView: View {
    @ObservedObject var userViewModel: SharedUserViewModel
    
    @State var isTextShowing = false
    @State var isSignInSheet = false
    @State var isSignUpSheet = false
    
    var body: some View {
        VStack(spacing: 50) {
            Image(.appBadgeEntryViewLight)
                .shadow(radius: 10)
            
            if isTextShowing {
                textRow()
                    .opacity(isTextShowing ? 1 : 0)
                    .animation(.easeInOut.delay(0.5), value: isTextShowing)
                
                buttonRow()
                    .opacity(isTextShowing ? 1 : 0)
                    .animation(.easeInOut.delay(1.5), value: isTextShowing)
            }
            
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
        .onAppear {
            withAnimation(.easeInOut.delay(2.0)) {
                isTextShowing.toggle()
            }
        }
        .sheet(isPresented: $isSignInSheet) {
            SignInSheet(isSignInSheet: $isSignInSheet, userViewModel: userViewModel, loginViewModel: LoginViewModel(repository: userViewModel.repository)) {
                
            }
        }
        .sheet(isPresented: $isSignUpSheet) {
            SignUpSheet(isSignUpSheet: $isSignUpSheet, userViewModel: userViewModel, registerViewModel: RegisterViewModel(repository: userViewModel.repository)) {
                
            }
        }
    }
    
    @ViewBuilder func buttonRow() -> some View {
        HStack {
            Button("SignIn") {
                isSignInSheet.toggle()
            }
            .buttonStyle(DarkButtonStlye())
            
            Spacer()
            
            Button("SignUp") {
                isSignUpSheet.toggle()
            }
            .buttonStyle(TransparentButtonStyle())
        }
    }
    
    @ViewBuilder func textRow() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your Team. \nYour connection. \nYour success.")
                .font(.title.bold())
                .foregroundStyle(Theme.darkOrange)
                 
            Text("Bereit für den Sprung? Lass uns starten! Melde dich an, um loszulegen und teil der Community zu werden.")
                .foregroundStyle(Theme.myGray)
                .lineSpacing(5)
        }
        .lineSpacing(5)
    }
} 
 
private struct SignInSheet: View {
    @Binding var isSignInSheet: Bool
    @ObservedObject var userViewModel: SharedUserViewModel
    @ObservedObject var loginViewModel: LoginViewModel
    
    @Environment(\.errorHandler) var errorHanler
    @State var isLoadingAnimation: Bool = false
    
    @FocusState var focus: LoginViewModel.Field?
    
    let navigate: () -> Void
    
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
                .blur(radius: isLoadingAnimation ? 2.5 : 0)
                .animation(.easeInOut, value: isLoadingAnimation)
                
                LoadingCard(isLoading: $isLoadingAnimation)
            }
            .padding()
            .navigationTitle("SignIn")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.medium])
            .presentationCornerRadius(20)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button("Cancel") {
                        isSignInSheet.toggle()
                    }
                    .foregroundStyle(.primary)
                })
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button("SignIn") {
                        isLoadingAnimation.toggle()
                         
                        Task {
                            do {
                                
                                try await Task.sleep(for: .seconds(1))
                                
                                let (user, userProfile) = try await loginViewModel.signIn()
                                
                                if let user = user {
                                    userViewModel.user = user
                                }
                                
                                userViewModel.userProfile = userProfile
                                
                                isLoadingAnimation.toggle()
                                
                                try await Task.sleep(for: .seconds(1))
                                
                                isSignInSheet.toggle()
                            } catch {
                                errorHanler.handleError(error: error)
                                isLoadingAnimation.toggle()
                            }
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

private struct SignUpSheet: View {
    @Binding var isSignUpSheet: Bool
    @ObservedObject var userViewModel: SharedUserViewModel
    @ObservedObject var registerViewModel: RegisterViewModel
    
    @Environment(\.errorHandler) var errorHanler
    @State var isLoadingAnimation = false
    @FocusState var focus: RegisterViewModel.Field?
    
    let navigate: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        SmallText("E-Mail")
                        TextField("E-Mail", text: $registerViewModel.email, prompt: Text("Enter your E-Mail"))
                            .keyboardType(.emailAddress)
                            .focused($focus, equals: .email)
                            .submitLabel(.next)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        SmallText("Firstname")
                        TextField("Firstname", text: $registerViewModel.firstName, prompt: Text("Enter your Firstname"))
                            .focused($focus, equals: .firstName)
                            .submitLabel(.next)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        SmallText("Lastname")
                        TextField("Lastname", text: $registerViewModel.lastName, prompt: Text("Enter your Lastname"))
                            .focused($focus, equals: .lastName)
                            .submitLabel(.next)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    DatePicker("Your Birthday", selection: $registerViewModel.birthday, displayedComponents: .date)
                        .datePickerStyle(.compact)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        SmallText("Password")
                        if registerViewModel.showPassword {
                            TextField("Password", text: $registerViewModel.password, prompt: Text("Enter your Password"))
                                .focused($focus, equals: .password)
                                .submitLabel(.done)
                                .textFieldStyle(.roundedBorder)
                                .overlay(alignment: .trailing) {
                                    ShowPasswordButton(showPassword: $registerViewModel.showPassword)
                                }
                        } else {
                            SecureField("Password", text: $registerViewModel.password, prompt: Text("Enter your Password"))
                                .focused($focus, equals: .password)
                                .submitLabel(.done)
                                .textFieldStyle(.roundedBorder)
                                .overlay(alignment: .trailing) {
                                    ShowPasswordButton(showPassword: $registerViewModel.showPassword)
                                }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        SmallText("Repeat password")
                        if registerViewModel.showPassword {
                            TextField("Repeat password", text: $registerViewModel.repeatPassword, prompt: Text("Repeat your password"))
                                .focused($focus, equals: .repeatPassword)
                                .submitLabel(.done)
                                .textFieldStyle(.roundedBorder)
                                .overlay(alignment: .trailing) {
                                    ShowPasswordButton(showPassword: $registerViewModel.showRepeatPassword)
                                }
                        } else {
                            SecureField("Repeat password", text: $registerViewModel.repeatPassword, prompt: Text("Repeat your password"))
                                .focused($focus, equals: .repeatPassword)
                                .submitLabel(.done)
                                .textFieldStyle(.roundedBorder)
                                .overlay(alignment: .trailing) {
                                    ShowPasswordButton(showPassword: $registerViewModel.showRepeatPassword)
                                }
                        }
                    }
                }
                .blur(radius: isLoadingAnimation ? 2.5 : 0)
                .animation(.easeInOut, value: isLoadingAnimation)
                 
                LoadingCard(isLoading: $isLoadingAnimation)
            }
            .padding()
            .navigationTitle("SignUp")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.height(500)])
            .presentationCornerRadius(20)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button("Cancel") {
                        isSignUpSheet.toggle()
                    }
                    .foregroundStyle(.primary)
                })
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button("SignUp") {
                        isLoadingAnimation.toggle()
                         
                        Task {
                            try await Task.sleep(for: .seconds(1))
                            
                            do {
                                let (user, profile) = try await registerViewModel.signUp()
                                
                                if let user = user {
                                    userViewModel.user = user
                                }
                                
                                userViewModel.userProfile = profile
                                
                                isLoadingAnimation.toggle()
                                
                                try await Task.sleep(for: .seconds(1))
                                
                                isSignUpSheet.toggle()
                            } catch {
                                errorHanler.handleError(error: error)
                                isLoadingAnimation.toggle()
                            }
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
    LoginEntryView(userViewModel: SharedUserViewModel(repository: RepositoryPreview.shared) )
        .preferredColorScheme(.light)
        .previewEnvirments()
}

#Preview("Dark") {
    LoginEntryView(userViewModel: SharedUserViewModel(repository: RepositoryPreview.shared) )
        .preferredColorScheme(.dark)
        .previewEnvirments()
}
