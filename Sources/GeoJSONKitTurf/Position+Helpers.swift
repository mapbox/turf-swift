//
//  Position+Helpers.swift
//  GeoJSONKitTurf
//
//  Created by Adrian Schönig on 4/9/21.
//

import Foundation

import GeoJSONKit

extension GeoJSON.Position {
  
  func squaredDistance(from other: GeoJSON.Position) -> Double {
    let dx = longitude - other.longitude
    let dy = latitude - other.latitude
    return dx * dx + dy * dy
  }
  
}
