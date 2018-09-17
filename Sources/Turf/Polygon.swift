import Foundation
#if !os(Linux)
import CoreLocation
#endif


/**
 A `Polygon` geometry represents a shape constisting of a closed `LineString`.
 */
public struct Polygon: Codable, Equatable {
    var type: String = GeometryType.Polygon.rawValue
    public var coordinates: [[CLLocationCoordinate2D]]
    
    public init(_ coordinates: [[CLLocationCoordinate2D]]) {
        self.coordinates = coordinates
    }
    
    public var innerRings: [Ring]? {
        get { return Array(coordinates.suffix(from: 1)).map { Ring(coordinates: $0) } }
    }
    
    public var outerRing: Ring {
        get { return Ring(coordinates: coordinates.first! ) }
    }
}

public struct PolygonFeature: GeoJSONObject {
    public var type: FeatureType = .feature
    public var identifier: FeatureIdentifier?
    public var geometry: Polygon
    public var properties: [String : AnyJSONType]?
    
    public init(_ geometry: Polygon) {
        self.geometry = geometry
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GeoJSONCodingKeys.self)
        geometry = try container.decode(Polygon.self, forKey: .geometry)
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

extension Polygon {
    
    // Ported from https://github.com/Turfjs/turf/blob/a94151418cb969868fdb42955a19a133512da0fd/packages/turf-area/index.js
    public var area: Double {
        return abs(outerRing.area) - innerRings!
            .map { abs($0.area) }
            .reduce(0, +)
    }
}

extension Polygon {
    
    /**
     * Determines if the given coordinate falls within the polygon and outside of its interior rings.
     * The optional parameter `ignoreBoundary` will result in the method returning true if the given coordinate
     * lies on the boundary line of the polygon or its interior rings.
     *
     * Ported from: https://github.com/Turfjs/turf/blob/e53677b0931da9e38bb947da448ee7404adc369d/packages/turf-boolean-point-in-polygon/index.ts#L31-L75
     */
    public func contains(_ coordinate: CLLocationCoordinate2D, ignoreBoundary: Bool = false) -> Bool {
        let bbox = BoundingBox(from: coordinates.first)
        guard bbox?.contains(coordinate) ?? false else {
            return false
        }
        guard outerRing.contains(coordinate, ignoreBoundary: ignoreBoundary) else {
            return false
        }
        if let innerRings = innerRings {
            for ring in innerRings {
                if ring.contains(coordinate, ignoreBoundary: ignoreBoundary) {
                    return false
                }
            }
        }
        return true
    }
}

