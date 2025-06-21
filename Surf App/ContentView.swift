//
//  ContentView.swift
//  Surf App
//
//  Created by ryan anderson on 6/21/25.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @State private var isShowingSurfInfo = false
    @State private var selectedDifficulty: SurfDifficulty = .beginner
    @State private var showingSurfSpots = false
    @State private var showingAllSpots = true // Track if "All" is selected
    @State private var welcomeScreenDifficulty: SurfDifficulty? = nil // Track welcome screen selection
    @StateObject private var viewModel = SurfSpotViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if !showingSurfSpots {
                        // Welcome Screen
                        welcomeContent
                    } else {
                        // Surf Spots List
                        surfSpotsContent
                    }
                }
                .padding()
            }
            .navigationTitle("Surf App")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if showingSurfSpots {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Back") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingSurfSpots = false
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            Task {
                                await viewModel.refreshConditions()
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                        .disabled(viewModel.isLoading)
                    }
                }
            }
        }
    }
    
    // MARK: - Welcome Content
    private var welcomeContent: some View {
        VStack(spacing: 20) {
            // Header
            headerSection
            
            // Main Content
            mainContentSection
            
            // Difficulty Selector
            difficultySection
            
            // Action Buttons
            actionButtonsSection
        }
    }
    
    // MARK: - Surf Spots Content
    private var surfSpotsContent: some View {
        VStack(spacing: 16) {
            // Filter Section
            filterSection
            
            // Loading State
            if viewModel.isLoading {
                ProgressView("Loading surf spots...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage {
                // Error State
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title)
                        .foregroundColor(.orange)
                    
                    Text("Error")
                        .font(.headline)
                    
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Try Again") {
                        Task {
                            await viewModel.loadNearbySpots()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                // Surf Spots List
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.surfSpots) { spot in
                        SurfSpotCard(surfSpot: spot) {
                            // Handle spot selection
                            print("Selected spot: \(spot.name)")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filter by Difficulty")
                .font(.headline)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "All",
                        isSelected: showingAllSpots
                    ) {
                        showingAllSpots = true
                        viewModel.filterSpots(by: nil)
                    }
                    
                    ForEach(SurfDifficulty.allCases, id: \.self) { difficulty in
                        FilterChip(
                            title: difficulty.rawValue,
                            isSelected: !showingAllSpots && selectedDifficulty == difficulty
                        ) {
                            showingAllSpots = false
                            selectedDifficulty = difficulty
                            viewModel.filterSpots(by: difficulty)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - View Components
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "water.waves")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
                .accessibilityLabel("Surf waves icon")
            
            Text("Welcome to Surf App")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
    }
    
    private var mainContentSection: some View {
        VStack(spacing: 16) {
            Text("Your ultimate surfing companion")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if isShowingSurfInfo {
                surfInfoCard
            }
        }
    }
    
    private var surfInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("Surf Conditions")
                    .font(.headline)
                Spacer()
            }
            
            Text("Check real-time wave conditions, tides, and weather for the best surfing experience.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(12)
        .transition(.opacity.combined(with: .scale))
    }
    
    private var difficultySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Difficulty Level")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(SurfDifficulty.allCases, id: \.self) { difficulty in
                    DifficultyButton(
                        difficulty: difficulty,
                        isSelected: selectedDifficulty == difficulty
                    ) {
                        selectedDifficulty = difficulty
                        welcomeScreenDifficulty = difficulty
                    }
                }
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isShowingSurfInfo.toggle()
                }
            }) {
                HStack {
                    Image(systemName: isShowingSurfInfo ? "eye.slash" : "eye")
                    Text(isShowingSurfInfo ? "Hide Info" : "Show Info")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .accessibilityHint("Toggle surf information display")
            
            Button("Get Started") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingSurfSpots = true
                }
                Task {
                    await viewModel.loadNearbySpots()
                    // Set initial filter based on welcome screen selection
                    if let welcomeScreenDifficulty = welcomeScreenDifficulty {
                        showingAllSpots = false
                        selectedDifficulty = welcomeScreenDifficulty
                        viewModel.filterSpots(by: welcomeScreenDifficulty)
                    } else {
                        showingAllSpots = true
                        viewModel.filterSpots(by: nil)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .accessibilityHint("Begin using the surf app features")
        }
    }
}

// MARK: - Supporting Views
struct DifficultyButton: View {
    let difficulty: SurfDifficulty
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: difficulty.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : difficultyColor)
                
                Text(difficulty.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? difficultyColor : Color(uiColor: .systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(difficultyColor, lineWidth: isSelected ? 0 : 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(difficulty.rawValue) difficulty level")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
    private var difficultyColor: Color {
        switch difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        case .expert: return .purple
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color(uiColor: .systemGray5))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}
