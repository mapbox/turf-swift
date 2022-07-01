import Foundation

import GeoJSONKit

/**
 A `Ring` struct that represents a closed figure that is bounded by three or more straight line segments.
 */
extension GeoJSON.Polygon.LinearRing {
  
  /**
   * Calculate the approximate area of the polygon were it projected onto the earth, in square meters.
   * Note that this area will be positive if ring is oriented clockwise, otherwise it will be negative.
   *
   * Reference:
   * Robert. G. Chamberlain and William H. Duquette, "Some Algorithms for Polygons on a Sphere", JPL Publication 07-03, Jet Propulsion
   * Laboratory, Pasadena, CA, June 2007 https://trs.jpl.nasa.gov/handle/2014/41271
   *
   */
  public var area: Double {
    var area: Double = 0
    let coordinatesCount: Int = positions.count
    let coordinates = positions
    
    if coordinatesCount > 2 {
      for index in 0..<coordinatesCount {
        
        let controlPoints: (GeoJSON.Position, GeoJSON.Position, GeoJSON.Position)
        
        if index == coordinatesCount - 2 {
          controlPoints = (coordinates[coordinatesCount - 2],
                           coordinates[coordinatesCount - 1],
                           coordinates[0])
        } else if index == coordinatesCount - 1 {
          controlPoints = (coordinates[coordinatesCount - 1],
                           coordinates[0],
                           coordinates[1])
        } else {
          controlPoints = (coordinates[index],
                           coordinates[index + 1],
                           coordinates[index + 2])
        }
        
        area += (controlPoints.2.longitude.toRadians() - controlPoints.0.longitude.toRadians()) * sin(controlPoints.1.latitude.toRadians())
      }
      
      area *= equatorialRadius * equatorialRadius / 2
    }
    return area
  }

  /**
   * Determines if the given point falls within the ring.
   * The optional parameter `ignoreBoundary` will result in the method returning true if the given point
   * lies on the boundary line of the ring.
   *
   * Ported from: https://github.com/Turfjs/turf/blob/e53677b0931da9e38bb947da448ee7404adc369d/packages/turf-boolean-point-in-polygon/index.ts#L77-L108
   */
  public func contains(_ coordinate: GeoJSON.Position, ignoreBoundary: Bool = false) -> Bool {
    
    // Optimization for triangles, using barycentric method
    guard positions.count > 3 else {
      // x: longitude; y: latitude
      let p  = coordinate
      let p0 = positions[0]
      let p1 = positions[1]
      let p2 = positions[2]
      let s = p0.latitude  * p2.longitude
            - p0.longitude * p2.latitude
            + (p2.latitude  - p0.latitude)  * p.longitude
            + (p0.longitude - p2.longitude) * p.latitude
      let t = p0.longitude * p1.latitude
            - p0.latitude  * p1.longitude
            + (p0.latitude  - p1.latitude)  * p.longitude
            + (p1.longitude - p0.longitude) * p.latitude
      guard (s < 0) == (t < 0) else { return false }
      
      let a = -p1.latitude * p2.longitude
            + p0.latitude  * (p2.longitude - p1.longitude)
            + p0.longitude * (p1.latitude - p2.latitude)
            + p1.longitude * p2.latitude
      return a < 0
            ? (s <= 0 && s + t >= a)
            : (s >= 0 && s + t <= a)
    }
    
    
    let bbox = GeoJSON.BoundingBox(positions: positions)
    guard bbox.contains(coordinate, ignoreBoundary: ignoreBoundary) else {
      return false
    }
    
    let coordinates = positions
    var ring: ArraySlice<GeoJSON.Position>!
    var isInside = false
    if coordinates.first == coordinates.last {
      ring = coordinates.prefix(coordinates.count - 1)
    }
    else {
      ring = coordinates.prefix(coordinates.count)
    }
    var i = 0
    var j = ring.count - 1
    while i < ring.count {
      let xi = ring[i].longitude
      let yi = ring[i].latitude
      let xj = ring[j].longitude
      let yj = ring[j].latitude
      let onBoundary = (coordinate.latitude * (xi - xj) + yi * (xj - coordinate.longitude) + yj * (coordinate.longitude - xi) == 0) &&
      ((xi - coordinate.longitude) * (xj - coordinate.longitude) <= 0) && ((yi - coordinate.latitude) * (yj - coordinate.latitude) <= 0)
      if onBoundary {
        return !ignoreBoundary
      }
      let intersect = ((yi > coordinate.latitude) != (yj > coordinate.latitude)) &&
      (coordinate.longitude < (xj - xi) * (coordinate.latitude - yi) / (yj - yi) + xi);
      if (intersect) {
        isInside = !isInside;
      }
      j = i
      i = i + 1
    }
    return isInside
  }
  
  func closestPosition(to coordinate: GeoJSON.Position) -> GeoJSON.Position? {
    GeoJSON.LineString.IndexedCoordinate.findClosest(to: coordinate, on: positions)?.coordinate
  }

}
