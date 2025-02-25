//
//  SignUpSheet.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 11.02.25.
//
import SwiftUI

struct SignUpSheet: View {
    @Environment(\.dismiss) var dismiss
    @State var registerViewModel: RegisterViewModel = RegisterViewModel()
    @FocusState var focus: RegisterViewModel.Field?
    
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
                        .tint(Theme.headline)
                    
                    HStack {
                        Text("User role")
                        Spacer()
                        Picker("User role", selection: $registerViewModel.userRole) {
                            ForEach(UserRole.registerRoles) { role in
                                Text(role.localized).tag(role)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.primary)
                    }
                    
                    if registerViewModel.userRole == .player {
                        HStack {
                            Text("Position")
                            Spacer()
                            Picker("Position", selection: $registerViewModel.position) {
                                ForEach(BasketballPosition.allCases) { position in
                                    Text(position.rawValue).tag(position)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.primary)
                        }
                    }
 
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
                .saveSize(in: $registerViewModel.containerSize)
                .blur(radius: registerViewModel.isLoadingAnimation ? 2.5 : 0)
                .animation(.easeInOut, value: registerViewModel.isLoadingAnimation)
                 
                LoadingCard(isLoading: $registerViewModel.isLoadingAnimation)
            }
            .errorAlert()
            .padding()
            .navigationTitle(title: "SignUp")
            .presentationDetents([.height(registerViewModel.containerSize.height + 100)])
            .presentationCornerRadius(20)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.primary)
                })
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button("SignUp") {
                        registerViewModel.signUp() 
                    }
                    .foregroundStyle(.primary)
                })
            }
            .fullScreenCover(
                isPresented: $registerViewModel.isOnboardingSheet,
                content: {
                    if let userProfile = registerViewModel.userProfile {
                        OnBoardingView(userProfile: userProfile)
                            .onDisappear {
                                Task {
                                    await registerViewModel.onDismissOnBoarding(userProfile: userProfile)
                                    dismiss()
                                }
                            }
                    }
                }
            )
        }
        .errorAlert()
        .presentationDragIndicator(.visible)
        .presentationBackground(Material.ultraThinMaterial)
        .shadow(radius: 20)
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
