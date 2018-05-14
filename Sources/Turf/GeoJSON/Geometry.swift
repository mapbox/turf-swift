import Foundation
#if !os(Linux)
import CoreLocation
#endif

public enum GeometryType: String {
    case Point
    case LineString
    case Polygon
    case MultiPoint
    case MultiLineString
    case MultiPolygon
    
    static let allValues: [GeometryType] = [.Point, .LineString, .Polygon, .MultiPoint, .MultiLineString, .MultiPolygon]
}

public struct Geometry: Codable {
    public var type: String
    
    public var geometryType: GeometryType? {
        return GeometryType(rawValue: type)
    }
}

// `Polyline` has been renamed to `LineString`. This alias is for backwards compatibility.
public typealias Polyline = LineString

/**
 A `Point` geometry. The `coordinates` property represents a single position.
 */
public struct Point: Codable, Equatable {
    var type: String = GeometryType.Point.rawValue
    public var coordinates: CLLocationCoordinate2D
}

/**
 `LineString` geometry represents a shape consisting of two or more coordinates.
 */
public struct LineString: Codable, Equatable {
    var type: String = GeometryType.LineString.rawValue
    public var coordinates: [CLLocationCoordinate2D]
}

/**
 A `Polygon` geometry represents a shape constisting of a closed `LineString`.
 */
public struct Polygon: Codable, Equatable {
    var type: String = GeometryType.Polygon.rawValue
    public var coordinates: [[CLLocationCoordinate2D]]
    
    init(coordinates: [[CLLocationCoordinate2D]]) {
        self.coordinates = coordinates
    }
    
    public var innerRings: [Ring]? {
        get { return Array(coordinates.suffix(from: 1)).map { Ring(coordinates: $0) } }
    }
    
    public var outerRing: Ring {
        get { return Ring(coordinates: coordinates.first! ) }
    }
}

/**
 A `MultiPint` geometry. The coordinates property represents a `[CLLocationCoordinate2D]`.
 */
public struct MultiPoint: Codable, Equatable {
    var type: String = GeometryType.MultiPoint.rawValue
    public var coordinates: [CLLocationCoordinate2D]
}

/**
 A `MultiLineString` geometry. The coordinates property represent a `[CLLocationCoordinate2D]` of two or more coordinates.
 */
public struct MultiLineString: Codable, Equatable {
    var type: String = GeometryType.MultiLineString.rawValue
    public var coordinates: [[CLLocationCoordinate2D]]
}

/**
 A `MultiLineString` geometry. The coordinates property represents a `[LineString]`.
 */
public struct MultiPolygon: Codable, Equatable {
    var type: String = GeometryType.MultiLineString.rawValue
    public var coordinates: [[[CLLocationCoordinate2D]]]
}
