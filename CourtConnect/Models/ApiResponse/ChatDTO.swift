//
//  ChatDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 22.01.25.
//
import Foundation 
 
class ChatDTO: DTOProtocol {
    var id: UUID
    var senderId: UUID
    var recipientId: UUID
    var message: String
    var readedAt: Date?
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID, senderId: UUID, recipientId: UUID, message: String, readedAt: Date? = nil, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.senderId = senderId
        self.recipientId = recipientId
        self.message = message
        self.readedAt = readedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> Chat {
        Chat(id: id, senderId: senderId, recipientId: recipientId, message: message, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}

/*
 -- 1. Trigger-Funktion erstellen
 CREATE OR REPLACE FUNCTION "LogChatCrud"()
 RETURNS TRIGGER AS $$
 BEGIN
     INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "userId")
     VALUES ('Chat', NOW(), COALESCE(NEW."userId", OLD."userId"))
     ON CONFLICT ("tableString", "userId")
     DO UPDATE SET "timestamp" = NOW();

     RETURN NULL;
 END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "LogChatCrudTrigger"
 AFTER INSERT OR DELETE OR UPDATE ON "Chat"
 FOR EACH ROW
 EXECUTE FUNCTION "LogChatCrud"();
 */
