//
//  LocationDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation 

struct LocationDTO: DTOProtocol {
    var id: UUID
    var name: String
    var street: String
    var number: String
    var zip: String
    var city: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    func toModel() -> Location {
        return Location(id: id, name: name, street: street, number: number, zip: zip, city: city, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
} 
// SYNC ALL
/*
 -- 1. Trigger-Funktion erstellen
 CREATE OR REPLACE FUNCTION "LogLocationCrud"()
 RETURNS TRIGGER AS $$
 BEGIN
     INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "userId")
     VALUES ('Location', NOW(), COALESCE(NEW."userId", OLD."userId"))
     ON CONFLICT ("tableString", "userId")
     DO UPDATE SET "timestamp" = NOW();

     RETURN NULL;
 END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "LogLocationCrudTrigger"
 AFTER INSERT OR DELETE OR UPDATE ON "Location"
 FOR EACH ROW
 EXECUTE FUNCTION "LogLocationCrud"();
 */
