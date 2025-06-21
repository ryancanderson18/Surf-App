//
//  SurfSpot.swift
//  Surf App
//
//  Created by ryan anderson on 6/21/25.
//

import Foundation
import CoreLocation

/// Represents a surf spot with location and condition information
struct SurfSpot: Identifiable, Codable, Equatable {
    // MARK: - Properties
    let id: UUID
    let name: String
    let location: CLLocationCoordinate2D
    let description: String
    let difficulty: SurfDifficulty
    let currentConditions: SurfConditions?
    
    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double,
        description: String,
        difficulty: SurfDifficulty,
        currentConditions: SurfConditions? = nil
    ) {
        self.id = id
        self.name = name
        self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.description = description
        self.difficulty = difficulty
        self.currentConditions = currentConditions
    }
    
    static func == (lhs: SurfSpot, rhs: SurfSpot) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.location.latitude == rhs.location.latitude &&
        lhs.location.longitude == rhs.location.longitude &&
        lhs.description == rhs.description &&
        lhs.difficulty == rhs.difficulty &&
        lhs.currentConditions == rhs.currentConditions
    }
}

// MARK: - Supporting Types
enum SurfDifficulty: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    
    var color: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "yellow"
        case .advanced: return "orange"
        case .expert: return "red"
        }
    }
    
    var icon: String {
        switch self {
        case .beginner: return "1.circle.fill"
        case .intermediate: return "2.circle.fill"
        case .advanced: return "3.circle.fill"
        case .expert: return "4.circle.fill"
        }
    }
}

struct SurfConditions: Codable, Equatable {
    let waveHeight: Double // in feet
    let windSpeed: Double // in mph
    let windDirection: String
    let tide: TideType
    let waterTemperature: Double // in Fahrenheit
    let airTemperature: Double // in Fahrenheit
    let swellDirection: String
    let swellPeriod: Int // in seconds
    
    var isGoodForSurfing: Bool {
        waveHeight >= 2.0 && waveHeight <= 12.0 &&
        windSpeed <= 15.0 &&
        swellPeriod >= 8
    }
}

enum TideType: String, CaseIterable, Codable {
    case low = "Low"
    case rising = "Rising"
    case high = "High"
    case falling = "Falling"
    
    var icon: String {
        switch self {
        case .low: return "arrow.down.circle"
        case .rising: return "arrow.up.circle"
        case .high: return "arrow.up.circle.fill"
        case .falling: return "arrow.down.circle.fill"
        }
    }
}

// MARK: - CLLocationCoordinate2D Codable Extension
extension CLLocationCoordinate2D: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    private enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
} 