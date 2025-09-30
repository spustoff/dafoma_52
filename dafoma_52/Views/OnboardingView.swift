//
//  OnboardingView.swift
//  ChronicleSpark
//
//  Created by Вячеслав on 9/30/25.
//

import SwiftUI
import Charts

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("primaryFocusAreas") private var primaryFocusAreasData = Data()
    @State private var currentStep = 0
    @State private var focusAreas: [String] = []
    @State private var newFocusArea = ""
    @State private var animateChart = false
    
    private let totalSteps = 3
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress indicator
                    ProgressView(value: Double(currentStep + 1), total: Double(totalSteps))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // Content
                    TabView(selection: $currentStep) {
                        // Step 1: Welcome
                        welcomeStep
                            .tag(0)
                        
                        // Step 2: Focus Areas Setup
                        focusAreasStep
                            .tag(1)
                        
                        // Step 3: Features Overview
                        featuresStep
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentStep)
                    
                    // Navigation buttons
                    HStack {
                        if currentStep > 0 {
                            Button("Back") {
                                withAnimation {
                                    currentStep -= 1
                                }
                            }
                            .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Button(currentStep == totalSteps - 1 ? "Get Started" : "Next") {
                            if currentStep == totalSteps - 1 {
                                completeOnboarding()
                            } else {
                                withAnimation {
                                    currentStep += 1
                                }
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(25)
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Step 1: Welcome
    
    private var welcomeStep: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App icon and title
            VStack(spacing: 20) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .scaleEffect(animateChart ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateChart)
                
                VStack(spacing: 8) {
                    Text("Welcome to")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("ChronicleSpark Up")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
            
            // Description
            VStack(spacing: 16) {
                Text("Your productivity companion")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("ChronicleSpark helps you optimize your time, track your progress, and achieve your goals with intelligent insights and beautiful visualizations.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            .padding(.horizontal)
            
            // Sample chart preview
            if #available(iOS 16.0, *) {
                sampleChartView
                    .frame(height: 150)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .onAppear {
            animateChart = true
        }
    }
    
    // MARK: - Step 2: Focus Areas Setup
    
    private var focusAreasStep: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "target")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("Set Your Focus Areas")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("What areas of your life would you like to improve? Add your primary focus areas to get personalized insights.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            // Focus areas input
            VStack(spacing: 16) {
                HStack {
                    TextField("Enter focus area (e.g., Work, Health, Learning)", text: $newFocusArea)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Add") {
                        addFocusArea()
                    }
                    .disabled(newFocusArea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(newFocusArea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(8)
                }
                
                // Display added focus areas
                if !focusAreas.isEmpty {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                        ForEach(focusAreas, id: \.self) { area in
                            HStack {
                                Text(area)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    removeFocusArea(area)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .cornerRadius(16)
                        }
                    }
                }
                
                // Suggested focus areas
                if focusAreas.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Suggestions:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                            ForEach(["Work", "Health", "Learning", "Personal", "Finance", "Fitness"], id: \.self) { suggestion in
                                Button(suggestion) {
                                    newFocusArea = suggestion
                                    addFocusArea()
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(16)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .onSubmit {
            addFocusArea()
        }
    }
    
    // MARK: - Step 3: Features Overview
    
    private var featuresStep: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                
                Text("Powerful Features")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Discover what makes ChronicleSpark special")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            // Features list
            VStack(spacing: 20) {
                FeatureRow(
                    icon: "chart.bar.fill",
                    title: "Dynamic Time Allocation",
                    description: "Visualize and optimize your daily activities",
                    color: .blue
                )
                
                FeatureRow(
                    icon: "lightbulb.fill",
                    title: "Intelligent Suggestions",
                    description: "Get personalized task recommendations",
                    color: .orange
                )
                
                FeatureRow(
                    icon: "timer",
                    title: "Focus Mode & Pomodoro",
                    description: "Boost productivity with timed focus sessions",
                    color: .red
                )
                
                FeatureRow(
                    icon: "link",
                    title: "Cross-Reference Insights",
                    description: "Connect tasks and notes seamlessly",
                    color: .green
                )
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    // MARK: - Sample Chart View
    
    @available(iOS 16.0, *)
    private var sampleChartView: some View {
        let sampleData = [
            (day: "Mon", productivity: 65),
            (day: "Tue", productivity: 78),
            (day: "Wed", productivity: 82),
            (day: "Thu", productivity: 71),
            (day: "Fri", productivity: 89),
            (day: "Sat", productivity: 45),
            (day: "Sun", productivity: 52)
        ]
        
        return Chart(sampleData, id: \.day) { item in
            BarMark(
                x: .value("Day", item.day),
                y: .value("Productivity", item.productivity)
            )
            .foregroundStyle(Color.blue.gradient)
            .cornerRadius(4)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(position: .bottom)
        }
    }
    
    // MARK: - Helper Methods
    
    private func addFocusArea() {
        let trimmed = newFocusArea.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !focusAreas.contains(trimmed) {
            focusAreas.append(trimmed)
            newFocusArea = ""
        }
    }
    
    private func removeFocusArea(_ area: String) {
        focusAreas.removeAll { $0 == area }
    }
    
    private func completeOnboarding() {
        // Save focus areas
        if let encoded = try? JSONEncoder().encode(focusAreas) {
            primaryFocusAreasData = encoded
        }
        
        // Mark onboarding as completed
        hasCompletedOnboarding = true
    }
}

// MARK: - Feature Row Component

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    OnboardingView()
}
