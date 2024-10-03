import Foundation
#if !os(Linux)
import CoreLocation
#endif

let metersPerRadian: LocationDistance = 6_373_000.0
// WGS84 equatorial radius as specified by the International Union of Geodesy and Geophysics
let equatorialRadius: LocationDistance = 6_378_137

#if !MAPBOX_COMMON_WITH_TURF_SWIFT_LIBRARY
public typealias LineSegment = TurfLineSegment
#endif

/// A segment between two positions in a `TurfLineString` geometry or `TurfRing`.
public typealias TurfLineSegment = (TurfLocationCoordinate2D, TurfLocationCoordinate2D)

/**
 Returns the intersection of two line segments.
 
 This function is roughly equivalent to the [turf-line-intersect](https://turfjs.org/docs/#lineIntersect) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-line-intersect/)), except that it only accepts individual line segments instead of whole line strings.
 
 - seealso: `TurfLineString.intersection(with:)`
 */
public func intersection(_ line1: TurfLineSegment, _ line2: TurfLineSegment) -> TurfLocationCoordinate2D? {
    // Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-point-on-line/index.js, in turn adapted from http://jsfiddle.net/justin_c_rounds/Gd2S2/light/
    let denominator = ((line2.1.latitude - line2.0.latitude) * (line1.1.longitude - line1.0.longitude))
        - ((line2.1.longitude - line2.0.longitude) * (line1.1.latitude - line1.0.latitude))
    guard denominator != 0 else {
        return nil
    }
    
    let dStartY = line1.0.latitude - line2.0.latitude
    let dStartX = line1.0.longitude - line2.0.longitude
    let numerator1 = (line2.1.longitude - line2.0.longitude) * dStartY - (line2.1.latitude - line2.0.latitude) * dStartX
    let numerator2 = (line1.1.longitude - line1.0.longitude) * dStartY - (line1.1.latitude - line1.0.latitude) * dStartX
    let a = numerator1 / denominator
    let b = numerator2 / denominator
    
    /// Intersection when the lines are cast infinitely in both directions.
    let intersection = TurfLocationCoordinate2D(latitude: line1.0.latitude + a * (line1.1.latitude - line1.0.latitude),
                                            longitude: line1.0.longitude + a * (line1.1.longitude - line1.0.longitude))
    
    /// True if line 1 is finite and line 2 is infinite.
    let intersectsWithLine1 = a >= 0 && a <= 1
    /// True if line 2 is finite and line 1 is infinite.
    let intersectsWithLine2 = b >= 0 && b <= 1
    return intersectsWithLine1 && intersectsWithLine2 ? intersection : nil
}

/**
 Returns the point midway between two coordinates measured in degrees.
 
 This function is equivalent to the [turf-midpoint](https://turfjs.org/docs/#midpoint) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-midpoint/)). 
 */
public func mid(_ coord1: TurfLocationCoordinate2D, _ coord2: TurfLocationCoordinate2D) -> TurfLocationCoordinate2D {
    let dist = coord1.distance(to: coord2)
    let heading = coord1.direction(to: coord2)
    return coord1.coordinate(at: dist / 2, facing: heading)
}
