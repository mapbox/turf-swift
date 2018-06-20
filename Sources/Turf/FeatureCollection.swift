import Foundation


public struct FeatureCollection: GeoJSONObject {
    public var identifier: FeatureIdentifier?
    public var features: Array<FeatureVariant> = []
    public var properties: [String : AnyJSONType]?
    
    private enum CodingKeys: String, CodingKey {
        case properties
        case features
    }
    
    private enum GeometryCodingKeys: String, CodingKey {
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.features = try container.decode([FeatureVariant].self, forKey: .features)
        self.properties = try container.decode([String: AnyJSONType]?.self, forKey: .properties)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(features, forKey: .features)
        try container.encode(properties, forKey: .properties)
    }
}
