import Foundation
#if os(Linux)
public struct CLLocationCoordinate2D {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
public typealias CLLocationDirection = Double
public typealias CLLocationDistance = Double
public typealias CLLocationDegrees = Double
#else
import CoreLocation
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
     Returns the smaller difference between the receiver and another direction.
     
     To obtain the larger difference between the two directions, subtract the
     return value from 360°.
     */
    public func difference(from beta: CLLocationDirection) -> CLLocationDirection {
        let phi = abs(beta - self).truncatingRemainder(dividingBy: 360)
        return phi > 180 ? 360 - phi : phi
    }
}

struct CLLocationCoordinate2DCodable: Codable {
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var decodedCoordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude,
                                      longitude: longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(longitude)
        try container.encode(latitude)
    }
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        longitude = try container.decode(CLLocationDegrees.self)
        latitude = try container.decode(CLLocationDegrees.self)
    }
    
    init(_ coordinate: CLLocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }
}

extension CLLocationCoordinate2D {
    var codableCoordinates: CLLocationCoordinate2DCodable {
        return CLLocationCoordinate2DCodable(self)
    }
}

extension Array where Element == CLLocationCoordinate2DCodable {
    var decodedCoordinates: [CLLocationCoordinate2D] {
        return map { $0.decodedCoordinates }
    }
}

extension Array where Element == [CLLocationCoordinate2DCodable] {
    var decodedCoordinates: [[CLLocationCoordinate2D]] {
        return map { $0.decodedCoordinates }
    }
}

extension Array where Element == [[CLLocationCoordinate2DCodable]] {
    var decodedCoordinates: [[[CLLocationCoordinate2D]]] {
        return map { $0.decodedCoordinates }
    }
}

extension Array where Element == CLLocationCoordinate2D {
    var codableCoordinates: [CLLocationCoordinate2DCodable] {
        return map { $0.codableCoordinates }
    }
}

extension Array where Element == [CLLocationCoordinate2D] {
    var codableCoordinates: [[CLLocationCoordinate2DCodable]] {
        return map { $0.codableCoordinates }
    }
}

extension Array where Element == [[CLLocationCoordinate2D]] {
    var codableCoordinates: [[[CLLocationCoordinate2DCodable]]] {
        return map { $0.codableCoordinates }
    }
}

extension CLLocationCoordinate2D: Equatable {
    
    /// Instantiates a CLLocationCoordinate from a RadianCoordinate2D
    public init(_ radianCoordinate: RadianCoordinate2D) {
        self.init(latitude: radianCoordinate.latitude.toDegrees(), longitude: radianCoordinate.longitude.toDegrees())
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

