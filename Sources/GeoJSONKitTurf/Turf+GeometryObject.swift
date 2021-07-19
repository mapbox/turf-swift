import Foundation
#if !os(Linux)
import CoreLocation
#endif
import GeoJSONKit

extension GeoJSON.Geometry {
  public func contains(_ coordinate: GeoJSON.Position, ignoreBoundary: Bool = false) -> Bool {
    switch self {
    case .polygon(let polygon):
      return polygon.contains(coordinate, ignoreBoundary: ignoreBoundary)
    case .lineString, .point:
      return false
    }
  }
}

extension GeoJSON.GeometryObject {

  /**
   * Determines if the given coordinate falls within any of the polygons.
   * The optional parameter `ignoreBoundary` will result in the method returning true if the given coordinate
   * lies on the boundary line of the polygon or its interior rings.
   *
   * Calls contains function for each contained polygon
   */
  public func contains(_ coordinate: GeoJSON.Position, ignoreBoundary: Bool = false) -> Bool {
    switch self {
    case .single(let geometry):
      return geometry.contains(coordinate, ignoreBoundary: ignoreBoundary)
    case .multi(let geometries):
      return geometries.contains(where: { $0.contains(coordinate, ignoreBoundary: ignoreBoundary) })
    case .collection(let objects):
      return objects.contains(where: { $0.contains(coordinate, ignoreBoundary: ignoreBoundary) })
    }
  }
}
