import Foundation
#if !os(Linux)
import CoreLocation
#endif


/**
 A `MultiLineString` geometry. The coordinates property represents a `[LineString]`.
 */
public struct MultiPolygon: Codable, Equatable {
    var type: String = GeometryType.MultiPolygon.rawValue
    public var coordinates: [[[CLLocationCoordinate2D]]]
    
    public init(_ coordinates: [[[CLLocationCoordinate2D]]]) {
        self.coordinates = coordinates
    }
    
    public init(_ polygons: [Polygon]) {
        self.coordinates = polygons.map { (polygon) -> [[CLLocationCoordinate2D]] in
            return polygon.coordinates
        }
    }
    
    public var polygons: [Polygon] {
        return coordinates.map { (coordinates) -> Polygon in
            return Polygon(coordinates)
        }
    }
}

public struct MultiPolygonFeature: GeoJSONObject {
    public var type: FeatureType = .feature
    public var identifier: FeatureIdentifier?
    public var geometry: MultiPolygon
    public var properties: [String : AnyJSONType]?
    
    public init(_ geometry: MultiPolygon) {
        self.geometry = geometry
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GeoJSONCodingKeys.self)
        geometry = try container.decode(MultiPolygon.self, forKey: .geometry)
        properties = try container.decode([String: AnyJSONType]?.self, forKey: .properties)
        identifier = try container.decodeIfPresent(FeatureIdentifier.self, forKey: .identifier)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: GeoJSONCodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(geometry, forKey: .geometry)
        try container.encode(properties, forKey: .properties)
        try container.encodeIfPresent(identifier, forKey: .identifier)
    }
}

extension MultiPolygon {

    /**
     * Determines if the given coordinate falls within any of the polygons.
     * The optional parameter `ignoreBoundary` will result in the method returning true if the given coordinate
     * lies on the boundary line of the polygon or its interior rings.
     *
     * Calls contains funcion for each contained polygon
     */
    public func contains(_ coordinate: CLLocationCoordinate2D, ignoreBoundary: Bool = false) -> Bool {
        for polygon in polygons {
            if polygon.contains(coordinate, ignoreBoundary: ignoreBoundary) {
                return true
            }
        }
        return false
    }
}
