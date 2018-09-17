import Foundation
#if !os(Linux)
import CoreLocation
#endif

public struct BoundingBox: Codable {
    
    public init?(from coordinates: [CLLocationCoordinate2D]?) {
        guard coordinates?.count ?? 0 > 0 else {
            return nil
        }
        let (minLat, maxLat, minLon, maxLon) = coordinates!
            .reduce((minLat: 0, maxLat: 0, minLon: 0, maxLon: 0)) { (result, coordinate) -> (minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) in
                let minLat = min(coordinate.latitude, result.0)
                let maxLat = max(coordinate.latitude, result.1)
                let minLon = min(coordinate.longitude, result.2)
                let maxLon = max(coordinate.longitude, result.3)
                return (minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon)
        }
        northWest = CLLocationCoordinate2D(latitude: maxLat, longitude: minLon)
        southEast = CLLocationCoordinate2D(latitude: minLat, longitude: maxLon)
    }
    
    public init(_ northWest: CLLocationCoordinate2D, _ southEast: CLLocationCoordinate2D) {
        self.northWest = northWest
        self.southEast = southEast
    }
    
    public func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        return southEast.latitude < coordinate.latitude
            && northWest.latitude > coordinate.latitude
            && northWest.longitude < coordinate.longitude
            && southEast.longitude > coordinate.longitude
    }
    
    // MARK: - Private
    
    let northWest: CLLocationCoordinate2D
    let southEast: CLLocationCoordinate2D
}
