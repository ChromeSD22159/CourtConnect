//
//  DeletionRequests.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 25.01.25.
//
import Foundation

struct DeletionRequestDTO: DTOProtocol {
    var id: UUID
    var userId: UUID
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), userId: UUID, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> DeletionRequest {
        return DeletionRequest(id: id, userId: userId, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}

/*
 create trigger "DeletionRequestCrudTrigger"
 after insert or delete or update on "DeletionRequest" for each row
 execute function "LogDeletionRequestCrud" (); 
 -- OR --
 create trigger "DeletionRequestInsertTrigger"
 after insert on "DeletionRequest" for each row
 execute function "LogChatInsert"();
 
 create trigger "DeletionRequestUpdateTrigger"
 after update on "DeletionRequest" for each row
 execute function "LogChatInsert"();
 
 create trigger "DeletionRequestDeleteTrigger"
 after delete on "DeletionRequest" for each row
 execute function "LogChatInsert"();
 
 -- Function
 CREATE OR REPLACE FUNCTION "LogDeletionRequestInsert"()
 RETURNS TRIGGER AS $$
 BEGIN
     INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "userId")
     VALUES ('DeletionRequest', NOW(), NEW."userId");
     RETURN NEW;
 END;
 $$ LANGUAGE plpgsql;
 */
