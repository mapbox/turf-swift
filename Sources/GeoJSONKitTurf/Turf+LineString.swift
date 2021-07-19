import Foundation
#if !os(Linux)
import CoreLocation
#endif
import GeoJSONKit

extension GeoJSON.LineString {
  var coordinates: [GeoJSON.Position] { positions }
  
  /// Returns a new `.LineString` based on bezier transformation of the input line.
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
  
  /// Returns a `.LineString` along a `.LineString` within a distance from a coordinate.
  public func trimmed(from coordinate: GeoJSON.Position, distance: LocationDistance) -> GeoJSON.LineString? {
    let startVertex = closestCoordinate(to: coordinate)
    guard startVertex != nil && distance != 0 else {
      return nil
    }
    
    var vertices: [GeoJSON.Position] = [startVertex!.coordinate]
    var cumulativeDistance: LocationDistance = 0
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
  
  /// `IndexedCoordinate` is a coordinate with additional information such as
  /// the index from its position in the polyline and distance from the start
  /// of the polyline.
  public struct IndexedCoordinate {
    /// The coordinate
    public let coordinate: Array<GeoJSON.Position>.Element
    /// The index of the coordinate
    public let index: Array<GeoJSON.Position>.Index
    /// The coordinate’s distance from the start of the polyline
    public let distance: LocationDistance
  }
  
  /// Returns a coordinate along a `.LineString` at a certain distance from the start of the polyline.
  public func coordinateFromStart(distance: LocationDistance) -> GeoJSON.Position? {
    return indexedCoordinateFromStart(distance: distance)?.coordinate
  }
  
  /// Returns an indexed coordinate along a `.LineString` at a certain distance from the start of the polyline.
  ///
  /// Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-along/index.js
  public func indexedCoordinateFromStart(distance: LocationDistance) -> IndexedCoordinate? {
    var traveled: LocationDistance = 0
    
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
  public func distance(from start: GeoJSON.Position? = nil, to end: GeoJSON.Position? = nil) -> LocationDistance? {
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
    guard !coordinates.isEmpty else { return nil }
    
    let startVertex = (start != nil ? closestCoordinate(to: start!) : nil) ?? IndexedCoordinate(coordinate: coordinates.first!, index: 0, distance: 0)
    let endVertex = (end != nil ? closestCoordinate(to: end!) : nil) ?? IndexedCoordinate(coordinate: coordinates.last!, index: coordinates.indices.last!, distance: 0)
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
    guard let startCoordinate = coordinates.first else { return nil }
    
    guard coordinates.count > 1 else {
      return IndexedCoordinate(coordinate: startCoordinate, index: 0, distance: coordinate.distance(to: startCoordinate))
    }
    
    var closestCoordinate: IndexedCoordinate?
    var closestDistance: LocationDistance?
    
    for index in 0..<coordinates.count - 1 {
      let segment = (coordinates[index], coordinates[index + 1])
      let distances = (coordinate.distance(to: segment.0), coordinate.distance(to: segment.1))
      
      let maxDistance = max(distances.0, distances.1)
      let direction = segment.0.direction(to: segment.1)
      let perpendicularPoint1 = coordinate.coordinate(at: maxDistance, facing: direction + 90)
      let perpendicularPoint2 = coordinate.coordinate(at: maxDistance, facing: direction - 90)
      let intersectionPoint = intersection((perpendicularPoint1, perpendicularPoint2), segment)
      let intersectionDistance: LocationDistance? = intersectionPoint != nil ? coordinate.distance(to: intersectionPoint!) : nil
      
      if distances.0 < closestDistance ?? .greatestFiniteMagnitude {
        closestCoordinate = IndexedCoordinate(coordinate: segment.0,
                                              index: index,
                                              distance: startCoordinate.distance(to: segment.0))
        closestDistance = distances.0
      }
      if distances.1 < closestDistance ?? .greatestFiniteMagnitude {
        closestCoordinate = IndexedCoordinate(coordinate: segment.1,
                                              index: index+1,
                                              distance: startCoordinate.distance(to: segment.1))
        closestDistance = distances.1
      }
      if intersectionDistance != nil && intersectionDistance! < closestDistance ?? .greatestFiniteMagnitude {
        closestCoordinate = IndexedCoordinate(coordinate: intersectionPoint!,
                                              index: index,
                                              distance: startCoordinate.distance(to: intersectionPoint!))
        closestDistance = intersectionDistance!
      }
    }
    
    return closestCoordinate
  }
  
  private func squareDistance(from origin: GeoJSON.Position, to destination: GeoJSON.Position) -> Double {
    let dx = origin.longitude - destination.longitude
    let dy = origin.latitude - destination.latitude
    return dx * dx + dy * dy
  }
  
  private mutating func simplified(radialTolerance: Double) {
    guard coordinates.count > 2 else { return }
    
    var prevCoordinate = coordinates[0]
    var newCoordinates = [prevCoordinate]
    var coordinate = coordinates[1]
    
    for index in 1 ..< coordinates.count {
      coordinate = coordinates[index]
      
      if squareDistance(from: coordinate, to: prevCoordinate) > radialTolerance {
        newCoordinates.append(coordinate)
        prevCoordinate = coordinate
      }
    }
    
    if prevCoordinate != coordinate {
      newCoordinates.append(coordinate)
    }
    
    positions = newCoordinates
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
  
  /// Returns a copy of the LineString with the Ramer–Douglas–Peucker algorithm applied to it.
  ///
  /// tolerance:  Controls the level of simplification by specifying the maximum allowed distance between the original line point
  /// and the simplified point. Higher tolerance values results in higher simplification.
  ///
  /// highestQuality: Excludes distance-based preprocessing step which leads to highest quality simplification. High quality simplification runs considerably slower so consider how much precision is needed in your application.
  ///
  /// Ported from https://github.com/Turfjs/turf/blob/master/packages/turf-simplify/lib/simplify.js
  public func simplify(tolerance: Double = 1.0, highestQuality: Bool = false) -> GeoJSON.LineString {
    guard coordinates.count > 2 else { return GeoJSON.LineString(positions: coordinates) }
    
    var copy = GeoJSON.LineString(positions: coordinates)
    copy.simplified(tolerance: tolerance, highestQuality: highestQuality)
    return copy
  }
  
  /// Mutates the LineString into a simplified version using the Ramer–Douglas–Peucker algorithm.
  ///
  /// tolerance:  Controls the level of simplification by specifying the maximum allowed distance between the original line point
  /// and the simplified point. Higher tolerance values results in higher simplification.
  ///
  /// highestQuality: Excludes distance-based preprocessing step which leads to highest quality simplification. High quality simplification runs considerably slower so consider how much precision is needed in your application.
  ///
  /// Ported from https://github.com/Turfjs/turf/blob/master/packages/turf-simplify/lib/simplify.js
  public mutating func simplified(tolerance: Double = 1.0, highestQuality: Bool = false) {
    guard coordinates.count > 2 else { return }
    
    let squareTolerance = tolerance * tolerance
    
    if !highestQuality {
      simplified(radialTolerance: squareTolerance)
    }
    
    positions = simplifyDouglasPeucker(coordinates, tolerance: squareTolerance)
  }
}
