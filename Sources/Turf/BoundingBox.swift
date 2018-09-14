import Foundation
#if !os(Linux)
import CoreLocation
#endif

public class BoundingBox {
    
    public init?(points: [CLLocationCoordinate2D]?) {
        guard points?.count ?? 0 > 0 else {
            return nil
        }
        (minLat, maxLat, minLon, maxLon) = points!
            .reduce((minLat: 0, maxLat: 0, minLon: 0, maxLon: 0)) { (result, coordinate) -> (minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) in
                let minLat = min(coordinate.latitude, result.0)
                let maxLat = max(coordinate.latitude, result.1)
                let minLon = min(coordinate.longitude, result.2)
                let maxLon = max(coordinate.longitude, result.3)
                return (minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon)
        }
    }
    
    public func contains(point: CLLocationCoordinate2D) -> Bool {
        return minLat < point.latitude && maxLat > point.latitude && minLon < point.longitude && maxLon > point.longitude
    }
    
    // MARK: - Private
    
    let minLat: Double
    let maxLat: Double
    let minLon: Double
    let maxLon: Double
}
