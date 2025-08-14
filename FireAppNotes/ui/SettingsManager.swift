//
//  SettingsManager.swift
//  fire
//
//  Created by pc on 30.07.25.
//

import Foundation

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: "isSoundEnabled")
        }
    }
    
    @Published var isVibrationEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isVibrationEnabled, forKey: "isVibrationEnabled")
        }
    }
    
    private init() {
        // Default both to true
        self.isSoundEnabled = UserDefaults.standard.object(forKey: "isSoundEnabled") as? Bool ?? true
        self.isVibrationEnabled = UserDefaults.standard.object(forKey: "isVibrationEnabled") as? Bool ?? true
    }
    
    func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
    }
}