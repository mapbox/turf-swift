import Foundation

import GeoJSONKit

extension GeoJSON.LineString {
  var coordinates: [GeoJSON.Position] { positions }
  
  /**
    Representation of current `LineString` as an array of `LineSegment`s.
    */
   var segments: [LineSegment] {
     return zip(coordinates.dropLast(), coordinates.dropFirst()).map { LineSegment($0.0, $0.1) }
   }
  
  /// Returns a new line string based on bezier transformation of the input line.
  ///
  /// ported from https://github.com/Turfjs/turf/blob/1ea264853e1be7469c8b7d2795651c9114a069aa/packages/turf-bezier-spline/index.ts
  public func bezier(resolution: Int = 10000, sharpness: Double = 0.85) -> GeoJSON.LineString? {
    let points = coordinates.map {
      SplinePoint(coordinate: $0)
    }
    guard let spline = Spline(points: points, duration: resolution, sharpness: sharpness) else {
      return nil
    }
    let coords = stride(from: 0, to: resolution, by: 10)
      .filter { Int(floor(Double($0) / 100)) % 2 == 0 }
      .map { spline.position(at: $0).coordinate }
    return GeoJSON.LineString(positions: coords)
  }
  
  /**
   Returns the portion of the line string that begins at the given start distance and extends the given stop distance along the line string.
   
   This method is equivalent to the [turf-line-slice-along](https://turfjs.org/docs/#lineSliceAlong) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-line-slice-along/)).
   */
  public func trimmed(from startDistance: GeoJSON.Distance, to stopDistance: GeoJSON.Distance) -> GeoJSON.LineString? {
    // The method is porting from https://github.com/Turfjs/turf/blob/5375941072b90d489389db22b43bfe809d5e451e/packages/turf-line-slice-along/index.js
    guard startDistance >= 0, stopDistance >= startDistance else { return nil }
    let positions = self.coordinates
    var traveled: GeoJSON.Distance = 0
    var slice = [GeoJSON.Position]()
    
    for i in 0..<positions.endIndex {
      if startDistance >= traveled, i == positions.endIndex - 1 {
        break
      } else if traveled > startDistance, slice.isEmpty {
        let overshoot = startDistance - traveled
        if overshoot == 0.0 {
          slice.append(positions[i])
          return GeoJSON.LineString(positions: slice)
        }
        let direction = positions[i].direction(to: positions[i - 1]) - 180
        let interpolated = positions[i].coordinate(at: overshoot, facing: direction)
        slice.append(interpolated)
      }
      
      if traveled >= stopDistance {
        let overshoot = stopDistance - traveled
        if overshoot == 0.0 {
          slice.append(positions[i])
          return GeoJSON.LineString(positions: slice)
        }
        let direction = positions[i].direction(to: positions[i - 1]) - 180
        let interpolated = positions[i].coordinate(at: overshoot, facing: direction)
        slice.append(interpolated)
        return GeoJSON.LineString(positions: slice)
      }
      
      if traveled >= startDistance {
        slice.append(positions[i])
      }
      
      if i == positions.count - 1 {
        return GeoJSON.LineString(positions: slice)
      }
      
      traveled += positions[i].distance(to: positions[i + 1])
    }
    
    if traveled < startDistance {
      return nil
    }
    
    if let last = positions.last {
      return GeoJSON.LineString(positions: [last, last])
    }
    
    return nil
  }
  
  /// Returns the portion of the line string that begins at the given coordinate and extends the given distance along the line string.
  public func trimmed(from coordinate: GeoJSON.Position, distance: GeoJSON.Distance) -> GeoJSON.LineString? {
    let startVertex = closestCoordinate(to: coordinate)
    guard startVertex != nil && distance != 0 else {
      return nil
    }
    
    var vertices: [GeoJSON.Position] = [startVertex!.coordinate]
    var cumulativeDistance: GeoJSON.Distance = 0
    let addVertex = { (vertex: GeoJSON.Position) -> Bool in
      let lastVertex = vertices.last!
      let incrementalDistance = lastVertex.distance(to: vertex)
      if cumulativeDistance + incrementalDistance <= abs(distance) {
        vertices.append(vertex)
        cumulativeDistance += incrementalDistance
        return true
      } else {
        let remainingDistance = abs(distance) - cumulativeDistance
        let direction = lastVertex.direction(to: vertex)
        let endpoint = lastVertex.coordinate(at: remainingDistance, facing: direction)
        vertices.append(endpoint)
        cumulativeDistance += remainingDistance
        return false
      }
    }
    
    if distance > 0 {
      for vertex in coordinates.suffix(from: startVertex!.index) {
        if !addVertex(vertex) {
          break
        }
      }
    } else {
      for vertex in coordinates.prefix(through: startVertex!.index).reversed() {
        if !addVertex(vertex) {
          break
        }
      }
    }
    assert(round(cumulativeDistance) <= round(abs(distance)))
    return GeoJSON.LineString(positions: vertices)
  }
  
