import Foundation
#if !os(Linux)
import CoreLocation
#endif

/**
 A [Geometry object](https://datatracker.ietf.org/doc/html/rfc7946#section-3.1) represents points, curves, and surfaces in coordinate space. Use an instance of this enumeration whenever a value could be any kind of Geometry object.
 */
public enum Geometry: Equatable {
    /// A single position.
    case point(_ geometry: Point)
    
    /// A collection of two or more positions, each position connected to the next position linearly.
    case lineString(_ geometry: LineString)
    
    /// Conceptually, a collection of `Ring`s that form a single connected geometry.
    case polygon(_ geometry: Polygon)
    
    /// A collection of positions that are disconnected but related.
    case multiPoint(_ geometry: MultiPoint)
    
    /// A collection of `LineString` geometries that are disconnected but related.
    case multiLineString(_ geometry: MultiLineString)
    
    /// A collection of `Polygon` geometries that are disconnected but related.
    case multiPolygon(_ geometry: MultiPolygon)
    
    /// A heterogeneous collection of geometries that are related.
    case geometryCollection(_ geometry: GeometryCollection)
    
    /// Initializes a geometry representing the given geometry–convertible instance.
    public init(_ geometry: GeometryConvertible) {
        self = geometry.geometry
    }
}

extension Geometry: Codable {
    private enum CodingKeys: String, CodingKey {
        case kind = "type"
    }
    
    enum Kind: String, Codable, CaseIterable {
        case Point
        case LineString
        case Polygon
        case MultiPoint
        case MultiLineString
        case MultiPolygon
        case GeometryCollection
    }
    
    public init(from decoder: Decoder) throws {
        let kindContainer = try decoder.container(keyedBy: CodingKeys.self)
        let container = try decoder.singleValueContainer()
        switch try kindContainer.decode(Kind.self, forKey: .kind) {
        case .Point:
            self = .point(try container.decode(Point.self))
        case .LineString:
            self = .lineString(try container.decode(LineString.self))
        case .Polygon:
            self = .polygon(try container.decode(Polygon.self))
        case .MultiPoint:
            self = .multiPoint(try container.decode(MultiPoint.self))
        case .MultiLineString:
            self = .multiLineString(try container.decode(MultiLineString.self))
        case .MultiPolygon:
            self = .multiPolygon(try container.decode(MultiPolygon.self))
        case .GeometryCollection:
            self = .geometryCollection(try container.decode(GeometryCollection.self))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .point(let point):
            try container.encode(point)
        case .lineString(let lineString):
            try container.encode(lineString)
        case .polygon(let polygon):
            try container.encode(polygon)
        case .multiPoint(let multiPoint):
            try container.encode(multiPoint)
        case .multiLineString(let multiLineString):
            try container.encode(multiLineString)
        case .multiPolygon(let multiPolygon):
            try container.encode(multiPolygon)
        case .geometryCollection(let geometryCollection):
            try container.encode(geometryCollection)
        }
    }
}

/**
 A type that can be represented as a `Geometry` instance.
 */
public protocol GeometryConvertible {
    /// The instance wrapped in a `Geometry` instance.
    var geometry: Geometry { get }
}

extension Geometry: GeometryConvertible {
    public var geometry: Geometry { return self }
}

extension Point: GeometryConvertible {
    public var geometry: Geometry { return .point(self) }
}

extension LineString: GeometryConvertible {
    public var geometry: Geometry { return .lineString(self) }
}

extension Polygon: GeometryConvertible {
    public var geometry: Geometry { return .polygon(self) }
}

extension MultiPoint: GeometryConvertible {
    public var geometry: Geometry { return .multiPoint(self) }
}

extension MultiLineString: GeometryConvertible {
    public var geometry: Geometry { return .multiLineString(self) }
}

extension MultiPolygon: GeometryConvertible {
    public var geometry: Geometry { return .multiPolygon(self) }
}

extension GeometryCollection: GeometryConvertible {
    public var geometry: Geometry { return .geometryCollection(self) }
}
