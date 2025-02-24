//
//  TermineDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation 

struct TerminDTO: DTOProtocol {
    var id: UUID
    var teamId: UUID
    var title: String
    var place: String
    var infomation: String
    var typeString: String
    var durationMinutes: Int
    var startTime: Date
    var endTime: Date
    var createdByUserAccountId: UUID
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?

    init(id: UUID = UUID(), teamId: UUID, title: String, place: String, infomation: String, typeString: String, durationMinutes: Int, startTime: Date, endTime: Date, createdByUserAccountId: UUID, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.teamId = teamId
        self.title = title
        self.place = place
        self.infomation = infomation
        self.typeString = typeString
        self.durationMinutes = durationMinutes
        self.startTime = startTime
        self.endTime = endTime
        self.createdByUserAccountId = createdByUserAccountId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> some ModelProtocol { 
        return Termin(id: id, teamId: teamId, title: title, place: place, infomation: infomation, typeString: typeString, durationMinutes: durationMinutes, startTime: startTime, endTime: endTime, createdByUserAccountId: createdByUserAccountId, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}

/*
 -- 1. Trigger-Funktion erstellen
 CREATE OR REPLACE FUNCTION "LogTermineCrud"()
 RETURNS TRIGGER AS $$
 BEGIN
     INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "userId")
     VALUES ('Termine', NOW(), COALESCE(NEW."userId", OLD."userId"))
     ON CONFLICT ("tableString", "userId")
     DO UPDATE SET "timestamp" = NOW();

     RETURN NULL;
 END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "LogTermineCrudTrigger"
 AFTER INSERT OR DELETE OR UPDATE ON "Termine"
 FOR EACH ROW
 EXECUTE FUNCTION "LogTermineCrud"();
 */
