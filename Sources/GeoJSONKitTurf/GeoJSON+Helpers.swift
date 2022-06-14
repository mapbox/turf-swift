//
//  GeoJSON+Helpers.swift
//  
//
//  Created by Adrian Schönig on 14/6/2022.
//

import GeoJSONKit

extension GeoJSON.GeometryObject {
  public var geometries: [GeoJSON.Geometry] {
    switch self {
    case .single(let geo): return [geo]
    case .multi(let geos): return geos
    case .collection(let geoObjects): return geoObjects.flatMap(\.geometries)
    }
  }
  
  public var positions: [GeoJSON.Position] {
    geometries.flatMap(\.positions)
  }
}

extension GeoJSON.Geometry {
  public var positions: [GeoJSON.Position] {
    switch self {
    case .point(let position): return [position]
    case .lineString(let line): return line.positions
    case .polygon(let polygon):
      // Ignore the interior positions as the purpose of this is getting
      // bounding boxes, convex hull or alike
      return polygon.exterior.positions
    }
  }
}

extension GeoJSON {
  public var geometries: [GeoJSON.Geometry] {
    switch object {
    case .feature(let feature):
      return feature.geometry.geometries
    case .featureCollection(let features):
      return features.flatMap(\.geometry.geometries)
    case .geometry(let geometry):
      return geometry.geometries
    }
  }
  
  public var positions: [GeoJSON.Position] {
    geometries.flatMap(\.positions)
  }
}
