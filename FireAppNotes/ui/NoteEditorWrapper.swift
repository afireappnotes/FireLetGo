//
//  NoteEditorWrapper.swift
//  fire
//
//  Created by pc on 30.07.25.
//

import SwiftUI
import UIKit

struct NoteEditorWrapper: UIViewControllerRepresentable {
    let existingNote: Note?
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    init(existingNote: Note? = nil, onSave: @escaping (String) -> Void) {
        self.existingNote = existingNote
        self.onSave = onSave
    }
    
    func makeUIViewController(context: Context) -> NoteEditorViewController {
        let controller = NoteEditorViewController()
        controller.onSave = onSave
        controller.onDismiss = {
            dismiss()
        }
        
        // If editing existing note, populate the text view
        if let existingNote = existingNote {
            DispatchQueue.main.async {
                controller.populateWithNote(content: existingNote.content)
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: NoteEditorViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    NoteEditorWrapper { content in
        print("Saved: \(content)")
    }
    .preferredColorScheme(.dark)
}