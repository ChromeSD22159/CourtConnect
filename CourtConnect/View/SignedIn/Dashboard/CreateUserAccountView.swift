//
//  CreateUserAccountView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 23.01.25.
//
import SwiftUI

@Observable @MainActor class CreateUserAccountViewModel {
    var repository: BaseRepository
    var userId: UUID
    
    var role: UserRole = .player
    var position: BasketballPosition = .center
    var accounts: [UserAccount] = []
    
    init(repository: BaseRepository, userId: UUID) {
        self.repository = repository
        self.userId = userId
    }
    
    func insertAccount() async throws {
        let account = UserAccount(userId: userId, teamId: nil, position: position.rawValue, role: role.rawValue, displayName: role.rawValue, createdAt: Date(), updatedAt: Date())
        
        try repository.accountRepository.usert(item: account)
        
        self.getAllFromDatabase()
        
        try await sendToServer(account: account)
        
        LocalStorageService.shared.userAccountId = account.id.uuidString
    }
    
    func getAllFromDatabase() {
        do {
            self.accounts = try repository.accountRepository.getAllAccounts(userId: userId)
        } catch {
            print(error)
        }
    }
    
    func sendToServer(account: UserAccount) async throws {
        try await repository.accountRepository.sendToBackend(item: account)
    }
}
 
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
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Create User Account")
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
    @Previewable @State var userViewModel = SharedUserViewModel(repository: RepositoryPreview.shared)
    ZStack {
    }
    .sheet(isPresented: .constant(true)) {
        CreateUserAccountView(userId: MockUser.myUserAccount.userId)
        .shadow(radius: 5)
        .previewEnvirments()
    }
}
