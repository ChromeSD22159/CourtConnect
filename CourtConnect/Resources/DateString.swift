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
            Text(date.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year(.twoDigits)))
        case .hourMinute:
            Text(date.formatted(.dateTime.hour().minute()))
        }
    }

    enum Style {
        case dayMonthYear
        case hourMinute
    }
}
