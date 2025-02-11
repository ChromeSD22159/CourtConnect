//
//  ChatRoomViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 17.01.25.
//
import Observation
import Foundation
import SwiftUICore
 
@MainActor
@Observable class ChatRoomViewModel: ObservableObject {
    private let supabase = BackendClient.shared
    let repository: BaseRepository
    
    var myUser: UserProfile
    
    var recipientUser: UserProfile
    
    var messages: [Chat] = []
    
    var inputText: String = ""
    
    var scrollPosition = ScrollPosition()
    
    init(repository: BaseRepository, myUser: UserProfile, recipientUser: UserProfile) {
        self.repository = repository
        self.myUser = myUser
        self.recipientUser = recipientUser 
    }
    
    func addMessage(senderID: UUID, recipientId: UUID) {
        guard !inputText.isEmpty else { return } 
        let new = Chat(senderId: senderID, recipientId: recipientId, message: inputText, createdAt: Date(), updatedAt: Date(), readedAt: nil)
        Task {
            do {
                try self.repository.chatRepository.upsertLocal(message: new)
                try self.repository.syncHistoryRepository.insertLastSyncTimestamp(for: .chat, userId: myUser.userId)
                 
                try await self.repository.chatRepository.sendMessageToBackend(message: new)
                
                self.getAllLocalMessages()
                
                inputText = ""
            } catch {
                print("asdasd \(error.localizedDescription)")
            }
        }
    }
    
    func getAllLocalMessages() {
        do {
            messages = try self.repository.chatRepository.getAllMessagesLocal(myUserId: myUser.userId, recipientId: recipientUser.userId)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func startReceiveMessages() {
        Task {
            repository.chatRepository.receiveMessageAndInsertLocal(myUserId: myUser.userId, recipientId: recipientUser.userId) {
                Task {
                    do {
                        try self.repository.syncHistoryRepository.insertLastSyncTimestamp(for: .chat, userId: self.myUser.userId)
                        self.getAllLocalMessages()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
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
        return try repository.syncHistoryRepository.getLastSyncDate(for: .chat, userId: myUser.userId).timestamp
    }  
}
