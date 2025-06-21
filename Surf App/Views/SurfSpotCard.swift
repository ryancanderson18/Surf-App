//
//  SurfSpotCard.swift
//  Surf App
//
//  Created by ryan anderson on 6/21/25.
//

import SwiftUI

/// A card view displaying surf spot information with Apple design principles
struct SurfSpotCard: View {
    // MARK: - Properties
    let surfSpot: SurfSpot
    let onTap: () -> Void
    
    @State private var isPressed = false
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Body
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                onTap()
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with name and difficulty
                headerSection
                
                // Description
                descriptionSection
                
                // Conditions (if available)
                if let conditions = surfSpot.currentConditions {
                    conditionsSection(conditions)
                }
                
                // Location info
                locationSection
            }
            .padding(16)
            .background(backgroundGradient)
            .cornerRadius(16)
            .shadow(
                color: shadowColor,
                radius: isPressed ? 2 : 8,
                x: 0,
                y: isPressed ? 1 : 4
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Surf spot \(surfSpot.name), \(surfSpot.difficulty.rawValue) difficulty")
        .accessibilityHint("Double tap to view details")
    }
    
    // MARK: - View Components
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(surfSpot.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Image(systemName: surfSpot.difficulty.icon)
                        .foregroundColor(difficultyColor)
                        .font(.caption)
                    
                    Text(surfSpot.difficulty.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(difficultyColor)
                }
            }
            
            Spacer()
            
            // Favorite button (placeholder)
            Button(action: {
                // TODO: Implement favorite functionality
            }) {
                Image(systemName: "heart")
                    .foregroundColor(.red)
                    .font(.title3)
            }
            .accessibilityLabel("Add to favorites")
        }
    }
    
    private var descriptionSection: some View {
        Text(surfSpot.description)
            .font(.body)
            .foregroundColor(.secondary)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }
    
    private func conditionsSection(_ conditions: SurfConditions) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "water.waves")
                    .foregroundColor(.blue)
                Text("Current Conditions")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                
                // Surf quality indicator
                HStack(spacing: 4) {
                    Image(systemName: conditions.isGoodForSurfing ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(conditions.isGoodForSurfing ? .green : .red)
                    Text(conditions.isGoodForSurfing ? "Good" : "Poor")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(conditions.isGoodForSurfing ? .green : .red)
                }
            }
            
            // Conditions grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ConditionRow(
                    icon: "arrow.up.and.down",
                    title: "Wave Height",
                    value: "\(String(format: "%.1f", conditions.waveHeight)) ft"
                )
                
                ConditionRow(
                    icon: "wind",
                    title: "Wind",
                    value: "\(String(format: "%.0f", conditions.windSpeed)) mph"
                )
                
                ConditionRow(
                    icon: "thermometer",
                    title: "Water Temp",
                    value: "\(String(format: "%.0f", conditions.waterTemperature))°F"
                )
                
                ConditionRow(
                    icon: conditions.tide.icon,
                    title: "Tide",
                    value: conditions.tide.rawValue
                )
            }
        }
        .padding(12)
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(12)
    }
    
    private var locationSection: some View {
        HStack {
            Image(systemName: "location.fill")
                .foregroundColor(.blue)
                .font(.caption)
            
            Text("\(String(format: "%.4f", surfSpot.location.latitude)), \(String(format: "%.4f", surfSpot.location.longitude))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button("Directions") {
                // TODO: Open in Maps app
            }
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.blue)
        }
    }
    
    // MARK: - Computed Properties
    private var difficultyColor: Color {
        switch surfSpot.difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        case .expert: return .purple
        }
    }
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(uiColor: .systemGray6).opacity(0.3)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var shadowColor: Color {
        colorScheme == .dark ? .black.opacity(0.3) : .black.opacity(0.1)
    }
}

// MARK: - Supporting Views
struct ConditionRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.caption)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    let sampleSpot = SurfSpot(
        name: "Pipeline",
        latitude: 21.6628,
        longitude: -158.0456,
        description: "World-famous surf break known for its powerful waves and barrel sections.",
        difficulty: .expert,
        currentConditions: SurfConditions(
            waveHeight: 8.5,
            windSpeed: 12.0,
            windDirection: "NE",
            tide: .rising,
            waterTemperature: 78.0,
            airTemperature: 82.0,
            swellDirection: "NW",
            swellPeriod: 12
        )
    )
    
    return SurfSpotCard(surfSpot: sampleSpot) {
        print("Card tapped")
    }
    .padding()
} 