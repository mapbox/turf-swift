import Foundation
#if !os(Linux)
import CoreLocation
#endif

/**
 A [Geometry object](https://datatracker.ietf.org/doc/html/rfc7946#section-3.1) represents points, curves, and surfaces in coordinate space.
 */
public enum Geometry {
    case point(_ geometry: Point)
    case lineString(_ geometry: LineString)
    case polygon(_ geometry: Polygon)
    case multiPoint(_ geometry: MultiPoint)
    case multiLineString(_ geometry: MultiLineString)
    case multiPolygon(_ geometry: MultiPolygon)
    case geometryCollection(_ geometry: GeometryCollection)
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
