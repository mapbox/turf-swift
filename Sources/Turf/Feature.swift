import Foundation
#if !os(Linux)
import CoreLocation
#endif

/**
 A [Feature object](https://datatracker.ietf.org/doc/html/rfc7946#section-3.2) represents a spatially bounded thing.
 */
public struct Feature {
    public var identifier: FeatureIdentifier?
    public var properties: [String : Any?]?
    public var geometry: Geometry
    
    public init(geometry: Geometry) {
        self.geometry = geometry
    }
}

extension Feature: Codable {
    private enum CodingKeys: String, CodingKey {
        case kind = "type"
        case geometry
        case properties
        case identifier = "id"
    }
    
    enum Kind: String, Codable {
        case Feature
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _ = try container.decode(Kind.self, forKey: .kind)
        geometry = try container.decode(Geometry.self, forKey: .geometry)
        properties = try container.decodeIfPresent([String: Any?].self, forKey: .properties)
        identifier = try container.decodeIfPresent(FeatureIdentifier.self, forKey: .identifier)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Kind.Feature, forKey: .kind)
        try container.encodeIfPresent(geometry, forKey: .geometry)
        try container.encodeIfPresent(properties, forKey: .properties)
        try container.encodeIfPresent(identifier, forKey: .identifier)
    }
}
