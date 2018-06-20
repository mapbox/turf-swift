import Foundation
#if !os(Linux)
import CoreLocation
#endif


/**
 A `Polygon` geometry represents a shape constisting of a closed `LineString`.
 */
public struct Polygon: Codable, Equatable {
    var type: String = GeometryType.Polygon.rawValue
    public var coordinates: [[CLLocationCoordinate2D]]
    
    init(coordinates: [[CLLocationCoordinate2D]]) {
        self.coordinates = coordinates
    }
    
    public var innerRings: [Ring]? {
        get { return Array(coordinates.suffix(from: 1)).map { Ring(coordinates: $0) } }
    }
    
    public var outerRing: Ring {
        get { return Ring(coordinates: coordinates.first! ) }
    }
}

public struct PolygonFeature: GeoJSONObject {
    public var identifier: FeatureIdentifier?
    public var geometry: Polygon!
    public var properties: [String : AnyJSONType]?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GeoJSONCodingKeys.self)
        geometry = try container.decode(Polygon.self, forKey: .geometry)
        properties = try container.decode([String: AnyJSONType]?.self, forKey: .properties)
        identifier = try container.decodeIfPresent(FeatureIdentifier.self, forKey: .identifier)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: GeoJSONCodingKeys.self)
        try container.encode(geometry, forKey: .geometry)
        try container.encode(properties, forKey: .properties)
        try container.encodeIfPresent(identifier, forKey: .identifier)
    }
}
