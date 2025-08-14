//
//  HomeView.swift
//  fire
//
//  Created by pc on 30.07.25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.createdAt, order: .reverse) private var notes: [Note]
    @State private var showingNoteEditor = false
    @State private var selectedNote: Note?
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if notes.isEmpty {
                    EmptyStateView {
                        showingNoteEditor = true
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(notes) { note in
                                NoteCard(note: note) {
                                    selectedNote = note
                                    showingNoteEditor = true
                                }
                                .onLongPressGesture {
                                    deleteNote(note)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Fire Notes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNoteEditor = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingNoteEditor, onDismiss: {
            selectedNote = nil
        }) {
            if let existingNote = selectedNote {
                NoteEditorWrapper(existingNote: existingNote) { content in
                    // Update existing note
                    existingNote.content = content
                    let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
                    existingNote.preview = trimmed.count > 100 ? String(trimmed.prefix(100)) + "..." : (trimmed.isEmpty ? "Empty note" : trimmed)
                    showingNoteEditor = false
                    selectedNote = nil
                }
                .ignoresSafeArea()
            } else {
                NoteEditorWrapper { content in
                    // Create new note
                    let newNote = Note(content: content)
                    modelContext.insert(newNote)
                    showingNoteEditor = false
                }
                .ignoresSafeArea()
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    private func deleteNote(_ note: Note) {
        withAnimation(.spring()) {
            modelContext.delete(note)
        }
    }
}

struct EmptyStateView: View {
    let onCreateNote: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animated flame icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.orange.opacity(0.3),
                                Color.red.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 60, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(1.1)
                    .animation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                        value: true
                    )
            }
            
            VStack(spacing: 16) {
                Text("No Notes Yet")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Most thoughts are meant to be burned.\nStart writing and let them go, or save the ones that matter.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 40)
            }
            
            Button(action: onCreateNote) {
                HStack(spacing: 12) {
                    Image(systemName: "doc.badge.plus")
                        .font(.title3)
                    Text("Write Your First Note")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
                .shadow(
                    color: Color.orange.opacity(0.4),
                    radius: 12,
                    x: 0,
                    y: 4
                )
            }
            .scaleEffect(1.0)
            .animation(.spring(response: 0.3), value: true)
            
            Spacer()
        }
        .padding()
    }
}

struct NoteCard: View {
    let note: Note
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(note.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(note.preview)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Image(systemName: "doc.text")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text("\(note.content.count) characters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("Tap to edit or burn")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.orange.opacity(0.3),
                                        Color.red.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(
                color: Color.black.opacity(0.1),
                radius: 8,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3), value: true)
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
        .modelContainer(for: Note.self, inMemory: true)
}
