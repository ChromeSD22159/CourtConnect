//
//  DateString.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 04.02.25.
//
import SwiftUI

struct DateString: View {
    let date: Date
    let style: Style

    var body: some View {
        switch style {
        case .dayMonthYear:
            Text(date.toDateString())
        case .hourMinute:
            Text(date.toTimeString())
        }
    }

    enum Style {
        case dayMonthYear
        case hourMinute
    }
}
