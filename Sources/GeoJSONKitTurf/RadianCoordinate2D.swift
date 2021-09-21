import Foundation

import GeoJSONKit

extension GeoJSON {
  public typealias DegreesRadians = Double
  public typealias DistanceRadian = Double
}

/**
 A `RadianCoordinate2D` is a coordinate represented in radians as opposed to
 `LocationCoordinate2D` which is represented in latitude and longitude.
 */
public struct RadianCoordinate2D {
  private(set) var latitude: GeoJSON.DegreesRadians
  private(set) var longitude: GeoJSON.DegreesRadians
  
  public init(latitude: GeoJSON.DegreesRadians, longitude: GeoJSON.DegreesRadians) {
    self.latitude = latitude
    self.longitude = longitude
  }
  
  public init(_ degreeCoordinate: GeoJSON.Position) {
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
  public func coordinate(at distance: GeoJSON.DistanceRadian, facing direction: Measurement<UnitAngle>) -> RadianCoordinate2D {
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
  public func distance(to coordinate: RadianCoordinate2D) -> GeoJSON.DistanceRadian {
    let a = pow(sin((coordinate.latitude - self.latitude) / 2), 2)
    + pow(sin((coordinate.longitude - self.longitude) / 2), 2) * cos(self.latitude) * cos(coordinate.latitude)
    return 2 * atan2(sqrt(a), sqrt(1 - a))
  }
}
