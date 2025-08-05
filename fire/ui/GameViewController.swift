//
//  GameViewController.swift
//  fire
//
//  Created by pc on 30.07.25.
//


import UIKit
import SpriteKit

class NoteEditorViewController: UIViewController {
    private let skView = PassthroughSKView()
    private let burnableContainer = UIView()
    private let maskLayer = CAShapeLayer()
    private var gameScene: GameScene?

    private let textView = UITextView()
    private let placeholderLabel = UILabel()
    let topToolbar = UIStackView()
    
    // Callbacks for SwiftUI integration
    var onSave: ((String) -> Void)?
    var onDismiss: (() -> Void)?
    
    // UI State
    private var saveButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        setupBackgroundView()
        setupBurnableNoteUI()
        setupSKView()
    }

    private func setupBackgroundView() {
        let backgroundLabel = UILabel()
        backgroundLabel.text = "Note is gone."
        backgroundLabel.textColor = .secondaryLabel
        backgroundLabel.font = UIFont.boldSystemFont(ofSize: 24)
        backgroundLabel.translatesAutoresizingMaskIntoConstraints = false

        let backButton = makeStyledCapsuleButton(title: "Go Home", color: .systemBlue, icon: "house.fill", useGradient: false)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(goHome), for: .touchUpInside)

        view.addSubview(backgroundLabel)
        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            backgroundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backButton.topAnchor.constraint(equalTo: backgroundLabel.bottomAnchor, constant: 10)
        ])
    }

    private func setupBurnableNoteUI() {
        burnableContainer.backgroundColor = .systemBackground
        burnableContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(burnableContainer)

        NSLayoutConstraint.activate([
            burnableContainer.topAnchor.constraint(equalTo: view.topAnchor),
            burnableContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            burnableContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            burnableContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        // Text Container
        let textContainer = UIView()
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        textContainer.layer.cornerRadius = 16
        textContainer.layer.masksToBounds = true
        textContainer.backgroundColor = UIColor.secondarySystemBackground
        burnableContainer.addSubview(textContainer)

        textView.font = UIFont.systemFont(ofSize: 18)
        textView.backgroundColor = .clear
        textView.textColor = UIColor.label
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        textContainer.addSubview(textView)

        placeholderLabel.text = "Write something you wanna let go..."
        placeholderLabel.textColor = UIColor.placeholderText
        placeholderLabel.font = textView.font
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.addSubview(placeholderLabel)

        topToolbar.axis = .horizontal
        topToolbar.spacing = 12
        topToolbar.alignment = .center
        topToolbar.translatesAutoresizingMaskIntoConstraints = false
        burnableContainer.addSubview(topToolbar)

        saveButton = makeStyledCapsuleButton(title: "Save", color: .systemBlue, icon: "square.and.arrow.down", useGradient: false)
        saveButton.addTarget(self, action: #selector(saveNote), for: .touchUpInside)
        saveButton.isEnabled = false // Initially disabled
        saveButton.alpha = 0.5

        let burnButton = makeStyledCapsuleButton(title: "Burn", color: .systemRed, icon: "flame.fill", useGradient: true)
        burnButton.addTarget(self, action: #selector(startBurn), for: .touchUpInside)

        topToolbar.addArrangedSubview(saveButton)
        topToolbar.addArrangedSubview(burnButton)

        NSLayoutConstraint.activate([
            topToolbar.topAnchor.constraint(equalTo: burnableContainer.safeAreaLayoutGuide.topAnchor, constant: 16),
            topToolbar.trailingAnchor.constraint(equalTo: burnableContainer.trailingAnchor, constant: -16),
            
            textContainer.topAnchor.constraint(equalTo: topToolbar.bottomAnchor, constant: 16),
            textContainer.leadingAnchor.constraint(equalTo: burnableContainer.leadingAnchor, constant: 16),
            textContainer.trailingAnchor.constraint(equalTo: burnableContainer.trailingAnchor, constant: -16),
            textContainer.bottomAnchor.constraint(equalTo: burnableContainer.safeAreaLayoutGuide.bottomAnchor, constant: -10),

            textView.topAnchor.constraint(equalTo: textContainer.topAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: 12),
            textView.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor, constant: -12),
            textView.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor, constant: -12),

            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 6),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 5),
        ])
    }

    private func makeStyledCapsuleButton(title: String, color: UIColor, icon: String, useGradient: Bool = false) -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: icon, withConfiguration: config)

        button.setImage(image, for: .normal)
        button.setTitle(" \(title)", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        button.layer.cornerRadius = 22
        
        let color = !useGradient ? UIColor.systemBlue : UIColor.systemOrange
        button.backgroundColor = color.withAlphaComponent(0.2)
        button.setTitleColor(color, for: .normal)
        button.tintColor = color
        
        // Add subtle border
        button.layer.borderWidth = 1
        button.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        
        return button
    }

    private func setupSKView() {
        skView.backgroundColor = .clear
        skView.allowsTransparency = true
        skView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add skView as the bottom layer, edge to edge
        view.insertSubview(skView, at: 0)
        
        NSLayoutConstraint.activate([
            skView.topAnchor.constraint(equalTo: view.topAnchor),
            skView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            skView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            skView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        skView.presentScene(scene)
        gameScene = scene
    }

    // MARK: - Actions

    @objc private func saveNote() {
        guard !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        print("💾 Note saved.")
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        // Call the save callback with the text content
        onSave?(textView.text)
        
        // Dismiss the view controller
        onDismiss?()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func goHome() {
        print("🏠 Going back to home.")
        onDismiss?()
    }

    @objc private func startBurn() {
        burnableContainer.isUserInteractionEnabled = false

        let duration: CFTimeInterval = 5.0
        let startRect = CGRect(x: 0, y: 8, width: burnableContainer.bounds.width, height: burnableContainer.bounds.height)
        let endRect = CGRect(x: 0, y: burnableContainer.bounds.height + 8, width: burnableContainer.bounds.width, height: 0)

        maskLayer.path = UIBezierPath(rect: startRect).cgPath
        burnableContainer.layer.mask = maskLayer

        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = UIBezierPath(rect: startRect).cgPath
        animation.toValue = UIBezierPath(rect: endRect).cgPath
        animation.duration = duration
//        animation.timingFunction = .linear
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        maskLayer.add(animation, forKey: "burnMask")

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        gameScene?.triggerFire()
    }
}

extension NoteEditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        updateSaveButtonState()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = true
    }
    
    private func updateSaveButtonState() {
        let hasText = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        UIView.animate(withDuration: 0.3) {
            self.saveButton.isEnabled = hasText
            self.saveButton.alpha = hasText ? 1.0 : 0.5
        }
    }
    
    // Method to populate text view with existing content
    func populateWithNote(content: String) {
        textView.text = content
        placeholderLabel.isHidden = !content.isEmpty
        updateSaveButtonState()
    }
}
