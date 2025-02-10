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
    let container: ModelContainer
    let backendClient = BackendClient.shared
     
    init(container: ModelContainer) {
        self.container = container
    }
    
    func upsertLocal(message: Chat) throws {
        container.mainContext.insert(message)
        try container.mainContext.save()
    }
    
    func getAllMessagesLocal(myUserId: UUID, recipientId: UUID) throws -> [Chat] {
        let predicate = #Predicate<Chat> { chat in
            chat.senderId == myUserId && chat.recipientId == recipientId || chat.senderId == recipientId && chat.recipientId == myUserId
        }
        
        let sortBy = [SortDescriptor(\Chat.createdAt, order: .forward)]
        
        let fetchDescriptor = FetchDescriptor<Chat>(predicate: predicate, sortBy: sortBy)
        
        return try container.mainContext.fetch(fetchDescriptor)
    }
  
    func sendMessageToBackend(message: Chat) async throws {
        do {
            let _: Bool = try await SupabaseService.insert(item: message.toDTO(), table: .chat) 
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func receiveMessageAndInsertLocal(myUserId: UUID, recipientId: UUID, complete: @escaping () -> Void) {
        let channel = backendClient.supabase.realtimeV2.channel("public:Messages")
         
        let inserts = channel.postgresChange(InsertAction.self, table: DatabaseTable.chat.rawValue)
        
        Task {
            await channel.subscribe()
            
            for await insertion in inserts {
                do {
                    
                    if let message: ChatDTO = decodeDTO(from: insertion) {
                        container.mainContext.insert(message.toModel())
                        try container.mainContext.save()
                        complete()
                    } else {
                        complete()
                    } 
                } catch {
                    complete()
                }
            }
        }
    }
    
    func delete(message: Chat) {
         container.mainContext.delete(message)
    }
    
    func decodeDTO<T: Codable>(from insertion: InsertAction) -> T? {
        let decoder = JSONDecoder()
        
        let iso8601Formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX", // Mit Mikrosekunden
            "yyyy-MM-dd'T'HH:mm:ssXXXXX"         // Ohne Mikrosekunden
        ]
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        decoder.dateDecodingStrategy = .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            for format in iso8601Formats {
                formatter.dateFormat = format
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateString)")
        }
        
        do {
            return try insertion.decodeRecord(as: T.self, decoder: decoder)
        } catch {
            print("Decoding error: \(error)")
            return nil
        }
    }
}

enum ChatError: Error, LocalizedError {
    case whileSendindToServer
    
    var errorDescription: String? {
        switch self {
        case .whileSendindToServer: return "whileSendindToServer"
        }
    }
}
