import Foundation
#if !os(Linux)
import CoreLocation
#endif

public enum FeatureType: String {
    case feature = "Feature"
    case featureCollection = "FeatureCollection"
}

extension FeatureType: Codable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = try container.decode(FeatureType.self)
    }
}

public protocol GeoJSONObject: Codable {
    var type: FeatureType { get }
    var identifier: FeatureIdentifier? { get set }
    var properties: [String: AnyJSONType]? { get set }
}

enum GeoJSONCodingKeys: String, CodingKey {
    case type
    case properties
    case geometry
    case identifier = "id"
}

//public enum FeatureVariant {
//    case pointFeature(PointFeature)
//    case lineStringFeature(LineStringFeature)
//    case polygonFeature(PolygonFeature)
//    case multiPointFeature(MultiPointFeature)
//    case multiLineStringFeature(MultiLineStringFeature)
//    case multiPolygonFeature(MultiPolygonFeature)
//
//    public var value: Any? {
//        switch self {
//        case .pointFeature(let value):
//            return value
//        case .lineStringFeature(let value):
//            return value
//        case .polygonFeature(let value):
//            return value
//        case .multiPointFeature(let value):
//            return value
//        case .multiLineStringFeature(let value):
//            return value
//        case .multiPolygonFeature(let value):
//            return value
//        }
//    }
//}
//
//extension FeatureVariant: Codable {
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        switch self {
//        case .pointFeature(let value):
//            try container.encode(value)
//        case .lineStringFeature(let value):
//            try container.encode(value)
//        case .polygonFeature(let value):
//            try container.encode(value)
//        case .multiPointFeature(let value):
//            try container.encode(value)
//        case .multiLineStringFeature(let value):
//            try container.encode(value)
//        case .multiPolygonFeature(let value):
//            try container.encode(value)
//        }
//    }
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        if let value = try? container.decode(PointFeature.self) {
//            self = .pointFeature(value)
//        } else if let value = try? container.decode(LineStringFeature.self) {
//            self = .lineStringFeature(value)
//        } else if let value = try? container.decode(PolygonFeature.self) {
//            self = .polygonFeature(value)
//        } else if let value = try? container.decode(MultiPointFeature.self) {
//            self = .multiPointFeature(value)
//        } else if let value = try? container.decode(MultiLineStringFeature.self) {
//            self = .multiLineStringFeature(value)
//        } else {
//            self = .multiPolygonFeature(try container.decode(MultiPolygonFeature.self))
//        }
//    }
//}

struct FeatureProxy: Codable {
    public var type: FeatureType
        
    private enum CodingKeys: String, CodingKey {
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            type = try FeatureType(rawValue: container.decode(String.self, forKey: .type))!
        } catch {
            throw GeoJSONError.noTypeFound
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type.rawValue, forKey: .type)
    }
}

public enum GeoJSONType: String, CaseIterable {
    case Feature
    case FeatureCollection
    case Unknown
}

public enum GeoJSONError: Error {
    case unknownType
    case noTypeFound
}

public class GeoJSON: Codable {
    
    public var decoded: Codable?
    public var decodedFeature: _Feature? {
        decoded as? _Feature
    }
    public var decodedFeatueCollection: FeatureCollection? {
        decoded as? FeatureCollection
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let featureProxy = try container.decode(FeatureProxy.self)
        
        switch featureProxy.type {
        case .feature:
            self.decoded = try container.decode(_Feature.self)
        case .featureCollection:
            self.decoded = try container.decode(FeatureCollection.self)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let value = decoded as? FeatureCollection {
            try container.encode(value)
        } else if let value = decoded as? _Feature {
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
    public static func parse<T: GeoJSONObject>(_ type: T.Type, from data: Data) throws -> T {  // ???
        return try JSONDecoder().decode(T.self, from: data)
    }
}
