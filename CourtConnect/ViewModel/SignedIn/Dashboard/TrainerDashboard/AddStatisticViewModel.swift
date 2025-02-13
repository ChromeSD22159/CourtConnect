//
//  AddStatisticViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 07.02.25.
//
import Foundation

@Observable @MainActor class AddStatisticViewModel {
    let repository: BaseRepository = Repository.shared
    let teamId: UUID
    let userId: UUID
    
    var teamPlayer: [TeamMemberProfileStatistic] = []
    var teamTrainer: [TeamMemberProfile] = []
    
    var termine: [Termin] = []
    var selectedTermin: Termin?
    
    init(teamId: UUID, userId: UUID) {
        self.teamId = teamId
        self.userId = userId
        
        self.getTermine()
    }
    
    func setTermin(termin: Termin) {
        selectedTermin = termin
        
        self.getTeamMember(termin: termin)
    }
     
    func getTeamMember(termin: Termin) {
        do {
            let teamMember = try repository.teamRepository.getTeamMembers(for: teamId)
            
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
    
    func saveStatistics(termin: Termin) {
        let totalPoints = teamPlayer.map { $0.statistic.points }.reduce(0, +)
        guard totalPoints != 0 else {
            print("Keine Punkte zum Speichern.")
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
                for statsistic in statistics {
                   try await repository.teamRepository.upsertPlayerStatistic(statistic: statsistic, userId: userId)
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func getTermine() {
        do {
            termine = try repository.teamRepository.getPastTeamTermine(for: teamId)
        } catch {
            print(error)
        }
    }
    
    private func reset() {
        selectedTermin = nil
        teamPlayer = []
        teamTrainer = []
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
