//
//  Simplify.swift
//  GeoJSONKit+Turf
//
//  Created by Adrian Schönig on 4/9/21.
//

import Foundation
import GeoJSONKit

public struct SimplifyOptions {
  public enum Algorithm {
    /// Uses the Ramer–Douglas–Peucker algorithm.
    /// - `tolerance`:  Controls the level of simplification by specifying the maximum allowed distance between the original line point
    /// and the simplified point. Higher tolerance values results in higher simplification.
    /// Ported from https://github.com/Turfjs/turf/blob/master/packages/turf-simplify/lib/simplify.js
    case RamerDouglasPeucker(tolerance: Double = 0.01)
  }

  
  public init(algorithm: Algorithm = .RamerDouglasPeucker(), highestQuality: Bool = false) {
    self.algorithm = algorithm
    self.highestQuality = highestQuality
  }
  
  public var algorithm: Algorithm = .RamerDouglasPeucker()
  
  /// Excludes distance-based preprocessing step which leads to highest quality simplification. High quality simplification runs considerably slower so consider how much precision is needed in your application.
  public var highestQuality: Bool = false
}

extension GeoJSON {
  public func simplified(options: SimplifyOptions = .init()) -> GeoJSON {
    var copy = self
    copy.simplify(options: options)
    return copy
  }
  
  public mutating func simplify(options: SimplifyOptions = .init()) {
    object.simplify(options: options)
  }
}

extension GeoJSON.GeoJSONObject {
  public func simplified(options: SimplifyOptions = .init()) -> GeoJSON.GeoJSONObject {
    var copy = self
    copy.simplify(options: options)
    return copy
  }
  
  public mutating func simplify(options: SimplifyOptions = .init()) {
    switch self {
    case .feature(let feature):
      self = .feature(feature.simplified(options: options))
    case .featureCollection(let features):
      self = .featureCollection(features.map { $0.simplified(options: options) })
    case .geometry(let geometry):
      self = .geometry(geometry.simplified(options: options))
    }
  }
}

extension GeoJSON.Feature {
  public func simplified(options: SimplifyOptions = .init()) -> GeoJSON.Feature {
    var copy = self
    copy.simplify(options: options)
    return copy
  }
  
  public mutating func simplify(options: SimplifyOptions = .init()) {
    geometry.simplify(options: options)
  }
}

extension GeoJSON.GeometryObject {
  public func simplified(options: SimplifyOptions = .init()) -> GeoJSON.GeometryObject {
    var copy = self
    copy.simplify(options: options)
    return copy
  }
  
  public mutating func simplify(options: SimplifyOptions = .init()) {
    switch self {
    case .single(let geometry):
      self = .single(geometry.simplified(options: options))
    case .multi(let geometries):
      self = .multi(geometries.map { $0.simplified(options: options) })
    case .collection(let objects):
      self = .collection(objects.map { $0.simplified(options: options) })
    }
  }
}

extension GeoJSON.Geometry {
  public func simplified(options: SimplifyOptions = .init()) -> GeoJSON.Geometry {
    var copy = self
    copy.simplify(options: options)
    return copy
  }
  
  public mutating func simplify(options: SimplifyOptions = .init()) {
    switch self {
    case .point: return
    case .lineString(let line):
      self = .lineString(line.simplified(options: options))
    case .polygon(let polygon):
      self = .polygon(polygon.simplified(options: options))
    }
  }
}

extension Array where Element == GeoJSON.Position {
  fileprivate func simplifiedRadialDistance(squaredTolerance: Double) -> [GeoJSON.Position] {
    guard count > 2, let first = first, let last = last else { return self }
    
    var newPositions = [first]
    
    for position in self[1...] {
      if let lastNew = newPositions.last, position.squaredDistance(from: lastNew) > squaredTolerance {
        newPositions.append(position)
      }
    }
    
    if newPositions.last != last {
      newPositions.append(last)
    }
    return newPositions
  }
}

extension GeoJSON.LineString {
  
