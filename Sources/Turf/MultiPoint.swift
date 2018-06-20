import Foundation
#if !os(Linux)
import CoreLocation
#endif


/**
 A `MultiPint` geometry. The coordinates property represents a `[CLLocationCoordinate2D]`.
 */
public struct MultiPoint: Codable, Equatable {
    var type: String = GeometryType.MultiPoint.rawValue
    public var coordinates: [CLLocationCoordinate2D]
}

public struct MultiPointFeature: GeoJSONObject {
    public var identifier: FeatureIdentifier?
    public var geometry: MultiPoint!
    public var properties: [String : AnyJSONType]?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GeoJSONCodingKeys.self)
        geometry = try container.decode(MultiPoint.self, forKey: .geometry)
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
