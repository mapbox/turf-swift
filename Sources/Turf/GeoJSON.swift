import Foundation
#if !os(Linux)
import CoreLocation
#endif

public protocol GeoJSONFeature: Codable { }

public struct LineString: Codable {
    var coordinates: [CLLocationCoordinate2D]
}

public struct Point: Codable {
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

public struct Polygon {
    
    var outerRing: Ring
    var innerRings: [Ring]
    
    init(outerRing: Ring, innerRings: [Ring]) {
        self.outerRing = outerRing
        self.innerRings = innerRings
    }
}

public struct GeoJSON<Geometry: Codable>: GeoJSONFeature {
    
    private enum CodingKeys: String, CodingKey {
        case geoJSONType = "type"
        case properties
        case geometry
    }
    
    public enum GeoJSONType: String, Codable {
        case Feature
    }
    
    public var geoJSONType: GeoJSONType?
    public var properties: [String: AnyJSONType]?
    public var geometry: Geometry?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        geoJSONType = try container.decode(GeoJSONType.self, forKey: .geoJSONType)
        properties = try container.decodeIfPresent([String: AnyJSONType].self, forKey: .properties)
        geometry = try container.decode(Geometry.self, forKey: .geometry)
    }
}
