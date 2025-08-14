//
//  FireApp.swift
//  fire
//
//  Created by pc on 30.07.25.
//

import SwiftUI
import SwiftData

// @main
struct FireApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Note.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .preferredColorScheme(.dark) // Lock to dark mode
        }
    }
}

// MARK: - SwiftData Model

@Model
class Note {
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var preview: String
    
    init(title: String = "", content: String) {
        self.id = UUID()
        self.title = title.isEmpty ? "Untitled Note" : title
        self.content = content
        self.createdAt = Date()
        
        // Create preview from content (first 100 characters)
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedContent.count > 100 {
            self.preview = String(trimmedContent.prefix(100)) + "..."
        } else {
            self.preview = trimmedContent.isEmpty ? "Empty note" : trimmedContent
        }
    }
}

