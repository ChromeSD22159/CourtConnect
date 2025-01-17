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
class ChatRepository: DatabaseProtocol {
    let type: RepositoryType
    let container: ModelContainer
    var context: ModelContext { container.mainContext }
    let backendClient = BackendClient.shared
     
    init(type: RepositoryType) {
        self.type = type
         
        let schema = Schema([
            Chat.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: type == .preview ? true : false )
        
        do {
            self.container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create User DataBase Container: \(error)")
        }
    }
    
    func getAllFromDatabase(senderId: String, recipientId: String) throws -> [Chat] {
        let predicate = #Predicate<Chat> { chat in
            chat.senderId == senderId && chat.recipientId == recipientId
        }
        
        let sortBy = [SortDescriptor(\Chat.createdAt, order: .reverse)]
        
        let fetchDescriptor = FetchDescriptor<Chat>(predicate: predicate, sortBy: sortBy)
        
        return try context.fetch(fetchDescriptor)
    }
    
    func syncChatFromBackend(senderId: String, recipientId: String, afterTimeStamp: Date? = nil, complete: @escaping ([Chat]) -> Void) async {
        
        let cal = Calendar.current
        let defaultStartDate = cal.date(byAdding: .year, value: -10, to: Date())!
        
        do {
            let response: [Chat] = try await backendClient.supabase.from("Messages")
               .select("*")
               //.eq("senderId", value: senderId)
               //.eq("recipientId", value: recipientId)
               //.greaterThan("timestamp", value: DateUtil.convertDateToString(date: timeStamp ?? defaultStartDate))
               .or("senderId.eq.\(senderId), recipientId.eq.\(recipientId)") // OR-Bedingung
               .greaterThan("createdAt", value: DateUtil.convertDateToString(date: afterTimeStamp ?? defaultStartDate)) // Zeitstempelvergleich
               .order("createdAt", ascending: true) // Sortiere nach createdAt
               .execute()
               .value

            for chat in response {
                context.insert(chat)
            }
            
            let all = try getAllFromDatabase(senderId: senderId, recipientId: recipientId)
            
            complete(all)
        } catch {
            print("Fehler beim Abrufen von Nachrichten:", error)
            complete([])
        }
    }
    
    func sendMessageToBackend(senderId: String, recipientId: String, text: String, complete: @escaping ([Chat]) -> Void) async throws {
        do {
            let data = Chat(senderId: senderId, recipientId: recipientId, text: text, readedAt: nil).encryptMessage()
            try await backendClient.supabase.from(SupabaseTable.messages.rawValue).insert(data).execute()
            
            await syncChatFromBackend(senderId: senderId, recipientId: recipientId) { chats in
                complete(chats)
            }
        } catch {
            throw error
        }
    }
    
    func receiveMessages(senderId: String, recipientId: String, complete: @escaping ([Chat]) -> Void) {
        let channel = backendClient.supabase.realtimeV2.channel("public:Messages")
        let insertions = channel.postgresChange(InsertAction.self, table: "Messages")
        
        Task {
            await channel.subscribe()
            
            for await insertion in insertions {
                if let message = await handleInsertedAndDecode(insertion) {
                    context.insert(message)
                }
            }
            
            let all = try self.getAllFromDatabase(senderId: senderId, recipientId: recipientId)
            
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
}


