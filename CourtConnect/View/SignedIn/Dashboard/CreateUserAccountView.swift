//
//  CreateUserAccountView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 23.01.25.
//
import SwiftUI 
 
struct CreateUserAccountView: View {
    @State private var createUserAccountViewModel: CreateUserAccountViewModel
    
    @Environment(\.dismiss) var dismiss
    
    init(userId: UUID) {
        self.createUserAccountViewModel = CreateUserAccountViewModel(repository: Repository.shared, userId: userId)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Picker("Kind", selection: $createUserAccountViewModel.role) {
                    ForEach(UserRole.registerRoles) { position in
                        Text(position.rawValue).tag(position)
                    }
                }
                .pickerStyle(.menu)
                .tint(.primary)
                .listRowSeparatorTint(.orange)

                if createUserAccountViewModel.role == .player {
                    Picker("Position", selection: $createUserAccountViewModel.position) {
                        ForEach(BasketballPosition.allCases) { position in
                            Text(position.rawValue).tag(position)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.primary)
                }
            }  
            .navigationTitle(title: "Create User Account")
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        Task {
                            do {
                                try await createUserAccountViewModel.insertAccount()
                                
                                dismiss()
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: {
                        dismiss()
                    })
                }
            }
        }
        .navigationStackTint()
        .presentationDetents([.height(300)])
    }
}
 
#Preview { 
    ZStack {
    }
    .sheet(isPresented: .constant(true)) {
        CreateUserAccountView(userId: MockUser.myUserAccount.userId)
        .shadow(radius: 5)
        .previewEnvirments()
    }
}
