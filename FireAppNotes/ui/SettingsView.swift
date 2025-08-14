//
//  SettingsView.swift
//  fire
//
//  Created by pc on 30.07.25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = SettingsManager.shared
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = true
    @Environment(\.dismiss) private var dismiss
    @State private var showingOnboarding = false
    
    var body: some View {
        NavigationView {
            List {
                // Audio & Haptics Section
                Section("Audio & Haptics") {
                    HStack {
                        Image(systemName: "speaker.wave.2")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        Text("Fire Sound Effects")
                        
                        Spacer()
                        
                        Toggle("", isOn: $settings.isSoundEnabled)
                            .tint(.orange)
                    }
                    
                    HStack {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        Text("Vibration Feedback")
                        
                        Spacer()
                        
                        Toggle("", isOn: $settings.isVibrationEnabled)
                            .tint(.orange)
                    }
                }
                
                // Onboarding Section
                Section("Getting Started") {
                    Button(action: {
                        showingOnboarding = true
                    }) {
                        HStack {
                            Image(systemName: "play.circle")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Show Onboarding Again")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                
                // App Info Section
                Section("About") {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        
                        Text("Version")
                        
                        Spacer()
                        
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        Text("Fire Notes")
                        
                        Spacer()
                        
                        Text("Therapeutic Writing")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                
                // Footer section with description
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fire Notes")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("A therapeutic writing app designed to help you express thoughts, let go of what weighs you down, and find peace through the cathartic act of release.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(nil)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingView()
        }
    }
    
    private var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "\(version) (\(build))"
        }
        return "1.0.0"
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}