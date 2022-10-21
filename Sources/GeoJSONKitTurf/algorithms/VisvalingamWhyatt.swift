//
//  Turf+Polygon+VisvalingamWhyatt.swift
//  GeoJSONKit+Turf
//
//  Created by Adrian Schönig on 4/9/21.
//

import Foundation

import GeoJSONKit
// import struct PriorityQueueModule.Heap

/// Implementation of the Visvilingam-Whyatt (1993) algorithm for line simplification by vertex filtering.
/// It is more adapted to natural line than the Douglas&Peucker algorithm.
///
/// Adapted from https://github.com/forallx-algorithms/visvalingam-whyatt-simplification
struct VisvilingamWhyatt {
  let areaTolerance: Double
  
  private struct PointEntry: Comparable, Equatable {
    static func < (lhs: VisvilingamWhyatt.PointEntry, rhs: VisvilingamWhyatt.PointEntry) -> Bool {
      lhs.area < rhs.area
    }
    
    let index: Int
    var left: Int
    var right: Int
    let area: Double
  }
    
  func simplify(_ coordinates: [GeoJSON.Position]) -> [GeoJSON.Position] {
    guard coordinates.count > 2 else {
      return coordinates
    }
    
    var simplified = coordinates
    while true {
      let removable = (1..<simplified.count - 2)
      //          .filter { !Self.triangleOverlaps(at: $0, all: simplified) }
      
      let (offset, _) = removable
        .map { (offset: $0, area: Self.triangleArea(at: $0, in: simplified)) }
        .filter { $0.area < areaTolerance }
        .min { $0.area < $1.area } ?? (nil, nil)
      guard let offset = offset else { break }
      simplified.remove(at: offset)
    }
    
    return Array(simplified)
  }
  
  /// Returns true if the triangle at `index` with its neighbours contains another point in `all`
  private static func triangleOverlaps(at index: Int, all: [GeoJSON.Position]) -> Bool {
    let before = all[index - 1]
    let this = all[index]
    let after = all[index + 1]
    let triangle = GeoJSON.Polygon([[before, this, after]])
    return all.enumerated()
      .contains { ($0.offset < index - 1 || $0.offset > index + 1) && triangle.contains($0.element) }
  }
  
  private static func triangleArea(at index: Int, in all: [GeoJSON.Position]) -> Double {
    let before = all[index - 1]
    let this = all[index]
    let after = all[index + 1]
    return triangleArea(before, this, after)
  }
  
  private static func length(_ x: GeoJSON.Position, _ y: GeoJSON.Position) -> Double {
    sqrt(x.squaredDistance(from: y))
  }
  
  private static func triangleArea(_ x: GeoJSON.Position, _ y: GeoJSON.Position, _ z: GeoJSON.Position) -> Double {
    // Heron's formula
    let a = length(x, y)
    let b = length(x, z)
    let c = length(y, z)
    let p  = (a + b + c) / 2
    return sqrt(p * (p - a) * (p - b) * (p - c))
  }
  
  // MARK: - Convenience
  
  static func simplify(_ coordinates: [GeoJSON.Position], tolerance: Double) -> [GeoJSON.Position] {
    return VisvilingamWhyatt(areaTolerance: tolerance).simplify(coordinates)
  }
}

struct VisvilingamWhyatt2 {
  let areaTolerance: Double
  
  private struct PointEntry: Comparable, Equatable {
    static func < (lhs: Self, rhs: Self) -> Bool {
      lhs.area < rhs.area
    }
    
    let index: Int
    var left: Int
    var right: Int
    let area: Double
  }
    
  func simplify(_ coordinates: [GeoJSON.Position]) -> [GeoJSON.Position] {
    guard coordinates.count > 2 else {
      return coordinates
    }
    
    // Important, `entry.index` is always one more than the index in `entries`
    var entries = (1..<coordinates.count - 2)
      .map { index -> PointEntry in
        let area = Self.triangleArea(at: index, in: coordinates)
        return PointEntry(index: index, left: index - 1, right: index + 1, area: area)
      }
    
    while let entry = entries.popLast(), entry.area < areaTolerance {
      var leftEntry = entries[entry.left]
      var rightEntry = entries[entry.right]
      leftEntry.right = rightEntry.index
      rightEntry.left = leftEntry.index
      #warning("Continue here")
      
      // 1. Update areas of left and right => Easy
      // 2. Update in `entries`            => Easy, too, as we have the index
      // 3. Update in `heap`               => Impossible :(
      
    }
    
    var simplified = coordinates
    while true {
      let removable = (1..<simplified.count - 2)
      //          .filter { !Self.triangleOverlaps(at: $0, all: simplified) }
      
      let (offset, _) = removable
        .map { (offset: $0, area: Self.triangleArea(at: $0, in: simplified)) }
        .filter { $0.area < areaTolerance }
        .min { $0.area < $1.area } ?? (nil, nil)
      guard let offset = offset else { break }
      simplified.remove(at: offset)
    }
    
    return Array(simplified)
  }
  
  /// Returns true if the triangle at `index` with its neighbours contains another point in `all`
  private static func triangleOverlaps(at index: Int, all: [GeoJSON.Position]) -> Bool {
    let before = all[index - 1]
    let this = all[index]
    let after = all[index + 1]
    let triangle = GeoJSON.Polygon([[before, this, after]])
    return all.enumerated()
      .contains { ($0.offset < index - 1 || $0.offset > index + 1) && triangle.contains($0.element) }
  }
  
  private static func triangleArea(at index: Int, in all: [GeoJSON.Position]) -> Double {
    let before = all[index - 1]
    let this = all[index]
    let after = all[index + 1]
    return triangleArea(before, this, after)
  }
  
  private static func length(_ x: GeoJSON.Position, _ y: GeoJSON.Position) -> Double {
    sqrt(x.squaredDistance(from: y))
  }
  
  private static func triangleArea(_ x: GeoJSON.Position, _ y: GeoJSON.Position, _ z: GeoJSON.Position) -> Double {
    // Heron's formula
    let a = length(x, y)
    let b = length(x, z)
    let c = length(y, z)
    let p  = (a + b + c) / 2
    return sqrt(p * (p - a) * (p - b) * (p - c))
  }
}
