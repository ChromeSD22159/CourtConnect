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
        .sheet(isPresented: $isSignInSheet, content: {
            SignInSheet(isSignInSheet: $isSignInSheet, userViewModel: userViewModel)
        })
        .sheet(isPresented: $isSignUpSheet, content: {
            SignUpSheet(isSignUpSheet: $isSignUpSheet, userViewModel: userViewModel)
        })
    }
    
    @ViewBuilder func buttonRow() -> some View {
        HStack {
            Button("SignIn") {
                isSignInSheet.toggle()
            }
            .padding()
            .font(.body.bold())
            .foregroundStyle(.white)
            .background(Theme.darkOrange)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            Spacer()
            
            Button("SignUp") {
                isSignUpSheet.toggle()
            }
            .font(.body.bold())
            .padding()
            .foregroundStyle(Theme.myGray)
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
    
    @State var viewModel: LoginViewModel
    @State var errorHanler = ErrorHandlerViewModel.shared
    @State var isLoadingAnimation = false
    
    @FocusState var focus: LoginViewModel.Field?
    
    private let navigate: () -> Void
    
    init(
        isSignInSheet: Binding<Bool>,
        @ObservedObject userViewModel: SharedUserViewModel,
        navigate: @escaping () -> Void = { }
    ) {
        self._isSignInSheet = isSignInSheet
        self.viewModel = LoginViewModel(repository: userViewModel.repository)
        self.userViewModel = userViewModel
        self.navigate = navigate
        self.focus = nil
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
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
                    .tint(Theme.darkOrange)
                }
                .blur(radius: isLoadingAnimation ? 2.5 : 0)
                .animation(.easeInOut, value: isLoadingAnimation)
                
                LoadingCard()
                    .opacity( isLoadingAnimation ? 1 : 0)
                    .animation(.easeInOut, value: isLoadingAnimation)
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
                                
                                let (user, userProfile) = try await viewModel.signIn()
                                
                                if let user = user {
                                    userViewModel.user = user
                                }
                                
                                userViewModel.userProfile = userProfile
                                
                                isLoadingAnimation.toggle()
                                
                                try await Task.sleep(for: .seconds(1))
                                
                                isSignInSheet.toggle()
                            } catch {
                                errorHanler.handleError(error: error)
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                })
            }
        }
        .presentationDragIndicator(.visible)
        .presentationBackground(Material.ultraThinMaterial)
        .shadow(radius: 20)
    }
}

private struct SignUpSheet: View {
    @Binding var isSignUpSheet: Bool
    @ObservedObject var userViewModel: SharedUserViewModel
    
    @State var viewModel: RegisterViewModel
    @State var errorHanler = ErrorHandlerViewModel.shared
    @State var isLoadingAnimation = false
    
    @FocusState var focus: RegisterViewModel.Field?
    
    private let navigate: () -> Void
    
    init(
        isSignUpSheet: Binding<Bool>,
        @ObservedObject userViewModel: SharedUserViewModel,
        navigate: @escaping () -> Void = { }
    ) {
        self._isSignUpSheet = isSignUpSheet
        self.viewModel = RegisterViewModel(repository: userViewModel.repository)
        self.userViewModel = userViewModel
        self.navigate = navigate
        self.focus = nil
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
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
                .blur(radius: isLoadingAnimation ? 2.5 : 0)
                .animation(.easeInOut, value: isLoadingAnimation)
                
                LoadingCard()
                    .opacity( isLoadingAnimation ? 1 : 0)
                    .animation(.easeInOut, value: isLoadingAnimation)
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
                                let (user, profile) = try await viewModel.signUp()
                                
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
        .presentationDragIndicator(.visible)
        .presentationBackground(Material.ultraThinMaterial)
        .shadow(radius: 20)
    }
}

#Preview("Light") {
    LoginEntryView(userViewModel: SharedUserViewModel(repository: Repository(type: .preview)) )
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    LoginEntryView(userViewModel: SharedUserViewModel(repository: Repository(type: .preview)) )
        .preferredColorScheme(.dark)
}
