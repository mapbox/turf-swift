import Foundation
#if !os(Linux)
import CoreLocation
#endif


/**
 A `Point` geometry. The `coordinates` property represents a single position.
 */
public struct Point: Codable, Equatable {
    var type: String = GeometryType.Point.rawValue
    public var coordinates: CLLocationCoordinate2D
}

public struct PointFeature: GeoJSONObject {
    public var identifier: FeatureIdentifier?
    public var geometry: Point!
    public var properties: [String : AnyJSONType]?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GeoJSONCodingKeys.self)
        geometry = try container.decode(Point.self, forKey: .geometry)
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
