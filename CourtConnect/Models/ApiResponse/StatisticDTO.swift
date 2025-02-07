//
//  StatisticDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 28.01.25.
//
import Foundation

struct StatisticDTO: DTOProtocol {
    var id: UUID
    var userAccountId: UUID
    var fouls: Int
    var twoPointAttempts: Int
    var threePointAttempts: Int
    var terminType: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    var terminId: UUID
    
    init(id: UUID = UUID(), userAccountId: UUID, fouls: Int, twoPointAttempts: Int, threePointAttempts: Int, terminType: String, terminId: UUID, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.userAccountId = userAccountId
        self.fouls = fouls
        self.twoPointAttempts = twoPointAttempts
        self.threePointAttempts = threePointAttempts
        self.terminType = terminType
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.terminId = terminId
    }
    
    var points: Int {
        (twoPointAttempts * 2) + (threePointAttempts * 3)
    }
    
    func toModel() -> Statistic {
        return Statistic(id: id, userAccountId: userAccountId, fouls: fouls, twoPointAttempts: twoPointAttempts, threePointAttempts: threePointAttempts, terminType: terminType, terminId: terminId, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}

/*
 -- 1. Trigger-Funktion erstellen
 CREATE OR REPLACE FUNCTION "LogStatisticCrud"()
 RETURNS TRIGGER AS $$
 BEGIN
     INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "userId")
     VALUES ('Statistic', NOW(), COALESCE(NEW."userId", OLD."userId"))
     ON CONFLICT ("tableString", "userId")
     DO UPDATE SET "timestamp" = NOW();

     RETURN NULL;
 END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "LogStatisticCrudTrigger"
 AFTER INSERT OR DELETE OR UPDATE ON "Statistic"
 FOR EACH ROW
 EXECUTE FUNCTION "LogStatisticCrud"();
 */