  /// Returns a copy of the LineString with the Ramer–Douglas–Peucker algorithm applied to it.
  ///
  /// tolerance:  Controls the level of simplification by specifying the maximum allowed distance between the original line point
  /// and the simplified point. Higher tolerance values results in higher simplification.
  ///
  /// highestQuality: Excludes distance-based preprocessing step which leads to highest quality simplification. High quality simplification runs considerably slower so consider how much precision is needed in your application.
  ///
  /// Ported from https://github.com/Turfjs/turf/blob/master/packages/turf-simplify/lib/simplify.js
  public func simplified(options: SimplifyOptions = .init()) -> GeoJSON.LineString {
    guard coordinates.count > 2 else { return GeoJSON.LineString(positions: coordinates) }
    
    var copy = self
    copy.simplify(options: options)
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
  public mutating func simplify(options: SimplifyOptions = .init()) {
    simplify(options: options, verifier: { _ in true })
  }
  
  mutating func simplify(options: SimplifyOptions, verifier: ([GeoJSON.Position]) -> Bool) {
    guard coordinates.count > 2 else { return }
    
    switch options.algorithm {
    case .RamerDouglasPeucker(var tolerance):
      var simplified: [GeoJSON.Position]
      repeat {
        let squared = tolerance * tolerance
        let input = options.highestQuality
          ? positions
          : positions.simplifiedRadialDistance(squaredTolerance: squared)
        
        simplified = DouglasPeucker.simplify(input, sqTolerance: squared)
        
        //remove 1 percent of tolerance if not verified
        tolerance -= tolerance * 0.01
      } while !verifier(simplified)
      positions = simplified
    }
  }
  
}

extension GeoJSON.Polygon.LinearRing {
  
  /// Returns a copy of the LinearRing with the Ramer–Douglas–Peucker algorithm applied to it.
  ///
  /// tolerance:  Controls the level of simplification by specifying the maximum allowed distance between the original line point
  /// and the simplified point. Higher tolerance values results in higher simplification.
  ///
  /// highestQuality: Excludes distance-based preprocessing step which leads to highest quality simplification. High quality simplification runs considerably slower so consider how much precision is needed in your application.
  ///
  /// Ported from https://github.com/Turfjs/turf/blob/master/packages/turf-simplify/lib/simplify.js
  public func simplified(options: SimplifyOptions = .init()) -> GeoJSON.Polygon.LinearRing {
    guard positions.count > 2 else { return GeoJSON.Polygon.LinearRing(positions: positions) }
    
    var copy = self
    copy.simplify(options: options)
    return copy
  }
  
  /// Mutates the LinearRing into a simplified version using the Ramer–Douglas–Peucker algorithm.
  ///
  /// tolerance:  Controls the level of simplification by specifying the maximum allowed distance between the original line point
  /// and the simplified point. Higher tolerance values results in higher simplification.
  ///
  /// highestQuality: Excludes distance-based preprocessing step which leads to highest quality simplification. High quality simplification runs considerably slower so consider how much precision is needed in your application.
  ///
  /// Ported from https://github.com/Turfjs/turf/blob/master/packages/turf-simplify/lib/simplify.js
  public mutating func simplify(options: SimplifyOptions = .init()) {
    simplify(options: options, verifier: { _ in true })
  }
  
  mutating func simplify(options: SimplifyOptions, verifier: ([GeoJSON.Position]) -> Bool) {
    guard positions.count > 2 else { return }
    
    switch options.algorithm {
    case .RamerDouglasPeucker(var tolerance):
      var simplified: [GeoJSON.Position]
      repeat {
        let squared = tolerance * tolerance
        let input = options.highestQuality
          ? positions
          : positions.simplifiedRadialDistance(squaredTolerance: squared)
        
        simplified = DouglasPeucker.simplify(input, sqTolerance: squared)
        
        //remove 1 percent of tolerance if not verified
        tolerance -= tolerance * 0.01
      } while !verifier(simplified)
      positions = simplified
    }
  }
  
}

extension GeoJSON.Polygon {
  
  /// Returns a simplified copy of the polygon
  public func simplified(options: SimplifyOptions = .init()) -> GeoJSON.Polygon {
    var copy = self
    copy.simplify(options: options)
    return copy
  }
  
  /// Mutates the Polygon into a simplified version
  public mutating func simplify(options: SimplifyOptions = .init()) {
    guard positionsArray.contains(where: { $0.count > 3 }) else { return }

    exterior.simplify(options: options, verifier: Self.checkValidity(ring:))
    interiors = interiors.map {
      var updated = $0
      updated.simplify(options: options, verifier: Self.checkValidity(ring:))
      return updated
    }
  }
  
  /// Checks if a ring has at least 3 coordinates. Will return false for a 3 coordinate ring
  /// where the first and last coordinates are the same
  ///
  /// - Parameter ring: Array of coordinates to be checked
  /// - Returns: true if valid
  private static func checkValidity(ring: [GeoJSON.Position]) -> Bool {
    guard ring.count >= 3 else { return false }
    // if the last point is the same as the first, it's not a triangle
    return !(
      ring.count == 3 &&
      ring[2].latitude == ring[0].latitude &&
      ring[2].longitude == ring[0].longitude
    )
  }
}
