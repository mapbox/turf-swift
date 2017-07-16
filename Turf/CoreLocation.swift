import CoreLocation


extension CLLocationDegrees {
    func toRadians() -> LocationRadians {
        return self * .pi / 180.0
    }
    
    func toDegrees() -> CLLocationDirection {
        return self * 180.0 / .pi
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
}
