import Foundation
#if !os(Linux)
import CoreLocation
#endif

import GeoJSONKit

extension GeoJSON.Polygon {
  
  /**
   Initializes a polygon as a given center coordinate with a given number of
   vertices, as a means to approximate a circle.
   
   - Parameter center: The center coordinate for the polygon.
   - Parameter radius: The radius of the polygon, measured in meters.
   - Parameter vertices: The number of vertices the polygon will have.
   The recommended amount is 64.
   - Returns: A polygon shape which approximates a circle.
   */
  public init(center: GeoJSON.Position, radius: LocationDistance, vertices: Int) {
    // The first and last coordinates in a polygon must be identical,
    // which is why we're using the inclusive range operator in this case.
    // Ported from https://github.com/Turfjs/turf/blob/17002ccd57e04e84ddb38d7e3ac8ede35b019c58/packages/turf-circle/index.ts
    let positions = (0...vertices).map { ( step ) -> GeoJSON.Position in
      let bearing = fabs(LocationDirection(step * -360 / vertices))
      return center.coordinate(at: radius, facing: bearing)
    }
    
    self.init([positions])
  }
  
  var coordinates: [[GeoJSON.Position]] { positionsArray }

  /// An area of current `.Polygon`
  ///
  /// Ported from https://github.com/Turfjs/turf/blob/a94151418cb969868fdb42955a19a133512da0fd/packages/turf-area/index.js
  public var area: Double {
    return abs(exterior.area) - interiors
      .map { abs($0.area) }
      .reduce(0, +)
  }
  
  /// Determines if the given coordinate falls within the polygon and outside of its interior rings.
  /// The optional parameter `ignoreBoundary` will result in the method returning true if the given coordinate
  /// lies on the boundary line of the polygon or its interior rings.
  ///
  ///Ported from: https://github.com/Turfjs/turf/blob/e53677b0931da9e38bb947da448ee7404adc369d/packages/turf-boolean-point-in-polygon/index.ts#L31-L75
  public func contains(_ coordinate: GeoJSON.Position, ignoreBoundary: Bool = false) -> Bool {
    guard exterior.contains(coordinate, ignoreBoundary: ignoreBoundary) else {
      return false
    }
    for ring in interiors {
      if ring.contains(coordinate, ignoreBoundary: !ignoreBoundary) {
        return false
      }
    }
    return true
  }
  
  /// Smooths a `.Polygon`. Based on [Chaikin's algorithm](http://graphics.cs.ucdavis.edu/education/CAGDNotes/Chaikins-Algorithm/Chaikins-Algorithm.html).
  /// Warning: may create degenerate polygons.
  ///
  /// Ported from https://github.com/Turfjs/turf/blob/402716a29f6ae16bf3d0220e213e5380cc5a50c4/packages/turf-polygon-smooth/index.js
  public func smooth(iterations: Int = 3) -> GeoJSON.Polygon {
    var poly = self
    var tempOutput: [[GeoJSON.Position]] = [[]];
    var outCoords: [[GeoJSON.Position]] = [[]];
    
    (0..<iterations).forEach({ i in
      tempOutput = [[]]
      
      if (i > 0) {
        poly = GeoJSON.Polygon(outCoords);
      }
      
      processPolygon(poly, &tempOutput);
      outCoords = tempOutput
    })
    
    return GeoJSON.Polygon(outCoords);
  }
  
  private func processPolygon(_ poly: GeoJSON.Polygon, _ tempOutput: inout [[GeoJSON.Position]]) {
    var coordIndex = 0
    var prevGeomIndex = 0;
    var geometryIndex = 0;
    var subtractCoordIndex = 0;
    
    (0..<poly.coordinates.count).forEach { j in
      (0..<poly.coordinates[j].count - 1).forEach { k in
        if (geometryIndex > prevGeomIndex) {
          prevGeomIndex = geometryIndex;
          subtractCoordIndex = coordIndex;
          tempOutput.append([]);
        }
        
        let currentCoord = poly.coordinates[j][k]
        let realCoordIndex = coordIndex - subtractCoordIndex;
        let p1 = poly.coordinates[geometryIndex][realCoordIndex + 1];
        let p0x = currentCoord.latitude;
        let p0y = currentCoord.longitude;
        let p1x = p1.latitude;
        let p1y = p1.longitude;
        tempOutput[geometryIndex].append(GeoJSON.Position(
          latitude: 0.75 * p0x + 0.25 * p1x,
          longitude: 0.75 * p0y + 0.25 * p1y
        ));
        tempOutput[geometryIndex].append(GeoJSON.Position(
          latitude: 0.25 * p0x + 0.75 * p1x,
          longitude: 0.25 * p0y + 0.75 * p1y
        ));
        
        coordIndex += 1
      }
      
      geometryIndex += 1
    }
    
    tempOutput.enumerated().forEach({ i, ring in
      tempOutput[i] = ring + [ring[0]]
    })
  }
  
  /// Returns a copy of the Polygon with the Ramer–Douglas–Peucker algorithm applied to it.
  ///
  /// tolerance:  Controls the level of simplification by specifying the maximum allowed distance between the original line point
  /// and the simplified point. Higher tolerance values results in higher simplification.
  ///
  /// highestQuality: Excludes distance-based preprocessing step which leads to highest quality simplification. High quality simplification runs considerably slower so consider how much precision is needed in your application.
  ///
  /// Ported from https://github.com/Turfjs/turf/blob/master/packages/turf-simplify/lib/simplify.js
  public func simplify(tolerance: Double = 1.0, highestQuality: Bool = false) -> GeoJSON.Polygon {
    var copy = GeoJSON.Polygon(positionsArray)
    copy.simplified(tolerance: tolerance, highestQuality: highestQuality)
    return copy
  }
  
