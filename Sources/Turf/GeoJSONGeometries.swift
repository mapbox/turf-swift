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

// Polyline has been renamed to `LineString`. This alias is for backwards compatibility.
public typealias Polyline = LineString

public struct Point: Codable {
    var type: String = GeometryType.Point.rawValue
    var coordinates: CLLocationCoordinate2D
}

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
    
    var outerRing: Ring {
        get { return Ring(coordinates: coordinates.first! ) }
    }
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
