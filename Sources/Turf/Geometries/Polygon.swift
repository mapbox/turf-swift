import Foundation
#if !os(Linux)
import CoreLocation
#endif


public struct Polygon: Equatable {
    public var coordinates: [[CLLocationCoordinate2D]]
    
    public init(_ coordinates: [[CLLocationCoordinate2D]]) {
        self.coordinates = coordinates
    }
    
    public init(outerRing: Ring, innerRings: [Ring] = []) {
        self.coordinates = ([outerRing] + innerRings).map { $0.coordinates }
    }
}

extension Polygon {
    /// Representation of `.Polygon`s coordinates of inner rings
    public var innerRings: [Ring] {
        return Array(coordinates.suffix(from: 1)).map { Ring(coordinates: $0) }
    }
    
    /// Representation of `.Polygon`s coordinates of outer ring
    public var outerRing: Ring {
        get {
            return Ring(coordinates: coordinates.first! )
        }
    }
    
    /// An area of current `.Polygon`
    ///
    /// Ported from https://github.com/Turfjs/turf/blob/a94151418cb969868fdb42955a19a133512da0fd/packages/turf-area/index.js
    public var area: Double {
        return abs(outerRing.area) - innerRings
            .map { abs($0.area) }
            .reduce(0, +)
    }
    
    /// Determines if the given coordinate falls within the polygon and outside of its interior rings.
    /// The optional parameter `ignoreBoundary` will result in the method returning true if the given coordinate
    /// lies on the boundary line of the polygon or its interior rings.
    ///
    ///Ported from: https://github.com/Turfjs/turf/blob/e53677b0931da9e38bb947da448ee7404adc369d/packages/turf-boolean-point-in-polygon/index.ts#L31-L75
    public func contains(_ coordinate: CLLocationCoordinate2D, ignoreBoundary: Bool = false) -> Bool {
        guard outerRing.contains(coordinate, ignoreBoundary: ignoreBoundary) else {
            return false
        }
        for ring in innerRings {
            if ring.contains(coordinate, ignoreBoundary: !ignoreBoundary) {
                return false
            }
        }
        return true
    }
}
