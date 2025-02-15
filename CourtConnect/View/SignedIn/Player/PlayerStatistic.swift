//
//  PlayerStatistic.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 01.02.25.
//
import SwiftUI
import Charts 

struct PlayerStatistic: View {
    @Environment(\.scenePhase) var scenePhase
    @State var viewModel = PlayerStatisticViewModel()
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 50) {
              
                HStack(spacing: 20) {
                     if let imageURL = viewModel.userProfile?.imageURL {
                         AsyncCachedImage(url: URL(string: imageURL)!) { image in
                             image
                                 .resizable()
                                 .scaledToFit()
                                 .frame(width: 100)
                                 .clipShape(Circle())
                                 .overlay(
                                     Circle()
                                        .stroke(Theme.topTrailingbottomLeadingGradient, lineWidth: 5)
                                 )
                         } placeholder: {
                             Image(.basketballPlayerProfile)
                                 .resizable()
                                 .scaledToFit()
                                 .frame(width: 100)
                                 .clipShape(Circle())
                                 .overlay(
                                     Circle()
                                        .stroke(Theme.topTrailingbottomLeadingGradient, lineWidth: 5)
                                 )
                         }
                     } else {
                         Image(.basketballPlayerProfile)
                             .resizable()
                             .scaledToFit()
                             .frame(width: 100)
                             .clipShape(Circle())
                             .overlay(
                                 Circle()
                                    .stroke(Theme.topTrailingbottomLeadingGradient, lineWidth: 5)
                             )
                     }
                     
                     VStack(alignment: .leading) {
                         Text(viewModel.userProfile?.fullName ?? "")
                             .font(.headline)
                         
                         Text(viewModel.teamMember?.position ?? "")
                             .font(.subheadline)
                     }
                 }
           
                ZStack {
                    SnapScrollView {
                        LazyHStack {
                            if let bestTwoPointAttempts = viewModel.bestTwoPointAttempts {
                                StatisticCard(title: "Most 2er", description: bestTwoPointAttempts.createdAt.toDateString(), statistic: bestTwoPointAttempts)
                            }
                            
                            if let bestThreePointAttempts = viewModel.bestThreePointAttempts {
                                StatisticCard(title: "Most 3er", description: bestThreePointAttempts.createdAt.toDateString(), statistic: bestThreePointAttempts)
                            }
                            
                            if let bestFouls = viewModel.bestFouls {
                                StatisticCard(title: "Lowest Fouls", description: bestFouls.createdAt.toDateString(), statistic: bestFouls)
                            }
                            
                            if let bestPoints = viewModel.bestPoints {
                                StatisticCard(title: "Most Points", description: bestPoints.createdAt.toDateString(), statistic: bestPoints)
                            }
                        }
                    }
                    .blur(radius: viewModel.hasData ? 0 : 2)
                    .opacity(viewModel.hasData ? 1.0 : 0.5)
                    
                    if !viewModel.hasData {
                        Text("Soon you will see your data here!")
                            .font(.footnote)
                    }
                }
                
                StatisticChart(statistics: viewModel.chartStatistics, hasData: viewModel.hasData) { type in
                    viewModel.getStatistic(for: type)
                }
               
                Spacer()
               
            }
        }
        .navigationTitle(title: "\(viewModel.userProfile?.fullName ?? "") Statistics")
        .contentMargins(.top, 20)
        .contentMargins(.bottom, 75)
        .reFetchButton(isFetching: $viewModel.isfetching, onTap: {
            viewModel.fetchDataFromRemote()
        }) 
        .onAppear {
            viewModel.initialze()
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                viewModel.fetchDataFromRemote()
            }
        }
    }
}

private struct StatisticCard: View {
    let title: LocalizedStringKey
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
            
            StatisticCardRow(key: .init("Fouls"), value: statistic.fouls.formatted())
            StatisticCardRow(key: "2er", value: (statistic.twoPointAttempts * 2).formatted())
            StatisticCardRow(key: "3er", value: (statistic.threePointAttempts * 3).formatted())
            StatisticCardRow(key: "Points", value: "\( statistic.points.formatted() )")
        }
        .foregroundStyle(Theme.text)
        .padding()
        .frame(width: 150, height: 150)
        .background(Material.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

private struct StatisticCardRow: View {
    let key: LocalizedStringKey
    let value: String
    var body: some View {
        HStack {
            Text("\(key.stringValue() ?? ""):")
            Spacer()
            Text("**\(value)**")
        }
        .font(.footnote)
    }
}

private struct StatisticChart: View {
    let statistics: [Statistic]
    let hasData: Bool
    
    var sortedByDate: [Statistic] {
        self.statistics.sorted {
            $0.createdAt < $1.createdAt
        }
    }
    
    var yValue: (Statistic) -> Int {
        switch selected {
        case .twoPointAttempts:
            return { statistic in statistic.twoPointAttempts }
        case .threePointAttempts:
            return { statistic in statistic.threePointAttempts }
        case .fouls:
            return { statistic in statistic.fouls }
        case .mostPoints:
            return { statistic in statistic.points }
        }
    }
    
    let onChange: (TerminType) -> Void
    
    @State var selected: SelectionType = .twoPointAttempts
    @State var selectedType: TerminType = .game
    @State private var lineOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                ForEach(TerminType.statistics, id: \.hashValue) { type in
                    Button(type.localized) {
                        withAnimation {
                            selectedType = type
                            onChange(type)
                        }
                    }
                    .buttonStyle(  RoundedFilledButtonStlye(color: selectedType == type ? Theme.lightOrange : Theme.myGray) )
                }
            }
            
            ZStack {
                Chart(sortedByDate) { statistic in
                    LineMark(
                        x: .value("Date", statistic.createdAt.toDateStringDDMM()),
                        y: .value("Value", yValue(statistic))
                    )
                    .opacity(hasData ? lineOpacity : 0.5)
                    .foregroundStyle(Theme.lightOrange)
                     
                    AreaMark(
                        x: .value("Date", statistic.createdAt.toDateStringDDMM()),
                        y: .value("Value", yValue(statistic))
                    )
                    .opacity(hasData ? lineOpacity : 0.5)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Theme.lightOrange.opacity(0.8),
                                Theme.lightOrange.opacity(0.05)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .blur(radius: hasData ? 0 : 2)
                .opacity(hasData ? 1.0 : 0.5)
                .chartYScale(domain: [0, selected.maxValue])
                
                if !hasData {
                    Text("Soon you will see your data here!")
                        .font(.footnote)
                }
            }
           
            HStack {
                ForEach(SelectionType.allCases, id: \.hashValue) { type in
                    Button(type.rawValue) {
                        withAnimation {
                            selected = type
                        }
                    }
                    .buttonStyle(  RoundedFilledButtonStlye(color: selected == type ? Theme.darkOrange : Theme.myGray) )
                }
            }
        }
        .padding(.horizontal)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                lineOpacity = 1.0
            }
        }
    }
    
    enum SelectionType: LocalizedStringKey, CaseIterable {
        case twoPointAttempts = "2er"
        case threePointAttempts = "3er"
        case fouls = "Fouls"
        case mostPoints = "Points"
        
        var maxValue: Int {
            switch self {
            case .twoPointAttempts: 20
            case .threePointAttempts: 20
            case .fouls: 10
            case .mostPoints: 100
            }
        }
    }
}
 
#Preview {
    NavigationStack {
        PlayerStatistic()
    }
}
