//
//  ViewModel.swift
//  Turf_DEMO
//
//  Created by Juniper Rodriguez on 4/27/26.
//
import Foundation
import CoreLocation
import Turf

@Observable
class ViewModel {
    
    var selectedStrategy: MeetStrategy = .midpoint
    var maryTravel: Double = SampleData.mary.defaultMaxTravel
    var selenaTravel: Double = SampleData.selena.defaultMaxTravel

    let users: (mary: MockUser, selena: MockUser) = (SampleData.mary, SampleData.selena)
    let venues: [Venue] = SampleData.venues
    let voronoiCells: [VoronoiCell] = SampleData.voronoiCells
    
    // MARK: - Result Point
    
    var resultPoint: CLLocationCoordinate2D {
        switch selectedStrategy {
        case .midpoint:
            return mid(users.mary.coordinate, users.selena.coordinate)
        case .weighted, .venueFilter, .voronoi:
            let dist = users.mary.coordinate.distance(to: users.selena.coordinate)
            let wM = 1.0 / maryTravel
            let wS = 1.0 / selenaTravel
            let ratio = wS / (wM + wS)
            let bearing = users.mary.coordinate.direction(to: users.selena.coordinate)
            return users.mary.coordinate.coordinate(at: dist * ratio, facing: bearing)
        }
    }
    
    var strategyLabel: String {
        switch selectedStrategy {
        case .midpoint: return "Midpoint"
        case .weighted: return "Weighted"
        case .venueFilter: return "Filter Origin"
        case .voronoi: return "Voronoi Origin"
        }
    }
    
    // MARK: - Circles
    
    var maryCircleCoords: [CLLocationCoordinate2D] {
        Polygon(center: users.mary.coordinate, radius: maryTravel, vertices: 64)
            .outerRing.coordinates
    }
    
    var selenaCircleCoords: [CLLocationCoordinate2D] {
        Polygon(center: users.selena.coordinate, radius: selenaTravel, vertices: 64)
            .outerRing.coordinates
    }
    
    // MARK: - Areas (Strategy 2)
    
    var maryAreaKm2: Double {
        Polygon(center: users.mary.coordinate, radius: maryTravel, vertices: 64).area / 1_000_000
    }
    
    var selenaAreaKm2: Double {
        Polygon(center: users.selena.coordinate, radius: selenaTravel, vertices: 64).area / 1_000_000
    }
    
    // MARK: - Separation
    
    var userSeparationMeters: Double {
        users.mary.coordinate.distance(to: users.selena.coordinate)
    }
    
    // MARK: - Bounding Box (Strategy 1)
    
    var boundingBoxCoords: [CLLocationCoordinate2D] {
        guard let bbox = BoundingBox(from: [users.mary.coordinate, users.selena.coordinate]) else {
            return []
        }
        let sw = bbox.southWest
        let ne = bbox.northEast
        return [
            sw,
            CLLocationCoordinate2D(latitude: sw.latitude, longitude: ne.longitude),
            ne,
            CLLocationCoordinate2D(latitude: ne.latitude, longitude: sw.longitude),
            sw,
        ]
    }
    
    // MARK: - Venue Filtering (Strategy 3)
    
    var reachableVenues: [Venue] {
        let cM = Polygon(center: users.mary.coordinate, radius: maryTravel, vertices: 64)
        let cS = Polygon(center: users.selena.coordinate, radius: selenaTravel, vertices: 64)
        return venues.filter { cM.contains($0.coordinate) && cS.contains($0.coordinate) }
    }
    
    // MARK: - Voronoi (Strategy 4)
    
    var voronoiSelectedVenue: Venue? {
        guard let cell = activeVoronoiCell else { return nil }
        return venues.first { $0.name == cell.venueName }
    }
    
    var activeVoronoiCell: VoronoiCell? {
        for cell in voronoiCells {
            let poly = Polygon(outerRing: Ring(coordinates: cell.vertices))
            if poly.contains(resultPoint) {
                return cell
            }
        }
        return nil
    }
}
