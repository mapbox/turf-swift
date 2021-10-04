import Foundation
#if !os(Linux)
import CoreLocation
#endif

/// A latitude or longitude measured in radians, as opposed to `LocationDegrees`, which is measured in degrees of arc.
public typealias LocationRadians = Double

/// A difference in latitude or longitude measured in radians, as opposed to `CLLocationDegrees`, which is used by some libraries to represent a similar distance measured in degrees of arc.
public typealias RadianDistance = Double

/**
 A coordinate pair measured in radians, as opposed to `LocationCoordinate2D`, which is measured in degrees of arc.
 */
public struct RadianCoordinate2D {
    /// The latitude measured in radians.
    private(set) var latitude: LocationRadians
    
    /// The longitude measured in radians.
    private(set) var longitude: LocationRadians
    
    /**
     Initializes a coordinate pair located at the given latitude and longitude.
     
     - parameter latitude: The latitude measured in radians.
     - parameter longitude: The longitude measured in radians.
     */
    public init(latitude: LocationRadians, longitude: LocationRadians) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    /**
     Initializes a coordinate pair measured in radians that is coincident to the given coordinate pair measured in degrees of arc.
     
     - parameter degreeCoordinate: A coordinate pair measured in degrees of arc.
     */
    public init(_ degreeCoordinate: LocationCoordinate2D) {
        latitude = degreeCoordinate.latitude.toRadians()
        longitude = degreeCoordinate.longitude.toRadians()
    }
    
    /**
     Returns direction given two coordinates.
     */
    public func direction(to coordinate: RadianCoordinate2D) -> Measurement<UnitAngle> {
        let a = sin(coordinate.longitude - longitude) * cos(coordinate.latitude)
        let b = cos(latitude) * sin(coordinate.latitude)
            - sin(latitude) * cos(coordinate.latitude) * cos(coordinate.longitude - longitude)
        return Measurement(value: atan2(a, b), unit: UnitAngle.radians)
    }
    
    /**
     Returns coordinate at a given distance and direction away from coordinate.
     */
    public func coordinate(at distance: RadianDistance, facing direction: Measurement<UnitAngle>) -> RadianCoordinate2D {
        let distance = distance, direction = direction
        let radiansDirection = direction.converted(to: .radians).value
        let otherLatitude = asin(sin(latitude) * cos(distance)
            + cos(latitude) * sin(distance) * cos(radiansDirection))
        let otherLongitude = longitude + atan2(sin(radiansDirection) * sin(distance) * cos(latitude),
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
