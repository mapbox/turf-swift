import Foundation
#if !os(Linux)
import CoreLocation
#endif

/**
 A [Feature object](https://datatracker.ietf.org/doc/html/rfc7946#section-3.2) represents a spatially bounded thing.
 */
public struct Feature: Equatable, ForeignMemberContainer {
    /**
     A string or number that commonly identifies the feature in the context of a data set.
     
     Turf does not guarantee that the feature is unique; however, a data set may make such a guarantee.
     */
    public var identifier: FeatureIdentifier?
    
    /// Arbitrary, JSON-compatible attributes to associate with the feature.
    public var properties: JSONObject?
    
    /// The geometry at which the feature is located.
    public var geometry: Geometry?
    
    public var foreignMembers: JSONObject = [:]
    
    /**
     Initializes a feature located at the given geometry.
     
     - parameter geometry: The geometry at which the feature is located.
     */
    public init(geometry: Geometry) {
        self.geometry = geometry
    }
    
    /**
     Initializes a feature defined by the given geometry-convertible instance.
     
     - parameter geometry: The geometry-convertible instance that bounds the feature.
     */
    public init(geometry: GeometryConvertible?) {
        self.geometry = geometry?.geometry
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
        geometry = try container.decodeIfPresent(Geometry.self, forKey: .geometry)
        properties = try container.decodeIfPresent(JSONObject.self, forKey: .properties)
        identifier = try container.decodeIfPresent(FeatureIdentifier.self, forKey: .identifier)
        try decodeForeignMembers(notKeyedBy: CodingKeys.self, with: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Kind.Feature, forKey: .kind)
        try container.encode(geometry, forKey: .geometry)
        try container.encodeIfPresent(properties, forKey: .properties)
        try container.encodeIfPresent(identifier, forKey: .identifier)
        try encodeForeignMembers(notKeyedBy: CodingKeys.self, to: encoder)
    }
}
