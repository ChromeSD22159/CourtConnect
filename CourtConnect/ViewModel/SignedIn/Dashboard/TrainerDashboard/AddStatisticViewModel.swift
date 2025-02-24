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
         
        Task {
            defer {
                getTermine()
            }
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
    
    func terminHasOpenMembers(termin: Termin) -> Bool {
        do {
            guard let team = currentTeam else { throw TeamError.teamNotFound }
            let teamMember = try repository.teamRepository.getTeamMembers(for: team.id)
            
            var teamPlayer: [TeamMemberProfileStatistic] = []
            
            for member in teamMember {
                if let userAccount = try repository.accountRepository.getAccount(id: member.userAccountId),
                   let userProfil = try repository.userRepository.getUserProfileFromDatabase(userId: userAccount.userId) {
                    
                    if userAccount.roleEnum == .player {
                        let teamMemberProfileStatistic = TeamMemberProfileStatistic(
                            userProfile: userProfil,
                            teamMember: member,
                            statistic: TempStatistic()
                        )
                         
                        let hasAttendance = repository.teamRepository.memberHasAttendance(userAccountId: teamMemberProfileStatistic.teamMember.userAccountId, terminId: termin.id, confirmedOnly: team.addStatisticConfirmedOnly)
                        
                        let has = try repository.teamRepository.playerHasStatistic(userAccountId: teamMemberProfileStatistic.teamMember.userAccountId, terminId: termin.id)
                       
                        if hasAttendance && !has {
                            teamPlayer.append(teamMemberProfileStatistic)
                        }
                        
                    }
                }
            }
            
            return !teamPlayer.isEmpty
        } catch {
            return false
        }
    }
    
    func terminHasOpenTrainer(termin: Termin) -> Bool {
        do {
            guard let team = currentTeam else { throw TeamError.teamNotFound }
            let teamMember = try repository.teamRepository.getTeamMembers(for: team.id)
            
            var teamTrainer: [TeamMemberProfile] = []
            
            for member in teamMember {
                if let userAccount = try repository.accountRepository.getAccount(id: member.userAccountId),
                   let userProfil = try repository.userRepository.getUserProfileFromDatabase(userId: userAccount.userId) {
                    if userAccount.roleEnum == .coach {
                        let teamMemberProfileStatistic = TeamMemberProfile(
                            userProfile: userProfil,
                            teamMember: member
                        )
                        let hasAttendance = repository.teamRepository.memberHasAttendance(userAccountId: teamMemberProfileStatistic.teamMember.userAccountId, terminId: termin.id, confirmedOnly: team.addStatisticConfirmedOnly)
                        let isConfirmed = try repository.teamRepository.isTrainerAttendanceConfirmed(userAccountId: teamMemberProfileStatistic.teamMember.userAccountId, terminId: termin.id)
                          
                        guard hasAttendance else { continue }
                        guard !isConfirmed else { continue }
                         
                        teamTrainer.append(teamMemberProfileStatistic)
                    }
                }
            }
            
            return !teamTrainer.isEmpty
        } catch {
            return false
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
        termine = []
        
        getTermine()
    }
    
    func filterTeamPlayer(terminId: UUID) -> [TeamMemberProfileStatistic] {
        guard let team = currentTeam else { return [] }
       
        do {
            return try teamPlayer.filter { player in
                let hasStatistic = try repository.teamRepository.playerHasStatistic(userAccountId: player.teamMember.userAccountId, terminId: terminId)
                let hasAttendance = repository.teamRepository.memberHasAttendance(userAccountId: player.teamMember.userAccountId, terminId: terminId, confirmedOnly: team.addStatisticConfirmedOnly)
                return !hasStatistic && hasAttendance
            }
        } catch {
            return []
        }
    }
    
    func confirmTrainerAttendance(userAccountId: UUID, terminId: UUID) {
        Task {
            do {
                guard let user = user else { throw UserError.userIdNotFound }
                if let attendance = try repository.teamRepository.getAttendance(userAccountId: userAccountId, terminId: terminId) {
                    attendance.trainerConfirmedAt = Date()
                    attendance.updatedAt = Date()
                    try await repository.teamRepository.upsertTerminAttendance(attendance: attendance, userId: user.id)
                }
            } catch {
                print(error)
            }
        }
    }
    
    func filterTeamTrainer(terminId: UUID) -> [TeamMemberProfile] {
        guard let team = currentTeam else { return [] }
        
        do {
            print(teamTrainer.count)
            
            let list = try teamTrainer.filter { trainer in
                let foundAttendance = repository.teamRepository.memberHasAttendance(userAccountId: trainer.teamMember.userAccountId, terminId: terminId, confirmedOnly: team.addStatisticConfirmedOnly)
                
                let isConfirmed = try repository.teamRepository.isTrainerAttendanceConfirmed(userAccountId: trainer.teamMember.userAccountId, terminId: terminId)

                guard foundAttendance else { return false }
                guard !isConfirmed else { return false }
                 
                return foundAttendance && !isConfirmed
            }
             
            print(list)
            
            return list
        } catch {
            return []
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
