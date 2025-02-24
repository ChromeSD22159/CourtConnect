//
//  NoteView.swift
//  CourtConnect
//
//  Created by Frederik Kohler on 18.02.25.
//
import SwiftUI
import SwiftData 
import Auth

@Observable class NoteViewModel: AuthProtocol {
    var repository = Repository.shared
    var user: User?
    var userAccount: UserAccount?
    var userProfile: UserProfile?
    var currentTeam: Team?
    
    var isAddNoteSheet = false
    var notes: [Note] = []
    var selectedNote: Note?
    
    init() {
        inizializeAuth()
        getAllNotes()
    }
    
    func getAllNotes() {
        do {
            guard let user = user else { throw UserError.userIdNotFound }
            notes = try repository.noteRepository.getAllNotes(userId: user.id)
        } catch {
            ErrorHandlerViewModel.shared.handleError(error: error)
        }
    }
    
    func delete(note: Note) {
        repository.noteRepository.deleteNote(note: note)
        getAllNotes()
    }
    
    func edit(note: Note) {
        selectedNote = note
    }
}

struct NoteView: View {
    @State private var viewModel = NoteViewModel()
    var body: some View {
        AnimationBackgroundChange {
            List {
                Section {
                    ListInfomationSection(text: "Looks like you haven't written any notes. Let's get started!")
                }
                .blurrylistRowBackground()
                 
                if viewModel.notes.isEmpty {
                    Section {
                        ContentUnavailableView("No Notes Yet", systemImage: "note.text", description: Text("Looks like you haven't written any notes"))
                    }
                    .blurrylistRowBackground()
                } else {
                    Section {
                        ForEach(viewModel.notes) { note in
                            NoteAccourdion(note: note)
                                .swipeActions {
                                    Button("Delete", systemImage: "trash", role: .destructive) {
                                        viewModel.delete(note: note)
                                    }
                                    
                                    Button("Edit", systemImage: "pencil", role: .cancel) {
                                        viewModel.edit(note: note)
                                    }
                                }
                        }
                    } footer: {
                        Text("Total Notes: \(viewModel.notes.count)")
                    }
                    .blurrylistRowBackground()
                }
            }
        }
        .listBackgroundAnimated()
        .navigationTitle(title: "Your Notes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.isAddNoteSheet.toggle()
                } label: {
                    Image(systemName: "note.text.badge.plus")
                }
                .foregroundStyle(.primary)
            }
        }
        .sheet(item: $viewModel.selectedNote) { note in
            EditNoteViewSheet(note: note)
                .onDisappear {
                    viewModel.getAllNotes()
                }
        }
        .sheet(isPresented: $viewModel.isAddNoteSheet) {
            AddNoteViewSheet()
                .onDisappear {
                    viewModel.getAllNotes()
                }
        }
    }
}

private struct NoteAccourdion: View {
    let note: Note
    
    @State private var isExpant = false
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(note.title)
                    .font(.subheadline)
                    .foregroundStyle(Theme.text)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .rotationEffect(Angle(degrees: isExpant ? 90 : -0), anchor: .center)
            }
            
            Text("\(note.date.toDateString()) \(note.date.toTimeString())")
                .foregroundStyle(Theme.text.opacity(0.8))
                .font(.caption2)
            
            if isExpant {
                Text(note.desc)
                    .font(.subheadline)
            }
        }
        .onTapGesture {
            withAnimation {
                isExpant.toggle()
            }
        }
        .padding(3)
    }
} 

#Preview {
    NavigationStack {
        NoteView()
    }
}
