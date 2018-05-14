import Foundation
#if !os(Linux)
import CoreLocation
#endif

public protocol GeoJSONObject: Codable {
    var identifier: FeatureIdentifier? { get set }
    var properties: [String: AnyJSONType]? { get set }
}

private enum GeoJSONCodingKeys: String, CodingKey {
    case properties
    case geometry
    case identifier = "id"
}

public enum FeatureVariant {
    case pointFeature(PointFeature)
    case lineStringFeature(LineStringFeature)
    case polygonFeature(PolygonFeature)
    case multiPointFeature(MultiPointFeature)
    case multiLineStringFeature(MultiLineStringFeature)
    case multiPolygonFeature(MultiPolygonFeature)
    
    var value: Any? {
        switch self {
        case .pointFeature(let value):
            return value
        case .lineStringFeature(let value):
            return value
        case .polygonFeature(let value):
            return value
        case .multiPointFeature(let value):
            return value
        case .multiLineStringFeature(let value):
            return value
        case .multiPolygonFeature(let value):
            return value
        }
    }
}

extension FeatureVariant: Codable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .pointFeature(let value):
            try container.encode(value)
        case .lineStringFeature(let value):
            try container.encode(value)
        case .polygonFeature(let value):
            try container.encode(value)
        case .multiPointFeature(let value):
            try container.encode(value)
        case .multiLineStringFeature(let value):
            try container.encode(value)
        case .multiPolygonFeature(let value):
            try container.encode(value)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(PointFeature.self) {
            self = .pointFeature(value)
        } else if let value = try? container.decode(LineStringFeature.self) {
            self = .lineStringFeature(value)
        } else if let value = try? container.decode(PolygonFeature.self) {
            self = .polygonFeature(value)
        } else if let value = try? container.decode(MultiPointFeature.self) {
            self = .multiPointFeature(value)
        } else if let value = try? container.decode(MultiLineStringFeature.self) {
            self = .multiLineStringFeature(value)
        } else {
            self = .multiPolygonFeature(try container.decode(MultiPolygonFeature.self))
        }
    }
}

public struct Feature: Codable {
    public var type: GeoJSONType
    
    // Used to extract the geometry’s type w/o double decoding its coordinates
    fileprivate var simplifiedGeometry: Geometry?
    
    private enum CodingKeys: String, CodingKey {
        case type
        case simplifiedGeometry = "geometry"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        simplifiedGeometry = try container.decodeIfPresent(Geometry.self, forKey: .simplifiedGeometry)
        type = try GeoJSONType(rawValue: container.decode(String.self, forKey: .type))!
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type.rawValue, forKey: .type)
    }
}

public struct PointFeature: GeoJSONObject {
    public var identifier: FeatureIdentifier?
    public var geometry: Point!
    public var properties: [String : AnyJSONType]?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GeoJSONCodingKeys.self)
        geometry = try container.decode(Point.self, forKey: .geometry)
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

public struct PolygonFeature: GeoJSONObject {
    public var identifier: FeatureIdentifier?
    public var geometry: Polygon!
    public var properties: [String : AnyJSONType]?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GeoJSONCodingKeys.self)
        geometry = try container.decode(Polygon.self, forKey: .geometry)
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

public struct MultiPolygonFeature: GeoJSONObject {
    public var identifier: FeatureIdentifier?
    public var geometry: MultiPolygon!
    public var properties: [String : AnyJSONType]?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GeoJSONCodingKeys.self)
        geometry = try container.decode(MultiPolygon.self, forKey: .geometry)
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

public struct MultiPointFeature: GeoJSONObject {
    public var identifier: FeatureIdentifier?
    public var geometry: MultiPoint!
    public var properties: [String : AnyJSONType]?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GeoJSONCodingKeys.self)
        geometry = try container.decode(MultiPoint.self, forKey: .geometry)
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

public struct MultiLineStringFeature: GeoJSONObject {
    public var identifier: FeatureIdentifier?
    public var geometry: MultiLineString!
    public var properties: [String : AnyJSONType]?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GeoJSONCodingKeys.self)
        geometry = try container.decode(MultiLineString.self, forKey: .geometry)
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

public enum GeoJSONType: String {
    case Feature
    case FeatureCollection
    static let allValues: [GeoJSONType] = [.Feature, .FeatureCollection]
}

public enum GeoJSONError: Error {
    case unknownType
    case noTypeFound
}

public class GeoJSON: Codable {
    
    var decoded: Codable?
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let feature = try container.decode(Feature.self)
        
        if feature.type == .Feature {
            guard let geometryType = feature.simplifiedGeometry?.geometryType else { throw GeoJSONError.unknownType }
            
            switch geometryType {
            case .Point:
                self.decoded = try container.decode(PointFeature.self)
            case .LineString:
                self.decoded = try container.decode(LineStringFeature.self)
            case .Polygon:
                self.decoded = try container.decode(PolygonFeature.self)
            case .MultiLineString:
                self.decoded = try container.decode(MultiLineStringFeature.self)
            case .MultiPoint:
                self.decoded = try container.decode(MultiPointFeature.self)
            case .MultiPolygon:
                self.decoded = try container.decode(MultiPolygonFeature.self)
            }
        } else if feature.type == .FeatureCollection {
            self.decoded = try container.decode(FeatureCollection.self)
        } else {
            throw GeoJSONError.noTypeFound
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let value = decoded as? FeatureCollection {
            try container.encode(value)
        } else if let value = decoded as? Feature {
            try container.encode(value)
        } else {
            throw GeoJSONError.unknownType
        }
    }
    
    /**
     Parse JSON encoded data into a GeoJSON of unknown type.
     
     - Parameter data: the JSON encoded GeoJSON data.
     
     - Throws: `GeoJSONError` if the type is not compatible.
     
     - Returns: decoded GeoJSON of any compatible type.
     */
    public static func parse(_ data: Data) throws -> GeoJSON {
        return try JSONDecoder().decode(GeoJSON.self, from: data)
    }
    
    
    /**
     Parse JSON encoded data into a GeoJSON of known type.
     
     - Parameter type: The known GeoJSON type (T).
     - Parameter data: the JSON encoded GeoJSON data.
     
     - Throws: `GeoJSONError` if the type is not compatible.
     
     - Returns: decoded GeoJSON of type T.
     */
    public static func parse<T: GeoJSONObject>(_ type: T.Type, from data: Data) throws -> T {
        return try JSONDecoder().decode(T.self, from: data)
    }
}
