//
//  ContentView.swift
//  fire
//
//  Created by pc on 30.07.25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        if hasSeenOnboarding {
            HomeView()
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}