//
//  PlayerStatistic.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 01.02.25.
//
import SwiftUI

struct PlayerStatistic: View {
    let statistics: [Statistic]
    
    var body: some View {
        SnapScrollView {
            LazyHStack {
                ForEach(statistics) { statistic in
                    StatisticCard(title: "Durschnitts Wert", description: "asdasd asd adsasd.", statistic: statistic)
                }
            }
        }
    }
}

struct StatisticCard: View {
    let title: String
    let description: String
    let statistic: Statistic
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Text(description)
                .font(.footnote)
                .foregroundStyle(Theme.myGray)
                .lineLimit(2)
                .truncationMode(.tail)
            
            row(key: "Fouls", value: statistic.fouls.formatted())
            row(key: "2er", value: (statistic.twoPointAttempts * 2).formatted())
            row(key: "3er", value: (statistic.threePointAttempts * 3).formatted())
            row(key: "Punkte", value: "\( statistic.points.formatted() )")
        }
        .foregroundStyle(Theme.text)
        .padding()
        .frame(width: 150, height: 150)
        .background(Material.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    @ViewBuilder func row(key: String, value: String) -> some View {
        HStack {
            Text(key + ":")
            Spacer()
            Text("**\(value)**")
        }
        .font(.footnote)
    }
}

#Preview {
    var statistcs: [Statistic] {
        var statistcs: [Statistic] = []
        for index in 0...9 {
            let statistc = Statistic(id: UUID(), userId: UUID(), fouls: Int.random(in: 0...9), twoPointAttempts: Int.random(in: 0...9), threePointAttempts: Int.random(in: 0...9), createdAt: Date(), updatedAt: Date())
            
            statistcs.append(statistc)
        }
        return statistcs
    }
    
    PlayerStatistic(statistics: statistcs)
}
