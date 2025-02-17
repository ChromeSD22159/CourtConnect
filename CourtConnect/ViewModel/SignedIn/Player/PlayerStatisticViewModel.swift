//
//  PlayerStatisticViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 10.02.25.
//
import Foundation
import SwiftUI
import Auth

@Observable @MainActor class PlayerStatisticViewModel: AuthProtocol, SyncHistoryProtocol {
    var repository: BaseRepository = Repository.shared
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var teamMember: TeamMember?
    var user: User?
    var currentTeam: Team?
    var isfetching: Bool = false
    var orginalStatistics: [Statistic] = []
    var statistics: [Statistic] = []
    var chartStatistics: [Statistic] = []
    var hasData: Bool = false
    
    var bestTwoPointAttempts: Statistic? {
        statistics.sorted {
            $0.twoPointAttempts > $1.twoPointAttempts
        }.first
    }
    
    var bestThreePointAttempts: Statistic? {
        statistics.sorted {
            $0.threePointAttempts > $1.threePointAttempts
        }.first
    }
    
    var bestFouls: Statistic? {
        statistics.sorted {
            $0.fouls < $1.fouls
        }.first
    }
    
    var bestPoints: Statistic? {
        statistics.sorted {
            $0.points > $1.points
        }.first
    }
    
    init() {
        loadLocalData()
    }
    
    func loadLocalData() {
        self.inizializeAuth()
        
        getStatistic(for: .game)
        getTeamMember()
    }
    
    func getStatistic(for terminType: TerminType) {
        statistics = []
        chartStatistics = []

        defer {
            Task {
                try await Task.sleep(for: .seconds(0.5))
                if hasData {
                    for item in chartStatistics.reversed() {
                        withAnimation {
                            item.fouls = orginalStatistics.first(where: { $0.id == item.id })!.fouls
                            item.twoPointAttempts = orginalStatistics.first(where: { $0.id == item.id })!.twoPointAttempts
                            item.threePointAttempts = orginalStatistics.first(where: { $0.id == item.id })!.threePointAttempts
                        }
                        
                        try await Task.sleep(for: .seconds(0.1))
                    }
                } else {
                    for item in chartStatistics.reversed() {
                        withAnimation {
                            item.fouls = Int.random(in: 2...20)
                            item.twoPointAttempts = Int.random(in: 2...20)
                            item.threePointAttempts = Int.random(in: 3...20)
                        }
                        
                        try await Task.sleep(for: .seconds(0.1))
                    }
                }
            }
        }
        do {
            guard let userAccountId = userAccount?.id else { return }
            let result = try repository.teamRepository.getPlayerStatistics(userAccountId: userAccountId, terminType: terminType.rawValue)
            if result.count >= 2 {
                orginalStatistics = result
                self.hasData = true
                for statistic in result {
                    let statistc = Statistic(id: statistic.id, userAccountId: statistic.userAccountId, fouls: 0, twoPointAttempts: 0, threePointAttempts: 0, terminType: TerminType.game.rawValue, terminId: statistic.terminId, createdAt: statistic.createdAt, updatedAt: statistic.updatedAt)
                    self.chartStatistics.append(statistc)
                    self.statistics.append(statistc)
                }
            } else {
                self.hasData = false
                for index in 0...7 {
                    let date = Calendar.current.date(byAdding: .day, value: -(7 * index + 1), to: Date())!
                    let statistc = Statistic(id: UUID(), userAccountId: UUID(), fouls: 0, twoPointAttempts: 0, threePointAttempts: 0, terminType: TerminType.game.rawValue, terminId: UUID(), createdAt: date, updatedAt: date)
                    self.chartStatistics.append(statistc)
                    self.statistics.append(statistc)
                }
            }
        } catch {
            print(error)
        }
    }
    
    func getTeamMember() {
        do {
            guard let userAccount = userAccount else { throw UserError.userAccountNotFound }
            teamMember = try repository.teamRepository.getMember(for: userAccount.id)
        } catch {
            print(error)
        }
    }
    
    func fetchDataFromRemote() {
        Task {
            await fetchData()
            
            loadLocalData()
        }
    }
}
