//
//  StatisticDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 28.01.25.
//
import Foundation

struct StatisticDTO: DTOProtocol {
    var id: UUID
    var userId: UUID
    var fouls: Int
    var twoPointAttempts: Int
    var threePointAttempts: Int
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID, userId: UUID, fouls: Int, twoPointAttempts: Int, threePointAttempts: Int, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.fouls = fouls
        self.twoPointAttempts = twoPointAttempts
        self.threePointAttempts = threePointAttempts
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    var points: Int {
        (twoPointAttempts * 2) + (threePointAttempts * 3)
    }
    
    func toModel() -> Statistic {
        return Statistic(id: id, userId: userId, fouls: fouls, twoPointAttempts: twoPointAttempts, threePointAttempts: threePointAttempts, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
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
