//
//  PDFInfo.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 21.02.25.
//
import SwiftUI 

struct PDFInfo {
    let title: LocalizedStringKey = "Time recording"
    let image: Image
    let description: LocalizedStringKey = "Description"
    let list: [TrainerSaleryData]
    let createdAt: Date
}
