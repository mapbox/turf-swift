import Foundation
#if !os(Linux)
import CoreLocation
#endif


// `Polyline` has been renamed to `LineString`. This alias is for backwards compatibility.
public typealias Polyline = LineString


/**
 `LineString` geometry represents a shape consisting of two or more coordinates.
 */
public struct LineString: Codable, Equatable {
    var type: String = GeometryType.LineString.rawValue
    public var coordinates: [CLLocationCoordinate2D]
}

public struct LineStringFeature: GeoJSONObject {
    public var identifier: FeatureIdentifier?
    public var geometry: LineString!
    public var properties: [String : AnyJSONType]?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GeoJSONCodingKeys.self)
        geometry = try container.decode(LineString.self, forKey: .geometry)
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
