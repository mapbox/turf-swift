import Foundation


#if !MAPBOX_COMMON_WITH_TURF_SWIFT_LIBRARY
public typealias FeatureCollection = TurfFeatureCollection
#endif

/**
 A [TurfFeatureCollection object](https://datatracker.ietf.org/doc/html/rfc7946#section-3.3) is a collection of TurfFeature objects.
 */
public struct TurfFeatureCollection: Equatable, ForeignMemberContainer {
    /// The features that the collection contains.
    public var features: [TurfFeature] = []
    
    public var foreignMembers: JSONObject = [:]
    
    /**
     Initializes a feature collection containing the given features.
     
     - parameter features: The features that the collection contains.
     */
    public init(features: [TurfFeature]) {
        self.features = features
    }
}

extension TurfFeatureCollection: Codable {
    private enum CodingKeys: String, CodingKey {
        case kind = "type"
        case features
    }
    
    enum Kind: String, Codable {
        case FeatureCollection
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _ = try container.decode(Kind.self, forKey: .kind)
        features = try container.decode([TurfFeature].self, forKey: .features)
        try decodeForeignMembers(notKeyedBy: CodingKeys.self, with: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Kind.FeatureCollection, forKey: .kind)
        try container.encode(features, forKey: .features)
        try encodeForeignMembers(notKeyedBy: CodingKeys.self, to: encoder)
    }
}
