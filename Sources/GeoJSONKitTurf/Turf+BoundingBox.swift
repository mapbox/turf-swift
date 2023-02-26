import Foundation

import GeoJSONKit

extension GeoJSON.BoundingBox {
  
  public func contains(_ coordinate: GeoJSON.Position, ignoreBoundary: Bool = true) -> Bool {
    switch (spansAntimeridian, ignoreBoundary) {
    case (false, true):
      return southWesterlyLatitude < coordinate.latitude
          && northEasterlyLatitude > coordinate.latitude
          && southWesterlyLongitude < coordinate.longitude
          && northEasterlyLongitude > coordinate.longitude
    case (false, false):
      return southWesterlyLatitude <= coordinate.latitude
          && northEasterlyLatitude >= coordinate.latitude
          && southWesterlyLongitude <= coordinate.longitude
          && northEasterlyLongitude >= coordinate.longitude
    case (true, true):
      return southWesterlyLatitude < coordinate.latitude
          && northEasterlyLatitude > coordinate.latitude
          && (southWesterlyLongitude > coordinate.longitude
           || northEasterlyLongitude < coordinate.longitude)
    case (true, false):
      return southWesterlyLatitude <= coordinate.latitude
          && northEasterlyLatitude >= coordinate.latitude
          && (southWesterlyLongitude >= coordinate.longitude
           || northEasterlyLongitude <= coordinate.longitude)
    }
  }
  
  public var center: GeoJSON.Position {
    .init(
      latitude: (southWesterlyLatitude + northEasterlyLatitude) / 2,
      longitude: (southWesterlyLongitude + northEasterlyLongitude) / 2 + (spansAntimeridian ? 180 : 0)
    )
  }
  
  public var spansAntimeridian: Bool {
    northEasterlyLongitude < southWesterlyLongitude
  }
  
  public init(positions: [GeoJSON.Position], allowSpanningAntimeridian: Bool) {
    guard allowSpanningAntimeridian, !positions.isEmpty else {
      self.init(positions: positions)
      return
    }
    
    let sorted = positions.sorted { $0.longitude < $1.longitude }
    
    self = sorted.dropFirst()
      .reduce(into: GeoJSON.BoundingBox(positions: Array(sorted.prefix(1)))) { box, next in
        box.append(next, allowSpanningAntimeridian: allowSpanningAntimeridian)
      }
  }
  
  public init(geometries: [GeoJSON.GeometryObject], allowSpanningAntimeridian: Bool = true) {
    self.init(positions: geometries.flatMap(\.positions), allowSpanningAntimeridian: allowSpanningAntimeridian)
  }
  
  mutating func append(_ position: GeoJSON.Position, allowSpanningAntimeridian: Bool = true) {
    guard !contains(position) else { return }
    let north = max(northEasterlyLatitude, position.latitude)
    let south = min(southWesterlyLatitude, position.latitude)
    
    func distance(to longitude: GeoJSON.Degrees, wrap: Bool) -> GeoJSON.Degrees {
      if wrap {
        return abs((position.longitude - longitude).remainder(dividingBy: 360))
      } else {
        return abs(position.longitude - longitude)
      }
    }
    
    let east, west: GeoJSON.Degrees
    if northEasterlyLongitude >= southWesterlyLongitude, position.longitude <= northEasterlyLongitude, position.longitude >= southWesterlyLongitude {
      // non-wrapping; longitude covered
      east = northEasterlyLongitude
      west = southWesterlyLongitude
    } else if spansAntimeridian, (position.longitude >= northEasterlyLongitude || position.longitude <= southWesterlyLongitude) {
      // wrapping; longitude covered
      east = northEasterlyLongitude
      west = southWesterlyLongitude
    } else if position.longitude > northEasterlyLongitude, distance(to: southWesterlyLongitude, wrap: true) < distance(to: northEasterlyLongitude, wrap: false) {
      // wrapping: position is east, but we extend across west
      east = northEasterlyLongitude
      west = position.longitude
    } else if position.longitude < southWesterlyLongitude, distance(to: northEasterlyLongitude, wrap: true) < distance(to: southWesterlyLongitude, wrap: false) {
      // wrapping: position is west, but we extend across east
      east = position.longitude
      west = southWesterlyLongitude
    } else {
      // non-wrapping: extend to include position
      east = max(position.longitude, northEasterlyLongitude)
      west = min(position.longitude, southWesterlyLongitude)
    }

    let minElev, maxElev: GeoJSON.Degrees?
    if let oldMin = minimumElevation, let oldMax = maximumElevation, let newElev = position.altitude {
      minElev = min(oldMin, newElev)
      maxElev = max(oldMax, newElev)
    } else {
      minElev = minimumElevation ?? position.altitude
      maxElev = maximumElevation ?? position.altitude
    }
    
    self = try! .init(coordinates: [
      west,
      south,
      minElev,
      east,
      north,
      maxElev,
    ].compactMap { $0 })
  }

}
