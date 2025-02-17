//
//  TeamViewViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 05.02.25.
//
import Foundation
import Auth

@Observable @MainActor class TeamViewViewModel: AuthProtocol, SyncHistoryProtocol {
    var repository: BaseRepository = Repository.shared
    var user: User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    var isfetching: Bool = false
    var documents: [Document] = []
    var termine: [Termin] = []
    
    var teamPlayers: [MemberProfile] = []
    var teamTrainers: [MemberProfile] = []
    
    var selectedDocument: Document?
    
    init() {
        loadLocalData()
    }
    
    func loadLocalData() {
        self.inizializeAuth()
        self.getAllDocuments()
        self.getTeamTermine()
        self.getTeamMembers()
    }
    
    private func getAllDocuments() {
        do {
            guard let team = currentTeam else { return }
            self.documents = try repository.documentRepository.getDocuments(for: team.id)
        } catch {
            print(error)
        }
    }
     
    func getTeamTermine() {
        do {
            guard let team = currentTeam else { throw TeamError.userHasNoTeam }
            termine = try repository.teamRepository.getTeamTermine(for: team.id)
        } catch {
            print(error)
        }
    }
    
    func getTeamMembers() {
        do {
            guard let team = currentTeam else { throw TeamError.teamNotFound }
             
            let teamMember = try repository.teamRepository.getTeamMembers(for: team.id)
            var teamPlayersTmp: [MemberProfile] = []
            let teamPlayers = teamMember.filter { $0.role == UserRole.player.rawValue }
            for player in teamPlayers {
                if let playerAccount = try repository.accountRepository.getAccount(id: player.userAccountId),
                    let userProfile = try repository.userRepository.getUserProfileFromDatabase(userId: playerAccount.userId) {
                    let userStatistic = try repository.teamRepository.getMemberAvgStatistic(for: playerAccount.id)
                    let profile = MemberProfile(
                        firstName: userProfile.firstName,
                        lastName: userProfile.lastName,
                        shirtNumber: player.shirtNumber,
                        avgFouls: userStatistic?.avgFouls ?? -0,
                        avgTwo: userStatistic?.avgTwoPointAttempts ?? 0,
                        avgtree: userStatistic?.avgThreePointAttempts ?? 0,
                        avgPoints: userStatistic?.avgPoints ?? 0
                    )
                    teamPlayersTmp.append(profile)
                }
            }
             
            var teamTrainersTmp: [MemberProfile] = []
            let teamTrainers = teamMember.filter { $0.role == UserRole.coach.rawValue }
            for trainer in teamTrainers {
                if let trainerAccount = try repository.accountRepository.getAccount(id: trainer.userAccountId),
                    let userProfile = try repository.userRepository.getUserProfileFromDatabase(userId: trainerAccount.userId) {
                    let profile = MemberProfile(firstName: userProfile.firstName, lastName: userProfile.lastName, avgFouls: 0, avgTwo: 0, avgtree: 0, avgPoints: 0)
                    teamTrainersTmp.append(profile)
                }
            }
            
            self.teamPlayers = teamPlayersTmp
            self.teamTrainers = teamTrainersTmp
        } catch {
            print(error)
        }
    }
    
    func setDocument(document: Document) {
        selectedDocument = document
    }
    
    func fetchDataFromRemote() {
        Task {
            do {
                if let userId = user?.id {
                    try await syncAllTables(userId: userId)
                    loadLocalData()
                }
            } catch {
                print(error)
            }
        }
    }
}
