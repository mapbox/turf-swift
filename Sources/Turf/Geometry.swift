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
    
    case point(_ geometry: Point)
    case lineString(_ geometry: LineString)
    case polygon(_ geometry: Polygon)
    case multiPoint(_ geometry: MultiPoint)
    case multiLineString(_ geometry: MultiLineString)
    case multiPolygon(_ geometry: MultiPolygon)
    case geometryCollection(_ geometry: GeometryCollection)
    
    public var type: GeometryType {
        switch self {
        case .point(_):
            return .Point
        case .lineString(_):
            return .LineString
        case .polygon(_):
            return .Polygon
        case .multiPoint(_):
            return .MultiPoint
        case .multiLineString(_):
            return .MultiLineString
        case .multiPolygon(_):
            return .MultiPolygon
        case .geometryCollection(_):
            return .GeometryCollection
        }
    }
    
    public var value: Any? {
        switch self {
        case .point(let value):
            return value
        case .lineString(let value):
            return value
        case .polygon(let value):
            return value
        case .multiPoint(let value):
            return value
        case .multiLineString(let value):
            return value
        case .multiPolygon(let value):
            return value
        case .geometryCollection(let value):
            return value
        }
    }
}


extension Geometry: Codable {
    public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(GeometryType.self, forKey: .type)
            
            switch type {
            case .Point:
                let coordinates = try container.decode(CLLocationCoordinate2DCodable.self, forKey: .coordinates).decodedCoordinates
                self = .point(.init(coordinates))
            case .LineString:
                let coordinates = try container.decode([CLLocationCoordinate2DCodable].self, forKey: .coordinates).decodedCoordinates
                self = .lineString(.init(coordinates))
            case .Polygon:
                let coordinates = try container.decode([[CLLocationCoordinate2DCodable]].self, forKey: .coordinates).decodedCoordinates
                self = .polygon(.init(coordinates))
            case .MultiPoint:
                let coordinates = try container.decode([CLLocationCoordinate2DCodable].self, forKey: .coordinates).decodedCoordinates
                self = .multiPoint(.init(coordinates))
            case .MultiLineString:
                let coordinates = try container.decode([[CLLocationCoordinate2DCodable]].self, forKey: .coordinates).decodedCoordinates
                self = .multiLineString(.init(coordinates))
            case .MultiPolygon:
                let coordinates = try container.decode([[[CLLocationCoordinate2DCodable]]].self, forKey: .coordinates).decodedCoordinates
                self = .multiPolygon(.init(coordinates))
            case .GeometryCollection:
                let geometries = try container.decode([Geometry].self, forKey: .geometries)
                self = .geometryCollection(.init(geometries: geometries))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type.rawValue, forKey: .type)
            
            switch self {
            case .point(let representation):
                try container.encode(representation.coordinates.codableCoordinates, forKey: .coordinates)
            case .lineString(let representation):
                try container.encode(representation.coordinates.codableCoordinates, forKey: .coordinates)
            case .polygon(let representation):
                try container.encode(representation.coordinates.codableCoordinates, forKey: .coordinates)
            case .multiPoint(let representation):
                try container.encode(representation.coordinates.codableCoordinates, forKey: .coordinates)
            case .multiLineString(let representation):
                try container.encode(representation.coordinates.codableCoordinates, forKey: .coordinates)
            case .multiPolygon(let representation):
                try container.encode(representation.coordinates.codableCoordinates, forKey: .coordinates)
            case .geometryCollection(let representation):
                try container.encode(representation.geometries, forKey: .geometries)
            }
        }
}
