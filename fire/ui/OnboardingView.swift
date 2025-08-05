//
//  OnboardingView.swift
//  fire
//
//  Created by pc on 30.07.25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    let pages = OnboardingPage.allPages
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemBackground).opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Progress dots
                HStack(spacing: 12) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.orange : Color.gray.opacity(0.4))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 50)
                
                // Tab view for pages
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Bottom section
                VStack(spacing: 20) {
                    if currentPage == pages.count - 1 {
                        // Get Started button
                        Button(action: {
                            withAnimation(.spring()) {
                                hasSeenOnboarding = true
                                dismiss()
                            }
                        }) {
                            HStack {
                                Image(systemName: "flame.fill")
                                Text("Start Burning")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.orange, Color.red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 32)
                    } else {
                        // Next button
                        Button(action: {
                            withAnimation(.spring()) {
                                currentPage += 1
                            }
                        }) {
                            HStack {
                                Text("Next")
                                    .fontWeight(.medium)
                                Image(systemName: "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 32)
                    }
                    
                    // Skip button
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            withAnimation(.spring()) {
                                hasSeenOnboarding = true
                                dismiss()
                            }
                        }
                        .foregroundColor(.secondary)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: page.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: page.gradientColors.first?.opacity(0.3) ?? .clear, radius: 20)
                
                Image(systemName: page.iconName)
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct OnboardingPage {
    let iconName: String
    let title: String
    let description: String
    let gradientColors: [Color]
    
    static let allPages = [
        OnboardingPage(
            iconName: "doc.text",
            title: "Write Your Thoughts",
            description: "Capture your thoughts, memories, regrets, or anything that weighs on your mind. This is your safe space to express freely.",
            gradientColors: [.blue, .cyan]
        ),
        OnboardingPage(
            iconName: "flame.fill",
            title: "Let It Burn",
            description: "Watch your words transform into beautiful flames. Sometimes the most healing thing we can do is let go and watch it all burn away.",
            gradientColors: [.orange, .red]
        ),
        OnboardingPage(
            iconName: "heart.fill",
            title: "Find Peace",
            description: "Experience the cathartic release of letting go. Or save the notes that matter to you. The choice is always yours.",
            gradientColors: [.pink, .purple]
        ),
        OnboardingPage(
            iconName: "leaf.fill",
            title: "Start Fresh",
            description: "Every burn is a new beginning. Every saved note is a treasured memory. Create your own ritual of release and renewal.",
            gradientColors: [.green, .mint]
        )
    ]
}

#Preview {
    OnboardingView()
        .preferredColorScheme(.dark)
}