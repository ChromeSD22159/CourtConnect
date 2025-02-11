//
//  PlayerLastAppointmentStatisticWidget.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 10.02.25.
//
import WidgetKit
import SwiftUI

@MainActor fileprivate struct LastAppointmentProvider: @preconcurrency TimelineProvider {
    
    func placeholder(in context: Context) -> LastAppointmentWidgetEntry {
        LastAppointmentWidgetEntry(date: Date(), title: "Newest Statistic", statistic: MemberStatistic(avgFouls: 2, avgTwoPointAttempts: 2, avgThreePointAttempts: 0, avgPoints: 4))
    }

    func getSnapshot(in context: Context, completion: @escaping (LastAppointmentWidgetEntry) -> ()) {
        let entry = LastAppointmentWidgetEntry(date: Date(), title: "Newest Statistic", statistic: MemberStatistic(avgFouls: 2, avgTwoPointAttempts: 2, avgThreePointAttempts: 0, avgPoints: 4))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [LastAppointmentWidgetEntry] = []
        
        do {
            let loadedData = try loadNewestStatistic()
            entries.append(loadedData)
        } catch {
            print(error)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func loadNewestStatistic() throws -> LastAppointmentWidgetEntry {
        guard let currentAccountIdString = LocalStorageService.shared.userAccountId else {
            throw UserError.userAccountNotFound
        }

        guard let currentAccountId = UUID(uuidString: currentAccountIdString) else {
            throw UserError.userAccountNotFound
        }

        let statistics = try Repository.shared.teamRepository.getMemberStatistic(for: currentAccountId)

        guard let newestStatistic = statistics.max(by: { $0.createdAt < $1.createdAt }) else {
            return LastAppointmentWidgetEntry(
                date: Date(),
                title: "Newest Statistic",
                statistic: MemberStatistic(avgFouls: 0, avgTwoPointAttempts: 0, avgThreePointAttempts: 0, avgPoints: 0)
            )
        }

        let newStatistic = MemberStatistic(
            avgFouls: newestStatistic.fouls,
            avgTwoPointAttempts: newestStatistic.twoPointAttempts,
            avgThreePointAttempts: newestStatistic.threePointAttempts,
            avgPoints: newestStatistic.points
        )
        
        return LastAppointmentWidgetEntry(
            date: newestStatistic.createdAt,
            title: "Newest Statistic",
            statistic: newStatistic
        )
    }
}

fileprivate struct LastAppointmentWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let statistic: MemberStatistic
}

fileprivate struct LastAppointmentEntryView : View {
    var entry: LastAppointmentProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(entry.title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Theme.darkOrange,
                            Theme.lightOrange
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
             
            Grid(horizontalSpacing: 15, verticalSpacing: 15) {
                GridRow(alignment: .center) {
                    IconLabel(imageResource: .customBasketball2Fill, value: entry.statistic.avgTwoPointAttempts)
                    IconLabel(imageResource: .customBasketball3Fill, value: entry.statistic.avgThreePointAttempts)
                }
                
                GridRow(alignment: .center) {
                    IconLabel(imageResource: .customFigureBasketballFoul, value: entry.statistic.avgFouls)
                    IconLabel(systemName: "trophy", value: entry.statistic.avgPoints)
                }
            }
            
            HStack {
                Text("Last Update:")
                Spacer()
                Text(entry.date.formattedTime() + " Uhr")
            }.font(.system(size: 9))
        }
        .containerBackground(Theme.background, for: .widget)
    }
}

struct PlayerLastAppointmentStatisticWidget: Widget {
    let kind: String = "PlayerLastAppointmentStatistic"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LastAppointmentProvider()) { entry in
            if #available(iOS 17.0, *) {
                LastAppointmentEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                LastAppointmentEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Player Statistic Widget")
        .description("With this widget you can see all the time your own AVG Statistics.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    PlayerLastAppointmentStatisticWidget()
} timeline: {
    LastAppointmentWidgetEntry(date: Date(), title: "Newest Statistic", statistic: MemberStatistic(avgFouls: 2, avgTwoPointAttempts: 2, avgThreePointAttempts: 0, avgPoints: 4))
    LastAppointmentWidgetEntry(date: Date(), title: "Newest Statistic", statistic: MemberStatistic(avgFouls: 2, avgTwoPointAttempts: 2, avgThreePointAttempts: 0, avgPoints: 4))
}
