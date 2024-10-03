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
public typealias TurfLocationCoordinate2D = CLLocationCoordinate2D
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

#if !MAPBOX_COMMON_WITH_TURF_SWIFT_LIBRARY
public typealias LocationCoordinate2D = TurfLocationCoordinate2D
#endif

/**
 A geographic coordinate with its components measured in degrees.
 */
public struct TurfLocationCoordinate2D: Sendable {
    /**
     The latitude in degrees.
     */
    public var latitude: LocationDegrees
    
    /**
     The longitude in degrees.
     */
    public var longitude: LocationDegrees
    
    /**
     Creates a degree-based geographic coordinate.
     */
    public init(latitude: LocationDegrees, longitude: LocationDegrees) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
#endif

extension TurfLocationCoordinate2D {
    /**
        Returns a normalized coordinate, wrapped to -180 and 180 degrees latitude
     */
    var normalized: TurfLocationCoordinate2D {
        return .init(
            latitude: latitude,
            longitude: longitude.wrap(min: -180, max: 180)
        )
    }
}

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
     
     This method is equivalent to the [`degreesToRadians`](https://turfjs.org/docs/#degreesToRadians) method of the turf-helpers package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers/)).
     */
    public func toRadians() -> LocationRadians {
        return self * .pi / 180.0
    }
    
    /**
     Returns the direction in degrees.
     
     This method is equivalent to the [`radiansToDegrees`](https://turfjs.org/docs/#radiansToDegrees) method of the turf-helpers package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers/)).
     */
    public func toDegrees() -> LocationDirection {
        return self * 180.0 / .pi
    }
}

struct LocationCoordinate2DCodable: Codable {
    var latitude: LocationDegrees
    var longitude: LocationDegrees
    var decodedCoordinates: TurfLocationCoordinate2D {
        return TurfLocationCoordinate2D(latitude: latitude, longitude: longitude)
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
    
    init(_ coordinate: TurfLocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }
}

extension TurfLocationCoordinate2D {
    var codableCoordinates: LocationCoordinate2DCodable {
        return LocationCoordinate2DCodable(self)
    }
}

extension Array where Element == LocationCoordinate2DCodable {
    var decodedCoordinates: [TurfLocationCoordinate2D] {
        return map { $0.decodedCoordinates }
    }
}

extension Array where Element == [LocationCoordinate2DCodable] {
    var decodedCoordinates: [[TurfLocationCoordinate2D]] {
        return map { $0.decodedCoordinates }
    }
}

extension Array where Element == [[LocationCoordinate2DCodable]] {
    var decodedCoordinates: [[[TurfLocationCoordinate2D]]] {
        return map { $0.decodedCoordinates }
    }
}

extension Array where Element == TurfLocationCoordinate2D {
    var codableCoordinates: [LocationCoordinate2DCodable] {
        return map { $0.codableCoordinates }
    }
}

extension Array where Element == [TurfLocationCoordinate2D] {
    var codableCoordinates: [[LocationCoordinate2DCodable]] {
        return map { $0.codableCoordinates }
    }
}

extension Array where Element == [[TurfLocationCoordinate2D]] {
    var codableCoordinates: [[[LocationCoordinate2DCodable]]] {
        return map { $0.codableCoordinates }
    }
}

#if swift(>=6.0)
extension TurfLocationCoordinate2D: @retroactive Equatable {
    public static func ==(lhs: TurfLocationCoordinate2D, rhs: TurfLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
#else
extension TurfLocationCoordinate2D: Equatable {
    public static func ==(lhs: TurfLocationCoordinate2D, rhs: TurfLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
#endif

extension TurfLocationCoordinate2D {

    /// Instantiates a TurfLocationCoordinate2D from a TurfRadianCoordinate2D
    public init(_ radianCoordinate: TurfRadianCoordinate2D) {
        self.init(latitude: radianCoordinate.latitude.toDegrees(), longitude: radianCoordinate.longitude.toDegrees())
    }

    /**
     Returns the direction from the receiver to the given coordinate.
     
     This method is equivalent to the [turf-bearing](https://turfjs.org/docs/#bearing) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-bearing/)).
     */
    public func direction(to coordinate: TurfLocationCoordinate2D) -> LocationDirection {
        return TurfRadianCoordinate2D(self).direction(to: TurfRadianCoordinate2D(coordinate)).converted(to: .degrees).value
    }
    
    /// Returns a coordinate a certain Haversine distance away in the given direction.
    public func coordinate(at distance: LocationDistance, facing direction: LocationDirection) -> TurfLocationCoordinate2D {
        let angle = Measurement(value: direction, unit: UnitAngle.degrees)
        return coordinate(at: distance, facing: angle)
    }

    /**
     Returns a coordinate a certain Haversine distance away in the given direction.
     
     This method is equivalent to the [turf-destination](https://turfjs.org/docs/#destination) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-destination/)).
     */
    public func coordinate(at distance: LocationDistance, facing direction: Measurement<UnitAngle>) -> TurfLocationCoordinate2D {
        let radianCoordinate = TurfRadianCoordinate2D(self).coordinate(at: distance / metersPerRadian, facing: direction)
        return TurfLocationCoordinate2D(radianCoordinate)
    }
    
    /**
     Returns the Haversine distance between two coordinates measured in degrees.
     
     This method is equivalent to the [turf-distance](https://turfjs.org/docs/#distance) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-distance/)).
     */
    public func distance(to coordinate: TurfLocationCoordinate2D) -> LocationDistance {
        return TurfRadianCoordinate2D(self).distance(to: TurfRadianCoordinate2D(coordinate)) * metersPerRadian
    }
}

