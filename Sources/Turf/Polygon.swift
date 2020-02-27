import Foundation
#if !os(Linux)
import CoreLocation
#endif


extension Geometry {
    /// Representation of `.Polygon`s coordinates of inner rings
    /// If current enum case is not `.Polygon` - always equals `nil`
    public var innerRings: [Ring]? {
        get {
            guard let coordinates = polygon else { return nil }
            return Array(coordinates.suffix(from: 1)).map { Ring(coordinates: $0) }
        }
    }
    
    /// Representation of `.Polygon`s coordinates of outer ring
    /// If current enum case is not `.Polygon` - always equals `nil`
    public var outerRing: Ring? {
        get {
            guard let coordinates = polygon else { return nil }
            return Ring(coordinates: coordinates.first! )
        }
    }
    
    /// An are of current `.Polygon`
    /// If current enum case is not `.Polygon` - always equals `nil`
    ///
    /// Ported from https://github.com/Turfjs/turf/blob/a94151418cb969868fdb42955a19a133512da0fd/packages/turf-area/index.js
    public var area: Double? {
        guard polygon != nil else { return nil }
        return abs(outerRing!.area) - innerRings!
            .map { abs($0.area) }
            .reduce(0, +)
    }
    
    /// Determines if the given coordinate falls within the polygon and outside of its interior rings.
    /// The optional parameter `ignoreBoundary` will result in the method returning true if the given coordinate
    /// lies on the boundary line of the polygon or its interior rings.
    /// If current enum case is not `.Polygon` - always equals `nil`
    ///
    ///Ported from: https://github.com/Turfjs/turf/blob/e53677b0931da9e38bb947da448ee7404adc369d/packages/turf-boolean-point-in-polygon/index.ts#L31-L75
    public func contains(_ coordinate: CLLocationCoordinate2D, ignoreBoundary: Bool = false) -> Bool? {
        guard let coordinates = polygon else { return nil }
        
        let bbox = BoundingBox(from: coordinates.first)
        guard bbox?.contains(coordinate) ?? false else {
            return false
        }
        guard outerRing!.contains(coordinate, ignoreBoundary: ignoreBoundary) else {
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
