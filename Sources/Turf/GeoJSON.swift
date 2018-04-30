import Foundation
#if !os(Linux)
import CoreLocation
#endif

public enum FeatureIdentifier {
    case string(String)
    case int(Int)
    
    var value: Any? {
        switch self {
        case .int(let value):
            return value
        case .string(let value):
            return value
        }
    }
}

extension FeatureIdentifier: Codable {
    enum CodingKeys: String, CodingKey {
        case string, int
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            self = .int(try container.decode(Int.self))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        }
    }
}

public protocol GeometryObject: Codable { }

public protocol GeoJSONObject: Codable {
    var identifier: FeatureIdentifier? { get set }
    var properties: [String: AnyJSONType]? { get set }
}

private enum GeoJSONCodingKeys: String, CodingKey {
    case properties
    case geometry
    case identifier = "id"
}

public struct Feature: Codable {
    public var type: GeoJSONType
    
    public var properties: [String : AnyJSONType]?
    // Used to extract the geometry’s type w/o double decoding its coordinates
    fileprivate var simplifiedGeometry: Geometry?
    
    private enum CodingKeys: String, CodingKey {
        case type
        case properties
        case simplifiedGeometry = "geometry"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        simplifiedGeometry = try container.decodeIfPresent(Geometry.self, forKey: .simplifiedGeometry)
        type = try GeoJSONType(rawValue: container.decode(String.self, forKey: .type))!
        properties = try container.decode([String : AnyJSONType]?.self, forKey: .properties)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(properties, forKey: .properties)
    }
}

public struct Geometry: Codable {
    public var type: String
    
    public var geometryType: GeometryType? {
        return GeometryType(rawValue: type)
    }
}

// Polyline has been renamed to `LineString`. This alias is for backwards compatibility.
public typealias Polyline = LineString

/**
 A `LineString` struct represents a shape consisting of two or more coordinates,
 specified as `[CLLocationCoordinate2D]`
 */
public struct LineString: Codable {
    var type: String = GeometryType.LineString.rawValue
    var coordinates: [CLLocationCoordinate2D]
}

public struct Polygon: Codable {
    var type: String = GeometryType.Polygon.rawValue
    var coordinates: [[CLLocationCoordinate2D]]
    
    init(coordinates: [[CLLocationCoordinate2D]]) {
        self.coordinates = coordinates
    }
    
    var innerRings: [Ring]? {
        get { return Array(coordinates.suffix(from: 1)).map { Ring(coordinates: $0) } }
    }
    
    var outerRing: Ring? {
        get { return Ring(coordinates: coordinates.first ?? []) }
    }
}

public struct Point: Codable {
    var type: String = GeometryType.Point.rawValue
    var coordinates: CLLocationCoordinate2D
}

public struct MultiPoint: Codable {
    var type: String = GeometryType.MultiPoint.rawValue
    var coordinates: [CLLocationCoordinate2D]
}

public struct MultiLineString: Codable {
    var type: String = GeometryType.MultiLineString.rawValue
    var coordinates: [[CLLocationCoordinate2D]]
}

public struct MultiPolygon: Codable {
    var type: String = GeometryType.MultiLineString.rawValue
    var coordinates: [[[CLLocationCoordinate2D]]]
}

public class PointFeature: GeoJSONObject {
    public var identifier: FeatureIdentifier?
    public var geometry: Point!
    public var properties: [String : AnyJSONType]?
    
    public required init(from decoder: Decoder) throws {
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

public struct LineStringFeature: GeoJSONObject, GeometryObject {
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
    public var features: Array<GeoJSONObject> = []
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
        var features: Array<GeoJSONObject> = []
        var featureTypes: Array<GeoJSONObject.Type> = []
        
        if var unkeyedContainer = try? container.nestedUnkeyedContainer(forKey: .features) {
            while (!unkeyedContainer.isAtEnd) {
                let feature = try unkeyedContainer.decode(Feature.self)

                if let test = feature.simplifiedGeometry?.geometryType {
                    switch test {
                    case .LineString:
                        featureTypes.append(LineStringFeature.self)
                    case .MultiLineString:
                        featureTypes.append(MultiLineStringFeature.self)
                    case .Point:
                        featureTypes.append(PointFeature.self)
                    case .Polygon:
                        featureTypes.append(PolygonFeature.self)
                    case .MultiPolygon:
                        featureTypes.append(MultiPolygonFeature.self)
                    case .MultiPoint:
                        featureTypes.append(MultiPointFeature.self)
                    }
                }
            }
        }
        
        if var mappedContainer = try? container.nestedUnkeyedContainer(forKey: .features) {
            while !mappedContainer.isAtEnd {
                let featureType = featureTypes[mappedContainer.currentIndex]
                if featureType is LineStringFeature.Type {
                    features.append(try mappedContainer.decode(LineStringFeature.self))
                } else if featureType is PolygonFeature.Type {
                    features.append(try mappedContainer.decode(PolygonFeature.self))
                } else if featureType is PointFeature.Type {
                    features.append(try mappedContainer.decode(PointFeature.self))
                } else if featureType is MultiPoint.Type {
                    features.append(try mappedContainer.decode(MultiPointFeature.self))
                } else if featureType is MultiLineString.Type {
                    features.append(try mappedContainer.decode(MultiLineStringFeature.self))
                } else if featureType is MultiPolygon.Type {
                    features.append(try mappedContainer.decode(MultiPolygonFeature.self))
                }
            }
        }
        
        self.features = features
        self.properties = try container.decode([String: AnyJSONType]?.self, forKey: .properties)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // TODO: Using 'GeoJSONObject' as a concrete type conforming to protocol 'Encodable' is not supported
        //try container.encode(features, forKey: .features)
        try container.encode(properties, forKey: .properties)
    }
}

public enum GeometryType: String {
    case Point
    case LineString
    case Polygon
    case MultiPoint
    case MultiLineString
    case MultiPolygon
    
    static let allValues: [GeometryType] = [.Point, .LineString, .Polygon, .MultiPoint, .MultiLineString, .MultiPolygon]
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
    
    public static func parse(data: Data) throws -> GeoJSON {
        return try JSONDecoder().decode(GeoJSON.self, from: data)
    }
    
    public static func parse<T: GeoJSONObject>(data: Data, as: T.Type) throws -> T {
        return try JSONDecoder().decode(T.self, from: data)
    }
}
