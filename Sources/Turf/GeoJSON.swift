import Foundation
#if !os(Linux)
import CoreLocation
#endif


public class BaseFeature: Codable {
    private enum CodingKeys: String, CodingKey {
        case properties
    }
    
    public var properties: [String : AnyJSONType]?
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        properties = try container.decode([String : AnyJSONType]?.self, forKey: .properties)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(properties, forKey: .properties)
    }
}

public class Feature: BaseFeature {
    public var type: GeoJSONType
    
    // Used to extract the geometry’s type w/o double decoding its coordinates
    fileprivate var simplifiedGeometry: Geometry?
    
    private enum CodingKeys: String, CodingKey {
        case type
        //case properties
        case simplifiedGeometry = "geometry"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        simplifiedGeometry = try container.decodeIfPresent(Geometry.self, forKey: .simplifiedGeometry)
        type = try GeoJSONType(rawValue: container.decode(String.self, forKey: .type))!
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type.rawValue, forKey: .type)
        try super.encode(to: encoder)
    }
}

public struct Geometry: Codable {
    public var type: String
}

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

public class LineStringFeature: Feature {
    public var geometry: LineString!
    
    private enum CodingKeys: String, CodingKey {
        case properties
        case geometry
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        geometry = try container.decode(LineString.self, forKey: .geometry)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(geometry, forKey: .geometry)
        try super.encode(to: encoder)
    }
}

public class PolygonFeature: Feature {
    public var geometry: Polygon!
    
    private enum CodingKeys: String, CodingKey {
        case properties
        case geometry
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        geometry = try container.decode(Polygon.self, forKey: .geometry)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(geometry, forKey: .geometry)
        try super.encode(to: encoder)
    }
}

public class PointFeature: Feature {
    public var geometry: Point!
    
    private enum CodingKeys: String, CodingKey {
        case properties
        case geometry
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        geometry = try container.decode(Point.self, forKey: .geometry)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(geometry, forKey: .geometry)
        try super.encode(to: encoder)
    }
}

public class MultiPolygonFeature: Feature {
    public var geometry: MultiPolygon!
    
    private enum CodingKeys: String, CodingKey {
        case properties
        case geometry
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        geometry = try container.decode(MultiPolygon.self, forKey: .geometry)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(geometry, forKey: .geometry)
        try super.encode(to: encoder)
    }
}

public class MultiPointFeature: Feature {
    public var geometry: MultiPoint!
    
    private enum CodingKeys: String, CodingKey {
        case properties
        case geometry
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        geometry = try container.decode(MultiPoint.self, forKey: .geometry)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(geometry, forKey: .geometry)
        try super.encode(to: encoder)
    }
}

public class MultiLineStringFeature: Feature {
    public var geometry: MultiLineString!
    
    private enum CodingKeys: String, CodingKey {
        case properties
        case geometry
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        geometry = try container.decode(MultiLineString.self, forKey: .geometry)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(geometry, forKey: .geometry)
        try super.encode(to: encoder)
    }
}

public class FeatureCollection: BaseFeature {
    
    public var features: [Feature]
    
    private enum CodingKeys: String, CodingKey {
        case properties
        case features
    }
    
    private enum GeometryCodingKeys: String, CodingKey {
        case type
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var features = [Feature]()
        var featureTypes = [Feature.Type]()
        
        if var unkeyedContainer = try? container.nestedUnkeyedContainer(forKey: .features) {
            while (!unkeyedContainer.isAtEnd) {
                let feature = try unkeyedContainer.decode(Feature.self)
                
                if let geometryType = GeometryType(rawValue: feature.simplifiedGeometry!.type) {
                    featureTypes.append(geometryType.featureType)
                }
            }
        }
        
        if var mappedContainer = try? container.nestedUnkeyedContainer(forKey: .features) {
            while (!mappedContainer.isAtEnd) {
                let type = featureTypes[mappedContainer.currentIndex]
                let feature = try mappedContainer.decode(type.self)
                features.append(feature)
            }
        }
        
        self.features = features
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.properties, forKey: .properties)
        try container.encode(self.features, forKey: .features)
        
        try super.encode(to: encoder)
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
    
    var featureType: Feature.Type {
        switch self {
        case .LineString:
            return LineStringFeature.self
        case .Polygon:
            return PolygonFeature.self
        case .Point:
            return PointFeature.self
        case .MultiPoint:
            return MultiPointFeature.self
        case .MultiLineString:
            return MultiLineStringFeature.self
        case .MultiPolygon:
            return MultiPolygonFeature.self
        }
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
    
    var value: Codable?
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let feature = try container.decode(Feature.self)
        
        if feature.type == .Feature {
            guard let type = GeometryType(rawValue: feature.simplifiedGeometry!.type) else {
                throw GeoJSONError.unknownType
            }
            self.value = try container.decode(type.featureType)
        } else if feature.type == .FeatureCollection {
            self.value = try container.decode(FeatureCollection.self)
        } else {
            throw GeoJSONError.noTypeFound
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let value = value as? FeatureCollection {
            try container.encode(value)
        } else if let value = value as? Feature {
            try container.encode(value)
        } else {
            throw GeoJSONError.unknownType
        }
    }
    
    public static func parse(data: Data) throws -> GeoJSON {
        return try JSONDecoder().decode(GeoJSON.self, from: data)
    }
    
    public static func parse<T: BaseFeature>(data: Data, as: T.Type) throws -> T {
        return try JSONDecoder().decode(T.self, from: data)
    }
}
