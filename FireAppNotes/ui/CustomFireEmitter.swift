//
//  CustomFireEmitter.swift
//  fire
//
//  Created by pc on 30.07.25.
//

import SpriteKit

class CustomFireEmitter {
    
    static func createFireParticleEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        
        // Set particle texture - based on the .sks file which uses "spark"
        emitter.particleTexture = SKTexture(imageNamed: "spark")
        
        // Basic emission properties
        emitter.particleBirthRate = 100
        emitter.numParticlesToEmit = 0 // Emit continuously
        
        // Particle lifetime
        emitter.particleLifetime = 2.0
        emitter.particleLifetimeRange = 0.4
        
        // Starting position and variance
        emitter.particlePositionRange = CGVector(dx: 20, dy: 5)
        
        // Emission angle and spread
        emitter.emissionAngle = CGFloat.pi / 2 // Upward
        emitter.emissionAngleRange = CGFloat.pi / 4 // 45 degree spread
        
        // Speed properties
        emitter.particleSpeed = 100
        emitter.particleSpeedRange = 50
        
        // Acceleration (gravity effect)
        emitter.yAcceleration = -50
        
        // Scale properties
        emitter.particleScale = 0.3
        emitter.particleScaleRange = 0.2
        emitter.particleScaleSpeed = -0.2
        
        // Alpha properties
        emitter.particleAlpha = 0.8
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = -0.5
        
        // Color properties (fire colors: red to orange to yellow)
        emitter.particleColor = SKColor.red
        emitter.particleColorRedRange = 0.3
        emitter.particleColorGreenRange = 0.3
        emitter.particleColorBlueRange = 0.0
        
        emitter.particleColorRedSpeed = 0.0
        emitter.particleColorGreenSpeed = 0.2
        emitter.particleColorBlueSpeed = 0.0
        
        // Rotation
        emitter.particleRotation = 0
        emitter.particleRotationRange = CGFloat.pi
        emitter.particleRotationSpeed = 2
        
        // Blend mode for fire effect
        emitter.particleBlendMode = .add
        
        return emitter
    }
}