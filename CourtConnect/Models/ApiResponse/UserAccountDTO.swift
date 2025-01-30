//
//  AccountDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 23.01.25.
//
import Foundation 

struct UserAccountDTO: DTOProtocol {
    var id: UUID // PK
    var userId: UUID
    var teamId: UUID?
    var position: String
    var role: String
    var displayName: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), userId: UUID, teamId: UUID?, position: String, role: String, displayName: String, createdAt: Date = Date(), updatedAt: Date = Date(), deletedAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.teamId = teamId
        self.position = position
        self.role = role
        self.displayName = displayName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> UserAccount {
        return UserAccount(id: id, userId: userId, teamId: teamId, position: position, role: role, displayName: displayName, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
} 

/*
 -- 1. Trigger-Funktion erstellen
 CREATE OR REPLACE FUNCTION "LogUserAccountCrud"()
 RETURNS TRIGGER AS $$
 BEGIN
     INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "userId")
     VALUES ('UserAccount', NOW(), COALESCE(NEW."userId", OLD."userId"))
     ON CONFLICT ("tableString", "userId")
     DO UPDATE SET "timestamp" = NOW();

     RETURN NULL;
 END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "LogUserAccountCrudTrigger"
 AFTER INSERT OR DELETE OR UPDATE ON "UserAccount"
 FOR EACH ROW
 EXECUTE FUNCTION "LogUserAccountCrud"();
 */
