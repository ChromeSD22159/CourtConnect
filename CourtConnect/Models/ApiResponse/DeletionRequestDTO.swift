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
 -- 1. Trigger-Funktion erstellen
 CREATE OR REPLACE FUNCTION "LogDeletionRequestCrud"()
 RETURNS TRIGGER AS $$
 BEGIN
     INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "userId")
     VALUES ('DeletionRequest', NOW(), COALESCE(NEW."userId", OLD."userId"))
     ON CONFLICT ("tableString", "userId")
     DO UPDATE SET "timestamp" = NOW();

     RETURN NULL;
 END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "DeletionRequestCrudTrigger"
 AFTER INSERT OR DELETE OR UPDATE ON "DeletionRequest"
 FOR EACH ROW
 EXECUTE FUNCTION "LogDeletionRequestCrud"();
 */
