//
//  MessageListener.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 17.01.25.
//
import Supabase
import Foundation
import SwiftData
 
@MainActor
class ChatRepository {
    let type: RepositoryType
    let container: ModelContainer
    let backendClient = BackendClient.shared
     
    init(container: ModelContainer, type: RepositoryType) {
        self.type = type
        self.container = container
    }
    
    func getAllFromDatabase(myUserId: String, recipientId: String) throws -> [Chat] {
        let predicate = #Predicate<Chat> { chat in
            chat.senderId == myUserId && chat.recipientId == recipientId || chat.senderId == recipientId && chat.recipientId == myUserId
        }
        
        let sortBy = [SortDescriptor(\Chat.createdAt, order: .forward)]
        
        let fetchDescriptor = FetchDescriptor<Chat>(predicate: predicate, sortBy: sortBy)
        
        return try container.mainContext.fetch(fetchDescriptor)
    }
    
    func syncChatFromBackend(myUserId: String, recipientId: String, lastSync: Date ,complete: @escaping ([Chat]) -> Void) async {
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Passe das Format an
            let formattedLastSync = dateFormatter.string(from: lastSync)
            
            let response: [Chat] = try await backendClient.supabase.from("Messages")
               .select()
               .or("senderId.eq.\(myUserId), recipientId.eq.\(recipientId), createdAt.gt.\(formattedLastSync)")
               .gte("createdAt", value: formattedLastSync)
               .order("createdAt", ascending: true)
               .execute()
               .value 

            for chat in response {
                container.mainContext.insert(chat)
                try container.mainContext.save()
            }
            
            let all = try getAllFromDatabase(myUserId: myUserId, recipientId: recipientId)
            
            complete(all)
        } catch {
            print("Fehler beim Abrufen von Nachrichten:", error)
            complete([])
        }
    }
    
    func sendMessageToBackend(message: Chat, lastDate: Date, complete: @escaping ([Chat]) -> Void) async throws {
        guard type == .app else { return }
        
        do {
            if let data = message.encryptMessage() {
                try await backendClient.supabase.from(SupabaseTable.messages.rawValue).insert(data).execute()
                
                await syncChatFromBackend(myUserId: data.senderId, recipientId: data.recipientId, lastSync: lastDate) { chats in
                    complete(chats)
                }
            } else {
                // TODO: THROW CANNOT SEND
            }
        } catch {
            throw error
        }
    }
    
    func receiveMessages(myUserId: String, recipientId: String, complete: @escaping ([Chat]) -> Void) {
        let channel = backendClient.supabase.realtimeV2.channel("public:Messages")
         
        let inserts = channel.postgresChange(InsertAction.self, table: SupabaseTable.userOnline.rawValue)
        
        Task {
            await channel.subscribe()
            
            for await insertion in inserts {
                print("NEW MESSAGE")
                
                if let message = await handleInsertedAndDecode(insertion) {
                    container.mainContext.insert(message)
                    try container.mainContext.save()
                }
            }
            
            let all = try self.getAllFromDatabase(myUserId: myUserId, recipientId: recipientId)
            
            complete(all)
        }
    }
    
    private func handleInsertedAndDecode(_ action: HasRecord) async -> Chat? {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let decodedMessage = try action.decodeRecord(decoder: decoder) as Chat
            if let message = decodedMessage.decryptMessage() {
                return message
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    func delete(message: Chat) {
         container.mainContext.delete(message)
    }
} 
