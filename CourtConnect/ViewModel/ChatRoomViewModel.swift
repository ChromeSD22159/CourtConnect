//
//  ChatRoomViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 17.01.25.
//
import Foundation

@MainActor
@Observable
class ChatRoomViewModel: ObservableObject {
    private let supabase = BackendClient.shared
    let repository: Repository
    
    init(repository: Repository) {
        self.repository = repository
    }
    
    var inputText = ""
    
    func addMessage(senderID: String, recipientId: String) {
        guard !inputText.isEmpty else { return }
        self.messages.append(Chat(senderId: senderID, recipientId: recipientId, text: inputText, readedAt: nil))
        self.inputText = ""
    }

    var messages: [Chat] = []
}
