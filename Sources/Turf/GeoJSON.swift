import Foundation
#if !os(Linux)
import CoreLocation
#endif


public class Feature: Codable {
    
    public var type: String
    public var properties: [String : AnyJSONType]?
    
    // Used to extract the geometry’s type w/o double decoding its coordinates
    fileprivate var simplifiedGeometry: Geometry
    
    private enum CodingKeys: String, CodingKey {
        case type
        case properties
        case simplifiedGeometry = "geometry"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        properties = try container.decode([String : AnyJSONType]?.self, forKey: .properties)
        type = try container.decode(String.self, forKey: .type)
        simplifiedGeometry = try container.decode(Geometry.self, forKey: .simplifiedGeometry)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(properties, forKey: .properties)
        try container.encode(type, forKey: .type)
    }
}

public struct Geometry: Codable {
    public var type: String
}

public struct LineString: Codable {
    var type: String
    var coordinates: [CLLocationCoordinate2D]
}

public struct Polygon: Codable {
    var type: String = GeoJSON.GeometryType.Polygon.rawValue
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
    var type: String
    var coordinates: CLLocationCoordinate2D
}

public struct MultiPoint: Codable {
    var coordinates: [CLLocationCoordinate2D]
}

public struct MultiLineString: Codable {
    var coordinates: [[CLLocationCoordinate2D]]
}

public struct MultiPolygon: Codable {
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

public struct FeatureCollection: Codable {
    
    public var properties: [String : AnyJSONType]?
    public var features: [Feature]
    
    private enum CodingKeys: String, CodingKey {
        case properties
        case features
    }
    
    private enum GeometryCodingKeys: String, CodingKey {
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        properties = try container.decode([String : AnyJSONType]?.self, forKey: .properties)
        
        var features = [Feature]()
        var featureTypes = [Feature.Type]()
        
        if var unkeyedContainer = try? container.nestedUnkeyedContainer(forKey: .features) {
            while (!unkeyedContainer.isAtEnd) {
                let feature = try unkeyedContainer.decode(Feature.self)
                
                if let geometryType = GeoJSON.GeometryType(rawValue: feature.simplifiedGeometry.type) {
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
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.properties, forKey: .properties)
        try container.encode(self.features, forKey: .features)
    }
}

public class GeoJSON {
    
    public enum GeometryType: String {
        case LineString
        case Polygon
        case Point
        case MultiPoint
        case MultiLineString
        case MultiPolygon
        
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
}
