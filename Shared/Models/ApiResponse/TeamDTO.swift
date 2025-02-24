//
//  TeamDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation

struct TeamDTO: DTOProtocol {
    var id: UUID
    var teamImageURL: String?
    var teamName: String
    var headcoach: String
    var joinCode: String
    var email: String
    var coachHourlyRate: Double?
    var addStatisticConfirmedOnly: Bool?
    var createdByUserAccountId: UUID
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(
        id: UUID = UUID(),
        teamImageURL: String?,
        teamName: String,
        headcoach: String,
        joinCode: String,
        email: String,
        coachHourlyRate: Double?,
        addStatisticConfirmedOnly: Bool?,
        createdByUserAccountId: UUID,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.teamImageURL = teamImageURL
        self.teamName = teamName
        self.headcoach = headcoach
        self.joinCode = joinCode
        self.email = email
        self.coachHourlyRate = coachHourlyRate
        self.addStatisticConfirmedOnly = addStatisticConfirmedOnly
        self.createdByUserAccountId = createdByUserAccountId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> Team { 
        return Team(id: id, teamImageURL: teamImageURL, teamName: teamName, headcoach: headcoach, joinCode: joinCode, email: email, coachHourlyRate: coachHourlyRate, addStatisticConfirmedOnly: addStatisticConfirmedOnly, createdByUserAccountId: createdByUserAccountId, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}

/*
 -- 1. Trigger-Funktion erstellen
 CREATE OR REPLACE FUNCTION "LogTeamCrud"()
 RETURNS TRIGGER AS $$
 BEGIN
     INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "userId")
     VALUES ('Team', NOW(), COALESCE(NEW."userId", OLD."userId"))
     ON CONFLICT ("tableString", "userId")
     DO UPDATE SET "timestamp" = NOW();

     RETURN NULL;
 END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "LogTeamCrudTrigger"
 AFTER INSERT OR DELETE OR UPDATE ON "Team"
 FOR EACH ROW
 EXECUTE FUNCTION "LogTeamCrud"();
 */ 
