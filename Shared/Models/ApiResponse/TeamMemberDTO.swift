//
//  TeamMemberDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation 

struct TeamMemberDTO: DTOProtocol {
    var id: UUID
    var userAccountId: UUID
    var teamId: UUID
    var shirtNumber: Int?
    var position: String
    var role: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), userAccountId: UUID, teamId: UUID, shirtNumber: Int?, position: String, role: String, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.userAccountId = userAccountId
        self.teamId = teamId
        self.shirtNumber = shirtNumber
        self.position = position
        self.role = role
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> TeamMember {
        return TeamMember(id: id, userAccountId: userAccountId, teamId: teamId, shirtNumber: shirtNumber, position: position, role: role, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}
// --> Get Account from userAccountId to get the UserId
/*
 -- 1. Trigger-Funktion erstellen
 CREATE OR REPLACE FUNCTION "LogTeamMemberCrud"()
 RETURNS TRIGGER AS $$
 BEGIN
     INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "userId")
     VALUES ('TeamMember', NOW(), COALESCE(NEW."userId", OLD."userId"))
     ON CONFLICT ("tableString", "userId")
     DO UPDATE SET "timestamp" = NOW();

     RETURN NULL;
 END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "LogTeamMemberCrudTrigger"
 AFTER INSERT OR DELETE OR UPDATE ON "TeamMember"
 FOR EACH ROW
 EXECUTE FUNCTION "LogTeamMemberCrud"();
 */
