import Foundation


public struct FeatureCollection: GeoJSONObject {
    public var type: FeatureType = .featureCollection
    public var identifier: FeatureIdentifier?
    public var features: Array<FeatureVariant> = []
    public var properties: [String : AnyJSONType]?
    
    private enum CodingKeys: String, CodingKey {
        case type
        case properties
        case features
    }
    
    private enum GeometryCodingKeys: String, CodingKey {
        case type
    }
    
    public init(_ features: [FeatureVariant]) {
        self.features = features
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.features = try container.decode([FeatureVariant].self, forKey: .features)
        self.properties = try container.decodeIfPresent([String: AnyJSONType].self, forKey: .properties)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(features, forKey: .features)
        try container.encodeIfPresent(properties, forKey: .properties)
    }
}
