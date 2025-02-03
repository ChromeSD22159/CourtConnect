//
//  DocumentDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//

import Foundation

struct DocumentDTO: DTOProtocol {
    var id: UUID
    var teamId: UUID
    var name: String
    var info: String
    var url: String
    var roleString: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), teamId: UUID, name: String, info: String, url: String, roleString: String, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.teamId = teamId
        self.name = name
        self.info = info
        self.url = url
        self.roleString = roleString
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> Document {
        Document(id: id, teamId: teamId, name: name, info: info, url: url, roleString: roleString, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
} 

/*
 -- 1. Trigger-Funktion erstellen
 CREATE OR REPLACE FUNCTION "LogDocumentCrud"()
 RETURNS TRIGGER AS $$
 BEGIN
     INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "userId")
     VALUES ('Document', NOW(), COALESCE(NEW."userId", OLD."userId"))
     ON CONFLICT ("tableString", "userId")
     DO UPDATE SET "timestamp" = NOW();

     RETURN NULL;
 END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "DocumentCrudTrigger"
 AFTER INSERT OR DELETE OR UPDATE ON "Document"
 FOR EACH ROW
 EXECUTE FUNCTION "LogDocumentCrud"();
 */
