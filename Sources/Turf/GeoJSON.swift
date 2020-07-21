import Foundation
#if !os(Linux)
import CoreLocation
#endif

public enum FeatureType: String, Codable {
    case feature = "Feature"
    case featureCollection = "FeatureCollection"
}

struct FeatureProxy: Codable {
    public var type: FeatureType
        
    private enum CodingKeys: String, CodingKey {
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            type = try container.decode(FeatureType.self, forKey: .type)
        } catch {
            throw GeoJSONError.noTypeFound
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
    }
}

public protocol GeoJSONObject: Codable {
    var type: FeatureType { get }
    var identifier: FeatureIdentifier? { get set }
    var properties: [String: Any?]? { get set }
}

public enum GeoJSONError: Error {
    case unknownType
    case noTypeFound
}

public class GeoJSON: Codable {
    
    public var decoded: Codable?
    public var decodedFeature: Feature? {
        return decoded as? Feature
    }
    public var decodedFeatureCollection: FeatureCollection? {
        return decoded as? FeatureCollection
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let featureProxy = try container.decode(FeatureProxy.self)
        
        switch featureProxy.type {
        case .feature:
            self.decoded = try container.decode(Feature.self)
        case .featureCollection:
            self.decoded = try container.decode(FeatureCollection.self)
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
