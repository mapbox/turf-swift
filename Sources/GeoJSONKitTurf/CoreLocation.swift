import Foundation
import GeoJSONKit

extension GeoJSON.Direction {
  /**
   Returns a normalized number given min and max bounds.
   */
  public func wrap(min minimumValue: GeoJSON.Direction, max maximumValue: GeoJSON.Direction) -> GeoJSON.Direction {
    let d = maximumValue - minimumValue
    return fmod((fmod((self - minimumValue), d) + d), d) + minimumValue
  }
  
  /**
   Returns the smaller difference between the receiver and another direction.
   
   To obtain the larger difference between the two directions, subtract the
   return value from 360°.
   */
  public func difference(from beta: GeoJSON.Direction) -> GeoJSON.Direction {
    let phi = abs(beta - self).truncatingRemainder(dividingBy: 360)
    return phi > 180 ? 360 - phi : phi
  }
}

extension GeoJSON.Degrees {
  /**
   Returns the direction in radians.
   */
  public func toRadians() -> GeoJSON.DegreesRadians {
    return self * .pi / 180.0
  }
}

extension GeoJSON.DegreesRadians {
  /**
   Returns the direction in degrees.
   */
  public func toDegrees() -> GeoJSON.Degrees {
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
  public func direction(to coordinate: GeoJSON.Position) -> GeoJSON.Direction {
    return RadianCoordinate2D(self).direction(to: RadianCoordinate2D(coordinate)).converted(to: .degrees).value
  }
  
  /// Returns a coordinate a certain Haversine distance away in the given direction.
  public func coordinate(at distance: GeoJSON.Distance, facing direction: GeoJSON.Direction) -> GeoJSON.Position {
    let angle = Measurement(value: direction, unit: UnitAngle.degrees)
    return coordinate(at: distance, facing: angle)
  }
  
  /// Returns a coordinate a certain Haversine distance away in the given direction.
  public func coordinate(at distance: GeoJSON.Distance, facing direction: Measurement<UnitAngle>) -> GeoJSON.Position {
    let radianCoordinate = RadianCoordinate2D(self).coordinate(at: distance / metersPerRadian, facing: direction)
    return GeoJSON.Position(radianCoordinate)
  }
  
  /**
   Returns the Haversine distance between two coordinates measured in degrees.
   */
  public func distance(to coordinate: GeoJSON.Position) -> GeoJSON.Distance {
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
