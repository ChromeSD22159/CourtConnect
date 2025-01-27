//
//  ChatRoomViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 17.01.25.
//
import Observation
import Foundation

@Observable
@MainActor
class ChatRoomViewModel: ObservableObject {
    private let supabase = BackendClient.shared
    let repository: Repository
    
    var myUser: UserProfile
    
    var recipientUser: UserProfile
    
    var messages: [Chat] = []
    
    var inputText: String = ""
    
    init(repository: Repository, myUser: UserProfile, recipientUser: UserProfile) {
        self.repository = repository
        self.myUser = myUser
        self.recipientUser = recipientUser 
    }
    
    func addMessage(senderID: UUID, recipientId: UUID) {
        guard !inputText.isEmpty else { return }
        // let timestamp = SyncHistory(table: DatabaseTable.messages, userId: myUser.userId)
        let new = Chat(senderId: senderID.uuidString, recipientId: recipientId.uuidString, message: inputText, createdAt: Date(), updatedAt: Date(), readedAt: nil)
        Task {
            do {
                let lastSync = try lastSyncDate()
                try await self.repository.chatRepository.sendMessageToBackend(message: new, lastDate: lastSync, complete: { result in
                    switch result {
                    case .success(let messages):
                        self.messages = messages
                        self.resetInput()
                    case .failure: break
                    }
                })
                try self.repository.syncHistoryRepository.insertLastSyncTimestamp(for: .messages, userId: myUser.userId)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getAllMessages() {
        Task {
            
            let lastSync = try lastSyncDate()
             
            await repository.chatRepository.syncChatFromBackend(myUserId: myUser.userId.uuidString, recipientId: recipientUser.userId.uuidString, lastSync: lastSync) { result in
                switch result {
                case .success(let messages):
                    self.messages = messages
                    self.resetInput()
                case .failure: break
                }
            }
        }
    }
    
    func startReceiveMessages() {
        Task {
            repository.chatRepository.receiveMessages(myUserId: myUser.userId.uuidString, recipientId: recipientUser.userId.uuidString, complete: { result in
                switch result {
                case .success(let messages):
                    self.messages = messages
                    self.resetInput()
                case .failure: break
                }
            })
        }
    }
    
    func deleteAll() {
        messages.forEach {
            repository.chatRepository.delete(message: $0)
        }
        
        messages = []
    }
    
    private func resetInput() {
        self.inputText = ""
    }
    
    private func lastSyncDate() throws -> Date {
        return try repository.syncHistoryRepository.getLastSyncDate(for: .messages, userId: myUser.userId).timestamp
    }
}
