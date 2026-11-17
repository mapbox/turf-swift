import Foundation
#if !os(Linux)
import CoreLocation
#endif

let metersPerRadian: LocationDistance = 6_373_000.0
// WGS84 equatorial radius as specified by the International Union of Geodesy and Geophysics
let equatorialRadius: LocationDistance = 6_378_137

/// A segment between two positions in a `LineString` geometry or `Ring`.
public typealias LineSegment = (LocationCoordinate2D, LocationCoordinate2D)

/**
 Returns the intersection of two line segments.
 
 This function is roughly equivalent to the [turf-line-intersect](https://turfjs.org/docs/#lineIntersect) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-line-intersect/)), except that it only accepts individual line segments instead of whole line strings.
 
 - seealso: `LineString.intersection(with:)`
 */
public func intersection(_ line1: LineSegment, _ line2: LineSegment) -> LocationCoordinate2D? {
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
    let intersection = LocationCoordinate2D(latitude: line1.0.latitude + a * (line1.1.latitude - line1.0.latitude),
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
public func mid(_ coord1: LocationCoordinate2D, _ coord2: LocationCoordinate2D) -> LocationCoordinate2D {
    let dist = coord1.distance(to: coord2)
    let heading = coord1.direction(to: coord2)
    return coord1.coordinate(at: dist / 2, facing: heading)
}

/**
 Returns all self-intersection coordinates for a set of rings or polyline chains.
 
 - parameter chains: An array of coordinate sequences (e.g. rings of a polygon, or lines in a multi-line string).
 - parameter areClosed: Whether each chain is treated as a closed ring.
 */
func selfIntersections(for chains: [[LocationCoordinate2D]], areClosed: Bool) -> [LocationCoordinate2D] {
    var intersections = Set<HashableCoordinate>()
    
    let segmentChains: [[LineSegment]] = chains.map { coords in
        guard coords.count > 1 else { return [] }
        return zip(coords.dropLast(), coords.dropFirst()).map { LineSegment($0.0, $0.1) }
    }
    
    for (chainIndex1, segments1) in segmentChains.enumerated() {
        let isClosed1 = areClosed || (chains[chainIndex1].count > 2 && chains[chainIndex1].first == chains[chainIndex1].last)
        let m1 = segments1.count
        
        for i in 0..<m1 {
            let seg1 = segments1[i]
            for j in (i + 1)..<m1 {
                let seg2 = segments1[j]
                
                // Skip adjacent segments (they share vertex i+1)
                if j == i + 1 {
                    continue
                }
                
                // For closed chains, skip the first and last segment sharing the closing vertex
                if isClosed1 && i == 0 && j == m1 - 1 {
                    if let pt = Turf.intersection(seg1, seg2) {
                        let closingVertex = seg1.0
                        if pt != closingVertex {
                            intersections.insert(.init(pt))
                        }
                    }
                    continue
                }
                
                // For non-adjacent segments, test intersection
                if let pt = Turf.intersection(seg1, seg2) {
                    intersections.insert(.init(pt))
                } else {
                    if seg1.0 == seg2.0 || seg1.0 == seg2.1 {
                        intersections.insert(.init(seg1.0))
                    } else if seg1.1 == seg2.0 || seg1.1 == seg2.1 {
                        intersections.insert(.init(seg1.1))
                    }
                }
            }
        }
        
        for (chainIndex2, segments2) in segmentChains.enumerated() where chainIndex2 > chainIndex1 {
            for seg1 in segments1 {
                for seg2 in segments2 {
                    if let pt = Turf.intersection(seg1, seg2) {
                        intersections.insert(.init(pt))
                    } else {
                        if seg1.0 == seg2.0 || seg1.0 == seg2.1 {
                            intersections.insert(.init(seg1.0))
                        } else if seg1.1 == seg2.0 || seg1.1 == seg2.1 {
                            intersections.insert(.init(seg1.1))
                        }
                    }
                }
            }
        }
    }
    
    return intersections.map { $0.locationCoordinate }
}

/**
 Takes a geometry and returns all self-intersections (kinks).
 
 This function is equivalent to the [turf-kinks](https://turfjs.org/docs/#kinks) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-kinks/)).
 
 - parameter geometry: The geometry to inspect for self-intersections.
 - returns: An array of coordinates where the geometry intersects itself.
 */
public func kinks(_ geometry: GeometryConvertible) -> [LocationCoordinate2D] {
    return geometry.geometry.selfIntersections
}