  /// Mutates the Polygon into a simplified version using the Ramer–Douglas–Peucker algorithm.
  ///
  /// tolerance:  Controls the level of simplification by specifying the maximum allowed distance between the original line point
  /// and the simplified point. Higher tolerance values results in higher simplification.
  ///
  /// highestQuality: Excludes distance-based preprocessing step which leads to highest quality simplification. High quality simplification runs considerably slower so consider how much precision is needed in your application.
  ///
  /// Ported from https://github.com/Turfjs/turf/blob/master/packages/turf-simplify/lib/simplify.js
  public mutating func simplified(tolerance: Double = 1.0, highestQuality: Bool = false) {
    let coordinates = positionsArray
    guard coordinates.allSatisfy({ $0.count > 3 }) else { return }
    
    positionsArray = coordinates.map({ ring in
      let squareTolerance = tolerance * tolerance
      var tolerance = tolerance
      
      if !highestQuality {
        simplified(radialTolerance: squareTolerance)
      }
      
      var simpleRing = simplifyDouglasPeucker(ring, tolerance: tolerance);
      //remove 1 percent of tolerance until enough points to make a triangle
      while (!checkValidity(ring: simpleRing)) {
        tolerance -= tolerance * 0.01;
        simpleRing = simplifyDouglasPeucker(ring, tolerance: tolerance)
      }
      
      if (
        simpleRing[simpleRing.count - 1].latitude != simpleRing[0].latitude ||
        simpleRing[simpleRing.count - 1].longitude != simpleRing[0].longitude
      ) {
        simpleRing.append(simpleRing[0]);
      }
      
      return simpleRing;
    })
  }
  
  private mutating func simplified(radialTolerance: Double) {
    let coordinates = positionsArray
    positionsArray = coordinates.map { ring in
      guard ring.count > 2 else { return ring }
      
      
      var prevCoordinate = ring[0]
      var newCoordinates = [prevCoordinate]
      var coordinate = ring[1]
      
      for index in 1 ..< ring.count {
        coordinate = ring[index]
        
        if squareDistance(from: coordinate, to: prevCoordinate) > radialTolerance {
          newCoordinates.append(coordinate)
          prevCoordinate = coordinate
        }
      }
      
      if prevCoordinate != coordinate {
        newCoordinates.append(coordinate)
      }
      
      return newCoordinates
    }
  }
  
  private func squareDistance(from origin: GeoJSON.Position, to destination: GeoJSON.Position) -> Double {
    let dx = origin.longitude - destination.longitude
    let dy = origin.latitude - destination.latitude
    return dx * dx + dy * dy
  }
  
  private func squareSegmentDistance(_ coordinate: GeoJSON.Position, segmentStart: GeoJSON.Position, segmentEnd: GeoJSON.Position) -> LocationDistance {
    var x = segmentStart.latitude
    var y = segmentStart.longitude
    var dx = segmentEnd.latitude - x
    var dy = segmentEnd.longitude - y
    
    if dx != 0 || dy != 0 {
      let t = ((segmentStart.latitude - x) * dx + (coordinate.longitude - y) * dy) / (dx * dx + dy * dy)
      if t > 1 {
        x = segmentEnd.latitude
        y = segmentEnd.longitude
      } else if t > 0 {
        x += dx * t
        y += dy * t
      }
    }
    
    dx = coordinate.latitude - x
    dy = coordinate.longitude - y
    
    return dx * dx + dy * dy
  }
  
  private func simplifyDouglasPeuckerStep(_ coordinates: [GeoJSON.Position], first: Int, last: Int, tolerance: Double, simplified: inout [GeoJSON.Position]) {
    var maxSquareDistance = tolerance
    var index = 0
    
    for i in first + 1 ..< last {
      let squareDistance = squareSegmentDistance(coordinates[i], segmentStart: coordinates[first], segmentEnd: coordinates[last])
      
      if squareDistance > maxSquareDistance {
        index = i
        maxSquareDistance = squareDistance
      }
    }
    
    if maxSquareDistance > tolerance {
      if index - first > 1 {
        simplifyDouglasPeuckerStep(coordinates, first: first, last: index, tolerance: tolerance, simplified: &simplified)
      }
      simplified.append(coordinates[index])
      if last - index > 1 {
        simplifyDouglasPeuckerStep(coordinates, first: index, last: last, tolerance: tolerance, simplified: &simplified)
      }
    }
  }
  
  private func simplifyDouglasPeucker(_ coordinates: [GeoJSON.Position], tolerance: Double) -> [GeoJSON.Position] {
    if coordinates.count <= 2 {
      return coordinates
    }
    
    let lastPoint = coordinates.count - 1
    var result = [coordinates[0]]
    simplifyDouglasPeuckerStep(coordinates, first: 0, last: lastPoint, tolerance: tolerance, simplified: &result)
    result.append(coordinates[lastPoint])
    return result
  }
  
  /// Checks if a ring has at least 3 coordinates. Will return false for a 3 coordinate ring
  /// where the first and last coordinates are the same
  ///
  /// - Parameter ring: Array of coordinates to be checked
  /// - Returns: true if valid
  private func checkValidity(ring: [GeoJSON.Position]) -> Bool {
    guard ring.count >= 3 else { return false }
    // if the last point is the same as the first, it's not a triangle
    return !(
      ring.count == 3 &&
      ring[2].latitude == ring[0].latitude &&
      ring[2].longitude == ring[0].longitude
    )
  }
}
