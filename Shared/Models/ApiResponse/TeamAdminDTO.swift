//
//  TeamAdminDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation 

struct TeamAdminDTO: DTOProtocol {
    var id: UUID
    var teamId: UUID
    var userAccountId: UUID
    var role: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), teamId: UUID, userAccountId: UUID, role: String, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.teamId = teamId
        self.userAccountId = userAccountId
        self.role = role
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> TeamAdmin {
        return TeamAdmin(id: id, teamId: teamId, userAccountId: userAccountId, role: role, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
} 
// --> Get Account from userAccountId to get the UserId
/*
 -- 1. Trigger-Funktion erstellen
 CREATE OR REPLACE FUNCTION "LogTeamAdminCrud"()
 RETURNS TRIGGER AS $$
 BEGIN
     INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "userId")
     VALUES ('TeamAdmin', NOW(), COALESCE(NEW."userId", OLD."userId"))
     ON CONFLICT ("tableString", "userId")
     DO UPDATE SET "timestamp" = NOW();

     RETURN NULL;
 END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "LogTeamAdminCrudTrigger"
 AFTER INSERT OR DELETE OR UPDATE ON "TeamAdmin"
 FOR EACH ROW
 EXECUTE FUNCTION "LogTeamAdminCrud"();
 */
