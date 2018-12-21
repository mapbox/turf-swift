import Foundation
#if !os(Linux)
import CoreLocation
#endif


let metersPerRadian: CLLocationDistance = 6_373_000.0
// WGS84 equatorial radius as specified by the International Union of Geodesy and Geophysics
let equatorialRadius: CLLocationDistance = 6_378_137

public typealias LineSegment = (CLLocationCoordinate2D, CLLocationCoordinate2D)


public struct Turf {
    
    /**
     Returns the intersection of two line segments.
     */
    public static func intersection(_ line1: LineSegment, _ line2: LineSegment) -> CLLocationCoordinate2D? {
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
        let intersection = CLLocationCoordinate2D(latitude: line1.0.latitude + a * (line1.1.latitude - line1.0.latitude),
                                                  longitude: line1.0.longitude + a * (line1.1.longitude - line1.0.longitude))
        
        /// True if line 1 is finite and line 2 is infinite.
        let intersectsWithLine1 = a > 0 && a < 1
        /// True if line 2 is finite and line 1 is infinite.
        let intersectsWithLine2 = b > 0 && b < 1
        return intersectsWithLine1 && intersectsWithLine2 ? intersection : nil
    }
}
