//
//  CourtConnectWidgetBundle.swift
//  CourtConnectWidget
//
//  Created by Frederik Kohler on 09.02.25.
//

import WidgetKit
import SwiftUI

@main
struct CourtConnectWidgetBundle: WidgetBundle {
    var body: some Widget {
        PlayerAverageStatisticWidget()
        PlayerLastAppointmentStatisticWidget()
    }
}
