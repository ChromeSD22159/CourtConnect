//
//  AttendanceDTO.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 27.01.25.
//
import Foundation

struct AttendanceDTO: DTOProtocol {
    var id: UUID
    var trainerId: UUID
    var terminId: UUID
    var startTime: Date
    var endTime: Date
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID = UUID(), trainerId: UUID, terminId: UUID, startTime: Date, endTime: Date, createdAt: Date, updatedAt: Date, deletedAt: Date? = nil) {
        self.id = id
        self.trainerId = trainerId
        self.terminId = terminId
        self.startTime = startTime
        self.endTime = endTime
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    func toModel() -> Attendance {
        Attendance(id: id, trainerId: trainerId, terminId: terminId, startTime: startTime, endTime: endTime, createdAt: createdAt, updatedAt: updatedAt, deletedAt: deletedAt)
    }
} 

/*
 -- 1. Trigger-Funktion erstellen
 CREATE OR REPLACE FUNCTION "LogAttendanceCrud"()
 RETURNS TRIGGER AS $$
 BEGIN
     INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "userId")
     VALUES ('Attendance', NOW(), COALESCE(NEW."userId", OLD."userId"))
     ON CONFLICT ("tableString", "userId")
     DO UPDATE SET "timestamp" = NOW();

     RETURN NULL;
 END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "AttendanceCrudTrigger"
 AFTER INSERT OR DELETE OR UPDATE ON "Attendance"
 FOR EACH ROW
 EXECUTE FUNCTION "LogAttendanceCrud"();
 */
