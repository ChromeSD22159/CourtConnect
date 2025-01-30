//
//  UserOnlineDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 17.01.25.
//
import SwiftData
import Foundation
import UIKit

struct UserOnlineDTO: DTOProtocol {
    var id: UUID
    var userId: UUID
    var firstName: String
    var lastName: String
    var deviceToken: String
    var timestamp: Date
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), userId: UUID, firstName: String, lastName: String, deviceToken: String, timestamp: Date = Date(), createdAt: Date = Date(), updatedAt: Date = Date(), deletedAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.timestamp = timestamp
        self.deviceToken = deviceToken
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> UserOnline {
        return UserOnline(id: id, userId: userId, firstName: firstName, lastName: lastName, deviceToken: deviceToken)
    }
} 

extension UserOnlineDTO {
    func toUserProfile() -> UserProfile {
        return UserProfile(userId: self.userId, firstName: self.firstName, lastName: self.lastName, birthday: "")
    }
}

/*
 -- 1. Trigger-Funktion erstellen
 CREATE OR REPLACE FUNCTION "LogUserOnlineCrud"()
 RETURNS TRIGGER AS $$
 BEGIN
     INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "userId")
     VALUES ('UserOnline', NOW(), COALESCE(NEW."userId", OLD."userId"))
     ON CONFLICT ("tableString", "userId")
     DO UPDATE SET "timestamp" = NOW();

     RETURN NULL;
 END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "LogUserOnlineCrudTrigger"
 AFTER INSERT OR DELETE OR UPDATE ON "UserOnline"
 FOR EACH ROW
 EXECUTE FUNCTION "LogUserOnlineCrud"();
 */ 
