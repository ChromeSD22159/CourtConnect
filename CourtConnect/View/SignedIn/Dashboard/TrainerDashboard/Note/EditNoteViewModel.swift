//
//  EditNoteViewModel.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 19.02.25.
//
import SwiftUI
import Auth

@Observable @MainActor class EditNoteViewModel: AuthProtocol {
    var repository = Repository.shared
    var user: User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    
    var id: UUID
    var title: String
    var description: String
    var remindetDate: Date
    var wantNotification: Bool
    
    init(note: Note) { 
        self.id = note.id
        self.title = note.title
        self.description = note.desc
        self.remindetDate = note.date
        self.wantNotification = note.wantNotification
        
        inizializeAuth()
    }
    
    func saveNote() throws {
        guard !title.isEmpty else { throw NoteError.titleToTooShort }
        guard !description.isEmpty else { throw NoteError.descriptionTooShort }
        guard remindetDate > Date() else { throw NoteError.dateNotInFuture }
        guard let user = user else { throw UserError.userIdNotFound }
        
        let note = Note(id: id, userId: user.id, title: title, desc: description, date: remindetDate, wantNotification: wantNotification)
        
        try repository.noteRepository.update(note: note)
    }
}

struct EditNoteViewSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EditNoteViewModel
    
    init(note: Note) {
        viewModel = EditNoteViewModel(note: note)
    }
    
    var body: some View {
        SheetStlye(title: "Edit Notes", detents: [.large], isLoading: .constant(false)) {
            Section {
                VStack(spacing: 40) {
                    TextField("", text: $viewModel.title, prompt: Text("Title e.g."))
                        .textFieldStyle(CustomTextFieldStyle(count: viewModel.title.count, max: 20))
                    
                    TextField("", text: $viewModel.description, prompt: Text("Title e.g."))
                        .textFieldStyle(CustomTextFieldStyle(count: viewModel.description.count, max: 50))
                     
                    Toggle(isOn: $viewModel.wantNotification) {
                        VStack(alignment: .leading) {
                            Text("Plan notification")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("When do you want to be remembered?")
                                .font(.caption)
                        }
                    }
                    .tint(Theme.headlineReversed)
                    
                    DatePicker("Reminder Date", selection: $viewModel.remindetDate, displayedComponents: [.date, .hourAndMinute]) 
                    
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .buttonStyle(RoundedFilledButtonStlye())
                        
                        Button("Save") {
                            do {
                                try viewModel.saveNote()
                                dismiss()
                            } catch {
                                ErrorHandlerViewModel.shared.handleError(error: error)
                            }
                        }
                        .buttonStyle(RoundedFilledButtonStlye())
                    }
                }
            }
            .padding(20)
        }
    }
}
