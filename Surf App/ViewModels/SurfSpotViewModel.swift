//
//  SurfSpotViewModel.swift
//  Surf App
//
//  Created by ryan anderson on 6/21/25.
//

import Foundation
import Combine
import CoreLocation

/// ViewModel for managing surf spot data and operations
@MainActor
class SurfSpotViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var surfSpots: [SurfSpot] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedSpot: SurfSpot?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let locationManager = CLLocationManager()
    private var allSurfSpots: [SurfSpot] = [] // Store original unfiltered data
    private var currentFilter: SurfDifficulty? = nil
    
    // MARK: - Initialization
    init() {
        setupLocationManager()
        // Don't load data initially - wait for explicit loadNearbySpots() call
    }
    
    // MARK: - Public Methods
    
    /// Loads surf spots near the user's location
    func loadNearbySpots() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Simulate network delay
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // In a real app, this would fetch from an API
            allSurfSpots = generateSampleSpots()
            applyCurrentFilter()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load surf spots: \(error.localizedDescription)"
        }
    }
    
    /// Refreshes surf conditions for all spots
    func refreshConditions() async {
        guard !allSurfSpots.isEmpty else { return }
        
        isLoading = true
        
        do {
            // Simulate API call to update conditions
            try await Task.sleep(nanoseconds: 500_000_000)
            
            // Update conditions for each spot in the original data
            for i in allSurfSpots.indices {
                allSurfSpots[i] = allSurfSpots[i].updatingConditions(generateRandomConditions())
            }
            
            // Reapply current filter to show updated data
            applyCurrentFilter()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to refresh conditions: \(error.localizedDescription)"
        }
    }
    
    /// Filters spots by difficulty level
    func filterSpots(by difficulty: SurfDifficulty?) {
        currentFilter = difficulty
        applyCurrentFilter()
    }
    
    /// Searches spots by name
    func searchSpots(query: String) {
        guard !query.isEmpty else {
            applyCurrentFilter() // Reset to current filter
            return
        }
        
        // Search within the currently filtered results
        let searchResults = allSurfSpots.filter { spot in
            spot.name.localizedCaseInsensitiveContains(query) ||
            spot.description.localizedCaseInsensitiveContains(query)
        }
        
        // Apply current filter to search results
        if let currentFilter = currentFilter {
            surfSpots = searchResults.filter { $0.difficulty == currentFilter }
        } else {
            surfSpots = searchResults
        }
    }
    
    /// Toggles favorite status for a spot
    func toggleFavorite(for spot: SurfSpot) {
        // TODO: Implement favorite functionality with persistence
        print("Toggled favorite for \(spot.name)")
    }
    
    // MARK: - Private Methods
    
    private func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func loadSampleData() {
        allSurfSpots = generateSampleSpots()
        applyCurrentFilter()
    }
    
    private func applyCurrentFilter() {
        if let filter = currentFilter {
            surfSpots = allSurfSpots.filter { $0.difficulty == filter }
        } else {
            surfSpots = allSurfSpots // Show all spots
        }
    }
    
    private func generateSampleSpots() -> [SurfSpot] {
        let spots = [
            SurfSpot(
                name: "Pipeline",
                latitude: 21.6628,
                longitude: -158.0456,
                description: "World-famous surf break known for its powerful waves and barrel sections.",
                difficulty: .expert,
                currentConditions: generateRandomConditions()
            ),
            SurfSpot(
                name: "Waikiki Beach",
                latitude: 21.2789,
                longitude: -157.8294,
                description: "Perfect for beginners with gentle waves and warm water.",
                difficulty: .beginner,
                currentConditions: generateRandomConditions()
            ),
            SurfSpot(
                name: "Mavericks",
                latitude: 37.4956,
                longitude: -122.4995,
                description: "Big wave surf spot that can reach heights of 60+ feet.",
                difficulty: .expert,
                currentConditions: generateRandomConditions()
            ),
            SurfSpot(
                name: "Malibu",
                latitude: 34.0370,
                longitude: -118.6780,
                description: "Classic point break with long, peeling waves.",
                difficulty: .intermediate,
                currentConditions: generateRandomConditions()
            ),
            SurfSpot(
                name: "Trestles",
                latitude: 33.3703,
                longitude: -117.5680,
                description: "High-performance wave with multiple sections.",
                difficulty: .advanced,
                currentConditions: generateRandomConditions()
            )
        ]
        
        return spots
    }
    
    private func generateRandomConditions() -> SurfConditions {
        let waveHeights = [2.0, 3.5, 5.0, 7.0, 9.0, 12.0]
        let windSpeeds = [5.0, 8.0, 12.0, 15.0, 20.0]
        let waterTemps = [65.0, 68.0, 72.0, 75.0, 78.0, 82.0]
        let swellPeriods = [8, 10, 12, 15, 18]
        
        return SurfConditions(
            waveHeight: waveHeights.randomElement() ?? 5.0,
            windSpeed: windSpeeds.randomElement() ?? 10.0,
            windDirection: ["N", "NE", "E", "SE", "S", "SW", "W", "NW"].randomElement() ?? "NE",
            tide: TideType.allCases.randomElement() ?? .rising,
            waterTemperature: waterTemps.randomElement() ?? 72.0,
            airTemperature: (waterTemps.randomElement() ?? 72.0) + Double.random(in: 2...8),
            swellDirection: ["N", "NE", "E", "SE", "S", "SW", "W", "NW"].randomElement() ?? "NW",
            swellPeriod: swellPeriods.randomElement() ?? 12
        )
    }
}

// MARK: - SurfSpot Extension
extension SurfSpot {
    func updatingConditions(_ newConditions: SurfConditions) -> SurfSpot {
        SurfSpot(
            id: self.id,
            name: self.name,
            latitude: self.location.latitude,
            longitude: self.location.longitude,
            description: self.description,
            difficulty: self.difficulty,
            currentConditions: newConditions
        )
    }
} 