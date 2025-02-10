//
//  PlayerStatistic.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 01.02.25.
//
import SwiftUI
import Charts 

struct PlayerStatistic: View {
    @State var viewModel: PlayerStatisticViewModel
    @State var userViewModel: SharedUserViewModel
    
    @State var isValid: Bool
    
    init(userViewModel: SharedUserViewModel) {
        self.userViewModel = userViewModel
         
        if let currentAccount = userViewModel.currentAccount {
            isValid = true
            self.viewModel = PlayerStatisticViewModel(userAccount: currentAccount)
        } else {
            isValid = false
            self.viewModel = PlayerStatisticViewModel(userAccount: nil)
        }
    }
    
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
                         Text("Frederik Kohler")
                             .font(.headline)
                         
                         Text("Point Gard")
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
        .navigationTitle((userViewModel.userProfile?.fullName ?? "") + " Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .contentMargins(.top, 20)
        .contentMargins(.bottom, 75)
    }
}

private struct StatisticCard: View {
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
                    Button(type.rawValue) {
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
    @Previewable @State var viewModel = SharedUserViewModel(repository: RepositoryPreview.shared)
    NavigationStack {
        PlayerStatistic(userViewModel: viewModel)
    }
    .onAppear {
        viewModel.userProfile = MockUser.myUserProfile
        viewModel.currentAccount = MockUser.myUserAccount
    }
}
