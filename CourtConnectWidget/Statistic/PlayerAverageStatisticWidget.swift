//
//  CourtConnectWidget.swift
//  CourtConnectWidget
//
//  Created by Frederik Kohler on 09.02.25.
//
import WidgetKit
import SwiftUI

@MainActor struct PlayerAverageStatisticProvider: @preconcurrency TimelineProvider {
    let repository: BaseRepository = Repository.shared
    
    func placeholder(in context: Context) -> PlayerAverageStatisticWidgetEntry {
        PlayerAverageStatisticWidgetEntry(date: Date(), title: "Average Statistic", statistic: MemberStatistic(avgFouls: 2, avgTwoPointAttempts: 2, avgThreePointAttempts: 0, avgPoints: 4))
    }

    func getSnapshot(in context: Context, completion: @escaping (PlayerAverageStatisticWidgetEntry) -> ()) {
        let entry = PlayerAverageStatisticWidgetEntry(date: Date(), title: "Average Statistic", statistic: MemberStatistic(avgFouls: 2, avgTwoPointAttempts: 2, avgThreePointAttempts: 0, avgPoints: 4))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [PlayerAverageStatisticWidgetEntry] = []
        
        do {
            if let loadedData = try loadMemberAvgStatistic() {
                let simpleEntry = PlayerAverageStatisticWidgetEntry(
                    date: Date(),
                    title: "Average Statistic",
                    statistic: loadedData
                )
                entries.append(simpleEntry)
            } 
        } catch {
            
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    } 
    
    func loadMemberAvgStatistic() throws -> MemberStatistic? {
        guard let currentAccountIdString = LocalStorageService.shared.userAccountId else { throw UserError.userAccountNotFound }
        if let currentAccountId = UUID(uuidString: currentAccountIdString), let avg = try repository.teamRepository.getMemberAvgStatistic(for: currentAccountId) {
            return avg
        } else {
            return nil
        }
    }
}

struct PlayerAverageStatisticWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let statistic: MemberStatistic
}

struct PlayerAverageStatisticWidgetEntryView : View {
    var entry: PlayerAverageStatisticProvider.Entry

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

struct PlayerAverageStatisticWidget: Widget {
    let kind: String = "PlayerAverageStatistic"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlayerAverageStatisticProvider()) { entry in
            if #available(iOS 17.0, *) {
                PlayerAverageStatisticWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                PlayerAverageStatisticWidgetEntryView(entry: entry)
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
    PlayerAverageStatisticWidget()
} timeline: {
    PlayerAverageStatisticWidgetEntry(date: Date(), title: "Average Statistic", statistic: MemberStatistic(avgFouls: 2, avgTwoPointAttempts: 2, avgThreePointAttempts: 0, avgPoints: 4))
    PlayerAverageStatisticWidgetEntry(date: Date(), title: "Average Statistic", statistic: MemberStatistic(avgFouls: 2, avgTwoPointAttempts: 2, avgThreePointAttempts: 0, avgPoints: 4))
}
