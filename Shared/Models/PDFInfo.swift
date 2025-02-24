//
//  PDFInfo.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 21.02.25.
//
import SwiftUI 

struct PDFInfo {
    var title: LocalizedStringKey = "Hourly report"
    var image: Image
    var description: LocalizedStringKey = "Description"
    var list: [TrainerSaleryData]
    var createdAt: Date
}
