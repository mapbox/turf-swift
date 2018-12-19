import Foundation
#if !os(Linux)
import CoreLocation
#endif


/**
 A `Point` geometry. The `coordinates` property represents a single position.
 */
public struct Point: Codable, Equatable {
    var type: String = GeometryType.Point.rawValue
    public var coordinates: CLLocationCoordinate2D
    
    public init(_ coordinates: CLLocationCoordinate2D) {
        self.coordinates = coordinates
    }
}

public struct PointFeature: GeoJSONObject {
    public var type: FeatureType = .feature
    public var identifier: FeatureIdentifier?
    public var geometry: Point
    public var properties: [String : AnyJSONType]?
    
    public init(_ geometry: Point) {
        self.geometry = geometry
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GeoJSONCodingKeys.self)
        geometry = try container.decode(Point.self, forKey: .geometry)
        properties = try container.decode([String: AnyJSONType]?.self, forKey: .properties)
        identifier = try container.decodeIfPresent(FeatureIdentifier.self, forKey: .identifier)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: GeoJSONCodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(geometry, forKey: .geometry)
        try container.encode(properties, forKey: .properties)
        try container.encodeIfPresent(identifier, forKey: .identifier)
    }
}


/// Returns the point midway between two coordinates measured in degrees
public func midpoint(point1: CLLocationCoordinate2D, point2: CLLocationCoordinate2D) -> CLLocationCoordinate2D{
    let dist = point1.distance(to: point2)
    let heading = point1.direction(to: point2)
    return point1.coordinate(at: dist / 2, facing: heading)
}
