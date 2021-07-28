import Foundation
#if canImport(CoreLocation)
import CoreLocation
#endif
import GeoJSONKit

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

extension GeoJSON.Position {
  
  /// Instantiates a LocationCoordinate2D from a RadianCoordinate2D
  public init(_ radianCoordinate: RadianCoordinate2D) {
    self.init(latitude: radianCoordinate.latitude.toDegrees(), longitude: radianCoordinate.longitude.toDegrees())
  }
  
  public static func ==(lhs: GeoJSON.Position, rhs: GeoJSON.Position) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
  }
  
  /// Returns the direction from the receiver to the given coordinate.
  public func direction(to coordinate: GeoJSON.Position) -> LocationDirection {
    return RadianCoordinate2D(self).direction(to: RadianCoordinate2D(coordinate)).converted(to: .degrees).value
  }
  
  /// Returns a coordinate a certain Haversine distance away in the given direction.
  public func coordinate(at distance: LocationDistance, facing direction: LocationDirection) -> GeoJSON.Position {
    let angle = Measurement(value: direction, unit: UnitAngle.degrees)
    return coordinate(at: distance, facing: angle)
  }
  
  /// Returns a coordinate a certain Haversine distance away in the given direction.
  public func coordinate(at distance: LocationDistance, facing direction: Measurement<UnitAngle>) -> GeoJSON.Position {
    let radianCoordinate = RadianCoordinate2D(self).coordinate(at: distance / metersPerRadian, facing: direction)
    return GeoJSON.Position(radianCoordinate)
  }
  
  /**
   Returns the Haversine distance between two coordinates measured in degrees.
   */
  public func distance(to coordinate: GeoJSON.Position) -> LocationDistance {
    return RadianCoordinate2D(self).distance(to: RadianCoordinate2D(coordinate)) * metersPerRadian
  }
  
  /**
   Returns a normalized coordinate, wrapped to -180 and 180 degrees latitude
   */
  var normalized: GeoJSON.Position {
    return .init(
      latitude: latitude,
      longitude: longitude.wrap(min: -180, max: 180)
    )
  }
}
