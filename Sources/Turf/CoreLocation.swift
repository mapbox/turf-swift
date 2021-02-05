import Foundation
#if canImport(CoreLocation)
import CoreLocation
#endif

#if canImport(CoreLocation)
/**
 An azimuth measured in degrees clockwise from true north.
 
 This is a compatibility shim to keep the library’s public interface consistent between Apple and non-Apple platforms that lack Core Location. On Apple platforms, you can use `CLLocationDirection` anywhere you see this type.
 */
public typealias LocationDirection = CLLocationDirection

/**
 A distance in meters.
 
 This is a compatibility shim to keep the library’s public interface consistent between Apple and non-Apple platforms that lack Core Location. On Apple platforms, you can use `CLLocationDistance` anywhere you see this type.
 */
public typealias LocationDistance = CLLocationDistance

/**
 A latitude or longitude in degrees.
 
 This is a compatibility shim to keep the library’s public interface consistent between Apple and non-Apple platforms that lack Core Location. On Apple platforms, you can use `CLLocationDegrees` anywhere you see this type.
 */
public typealias LocationDegrees = CLLocationDegrees

/**
 A geographic coordinate.
 
 This is a compatibility shim to keep the library’s public interface consistent between Apple and non-Apple platforms that lack Core Location. On Apple platforms, you can use `CLLocationCoordinate2D` anywhere you see this type.
 */
public typealias LocationCoordinate2D = CLLocationCoordinate2D
#else
/**
 An azimuth measured in degrees clockwise from true north.
 */
public typealias LocationDirection = Double

/**
 A distance in meters.
 */
public typealias LocationDistance = Double

/**
 A latitude or longitude in degrees.
 */
public typealias LocationDegrees = Double

/**
 A geographic coordinate with its components measured in degrees.
 */
public struct LocationCoordinate2D {
    /**
     The latitude in degrees.
     */
    public let latitude: LocationDegrees
    
    /**
     The longitude in degrees.
     */
    public let longitude: LocationDegrees
    
    /**
     Creates a degree-based geographic coordinate.
     */
    public init(latitude: LocationDegrees, longitude: LocationDegrees) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
#endif

extension LocationDirection {
    /**
     Returns a normalized number given min and max bounds.
     */
    public func wrap(min minimumValue: LocationDirection, max maximumValue: LocationDirection) -> LocationDirection {
        let d = maximumValue - minimumValue
        return fmod((fmod((self - minimumValue), d) + d), d) + minimumValue
    }
    
    /**
     Returns the smaller difference between the receiver and another direction.
     
     To obtain the larger difference between the two directions, subtract the
     return value from 360°.
     */
    public func difference(from beta: LocationDirection) -> LocationDirection {
        let phi = abs(beta - self).truncatingRemainder(dividingBy: 360)
        return phi > 180 ? 360 - phi : phi
    }
}

extension LocationDegrees {
    /**
     Returns the direction in radians.
     */
    public func toRadians() -> LocationRadians {
        return self * .pi / 180.0
    }
    
    /**
     Returns the direction in degrees.
     */
    public func toDegrees() -> LocationDirection {
        return self * 180.0 / .pi
    }
}

struct LocationCoordinate2DCodable: Codable {
    var latitude: LocationDegrees
    var longitude: LocationDegrees
    var decodedCoordinates: LocationCoordinate2D {
        return LocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(longitude)
        try container.encode(latitude)
    }
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        longitude = try container.decode(LocationDegrees.self)
        latitude = try container.decode(LocationDegrees.self)
    }
    
    init(_ coordinate: LocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }
}

extension LocationCoordinate2D {
    var codableCoordinates: LocationCoordinate2DCodable {
        return LocationCoordinate2DCodable(self)
    }
}

extension Array where Element == LocationCoordinate2DCodable {
    var decodedCoordinates: [LocationCoordinate2D] {
        return map { $0.decodedCoordinates }
    }
}

extension Array where Element == [LocationCoordinate2DCodable] {
    var decodedCoordinates: [[LocationCoordinate2D]] {
        return map { $0.decodedCoordinates }
    }
}

extension Array where Element == [[LocationCoordinate2DCodable]] {
    var decodedCoordinates: [[[LocationCoordinate2D]]] {
        return map { $0.decodedCoordinates }
    }
}

extension Array where Element == LocationCoordinate2D {
    var codableCoordinates: [LocationCoordinate2DCodable] {
        return map { $0.codableCoordinates }
    }
}

extension Array where Element == [LocationCoordinate2D] {
    var codableCoordinates: [[LocationCoordinate2DCodable]] {
        return map { $0.codableCoordinates }
    }
}

extension Array where Element == [[LocationCoordinate2D]] {
    var codableCoordinates: [[[LocationCoordinate2DCodable]]] {
        return map { $0.codableCoordinates }
    }
}

extension LocationCoordinate2D: Equatable {
    
    /// Instantiates a LocationCoordinate2D from a RadianCoordinate2D
    public init(_ radianCoordinate: RadianCoordinate2D) {
        self.init(latitude: radianCoordinate.latitude.toDegrees(), longitude: radianCoordinate.longitude.toDegrees())
    }
    
    public static func ==(lhs: LocationCoordinate2D, rhs: LocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    /// Returns the direction from the receiver to the given coordinate.
    public func direction(to coordinate: LocationCoordinate2D) -> LocationDirection {
        return RadianCoordinate2D(self).direction(to: RadianCoordinate2D(coordinate)).toDegrees()
    }
    
    /// Returns a coordinate a certain Haversine distance away in the given direction.
    public func coordinate(at distance: LocationDistance, facing direction: LocationDirection) -> LocationCoordinate2D {
        let radianCoordinate = RadianCoordinate2D(self).coordinate(at: distance / metersPerRadian, facing: direction.toRadians())
        return LocationCoordinate2D(radianCoordinate)
    }
    
    /**
     Returns the Haversine distance between two coordinates measured in degrees.
     */
    public func distance(to coordinate: LocationCoordinate2D) -> LocationDistance {
        return RadianCoordinate2D(self).distance(to: RadianCoordinate2D(coordinate)) * metersPerRadian
    }
}

