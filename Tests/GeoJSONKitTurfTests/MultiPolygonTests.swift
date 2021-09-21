import XCTest

import GeoJSONKit
import GeoJSONKitTurf

class MultiPolygonTests: XCTestCase {
  
  func testMultiPolygonContains() {
    let coordinate = GeoJSON.Position(latitude: 44, longitude: -77)
    let multiPolygon = GeoJSON.GeometryObject.multi([
      .polygon(GeoJSON.Polygon([[
        GeoJSON.Position(latitude: 0, longitude: 0),
        GeoJSON.Position(latitude: 1, longitude: 0),
        GeoJSON.Position(latitude: 1, longitude: 1),
        GeoJSON.Position(latitude: 0, longitude: 1),
        GeoJSON.Position(latitude: 0, longitude: 0),
      ]])),
      .polygon(GeoJSON.Polygon([[
        GeoJSON.Position(latitude: 41, longitude: -81),
        GeoJSON.Position(latitude: 47, longitude: -81),
        GeoJSON.Position(latitude: 47, longitude: -72),
        GeoJSON.Position(latitude: 41, longitude: -72),
        GeoJSON.Position(latitude: 41, longitude: -81),
      ]]))
    ])
    XCTAssertTrue(multiPolygon.contains(coordinate))
  }
  
  func testMultiPolygonDoesNotContain() {
    let coordinate = GeoJSON.Position(latitude: 44, longitude: -87)
    let multiPolygon = GeoJSON.GeometryObject.multi([
      .polygon(GeoJSON.Polygon([[
        GeoJSON.Position(latitude: 0, longitude: 0),
        GeoJSON.Position(latitude: 1, longitude: 0),
        GeoJSON.Position(latitude: 1, longitude: 1),
        GeoJSON.Position(latitude: 0, longitude: 1),
        GeoJSON.Position(latitude: 0, longitude: 0),
      ]])),
      .polygon(GeoJSON.Polygon([[
        GeoJSON.Position(latitude: 41, longitude: -81),
        GeoJSON.Position(latitude: 47, longitude: -81),
        GeoJSON.Position(latitude: 47, longitude: -72),
        GeoJSON.Position(latitude: 41, longitude: -72),
        GeoJSON.Position(latitude: 41, longitude: -81),
      ]]))
    ])
    XCTAssertFalse(multiPolygon.contains(coordinate))
  }
  
  func testMultiPolygonDoesNotContainWithHole() {
    let coordinate = GeoJSON.Position(latitude: 44, longitude: -77)
    let polygon = GeoJSON.Polygon([
      [
        GeoJSON.Position(latitude: 41, longitude: -81),
        GeoJSON.Position(latitude: 47, longitude: -81),
        GeoJSON.Position(latitude: 47, longitude: -72),
        GeoJSON.Position(latitude: 41, longitude: -72),
        GeoJSON.Position(latitude: 41, longitude: -81),
      ],
      [
        GeoJSON.Position(latitude: 43, longitude: -76),
        GeoJSON.Position(latitude: 43, longitude: -78),
        GeoJSON.Position(latitude: 45, longitude: -78),
        GeoJSON.Position(latitude: 45, longitude: -76),
        GeoJSON.Position(latitude: 43, longitude: -76),
      ],
    ])
    let multiPolygon = GeoJSON.GeometryObject.multi([
      .polygon(polygon),
      .polygon(GeoJSON.Polygon([[
        GeoJSON.Position(latitude: 0, longitude: 0),
        GeoJSON.Position(latitude: 1, longitude: 0),
        GeoJSON.Position(latitude: 1, longitude: 1),
        GeoJSON.Position(latitude: 0, longitude: 1),
        GeoJSON.Position(latitude: 0, longitude: 0),
      ]]))
    ])
    XCTAssertFalse(multiPolygon.contains(coordinate))
  }
  
  func testMultiPolygonContainsAtBoundary() {
    let coordinate = GeoJSON.Position(latitude: 1, longitude: 1)
    let multiPolygon = GeoJSON.GeometryObject.multi([
      .polygon(GeoJSON.Polygon([[
        GeoJSON.Position(latitude: 0, longitude: 0),
        GeoJSON.Position(latitude: 1, longitude: 0),
        GeoJSON.Position(latitude: 1, longitude: 1),
        GeoJSON.Position(latitude: 0, longitude: 1),
        GeoJSON.Position(latitude: 0, longitude: 0),
      ]])),
      .polygon(GeoJSON.Polygon([[
        GeoJSON.Position(latitude: 41, longitude: -81),
        GeoJSON.Position(latitude: 47, longitude: -81),
        GeoJSON.Position(latitude: 47, longitude: -72),
        GeoJSON.Position(latitude: 41, longitude: -72),
        GeoJSON.Position(latitude: 41, longitude: -81),
      ]]))
    ])
    
    XCTAssertFalse(multiPolygon.contains(coordinate, ignoreBoundary: true))
    XCTAssertTrue(multiPolygon.contains(coordinate, ignoreBoundary: false))
    XCTAssertTrue(multiPolygon.contains(coordinate))
  }
  
  func testMultiPolygonWithHoleContainsAtBoundary() {
    let coordinate = GeoJSON.Position(latitude: 43, longitude: -78)
    let multiPolygon = GeoJSON.GeometryObject.multi([
      .polygon(GeoJSON.Polygon([
        [
          GeoJSON.Position(latitude: 41, longitude: -81),
          GeoJSON.Position(latitude: 47, longitude: -81),
          GeoJSON.Position(latitude: 47, longitude: -72),
          GeoJSON.Position(latitude: 41, longitude: -72),
          GeoJSON.Position(latitude: 41, longitude: -81),
        ],
        [
          GeoJSON.Position(latitude: 43, longitude: -76),
          GeoJSON.Position(latitude: 43, longitude: -78),
          GeoJSON.Position(latitude: 45, longitude: -78),
          GeoJSON.Position(latitude: 45, longitude: -76),
          GeoJSON.Position(latitude: 43, longitude: -76),
        ]
      ])),
      .polygon(GeoJSON.Polygon([[
        GeoJSON.Position(latitude: 0, longitude: 0),
        GeoJSON.Position(latitude: 1, longitude: 0),
        GeoJSON.Position(latitude: 1, longitude: 1),
        GeoJSON.Position(latitude: 0, longitude: 1),
        GeoJSON.Position(latitude: 0, longitude: 0),
      ]]))
    ])
    
    XCTAssertFalse(multiPolygon.contains(coordinate, ignoreBoundary: true))
    XCTAssertTrue(multiPolygon.contains(coordinate, ignoreBoundary: false))
    XCTAssertTrue(multiPolygon.contains(coordinate))
  }
}
