//
//  ClosestCoordinate.swift
//  
//
//  Created by Adrian Schönig on 1/7/2022.
//

import Foundation

import GeoJSONKit

extension GeoJSON.LineString {
  
  /// `IndexedCoordinate` is a coordinate with additional information such as
  /// the index from its position in the polyline and distance from the start
  /// of the polyline.
  public struct IndexedCoordinate {
    /// The coordinate
    public let coordinate: Array<GeoJSON.Position>.Element
    /// The index of the coordinate
    public let index: Array<GeoJSON.Position>.Index
    /// The coordinate’s distance from the start of the polyline
    public let distance: GeoJSON.Distance
  }
  
}

extension GeoJSON.LineString.IndexedCoordinate {
  
  static func findClosest(to coordinate: GeoJSON.Position, on coordinates: [GeoJSON.Position]) -> GeoJSON.LineString.IndexedCoordinate? {
    
    guard let startCoordinate = coordinates.first else { return nil }
    
    guard coordinates.count > 1 else {
      return GeoJSON.LineString.IndexedCoordinate(coordinate: startCoordinate, index: 0, distance: coordinate.distance(to: startCoordinate))
    }
    
    var closestCoordinate: GeoJSON.LineString.IndexedCoordinate?
    var closestDistance: GeoJSON.Distance?
    
    for index in 0..<coordinates.count - 1 {
      let segment = (coordinates[index], coordinates[index + 1])
      let distances = (coordinate.distance(to: segment.0), coordinate.distance(to: segment.1))
      
      let maxDistance = max(distances.0, distances.1)
      let direction = segment.0.direction(to: segment.1)
      let perpendicularPoint1 = coordinate.coordinate(at: maxDistance, facing: direction + 90)
      let perpendicularPoint2 = coordinate.coordinate(at: maxDistance, facing: direction - 90)
      let intersectionPoint = intersection((perpendicularPoint1, perpendicularPoint2), segment)
      let intersectionDistance: GeoJSON.Distance? = intersectionPoint != nil ? coordinate.distance(to: intersectionPoint!) : nil
      
      if distances.0 < closestDistance ?? .greatestFiniteMagnitude {
        closestCoordinate = GeoJSON.LineString.IndexedCoordinate(coordinate: segment.0,
                                                                 index: index,
                                                                 distance: startCoordinate.distance(to: segment.0))
        closestDistance = distances.0
      }
      if distances.1 < closestDistance ?? .greatestFiniteMagnitude {
        closestCoordinate = GeoJSON.LineString.IndexedCoordinate(coordinate: segment.1,
                                                                 index: index + 1,
                                                                 distance: startCoordinate.distance(to: segment.1))
        closestDistance = distances.1
      }
      if intersectionDistance != nil && intersectionDistance! < closestDistance ?? .greatestFiniteMagnitude {
        closestCoordinate = GeoJSON.LineString.IndexedCoordinate(coordinate: intersectionPoint!,
                                                                 index: index,
                                                                 distance: startCoordinate.distance(to: intersectionPoint!))
        closestDistance = intersectionDistance!
      }
    }
    
    return closestCoordinate
    
  }
  
}
