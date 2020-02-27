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
}

public enum Geometry {
    private enum CodingKeys: String, CodingKey {
        case type
        case coordinates
        case geometries
    }
    
    case Point(coordinates: CLLocationCoordinate2D)
    case LineString(coordinates: [CLLocationCoordinate2D])
    case Polygon(coordinates: [[CLLocationCoordinate2D]])
    case MultiPoint(coordinates: [CLLocationCoordinate2D])
    case MultiLineString(coordinates: [[CLLocationCoordinate2D]])
    case MultiPolygon(coordinates: [[[CLLocationCoordinate2D]]])
    case GeometryCollection(geometries: [Geometry])
    
    public var type: GeometryType {
        switch self {
        case .Point(_):
            return .Point
        case .LineString(_):
            return .LineString
        case .Polygon(_):
            return .Polygon
        case .MultiPoint(_):
            return .MultiPoint
        case .MultiLineString(_):
            return .MultiLineString
        case .MultiPolygon(_):
            return .MultiPolygon
        case .GeometryCollection(_):
            return .GeometryCollection
        }
    }
    
    public var value: Any? {
        switch self {
        case .Point(let value):
            return value
        case .LineString(let value):
            return value
        case .Polygon(let value):
            return value
        case .MultiPoint(let value):
            return value
        case .MultiLineString(let value):
            return value
        case .MultiPolygon(let value):
            return value
        case .GeometryCollection(let value):
            return value
        }
    }
}

extension Geometry {
    /// Returns coordinates if current enum case is `.Point`
    public var point: CLLocationCoordinate2D? {
        guard case let .Point(coordinates: coordinates) = self else { return nil }
        return coordinates
    }
    /// Returns coordinates if current enum case is `.LineString`
    public var lineString: [CLLocationCoordinate2D]? {
        guard case let .LineString(coordinates: coordinates) = self else { return nil }
        return coordinates
    }
    /// Returns coordinates if current enum case is `.Polygon`
    public var polygon: [[CLLocationCoordinate2D]]? {
        guard case let .Polygon(coordinates: coordinates) = self else { return nil }
        return coordinates
    }
    /// Returns coordinates if current enum case is `.MultiPoint`
    public var multiPoint: [CLLocationCoordinate2D]? {
        guard case let .MultiPoint(coordinates: coordinates) = self else { return nil }
        return coordinates
    }
    /// Returns coordinates if current enum case is `.MultiLineString`
    public var multiLineString: [[CLLocationCoordinate2D]]? {
        guard case let .MultiLineString(coordinates: coordinates) = self else { return nil }
        return coordinates
    }
    /// Returns coordinates if current enum case is `.MultiPolygon`
    public var multiPolygon: [[[CLLocationCoordinate2D]]]? {
        guard case let .MultiPolygon(coordinates: coordinates) = self else { return nil }
        return coordinates
    }
    /// Returns geometries collection if current enum case is `.GeometryCollection`
    public var geometryCollection: [Geometry]? {
        guard case let .GeometryCollection(geometries: geometries) = self else { return nil }
        return geometries
    }
}

extension Geometry: Codable {
    public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(GeometryType.self, forKey: .type)
            
            switch type {
            case .Point:
                let coordinates = try container.decode(CLLocationCoordinate2D.self, forKey: .coordinates)
                self = .Point(coordinates: coordinates)
            case .LineString:
                let coordinates = try container.decode([CLLocationCoordinate2D].self, forKey: .coordinates)
                self = .LineString(coordinates: coordinates)
            case .Polygon:
                let coordinates = try container.decode([[CLLocationCoordinate2D]].self, forKey: .coordinates)
                self = .Polygon(coordinates: coordinates)
            case .MultiPoint:
                let coordinates = try container.decode([CLLocationCoordinate2D].self, forKey: .coordinates)
                self = .MultiPoint(coordinates: coordinates)
            case .MultiLineString:
                let coordinates = try container.decode([[CLLocationCoordinate2D]].self, forKey: .coordinates)
                self = .MultiLineString(coordinates: coordinates)
            case .MultiPolygon:
                let coordinates = try container.decode([[[CLLocationCoordinate2D]]].self, forKey: .coordinates)
                self = .MultiPolygon(coordinates: coordinates)
            case .GeometryCollection:
                let geometries = try container.decode([Geometry].self, forKey: .geometries)
                self = .GeometryCollection(geometries: geometries)
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type.rawValue, forKey: .type)
            
            switch self {
            case .Point(let coordinates):
                try container.encode(coordinates, forKey: .coordinates)
            case .LineString(let coordinates):
                try container.encode(coordinates, forKey: .coordinates)
            case .Polygon(let coordinates):
                try container.encode(coordinates, forKey: .coordinates)
            case .MultiPoint(let coordinates):
                try container.encode(coordinates, forKey: .coordinates)
            case .MultiLineString(let coordinates):
                try container.encode(coordinates, forKey: .coordinates)
            case .MultiPolygon(let coordinates):
                try container.encode(coordinates, forKey: .coordinates)
            case .GeometryCollection(let geometries):
                try container.encode(geometries, forKey: .geometries)
            }
        }
}
