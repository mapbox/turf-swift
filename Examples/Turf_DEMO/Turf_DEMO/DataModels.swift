//
//  DataModels.swift
//  Turf_DEMO
//
//  Created by Juniper Rodriguez on 4/27/26.
//
import CoreLocation
import Turf

struct MockUser: Identifiable {
    let id = UUID()
    let name: String
    let neighborhood: String
    let coordinate: CLLocationCoordinate2D
    let defaultMaxTravel: Double // meters
}
 
struct Venue: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let rating: Double
}

struct VoronoiCell: Identifiable {
    let id = UUID()
    let venueName: String
    let vertices: [CLLocationCoordinate2D]
}

enum MeetStrategy: String, CaseIterable, Identifiable {
    case midpoint = "Midpoint"
    case weighted = "Weighted"
    case venueFilter = "Filter"
    case voronoi = "Voronoi"
    var id: String { rawValue }
}
 
// MARK: - Hardcoded Data
 
enum SampleData {
    static let mary = MockUser(
        name: "Mary P.",
        neighborhood: "Hyde Park",
        coordinate: CLLocationCoordinate2D(latitude: 41.7943, longitude: -87.5907),
        defaultMaxTravel: 6000,
    )
    
    static let selena = MockUser(
        name: "Selena S.",
        neighborhood: "Logan Square",
        coordinate: CLLocationCoordinate2D(latitude: 41.9215, longitude: -87.7080),
        defaultMaxTravel: 10000,
    )
    
    static let venues: [Venue] = [
        Venue(name: "Cafe Jumping Bean",
              coordinate: CLLocationCoordinate2D(latitude: 41.8577, longitude: -87.6628),
              rating: 4.7),
        Venue(name: "Bridgeport Coffeehouse",
              coordinate: CLLocationCoordinate2D(latitude: 41.8379, longitude: -87.6509),
              rating: 4.5),
        Venue(name: "Two Shades Cafe",
              coordinate: CLLocationCoordinate2D(latitude: 41.8695, longitude: -87.6563),
              rating: 4.5),
        Venue(name: "Anticonquista Café",
              coordinate: CLLocationCoordinate2D(latitude: 41.8583, longitude: -87.6507),
              rating: 4.9),
        Venue(name: "Stockyard Coffeehouse",
              coordinate: CLLocationCoordinate2D(latitude: 41.8273, longitude: -87.6410),
              rating: 4.7),
    ]
    
    // Precomputed via scipy.spatial.Voronoi, clipped to bounding box
    static let voronoiCells: [VoronoiCell] = [
        VoronoiCell(venueName: "Cafe Jumping Bean", vertices: [
            CLLocationCoordinate2D(latitude: 41.862172, longitude: -87.656957),
            CLLocationCoordinate2D(latitude: 41.848154, longitude: -87.656262),
            CLLocationCoordinate2D(latitude: 41.817058, longitude: -87.708000),
            CLLocationCoordinate2D(latitude: 41.890289, longitude: -87.708000),
            CLLocationCoordinate2D(latitude: 41.862172, longitude: -87.656957),
        ]),
        VoronoiCell(venueName: "Bridgeport Coffeehouse", vertices: [
            CLLocationCoordinate2D(latitude: 41.848154, longitude: -87.656262),
            CLLocationCoordinate2D(latitude: 41.847892, longitude: -87.629577),
            CLLocationCoordinate2D(latitude: 41.794300, longitude: -87.686958),
            CLLocationCoordinate2D(latitude: 41.794300, longitude: -87.708000),
            CLLocationCoordinate2D(latitude: 41.817058, longitude: -87.708000),
            CLLocationCoordinate2D(latitude: 41.848154, longitude: -87.656262),
        ]),
        VoronoiCell(venueName: "Two Shades Cafe", vertices: [
            CLLocationCoordinate2D(latitude: 41.862172, longitude: -87.656957),
            CLLocationCoordinate2D(latitude: 41.890289, longitude: -87.708000),
            CLLocationCoordinate2D(latitude: 41.921500, longitude: -87.708000),
            CLLocationCoordinate2D(latitude: 41.921500, longitude: -87.590700),
            CLLocationCoordinate2D(latitude: 41.895300, longitude: -87.590700),
            CLLocationCoordinate2D(latitude: 41.862172, longitude: -87.656957),
        ]),
        VoronoiCell(venueName: "Anticonquista Café", vertices: [
            CLLocationCoordinate2D(latitude: 41.862172, longitude: -87.656957),
            CLLocationCoordinate2D(latitude: 41.895300, longitude: -87.590700),
            CLLocationCoordinate2D(latitude: 41.860057, longitude: -87.590700),
            CLLocationCoordinate2D(latitude: 41.847892, longitude: -87.629577),
            CLLocationCoordinate2D(latitude: 41.848154, longitude: -87.656262),
            CLLocationCoordinate2D(latitude: 41.862172, longitude: -87.656957),
        ]),
        VoronoiCell(venueName: "Stockyard Coffeehouse", vertices: [
            CLLocationCoordinate2D(latitude: 41.860057, longitude: -87.590700),
            CLLocationCoordinate2D(latitude: 41.794300, longitude: -87.590700),
            CLLocationCoordinate2D(latitude: 41.794300, longitude: -87.686958),
            CLLocationCoordinate2D(latitude: 41.847892, longitude: -87.629577),
            CLLocationCoordinate2D(latitude: 41.860057, longitude: -87.590700),
        ]),
    ]
}



