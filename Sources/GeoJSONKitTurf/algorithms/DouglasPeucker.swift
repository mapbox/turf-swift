//
//  DouglasPeucher.swift
//  GeoJSONKitTurf
//
//  Created by Adrian Schönig on 4/9/21.
//

import Foundation

import GeoJSONKit

struct DouglasPeucker {
  let coordinates: [GeoJSON.Position]
  let sqTolerance: Double
  
  var result: [GeoJSON.Position]

  mutating func start() {
    step(first: 0, last: coordinates.count - 1)
  }
  
  private mutating func step2(first: Int, last: Int) {
    let start = coordinates[first]
    let end   = coordinates[last]
    let slice = coordinates[(first+1)..<last]
    
    guard !slice.isEmpty else { return }
    let (offset, maxSquareDistance) = slice
      .map { Self.squareSegmentDistance($0, start: start, end: end) }
      .enumerated()
      .max { $0.element < $1.element }!
    
    guard maxSquareDistance > sqTolerance else { return }
    
    let index = first + 1 + offset
    if first + 1 < index {
      step(first: first, last: index)
    }
    result.append(coordinates[index])
    if index < last - 1 {
      step(first: index, last: last)
    }
  }
  
  private mutating func step(first: Int, last: Int) {
    let start = coordinates[first]
    let end   = coordinates[last]
    
    var index = 0
    var maxSquareDistance = sqTolerance
    
    for i in first + 1 ..< last {
      let squareDistance = Self.squareSegmentDistance(coordinates[i], start: start, end: end)
      if squareDistance > maxSquareDistance {
        index = i
        maxSquareDistance = squareDistance
      }
    }
    
    guard maxSquareDistance > sqTolerance else { return }
    
    if first + 1 < index {
      step(first: first, last: index)
    }
    
    result.append(coordinates[index])
    if index < last - 1 {
      step(first: index, last: last)
    }
  }
  
  private static func squareSegmentDistance(_ coordinate: GeoJSON.Position, start: GeoJSON.Position, end: GeoJSON.Position) -> GeoJSON.Distance {
    var x = start.longitude
    var y = start.latitude
    var dx = end.longitude - x
    var dy = end.latitude - y
    
    if dx != 0 || dy != 0 {
      let t = ((coordinate.longitude - x) * dx + (coordinate.latitude - y) * dy) / (dx * dx + dy * dy)
      if t > 1 {
        x = end.longitude
        y = end.latitude
      } else if t > 0 {
        x += dx * t
        y += dy * t
      }
    }
    
    dx = coordinate.longitude - x
    dy = coordinate.latitude - y
    
    return dx * dx + dy * dy
  }
  
  // MARK: - Convenience
  
  static func simplify(_ coordinates: [GeoJSON.Position], sqTolerance: Double) -> [GeoJSON.Position] {
    
    guard coordinates.count > 2, let first = coordinates.first, let last = coordinates.last else {
      return coordinates
    }

    var simplifier = DouglasPeucker(coordinates: coordinates, sqTolerance: sqTolerance, result: [first])
    simplifier.start()
    return simplifier.result + [last]
  }
}
