import Foundation
#if !os(Linux)
import CoreLocation
#endif

public struct BoundingBox: Codable {
    
    public init?(from coordinates: [CLLocationCoordinate2D]?) {
        guard coordinates?.count ?? 0 > 0 else {
            return nil
        }
        let startValue = (minLat: coordinates!.first!.latitude, maxLat: coordinates!.first!.latitude, minLon: coordinates!.first!.longitude, maxLon: coordinates!.first!.longitude)
        let (minLat, maxLat, minLon, maxLon) = coordinates!
            .reduce(startValue) { (result, coordinate) -> (minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) in
                let minLat = min(coordinate.latitude, result.0)
                let maxLat = max(coordinate.latitude, result.1)
                let minLon = min(coordinate.longitude, result.2)
                let maxLon = max(coordinate.longitude, result.3)
                return (minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon)
        }
        southWest = CLLocationCoordinate2D(latitude: minLat, longitude: minLon)
        northEast = CLLocationCoordinate2D(latitude: maxLat, longitude: maxLon)
    }
    
    public init(_ southWest: CLLocationCoordinate2D, _ northEast: CLLocationCoordinate2D) {
        self.southWest = southWest
        self.northEast = northEast
    }
    
    public func contains(_ coordinate: CLLocationCoordinate2D, ignoreBoundary: Bool = true) -> Bool {
        if ignoreBoundary {
            return southWest.latitude < coordinate.latitude
                && northEast.latitude > coordinate.latitude
                && southWest.longitude < coordinate.longitude
                && northEast.longitude > coordinate.longitude
        } else {
            return southWest.latitude <= coordinate.latitude
                && northEast.latitude >= coordinate.latitude
                && southWest.longitude <= coordinate.longitude
                && northEast.longitude >= coordinate.longitude
        }
    }
    
    // MARK: - Codable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(southWest.codableCoordinates)
        try container.encode(northEast.codableCoordinates)
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        southWest = try container.decode(CLLocationCoordinate2DCodable.self).decodedCoordinates
        northEast = try container.decode(CLLocationCoordinate2DCodable.self).decodedCoordinates
    }
    
    // MARK: - Properties
    
    public var southWest: CLLocationCoordinate2D
    public var northEast: CLLocationCoordinate2D
}
