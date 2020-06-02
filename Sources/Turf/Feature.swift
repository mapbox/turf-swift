import Foundation
#if !os(Linux)
import CoreLocation
#endif


public struct Feature: GeoJSONObject {
    public var type: FeatureType = .feature
    public var identifier: FeatureIdentifier?
    public var properties: [String : Any?]?
    public var geometry: Geometry
    
    private enum CodingKeys: String, CodingKey {
            case type
            case geometry
            case properties
            case identifier = "id"
    }
    
    public init(geometry: Geometry) {
        self.geometry = geometry
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        geometry = try container.decode(Geometry.self, forKey: .geometry)
        properties = try container.decodeIfPresent([String: Any?].self, forKey: .properties)
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
