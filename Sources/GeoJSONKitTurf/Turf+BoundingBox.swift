import Foundation

import GeoJSONKit

extension GeoJSON.BoundingBox {
  
  public func contains(_ coordinate: GeoJSON.Position, ignoreBoundary: Bool = true) -> Bool {
    if ignoreBoundary {
      return southWesterlyLatitude < coordinate.latitude
          && northEasterlyLatitude > coordinate.latitude
          && southWesterlyLongitude < coordinate.longitude
          && northEasterlyLongitude > coordinate.longitude
    } else {
      return southWesterlyLatitude <= coordinate.latitude
          && northEasterlyLatitude >= coordinate.latitude
          && southWesterlyLongitude <= coordinate.longitude
          && northEasterlyLongitude >= coordinate.longitude
    }
  }
  
  public var center: GeoJSON.Position {
    .init(
      latitude: (southWesterlyLatitude + northEasterlyLatitude) / 2,
      longitude: (southWesterlyLongitude + northEasterlyLongitude) / 2
    )
  }

}
