//
//  Turf+ConvexHull.swift
//  
//
//  Created by Adrian Schönig on 14/6/2022.
//

import Foundation

import GeoJSONKit

extension Collection where Element == GeoJSON.Position {
  /// Calculates the convex hull of a given sequence of positions.
  ///
  /// - Complexity: O(*n* log *n*), where *n* is the count of `points`.
  ///
  /// - Returns: The convex hull of this sequence as a polygon
  public func convexHull() -> GeoJSON.Polygon {
    let positions = AndrewsMonotoneChain.convexHull(self).map { $0.removingAltitude }
    return .init(exterior: .init(positions: positions))
  }
}

extension GeoJSON {
  /// Calculates the convex hull of all the elements of this GeoJSON
  ///
  /// - Returns: The convex hull of this GeoJSON as a polygon
  public func convexHull() -> GeoJSON.Polygon {
    return positions.convexHull()
  }
}

extension GeoJSON.Position {
  fileprivate var removingAltitude: GeoJSON.Position {
    guard altitude != nil else { return self }
    var updated = self
    updated.altitude = nil
    return updated
  }
}
