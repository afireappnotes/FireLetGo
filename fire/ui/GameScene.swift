//
//  GameScene.swift
//  fire
//
//  Created by pc on 30.07.25.
//

import SpriteKit
import GameplayKit
import AVFoundation
import UIKit

class GameScene: SKScene {
    private var fireStarted = false
    private var audioPlayer: AVAudioPlayer?
    private var hapticTimer: Timer?

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        setupAudio()
    }

    func triggerFire() {
        guard !fireStarted else { return }
        fireStarted = true

        guard let fireEmitter = SKEmitterNode(fileNamed: "fireParticke.sks") else {
            print("❌ Failed to load fireParticke.sks")
            return
        }

        fireEmitter.particlePositionRange = CGVector(dx: size.width, dy: 0)
        fireEmitter.position = CGPoint(x: size.width / 2, y: size.height)
        fireEmitter.targetNode = self
        fireEmitter.particleBirthRate *= size.width / 40.0
        fireEmitter.numParticlesToEmit = Int(7 * fireEmitter.particleBirthRate)

        addChild(fireEmitter)
        fireEmitter.run(.moveBy(x: 0, y: -size.height, duration: 5))
        
        // Play fire sound if enabled
        if SettingsManager.shared.isSoundEnabled {
            playFireSound()
        }
        
        // Start vibration if enabled
        if SettingsManager.shared.isVibrationEnabled {
            startVibration()
        }
    }
    
    private func setupAudio() {
        guard let url = Bundle.main.url(forResource: "fire7", withExtension: "wav") else {
            print("❌ Fire sound file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 0.5
            audioPlayer?.prepareToPlay()
        } catch {
            print("❌ Failed to setup audio: \(error)")
        }
    }
    
    private func playFireSound() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }
    
    private func startVibration() {
        // Create a 5-second vibration pattern
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.prepare()
        
        // Initial strong vibration
        impactFeedback.impactOccurred(intensity: 1.0)
        
        // Create timer for continuous vibration over 5 seconds
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] timer in
            let lightFeedback = UIImpactFeedbackGenerator(style: .light)
            lightFeedback.impactOccurred(intensity: 0.7)
            
            // Stop after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                timer.invalidate()
                self?.hapticTimer = nil
            }
        }
    }
}

class PassthroughSKView: SKView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false // Ignore all touches
    }
}