  /// Returns a coordinate along a `.LineString` at a certain distance from the start of the polyline.
  public func coordinateFromStart(distance: GeoJSON.Distance) -> GeoJSON.Position? {
    return indexedCoordinateFromStart(distance: distance)?.coordinate
  }
  
  /// Returns an indexed coordinate along a `.LineString` at a certain distance from the start of the polyline.
  ///
  /// Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-along/index.js
  public func indexedCoordinateFromStart(distance: GeoJSON.Distance) -> IndexedCoordinate? {
    var traveled: GeoJSON.Distance = 0
    
    guard let firstCoordinate = coordinates.first else {
      return nil
    }
    guard distance >= 0  else {
      return IndexedCoordinate(coordinate: firstCoordinate, index: 0, distance: 0)
    }
    
    for i in 0..<coordinates.count {
      guard distance < traveled || i < coordinates.count - 1 else {
        break
      }
      
      if traveled >= distance {
        let overshoot = distance - traveled
        if overshoot == 0 {
          return IndexedCoordinate(coordinate: coordinates[i], index: i, distance: traveled)
        }
        
        let direction = coordinates[i].direction(to: coordinates[i - 1]) - 180
        let coordinate = coordinates[i].coordinate(at: overshoot, facing: direction)
        return IndexedCoordinate(coordinate: coordinate, index: i - 1, distance: distance)
      }
      
      traveled += coordinates[i].distance(to: coordinates[i + 1])
    }
    
    return IndexedCoordinate(coordinate: coordinates.last!, index: coordinates.endIndex - 1, distance: traveled)
  }
  
  
  /// Returns the distance along a slice of a `.LineString` with the given endpoints.
  ///
  /// Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-line-slice/index.js
  public func distance(from start: GeoJSON.Position? = nil, to end: GeoJSON.Position? = nil) -> GeoJSON.Distance? {
    guard !coordinates.isEmpty else { return nil }
    
    guard let slicedCoordinates = sliced(from: start, to: end)?.coordinates else {
      return nil
    }
    
    let zippedCoordinates = zip(slicedCoordinates.prefix(upTo: slicedCoordinates.count - 1), slicedCoordinates.suffix(from: 1))
    return zippedCoordinates.map { $0.distance(to: $1) }.reduce(0, +)
  }
  
  /// Returns a subset of the `.LineString` between given coordinates.
  ///
  /// Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-line-slice/index.js
  public func sliced(from start: GeoJSON.Position? = nil, to end: GeoJSON.Position? = nil) -> GeoJSON.LineString? {
    guard let first = coordinates.first, let last = coordinates.last else { return nil }
    
    let startVertex = start.flatMap(closestCoordinate(to:)) ?? IndexedCoordinate(coordinate: first, index: 0, distance: 0)
    let endVertex = end.flatMap(closestCoordinate(to:)) ?? IndexedCoordinate(coordinate: last, index: coordinates.indices.last!, distance: 0)
    
    let ends: (IndexedCoordinate, IndexedCoordinate)
    if startVertex.index <= endVertex.index {
      ends = (startVertex, endVertex)
    } else {
      ends = (endVertex, startVertex)
    }
    
    var coords = ends.0.index == ends.1.index ? [] : Array(coordinates[ends.0.index + 1...ends.1.index])
    coords.insert(ends.0.coordinate, at: 0)
    if coords.last != ends.1.coordinate {
      coords.append(ends.1.coordinate)
    }
    
    return GeoJSON.LineString(positions: coords)
  }
  
  /// Returns the geographic coordinate along the `.LineString` that is closest to the given coordinate as the crow flies.
  /// The returned coordinate may not correspond to one of the polyline’s vertices, but it always lies along the polyline.
  ///
  /// Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-point-on-line/index.js
  
  public func closestCoordinate(to coordinate: GeoJSON.Position) -> IndexedCoordinate? {
    .findClosest(to: coordinate, on: positions)
  }

  /**
   Returns all intersections with another `LineString`.
   
   This function is roughly equivalent to the [turf-line-intersect](https://turfjs.org/docs/#lineIntersect) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-line-intersect/)). Order of found intersections is not determined.
   */
  public func intersections(with line: GeoJSON.LineString) -> Set<GeoJSON.Position> {
    var intersections = Set<GeoJSON.Position>()
    for segment1 in segments {
      for segment2 in line.segments {
        if let intersection = intersection(LineSegment(segment1.0, segment1.1),
                                           LineSegment(segment2.0, segment2.1)) {
          intersections.insert(intersection)
        }
      }
    }
    return intersections
  }

}
