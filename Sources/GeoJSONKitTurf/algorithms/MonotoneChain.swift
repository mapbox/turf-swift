//
//  MonotoneChain.swift
//  
//
//  Created by Adrian Schönig on 14/6/2022.
//

import Foundation

import GeoJSONKit

// Adopted from https://en.wikibooks.org/wiki/Algorithm_Implementation/Geometry/Convex_hull/Monotone_chain
struct AndrewsMonotoneChain {
  private static func cross(_ o: GeoJSON.Position, _ a: GeoJSON.Position, _ b: GeoJSON.Position) -> Double {
    let lhs = (a.x - o.x) * (b.y - o.y)
    let rhs = (a.y - o.y) * (b.x - o.x)
    return lhs - rhs
  }
  
  /// Calculate and return the convex hull of a given sequence of points.
  ///
  /// - Remark: Implements Andrew’s monotone chain convex hull algorithm.
  ///
  /// - Complexity: O(*n* log *n*), where *n* is the count of `points`.
  ///
  /// - Parameter points: A sequence of `GeoJSON.Position` elements.
  ///
  /// - Returns: An array containing the convex hull of `points`, ordered
  ///   lexicographically from the smallest coordinates to the largest,
  ///   turning counterclockwise.
  ///
  static func convexHull<Source>(_ points: Source) -> [GeoJSON.Position]
  where Source : Collection,
        Source.Element == GeoJSON.Position
  {
    // Exit early if there aren’t enough points to work with.
    guard points.count > 1 else { return Array(points) }
    
    // Create storage for the lower and upper hulls.
    var lower = [GeoJSON.Position]()
    var upper = [GeoJSON.Position]()
    
    // Sort points in lexicographical order.
    let points = points.sorted { a, b in
      a.x < b.x || a.x == b.x && a.y < b.y
    }
    
    // Construct the lower hull.
    for point in points {
      while lower.count >= 2 {
        let a = lower[lower.count - 2]
        let b = lower[lower.count - 1]
        if cross(a, b, point) > 0 { break }
        lower.removeLast()
      }
      lower.append(point)
    }
    
    // Construct the upper hull.
    for point in points.lazy.reversed() {
      while upper.count >= 2 {
        let a = upper[upper.count - 2]
        let b = upper[upper.count - 1]
        if cross(a, b, point) > 0 { break }
        upper.removeLast()
      }
      upper.append(point)
    }
    
    // Remove each array’s last point, as it’s the same as the first point
    // in the opposite array, respectively.
    lower.removeLast()
    upper.removeLast()
    
    // Join the arrays to form the convex hull.
    return lower + upper
  }
}

fileprivate extension GeoJSON.Position {
  var x: Double { longitude }
  var y: Double { latitude }
}
