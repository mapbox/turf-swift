import CoreLocation

#if os(OSX)
let CLLocationDistanceMax: CLLocationDistance = .greatestFiniteMagnitude
#endif

extension CLLocationDirection {
    /**
     Returns a normalized number given min and max bounds.
     */
    public func wrap(min minimumValue: CLLocationDirection, max maximumValue: CLLocationDirection) -> CLLocationDirection {
        let d = maximumValue - minimumValue
        return fmod((fmod((self - minimumValue), d) + d), d) + minimumValue
    }
}

extension CLLocationDegrees {
    /**
     Returns the direction in radians.
     */
    public func toRadians() -> LocationRadians {
        return self * .pi / 180.0
    }
    
    /**
     Returns the direction in degrees.
     */
    public func toDegrees() -> CLLocationDirection {
        return self * 180.0 / .pi
    }
}

extension CLLocationDirection {
    /**
     Returns the smallest angle between two angles.
     */
    public func differenceBetween(_ beta: CLLocationDirection) -> CLLocationDirection {
        let phi = abs(beta - self).truncatingRemainder(dividingBy: 360)
        return phi > 180 ? 360 - phi : phi
    }
}

extension CLLocationCoordinate2D: Equatable {
    
    /// Instantiates a CLLocationCoordinate from a RadianCoordinate2D
    public init(_ radianCoordinate: RadianCoordinate2D) {
        latitude = radianCoordinate.latitude.toDegrees()
        longitude = radianCoordinate.longitude.toDegrees()
    }
    
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    /// Returns the direction from the receiver to the given coordinate.
    public func direction(to coordinate: CLLocationCoordinate2D) -> CLLocationDirection {
        return RadianCoordinate2D(self).direction(to: RadianCoordinate2D(coordinate)).toDegrees()
    }
    
    /// Returns a coordinate a certain Haversine distance away in the given direction.
    public func coordinate(at distance: CLLocationDistance, facing direction: CLLocationDirection) -> CLLocationCoordinate2D {
        let radianCoordinate = RadianCoordinate2D(self).coordinate(at: distance / metersPerRadian, facing: direction.toRadians())
        return CLLocationCoordinate2D(radianCoordinate)
    }
    
    /**
     Returns the Haversine distance between two coordinates measured in degrees.
     */
    public func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        return RadianCoordinate2D(self).distance(to: RadianCoordinate2D(coordinate)) * metersPerRadian
    }
}

