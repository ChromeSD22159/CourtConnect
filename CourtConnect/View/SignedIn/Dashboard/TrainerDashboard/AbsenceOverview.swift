//
//  Absenses.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 15.02.25.
//
import SwiftUI
import Auth 

struct AbsenceOverview: View {
    @State var viewModel = ShowAbsenseViewModel()
    var body: some View {
        AnimationBackgroundChange {
            List {
                if viewModel.absenses.isEmpty {
                    Section {
                        NoAbsenceAvailableView()
                    }.blurrylistRowBackground()
                } else {
                    ForEach(viewModel.absenses.sorted(by: { $0.key < $1.key }), id: \.key) { date, users in
                        Section {
                            ForEach(users, id: \.id) { user in
                                HStack {
                                    Text(user.fullName)
                                     
                                    Spacer()
                                    
                                    let startDateString = user.startDate.formatted(.dateTime.day(.twoDigits).month(.twoDigits))
                                    let endDateString = user.endDate.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year(.twoDigits))
                                    Text("from \(startDateString) until \(endDateString)")
                                }
                            }
                        } header: {
                            UpperCasedheadline(text: date.formattedDate())
                        }.blurrylistRowBackground()
                    }
                }
            }
        }
        .navigationTitle(title: "Absence Overview")
        .listBackgroundAnimated()
    }
}
 
@Observable class ShowAbsenseViewModel: AuthProtocol {
    var repository: BaseRepository = Repository.shared
    
    var user: Auth.User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    var absenses: [Date : [AbsenceUser]] = [:]
    
    init() {
        inizializeAuth()
        getAllAbsense()
    }
    
    func getAllAbsense() {
        guard let team = currentTeam else { return }
        do {
            let localAbsenses = try repository.teamRepository.getTeamFutureAbsense(for: team.id)
            
            var absenceUsers: [AbsenceUser] = []
            for absence in localAbsenses {
                guard let account = try repository.accountRepository.getAccount(id: absence.userAccountId) else { return }
                guard let user = try repository.userRepository.getUserProfileFromDatabase(userId: account.userId) else { return }
                
                absenceUsers.append(AbsenceUser(fullName: user.fullName, startDate: absence.startDate, endDate: absence.endDate))
            }
            
            let groupSorted = Dictionary(grouping: absenceUsers) { $0.startDate }
            
            self.absenses = groupSorted
        } catch {
            print(error)
        }
    }
}

struct AbsenceUser {
    let id: UUID = UUID()
    let fullName: String
    let startDate: Date
    let endDate: Date
}
