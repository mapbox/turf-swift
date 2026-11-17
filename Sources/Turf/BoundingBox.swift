import Foundation
#if !os(Linux)
import CoreLocation
#endif

/**
 A [bounding box](https://datatracker.ietf.org/doc/html/rfc7946#section-5) indicates the extremes of a `GeoJSONObject` along the x- and y-axes (longitude and latitude, respectively).
 */
public struct BoundingBox: Sendable {
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
    
    /// The southeasternmost position contained in the bounding box.
    public var southEast: LocationCoordinate2D {
        return LocationCoordinate2D(latitude: southWest.latitude, longitude: northEast.longitude)
    }
    
    /// The northwesternmost position contained in the bounding box.
    public var northWest: LocationCoordinate2D {
        return LocationCoordinate2D(latitude: northEast.latitude, longitude: southWest.longitude)
    }
    
    /**
     The geographic center coordinate of the bounding box.
     */
    public var center: LocationCoordinate2D {
        return LocationCoordinate2D(
            latitude: (southWest.latitude + northEast.latitude) / 2.0,
            longitude: (southWest.longitude + northEast.longitude) / 2.0
        )
    }
    
    /// The span along latitude, in degrees.
    public var latitudeSpan: LocationDegrees {
        return northEast.latitude - southWest.latitude
    }
    
    /// The span along longitude, in degrees.
    public var longitudeSpan: LocationDegrees {
        return northEast.longitude - southWest.longitude
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
    
    /**
     Returns a Boolean value indicating whether this bounding box completely contains another bounding box.
     
     - parameter other: The bounding box that may or may not be contained by this bounding box.
     - parameter ignoreBoundary: A Boolean value indicating whether bounding boxes sharing an edge should be considered contained. Defaults to `false`.
     - returns: `true` if this bounding box contains the other bounding box; `false` otherwise.
     */
    public func contains(_ other: BoundingBox, ignoreBoundary: Bool = false) -> Bool {
        if ignoreBoundary {
            return southWest.latitude < other.southWest.latitude
                && northEast.latitude > other.northEast.latitude
                && southWest.longitude < other.southWest.longitude
                && northEast.longitude > other.northEast.longitude
        } else {
            return southWest.latitude <= other.southWest.latitude
                && northEast.latitude >= other.northEast.latitude
                && southWest.longitude <= other.southWest.longitude
                && northEast.longitude >= other.northEast.longitude
        }
    }
    
    /**
     Returns a Boolean value indicating whether this bounding box intersects another bounding box.
     
     - parameter other: The other bounding box.
     - parameter ignoreBoundary: A Boolean value indicating whether touching boundaries count as an intersection. Defaults to `false` (touching boundaries count).
     - returns: `true` if the bounding boxes intersect; `false` otherwise.
     */
    public func intersects(_ other: BoundingBox, ignoreBoundary: Bool = false) -> Bool {
        if ignoreBoundary {
            return southWest.latitude < other.northEast.latitude
                && northEast.latitude > other.southWest.latitude
                && southWest.longitude < other.northEast.longitude
                && northEast.longitude > other.southWest.longitude
        } else {
            return southWest.latitude <= other.northEast.latitude
                && northEast.latitude >= other.southWest.latitude
                && southWest.longitude <= other.northEast.longitude
                && northEast.longitude >= other.southWest.longitude
        }
    }
    
    /**
     Returns the smallest bounding box that contains both this bounding box and the given bounding box.
     
     - parameter other: The other bounding box to combine with this bounding box.
     - returns: A bounding box that encompasses both bounding boxes.
     */
    public func union(_ other: BoundingBox) -> BoundingBox {
        return BoundingBox(
            southWest: LocationCoordinate2D(
                latitude: min(southWest.latitude, other.southWest.latitude),
                longitude: min(southWest.longitude, other.southWest.longitude)
            ),
            northEast: LocationCoordinate2D(
                latitude: max(northEast.latitude, other.northEast.latitude),
                longitude: max(northEast.longitude, other.northEast.longitude)
            )
        )
    }
    
    /**
     Returns the overlapping region of this bounding box and the given bounding box, if they intersect.
     
     - parameter other: The other bounding box.
     - returns: The intersection bounding box, or `nil` if the bounding boxes do not intersect.
     */
    public func intersection(_ other: BoundingBox) -> BoundingBox? {
        let minLat = max(southWest.latitude, other.southWest.latitude)
        let maxLat = min(northEast.latitude, other.northEast.latitude)
        let minLon = max(southWest.longitude, other.southWest.longitude)
        let maxLon = min(northEast.longitude, other.northEast.longitude)
        guard minLat <= maxLat && minLon <= maxLon else {
            return nil
        }
        return BoundingBox(
            southWest: LocationCoordinate2D(latitude: minLat, longitude: minLon),
            northEast: LocationCoordinate2D(latitude: maxLat, longitude: maxLon)
        )
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
