import Foundation
#if !os(Linux)
import CoreLocation
#endif


public struct _Feature: GeoJSONObject {
    public var type: FeatureType = .feature
    public var identifier: FeatureIdentifier?
    public var properties: [String : AnyJSONType]?
    public var geometry: _Geometry
    
    private enum CodingKeys: String, CodingKey {
            case type
            case geometry
            case properties
            case identifier = "id"
    }
    
    public init(_ geometry: _Geometry) {
        self.geometry = geometry
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        geometry = try container.decode(_Geometry.self, forKey: .geometry)
        properties = try container.decode([String: AnyJSONType]?.self, forKey: .properties)
        identifier = try container.decodeIfPresent(FeatureIdentifier.self, forKey: .identifier)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type.rawValue, forKey: .type)
        try container.encodeIfPresent(geometry, forKey: .geometry)
        try container.encodeIfPresent(properties, forKey: .properties)
        try container.encodeIfPresent(identifier, forKey: .identifier)
    }
}
