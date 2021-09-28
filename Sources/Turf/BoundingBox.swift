import Foundation
#if !os(Linux)
import CoreLocation
#endif

/**
 A [bounding box](https://datatracker.ietf.org/doc/html/rfc7946#section-5) indicates the extremes of a `GeoJSONObject` along the x- and y-axes (longitude and latitude, respectively).
 */
public struct BoundingBox {
    /// The southwesternmost position contained in the bounding box.
    public var southWest: LocationCoordinate2D
    
    /// The northeasternmost position contained in the bounding box.
    public var northEast: LocationCoordinate2D
    
    /**
     Initializes the smallest bounding box that contains all the given coordinates.
     
     - parameter coordinates: The coordinates to fit in the bounding box.
     */
    public init?(from coordinates: [LocationCoordinate2D]?) {
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
        southWest = LocationCoordinate2D(latitude: minLat, longitude: minLon)
        northEast = LocationCoordinate2D(latitude: maxLat, longitude: maxLon)
    }
    
    /**
     Initializes a bounding box defined by its southwesternmost and northeasternmost positions.
     
     - parameter southWest: The southwesternmost position contained in the bounding box.
     - parameter northEast: The northeasternmost position contained in the bounding box.
     */
    public init(southWest: LocationCoordinate2D, northEast: LocationCoordinate2D) {
        self.southWest = southWest
        self.northEast = northEast
    }
    
    /**
     Returns a Boolean value indicating whether the bounding box contains the given position.
     
     - parameter coordinate: The coordinate that may or may not be contained by the bounding box.
     - parameter ignoreBoundary: A Boolean value indicating whether a position lying exactly on the edge of the bounding box should be considered to be contained in the bounding box.
     - returns: `true` if the bounding box contains the position; `false` otherwise.
     */
    public func contains(_ coordinate: LocationCoordinate2D, ignoreBoundary: Bool = true) -> Bool {
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
}

extension BoundingBox: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(southWest.longitude)
        hasher.combine(southWest.latitude)
        hasher.combine(northEast.longitude)
        hasher.combine(northEast.latitude)
    }
}

extension BoundingBox: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(southWest.codableCoordinates)
        try container.encode(northEast.codableCoordinates)
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        southWest = try container.decode(LocationCoordinate2DCodable.self).decodedCoordinates
        northEast = try container.decode(LocationCoordinate2DCodable.self).decodedCoordinates
    }
}
