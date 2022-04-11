import Foundation
#if !os(Linux)
import CoreLocation
#endif

/**
 A [MultiPolygon geometry](https://datatracker.ietf.org/doc/html/rfc7946#section-3.1.7) is a collection of `Polygon` geometries that are disconnected but related.
 */
public struct MultiPolygon: Equatable, ForeignMemberContainer {
    /// The positions at which the multipolygon is located. Each nested array corresponds to one polygon.
    public var coordinates: [[[LocationCoordinate2D]]]
    
    public var foreignMembers: JSONObject = [:]
    
    /// The polygon geometries that conceptually form the multipolygon.
    public var polygons: [Polygon] {
        return coordinates.map { (coordinates) -> Polygon in
            return Polygon(coordinates)
        }
    }
    
    /**
     Initializes a multipolygon defined by the given positions.
     
     - parameter coordinates: The positions at which the multipolygon is located. Each nested array corresponds to one polygon.
     */
    public init(_ coordinates: [[[LocationCoordinate2D]]]) {
        self.coordinates = coordinates
    }
    
    /**
     Initializes a multipolygon coincident to the given polygons.
     
     - parameter polygons: The polygons that together are coincident to the multipolygon.
     */
    public init(_ polygons: [Polygon]) {
        self.coordinates = polygons.map { (polygon) -> [[LocationCoordinate2D]] in
            return polygon.coordinates
        }
    }
}

extension MultiPolygon: Codable {
    enum CodingKeys: String, CodingKey {
        case kind = "type"
        case coordinates
    }
    
    enum Kind: String, Codable {
        case MultiPolygon
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _ = try container.decode(Kind.self, forKey: .kind)
        let coordinates = try container.decode([[[LocationCoordinate2DCodable]]].self, forKey: .coordinates).decodedCoordinates
        self = .init(coordinates)
        try decodeForeignMembers(notKeyedBy: CodingKeys.self, with: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Kind.MultiPolygon, forKey: .kind)
        try container.encode(coordinates.codableCoordinates, forKey: .coordinates)
        try encodeForeignMembers(notKeyedBy: CodingKeys.self, to: encoder)
    }
}

extension MultiPolygon {
    /**
     * Determines if the given coordinate falls within any of the polygons.
     * The optional parameter `ignoreBoundary` will result in the method returning true if the given coordinate
     * lies on the boundary line of the polygon or its interior rings.
     *
     * Calls contains function for each contained polygon
     */
    public func contains(_ coordinate: LocationCoordinate2D, ignoreBoundary: Bool = false) -> Bool {
        return polygons.contains {
            $0.contains(coordinate, ignoreBoundary: ignoreBoundary)
        }
    }
}
