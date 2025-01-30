//
//  TermineDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation 

struct TermineDTO: DTOProtocol {
    var id: UUID
    var teamId: UUID
    var typeString: String
    var locationId: UUID
    var date: Date
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
   
    init(id: UUID = UUID(), teamId: UUID, typeString: String, locationId: UUID, date: Date, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.teamId = teamId
        self.typeString = typeString
        self.locationId = locationId
        self.date = date
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> some ModelProtocol {
        return Termine(id: id, teamId: teamId, typeString: typeString, locationId: locationId, date: date, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
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
