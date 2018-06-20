import Foundation
#if !os(Linux)
import CoreLocation
#endif

public typealias LocationRadians = Double
public typealias RadianDistance = Double
public typealias RadianDirection = Double

/**
 A `RadianCoordinate2D` is a coordinate represented in radians as opposed to
 `CLLocationCoordinate2D` which is represented in latitude and longitude.
 */
public struct RadianCoordinate2D {
    private(set) var latitude: LocationRadians
    private(set) var longitude: LocationRadians
    
    public init(latitude: LocationRadians, longitude: LocationRadians) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public init(_ degreeCoordinate: CLLocationCoordinate2D) {
        latitude = degreeCoordinate.latitude.toRadians()
        longitude = degreeCoordinate.longitude.toRadians()
    }
    
    /**
     Returns direction given two coordinates.
     */
    public func direction(to coordinate: RadianCoordinate2D) -> RadianDirection {
        let a = sin(coordinate.longitude - longitude) * cos(coordinate.latitude)
        let b = cos(latitude) * sin(coordinate.latitude)
            - sin(latitude) * cos(coordinate.latitude) * cos(coordinate.longitude - longitude)
        return atan2(a, b)
    }
    
    /**
     Returns coordinate at a given distance and direction away from coordinate.
     */
    public func coordinate(at distance: RadianDistance, facing direction: RadianDirection) -> RadianCoordinate2D {
        let distance = distance, direction = direction
        let otherLatitude = asin(sin(latitude) * cos(distance)
            + cos(latitude) * sin(distance) * cos(direction))
        let otherLongitude = longitude + atan2(sin(direction) * sin(distance) * cos(latitude),
                                               cos(distance) - sin(latitude) * sin(otherLatitude))
        return RadianCoordinate2D(latitude: otherLatitude, longitude: otherLongitude)
    }
    
    /**
     Returns the Haversine distance between two coordinates measured in radians.
     */
    public func distance(to coordinate: RadianCoordinate2D) -> RadianDistance {
        let a = pow(sin((coordinate.latitude - self.latitude) / 2), 2)
            + pow(sin((coordinate.longitude - self.longitude) / 2), 2) * cos(self.latitude) * cos(coordinate.latitude)
        return 2 * atan2(sqrt(a), sqrt(1 - a))
    }
}
