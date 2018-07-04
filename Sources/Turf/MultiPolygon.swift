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
