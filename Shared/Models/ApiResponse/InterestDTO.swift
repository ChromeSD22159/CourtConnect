//
//  InterestDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation

struct InterestDTO: DTOProtocol {
    var id: UUID
    var memberId: UUID
    var terminId: UUID
    var willParticipate: Bool
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID, memberId: UUID, terminId: UUID, willParticipate: Bool, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.memberId = memberId
        self.terminId = terminId
        self.willParticipate = willParticipate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> Interest {
        return Interest(id: id, memberId: memberId, terminId: terminId, willParticipate: willParticipate, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}

// --> Get Account from memberId to get the UserId
/*
 -- 1. Trigger-Funktion erstellen
 CREATE OR REPLACE FUNCTION "LogInterestCrud"()
 RETURNS TRIGGER AS $$
 BEGIN
     INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "userId")
     VALUES ('Interest', NOW(), COALESCE(NEW."userId", OLD."userId"))
     ON CONFLICT ("tableString", "userId")
     DO UPDATE SET "timestamp" = NOW();

     RETURN NULL;
 END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "LogInterestCrudTrigger"
 AFTER INSERT OR DELETE OR UPDATE ON "Interest"
 FOR EACH ROW
 EXECUTE FUNCTION "LogInterestCrud"();
 */
