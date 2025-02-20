//
//  AddStatisticViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 07.02.25.
//
import Foundation
import Auth

@Observable @MainActor class AddStatisticViewModel: AuthProtocol, SyncHistoryProtocol {
    
    var repository: BaseRepository = Repository.shared
    var user: Auth.User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    var isfetching: Bool = false
    
    var teamPlayer: [TeamMemberProfileStatistic] = []
    var teamTrainer: [TeamMemberProfile] = []
    
    var termine: [Termin] = []
    var selectedTermin: Termin?
    
    init() {
        self.inizializeAuth()
        self.getTermine()
    }
    
    func setTermin(termin: Termin) {
        selectedTermin = termin
        
        self.getTeamMember(termin: termin)
    }
    
    func saveStatistics(termin: Termin) {
        let totalPoints = teamPlayer.map { $0.statistic.points }.reduce(0, +)
        guard totalPoints != 0 else {
            reset()
            return
        }
        
        let statistics = teamPlayer.map {
            Statistic(
                userAccountId: $0.teamMember.userAccountId,
                fouls: $0.statistic.fouls.number,
                twoPointAttempts: $0.statistic.twoPointAttempts.number,
                threePointAttempts: $0.statistic.threePointAttempts.number,
                terminType: termin.typeString,
                terminId: termin.id,
                createdAt: Date(),
                updatedAt: Date()
            )
        }
        
        // SEND INSERT/UPSERT TO SERVER
        Task {
            defer { reset() }
            do {
                guard let user = user else { throw UserError.userIdNotFound }
                for statsistic in statistics {
                    try await repository.teamRepository.upsertPlayerStatistic(statistic: statsistic, userId: user.id)
                }
            } catch {
                print(error)
            }
        }
    }
     
    private func getTeamMember(termin: Termin) {
        do {
            guard let team = currentTeam else { throw TeamError.teamNotFound }
            let teamMember = try repository.teamRepository.getTeamMembers(for: team.id)
            
            for member in teamMember {
                if let userAccount = try repository.accountRepository.getAccount(id: member.userAccountId),
                   let userProfil = try repository.userRepository.getUserProfileFromDatabase(userId: userAccount.userId) {
                    
                    if userAccount.roleEnum == .player {
                        let teamMemberProfileStatistic = TeamMemberProfileStatistic(
                            userProfile: userProfil,
                            teamMember: member,
                            statistic: TempStatistic()
                        )
                        
                        self.teamPlayer.append(teamMemberProfileStatistic)
                    }
                    if userAccount.roleEnum == .coach {
                        let teamMemberProfileStatistic = TeamMemberProfile(
                            userProfile: userProfil,
                            teamMember: member
                        )
                        self.teamTrainer.append(teamMemberProfileStatistic)
                    }
                }
            }
        } catch {
            print(error)
        }
    }
     
    private func getTermine() {
        do {
            guard let team = currentTeam else { throw TeamError.teamNotFound }
            termine = try repository.terminRepository.getPastTeamTermine(for: team.id)
        } catch {
            print(error)
        }
    }
    
    private func reset() {
        selectedTermin = nil
        teamPlayer = []
        teamTrainer = []
    }
    
    private func hasStatistic(userAccountId: UUID, terminId: UUID) -> Bool {
        do {
            return try repository.teamRepository.playerHasStatistic(userAccountId: userAccountId, terminId: terminId)
        } catch {
            return false
        }
    }
    
    func filterTeamPlayer(terminId: UUID) -> [TeamMemberProfileStatistic] {
        return teamPlayer.filter { player in
            !hasStatistic(userAccountId: player.teamMember.userAccountId, terminId: terminId)
        }
    }
    
    private func isTrainerAttendanceConfirmed(userAccountId: UUID, terminId: UUID) -> Bool {
        do {
            return try repository.teamRepository.isTrainerAttendanceConfirmed(userAccountId: userAccountId, terminId: terminId)
        } catch {
            return false
        }
    }
    
    func filterTeamTrainer(terminId: UUID) -> [TeamMemberProfile] {
        return teamTrainer.filter { trainer in
            !isTrainerAttendanceConfirmed(userAccountId: trainer.teamMember.userAccountId, terminId: terminId)
        }
    }
    
    func fetchDataFromRemote() {
        Task {
            isfetching = true
            defer {
                isfetching = false
                getTermine()
            }
            do {
                guard let user = user else { throw UserError.userIdNotFound }
                
                try await syncAllTables(userId: user.id)
            } catch {
                ErrorHandlerViewModel.shared.handleError(error: error)
            }
        }
    }
}

@Observable class TeamMemberProfileStatistic: Identifiable {
    let id: UUID = UUID()
    var userProfile: UserProfile
    var teamMember: TeamMember
    var statistic: TempStatistic
    
    init(userProfile: UserProfile, teamMember: TeamMember, statistic: TempStatistic) {
        self.userProfile = userProfile
        self.teamMember = teamMember
        self.statistic = statistic
    }
}

@Observable class TempStatistic: Identifiable {
    let id: UUID = UUID()
    var twoPointAttempts: StepperNumber = StepperNumber()
    var threePointAttempts: StepperNumber = StepperNumber()
    var fouls: StepperNumber = StepperNumber()
    var wasThere: ToggleValue = ToggleValue()
    
    var points: Int {
        (twoPointAttempts.number * 2) + (threePointAttempts.number * 3)
    }
}

@Observable class StepperNumber: Identifiable {
    let id = UUID()
    var number: Int = 0
}

@Observable class ToggleValue: Identifiable {
    let id: UUID = UUID()
    var value: Bool = false
}
