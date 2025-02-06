//
//  UserProfileDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation

class UserProfileDTO: DTOProtocol { 
    var id: UUID
    var userId: UUID
    var firstName: String
    var lastName: String
    var birthday: String
    var fcmToken: String?
    var lastOnline: Date
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    var onBoardingAt: Date?
     
    init(id: UUID = UUID(), userId: UUID, fcmToken: String? = nil, firstName: String, lastName: String, birthday: String, lastOnline: Date = Date(), createdAt: Date = Date(), updatedAt: Date = Date(), deletedAt: Date? = nil, onBoardingAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.fcmToken = fcmToken
        self.firstName = firstName
        self.lastName = lastName
        self.birthday = birthday
        self.lastOnline = lastOnline
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.onBoardingAt = onBoardingAt
    }
    
    func toModel() -> UserProfile {
        UserProfile(id: id, userId: userId, fcmToken: fcmToken, firstName: firstName, lastName: lastName, birthday: birthday, lastOnline: lastOnline, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt, onBoardingAt: onBoardingAt)
    }
}

/*
 -- 1. Trigger-Funktion erstellen
 CREATE OR REPLACE FUNCTION "LogUserProfileCrud"()
 RETURNS TRIGGER AS $$
 BEGIN
     INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "userId")
     VALUES ('UserProfile', NOW(), COALESCE(NEW."userId", OLD."userId"))
     ON CONFLICT ("tableString", "userId")
     DO UPDATE SET "timestamp" = NOW();

     RETURN NULL;
 END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "LogUserProfileCrudTrigger"
 AFTER INSERT OR DELETE OR UPDATE ON "UserProfile"
 FOR EACH ROW
 EXECUTE FUNCTION "LogUserProfileCrud"();
 */
