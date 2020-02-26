import Foundation
#if !os(Linux)
import CoreLocation
#endif


public enum GeometryType: String, Codable, CaseIterable {
    case Point
    case LineString
    case Polygon
    case MultiPoint
    case MultiLineString
    case MultiPolygon
    case GeometryCollection
    
//    static let allValues: [GeometryType] = [.Point, .LineString, .Polygon, .MultiPoint, .MultiLineString, .MultiPolygon]
}

public enum _Geometry {
    private enum CodingKeys: String, CodingKey {
        case type
        case coordinates
        case geometries
    }
    
    case Point(type: GeometryType, coordinates: CLLocationCoordinate2D)
    case LineString(type: GeometryType, coordinates: [CLLocationCoordinate2D])
    case Polygon(type: GeometryType, coordinates: [[CLLocationCoordinate2D]])
    case MultiPoint(type: GeometryType, coordinates: [CLLocationCoordinate2D])
    case MultiLineString(type: GeometryType, coordinates: [[CLLocationCoordinate2D]])
    case MultiPolygon(type: GeometryType, coordinates: [[[CLLocationCoordinate2D]]])
    case GeometryCollection(type: GeometryType, geometries: [_Geometry])
    
    public var type: GeometryType {
        switch self {
        case .Point(let type, _):
            return type
        case .LineString(let type, _):
            return type
        case .Polygon(let type, _):
            return type
        case .MultiPoint(let type, _):
            return type
        case .MultiLineString(let type, _):
            return type
        case .MultiPolygon(let type, _):
            return type
        case .GeometryCollection(let type, _):
            return type
        }
    }
    
    public var value: Any? {
        switch self {
        case .Point(_, let value):
            return value
        case .LineString(_, let value):
            return value
        case .Polygon(_, let value):
            return value
        case .MultiPoint(_, let value):
            return value
        case .MultiLineString(_, let value):
            return value
        case .MultiPolygon(_, let value):
            return value
        case .GeometryCollection(_, let value):
            return value
        }
    }
}

extension _Geometry: Codable {
    public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(GeometryType.self, forKey: .type)
            
            switch type {
            case .Point:
                let coordinates = try container.decode(CLLocationCoordinate2D.self, forKey: .coordinates)
                self = .Point(type: type, coordinates: coordinates)
            case .LineString:
                let coordinates = try container.decode([CLLocationCoordinate2D].self, forKey: .coordinates)
                self = .LineString(type: type, coordinates: coordinates)
            case .Polygon:
                let coordinates = try container.decode([[CLLocationCoordinate2D]].self, forKey: .coordinates)
                self = .Polygon(type: type, coordinates: coordinates)
            case .MultiPoint:
                let coordinates = try container.decode([CLLocationCoordinate2D].self, forKey: .coordinates)
                self = .MultiPoint(type: type, coordinates: coordinates)
            case .MultiLineString:
                let coordinates = try container.decode([[CLLocationCoordinate2D]].self, forKey: .coordinates)
                self = .MultiLineString(type: type, coordinates: coordinates)
            case .MultiPolygon:
                let coordinates = try container.decode([[[CLLocationCoordinate2D]]].self, forKey: .coordinates)
                self = .MultiPolygon(type: type, coordinates: coordinates)
            case .GeometryCollection:
                let geometries = try container.decode([_Geometry].self, forKey: .geometries)
                self = .GeometryCollection(type: type, geometries: geometries)
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type.rawValue, forKey: .type)
            
            switch self {
            case .Point(_, let coordinates):
                try container.encode(coordinates, forKey: .coordinates)
            case .LineString(_, let coordinates):
                try container.encode(coordinates, forKey: .coordinates)
            case .Polygon(_, let coordinates):
                try container.encode(coordinates, forKey: .coordinates)
            case .MultiPoint(_, let coordinates):
                try container.encode(coordinates, forKey: .coordinates)
            case .MultiLineString(_, let coordinates):
                try container.encode(coordinates, forKey: .coordinates)
            case .MultiPolygon(_, let coordinates):
                try container.encode(coordinates, forKey: .coordinates)
            case .GeometryCollection(_, let geometries):
                try container.encode(geometries, forKey: .geometries)
            }
        }
}

public struct Geometry: Codable {
    public var type: String
    
    public var geometryType: GeometryType? {
        return GeometryType(rawValue: type)
    }
}
