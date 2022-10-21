//
//  MartinezRuedaFeito.swift
//  
//
//  Created by Adrian Schönig on 25/8/2022.
//

import Foundation

import GeoJSONKit

struct MartinezRuedaFeito {
  
  let input: [GeoJSON.Polygon]
  
  var result: [GeoJSON.Polygon]
  
  mutating func union() {
    precondition(result.isEmpty)
  }
  
  mutating func intersection() {
    precondition(result.isEmpty)

    /* TODO: BBox optimization for intersection operation
     * If we can find any pair of multipolygons whose bbox does not overlap,
     * then the result will be empty. */

  }

  mutating func difference() {
    precondition(result.isEmpty)

    /* TODO: BBox optimization for difference operation
     * If the bbox of a multipolygon that's part of the clipping doesn't
     * intersect the bbox of the subject at all, we can just drop that
     * multiploygon. */
  }

}
