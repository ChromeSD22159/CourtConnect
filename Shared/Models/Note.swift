//
//  Note.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 19.02.25.
//
import SwiftData
import Foundation

@Model class Note: Identifiable {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var title: String
    var desc: String
    var date: Date
    var wantNotification: Bool
    
    init(id: UUID = UUID(), userId: UUID, title: String, desc: String, date: Date, wantNotification: Bool) {
        self.id = id
        self.userId = userId
        self.title = title
        self.desc = desc
        self.date = date
        self.wantNotification = wantNotification
    }
}
