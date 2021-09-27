import Foundation
#if !os(Linux)
import CoreLocation
#endif


public struct MultiPolygon: Equatable {
    public var coordinates: [[[LocationCoordinate2D]]]
    
    public init(_ coordinates: [[[LocationCoordinate2D]]]) {
        self.coordinates = coordinates
    }
    
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
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Kind.MultiPolygon, forKey: .kind)
        try container.encode(coordinates.codableCoordinates, forKey: .coordinates)
    }
}

extension MultiPolygon {
    
    public var polygons: [Polygon] {
        return coordinates.map { (coordinates) -> Polygon in
            return Polygon(coordinates)
        }
    }
    
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
