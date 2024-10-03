import Foundation
#if !os(Linux)
import CoreLocation
#endif

#if !MAPBOX_COMMON_WITH_TURF_SWIFT_LIBRARY
public typealias Geometry = TurfGeometry
#endif

/**
 A [TurfGeometry object](https://datatracker.ietf.org/doc/html/rfc7946#section-3.1) represents points, curves, and surfaces in coordinate space. Use an instance of this enumeration whenever a value could be any kind of TurfGeometry object.
 */
public enum TurfGeometry: Equatable, Sendable {
    /// A single position.
    case point(_ geometry: TurfPoint)
    
    /// A collection of two or more positions, each position connected to the next position linearly.
    case lineString(_ geometry: TurfLineString)
    
    /// Conceptually, a collection of `TurfRing`s that form a single connected geometry.
    case polygon(_ geometry: TurfPolygon)
    
    /// A collection of positions that are disconnected but related.
    case multiPoint(_ geometry: TurfMultiPoint)
    
    /// A collection of `TurfLineString` geometries that are disconnected but related.
    case multiLineString(_ geometry: TurfMultiLineString)
    
    /// A collection of `TurfPolygon` geometries that are disconnected but related.
    case multiPolygon(_ geometry: TurfMultiPolygon)
    
    /// A heterogeneous collection of geometries that are related.
    case geometryCollection(_ geometry: TurfGeometryCollection)
    
    /// Initializes a geometry representing the given geometry–convertible instance.
    public init(_ geometry: GeometryConvertible) {
        self = geometry.geometry
    }
}

extension TurfGeometry: Codable {
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
            self = .point(try container.decode(TurfPoint.self))
        case .LineString:
            self = .lineString(try container.decode(TurfLineString.self))
        case .Polygon:
            self = .polygon(try container.decode(TurfPolygon.self))
        case .MultiPoint:
            self = .multiPoint(try container.decode(TurfMultiPoint.self))
        case .MultiLineString:
            self = .multiLineString(try container.decode(TurfMultiLineString.self))
        case .MultiPolygon:
            self = .multiPolygon(try container.decode(TurfMultiPolygon.self))
        case .GeometryCollection:
            self = .geometryCollection(try container.decode(TurfGeometryCollection.self))
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

extension TurfGeometry {
    /// A single position.
    public var point: TurfPoint? {
        if case let .point(point) = self {
            return point
        } else {
            return nil
        }

    }

    /// A collection of two or more positions, each position connected to the next position linearly.
    public var lineString: TurfLineString? {
        if case let .lineString(lineString) = self {
            return lineString
        } else {
            return nil
        }

    }

    /// Conceptually, a collection of `TurfRing`s that form a single connected geometry.
    public var polygon: TurfPolygon? {
        if case let .polygon(polygon) = self {
            return polygon
        } else {
            return nil
        }

    }

    /// A collection of positions that are disconnected but related.
    public var multiPoint: TurfMultiPoint? {
        if case let .multiPoint(multiPoint) = self {
            return multiPoint
        } else {
            return nil
        }

    }

    /// A collection of `TurfLineString` geometries that are disconnected but related.
    public var multiLineString: TurfMultiLineString? {
        if case let .multiLineString(multiLineString) = self {
            return multiLineString
        } else {
            return nil
        }

    }

    /// A collection of `TurfPolygon` geometries that are disconnected but related.
    public var multiPolygon: TurfMultiPolygon? {
        if case let .multiPolygon(multiPolygon) = self {
            return multiPolygon
        } else {
            return nil
        }

    }

    /// A heterogeneous collection of geometries that are related.
    public var geometryCollection: TurfGeometryCollection? {
        if case let .geometryCollection(geometryCollection) = self {
            return geometryCollection
        } else {
            return nil
        }

    }
}

/**
 A type that can be represented as a `TurfGeometry` instance.
 */
public protocol GeometryConvertible: Sendable {
    /// The instance wrapped in a `TurfGeometry` instance.
    var geometry: TurfGeometry { get }
}

extension TurfGeometry: GeometryConvertible {
    public var geometry: TurfGeometry { return self }
}

extension TurfPoint: GeometryConvertible {
    public var geometry: TurfGeometry { return .point(self) }
}

extension TurfLineString: GeometryConvertible {
    public var geometry: TurfGeometry { return .lineString(self) }
}

extension TurfPolygon: GeometryConvertible {
    public var geometry: TurfGeometry { return .polygon(self) }
}

extension TurfMultiPoint: GeometryConvertible {
    public var geometry: TurfGeometry { return .multiPoint(self) }
}

extension TurfMultiLineString: GeometryConvertible {
    public var geometry: TurfGeometry { return .multiLineString(self) }
}

extension TurfMultiPolygon: GeometryConvertible {
    public var geometry: TurfGeometry { return .multiPolygon(self) }
}

extension TurfGeometryCollection: GeometryConvertible {
    public var geometry: TurfGeometry { return .geometryCollection(self) }
}
