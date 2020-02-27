import Foundation


public struct FeatureCollection: GeoJSONObject {
    public var type: FeatureType = .featureCollection
    public var identifier: FeatureIdentifier?
//    public var features: Array<FeatureVariant> = []
    public var features: Array<Feature> = []
    public var properties: [String : AnyJSONType]?
    
    private enum CodingKeys: String, CodingKey {
        case type
        case properties
        case features
    }
    
    private enum GeometryCodingKeys: String, CodingKey {
        case type
    }
    
//    public init(_ features: [FeatureVariant]) {
    public init(_ features: [Feature]) {
        self.features = features
    }
    
//    public init(_ multiPolygon: MultiPolygon) {
//        self.features = multiPolygon.coordinates.map {
//            $0.count > 1 ?
//                .multiLineStringFeature(.init(.init($0))) :
//                .lineStringFeature(LineStringFeature(LineString($0[0])))
//        }
//    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.features = try container.decode([FeatureVariant].self, forKey: .features)
        self.features = try container.decode([Feature].self, forKey: .features)
        self.properties = try container.decodeIfPresent([String: AnyJSONType].self, forKey: .properties)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(features, forKey: .features)
        try container.encodeIfPresent(properties, forKey: .properties)
    }
}
