import Foundation


public struct FeatureCollection: GeoJSONObject {
    public let type: FeatureType = .featureCollection
    public var identifier: FeatureIdentifier?
    public var features: Array<Feature> = []
    public var properties: [String : Any?]?
    
    private enum CodingKeys: String, CodingKey {
        case type
        case properties
        case features
    }
    
    public init(features: [Feature]) {
        self.features = features
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.features = try container.decode([Feature].self, forKey: .features)
        self.properties = try container.decodeIfPresent([String: Any?].self, forKey: .properties)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(features, forKey: .features)
        try container.encodeIfPresent(properties, forKey: .properties)
    }
}
