import Foundation
#if !os(Linux)
import CoreLocation
#endif


public struct Point: Equatable {
    /** Note: The pluralization of `coordinates` is defined
     in the GeoJSON RFC, so we've kept it for consistency.
     https://tools.ietf.org/html/rfc7946#section-1.5 */
    public var coordinates: LocationCoordinate2D
    
    public init(_ coordinates: LocationCoordinate2D) {
        self.coordinates = coordinates
    }
}
