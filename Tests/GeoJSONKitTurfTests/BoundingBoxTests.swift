import XCTest

@testable import GeoJSONKitTurf
import GeoJSONKit

class BoundingBoxTests: XCTestCase {
  
  func testAllPositive() {
    let coordinates = [
      GeoJSON.Position(latitude: 1, longitude: 2),
      GeoJSON.Position(latitude: 2, longitude: 1)
    ]
    let bbox = GeoJSON.BoundingBox(positions: coordinates, allowSpanningAntimeridian: true)
    XCTAssertFalse(bbox.spansAntimeridian)
    XCTAssertEqual(bbox.southWesterlyLatitude, 1)
    XCTAssertEqual(bbox.southWesterlyLongitude,1)
    XCTAssertEqual(bbox.northEasterlyLatitude, 2)
    XCTAssertEqual(bbox.northEasterlyLongitude, 2)
  }
  
  func testAllNegative() {
    let coordinates = [
      GeoJSON.Position(latitude: -1, longitude: -2),
      GeoJSON.Position(latitude: -2, longitude: -1)
    ]
    let bbox = GeoJSON.BoundingBox(positions: coordinates, allowSpanningAntimeridian: true)
    XCTAssertFalse(bbox.spansAntimeridian)
    XCTAssertEqual(bbox.southWesterlyLatitude, -2)
    XCTAssertEqual(bbox.southWesterlyLongitude, -2)
    XCTAssertEqual(bbox.northEasterlyLatitude, -1)
    XCTAssertEqual(bbox.northEasterlyLongitude, -1)
  }
  
  func testPositiveLatNegativeLon() {
    let coordinates = [
      GeoJSON.Position(latitude: 1, longitude: -2),
      GeoJSON.Position(latitude: 2, longitude: -1)
    ]
    let bbox = GeoJSON.BoundingBox(positions: coordinates, allowSpanningAntimeridian: true)
    XCTAssertFalse(bbox.spansAntimeridian)
    XCTAssertEqual(bbox.southWesterlyLatitude, 1)
    XCTAssertEqual(bbox.southWesterlyLongitude,-2)
    XCTAssertEqual(bbox.northEasterlyLatitude, 2)
    XCTAssertEqual(bbox.northEasterlyLongitude, -1)
  }
  
  func testNegativeLatPositiveLon() {
    let coordinates = [
      GeoJSON.Position(latitude: -1, longitude: 2),
      GeoJSON.Position(latitude: -2, longitude: 1)
    ]
    let bbox = GeoJSON.BoundingBox(positions: coordinates, allowSpanningAntimeridian: true)
    XCTAssertFalse(bbox.spansAntimeridian)
    XCTAssertEqual(bbox.southWesterlyLatitude, -2)
    XCTAssertEqual(bbox.southWesterlyLongitude, 1)
    XCTAssertEqual(bbox.northEasterlyLatitude, -1)
    XCTAssertEqual(bbox.northEasterlyLongitude, 2)
  }
  
  /// From GeoJSON Specs
  ///
  /// Consider a set of point Features within the Fiji archipelago,
  /// straddling the antimeridian between 16 degrees S and 20 degrees S.
  /// The southwest corner of the box containing these Features is at 20
  /// degrees S and 177 degrees E, and the northwest corner is at 16
  /// degrees S and 178 degrees W.  The antimeridian-spanning GeoJSON
  /// bounding box for this FeatureCollection is
  ///
  /// `"bbox": [177.0, -20.0, -178.0, -16.0]`
  ///
  /// and covers 5 degrees of longitude.
  func testFijiBoundingBox() {
    let southWest = GeoJSON.Position(latitude: -20, longitude: 177)
    let northEast = GeoJSON.Position(latitude: -16, longitude: -178)
    let box = GeoJSON.BoundingBox(positions: [southWest, northEast], allowSpanningAntimeridian: true)
    XCTAssertTrue(box.spansAntimeridian)
    XCTAssertEqual(box.northEasterlyLatitude,  northEast.latitude)
    XCTAssertEqual(box.northEasterlyLongitude, northEast.longitude)
    XCTAssertEqual(box.southWesterlyLatitude,  southWest.latitude)
    XCTAssertEqual(box.southWesterlyLongitude, southWest.longitude)
  }
  
  func testAntimeridianCrossExtendingEast() throws {
    var box = try GeoJSON.BoundingBox(coordinates: [175, 9, 176, 10])
    XCTAssertFalse(box.spansAntimeridian)
    
    box.append(.init(latitude: 8, longitude: -178), allowSpanningAntimeridian: true)
    XCTAssertTrue(box.spansAntimeridian)
    XCTAssertEqual(box.northEasterlyLatitude,  10)
    XCTAssertEqual(box.northEasterlyLongitude, -178)
    XCTAssertEqual(box.southWesterlyLatitude,  8)
    XCTAssertEqual(box.southWesterlyLongitude, 175)
  }
  
  func testAntimeridianCrossExtendingWest() throws {
    var box = try GeoJSON.BoundingBox(coordinates: [-178, 9, -177, 10])
    XCTAssertFalse(box.spansAntimeridian)

    box.append(.init(latitude: 8, longitude: 179), allowSpanningAntimeridian: true)
    XCTAssertTrue(box.spansAntimeridian)
    XCTAssertEqual(box.northEasterlyLatitude,  10)
    XCTAssertEqual(box.northEasterlyLongitude, -177)
    XCTAssertEqual(box.southWesterlyLatitude,  8)
    XCTAssertEqual(box.southWesterlyLongitude, 179)
  }
  
  func testExtendingGiantEastAcrossAntimeridian() throws {
    var box = try GeoJSON.BoundingBox(coordinates: [-170, 9, 178, 10])
    XCTAssertFalse(box.spansAntimeridian)

    box.append(.init(latitude: 8, longitude: -179), allowSpanningAntimeridian: true)
    XCTAssertTrue(box.spansAntimeridian)
    XCTAssertEqual(box.northEasterlyLatitude,  10)
    XCTAssertEqual(box.northEasterlyLongitude, -179)
    XCTAssertEqual(box.southWesterlyLatitude,  8)
    XCTAssertEqual(box.southWesterlyLongitude, -170)
  }
  
  func testExtendingGiantWestNotAcrossAntimeridian() throws {
    var box = try GeoJSON.BoundingBox(coordinates: [-170, 9, 178, 10])
    XCTAssertFalse(box.spansAntimeridian)

    box.append(.init(latitude: 8, longitude: -171), allowSpanningAntimeridian: true)
    XCTAssertFalse(box.spansAntimeridian)
    XCTAssertEqual(box.northEasterlyLatitude,  10)
    XCTAssertEqual(box.northEasterlyLongitude, 178)
    XCTAssertEqual(box.southWesterlyLatitude,  8)
    XCTAssertEqual(box.southWesterlyLongitude, -171)
  }
  
  func testExtendingGiantWestAcrossAntimeridian() throws {
    var box = try GeoJSON.BoundingBox(coordinates: [-178, 9, 170, 10])
    XCTAssertFalse(box.spansAntimeridian)

    box.append(.init(latitude: 8, longitude: 179), allowSpanningAntimeridian: true)
    XCTAssertTrue(box.spansAntimeridian)
    XCTAssertEqual(box.northEasterlyLatitude,  10)
    XCTAssertEqual(box.northEasterlyLongitude, 170)
    XCTAssertEqual(box.southWesterlyLatitude,  8)
    XCTAssertEqual(box.southWesterlyLongitude, 179)
  }
  
  func testExtendingGiantEastNotAcrossAntimeridian() throws {
    var box = try GeoJSON.BoundingBox(coordinates: [-178, 9, 170, 10])
    XCTAssertFalse(box.spansAntimeridian)

    box.append(.init(latitude: 8, longitude: 171), allowSpanningAntimeridian: true)
    XCTAssertFalse(box.spansAntimeridian)
    XCTAssertEqual(box.northEasterlyLatitude,  10)
    XCTAssertEqual(box.northEasterlyLongitude, 171)
    XCTAssertEqual(box.southWesterlyLatitude,  8)
    XCTAssertEqual(box.southWesterlyLongitude, -178)
  }
  
  func testAntimeridianExtendSouthOnPositive() throws {
    var box = try GeoJSON.BoundingBox(coordinates: [178, 9, -178, 10])
    XCTAssertTrue(box.spansAntimeridian)

    box.append(.init(latitude: 8, longitude: 179), allowSpanningAntimeridian: true)
    XCTAssertTrue(box.spansAntimeridian)
    XCTAssertEqual(box.northEasterlyLatitude,  10)
    XCTAssertEqual(box.northEasterlyLongitude, -178)
    XCTAssertEqual(box.southWesterlyLatitude,  8)
    XCTAssertEqual(box.southWesterlyLongitude, 178)
  }

  func testAntimeridianExtendSouthOnNegative() throws {
    var box = try GeoJSON.BoundingBox(coordinates: [178, 9, -178, 10])
    XCTAssertTrue(box.spansAntimeridian)

    box.append(.init(latitude: 8, longitude: -179), allowSpanningAntimeridian: true)
    XCTAssertTrue(box.spansAntimeridian)
    XCTAssertEqual(box.northEasterlyLatitude,  10)
    XCTAssertEqual(box.northEasterlyLongitude, -178)
    XCTAssertEqual(box.southWesterlyLatitude,  8)
    XCTAssertEqual(box.southWesterlyLongitude, 178)
  }
  
  func testContains() {
    let coordinate = GeoJSON.Position(latitude: 1, longitude: 1)
    let coordinates = [
      GeoJSON.Position(latitude: 0, longitude: 0),
      GeoJSON.Position(latitude: 2, longitude: 2)
    ]
    let bbox = GeoJSON.BoundingBox(positions: coordinates, allowSpanningAntimeridian: true)
    
    XCTAssertTrue(bbox.contains(coordinate))
  }
  
  func testDoesNotContain() {
    let coordinate = GeoJSON.Position(latitude: 2, longitude: 3)
    let coordinates = [
      GeoJSON.Position(latitude: 0, longitude: 0),
      GeoJSON.Position(latitude: 2, longitude: 2)
    ]
    let bbox = GeoJSON.BoundingBox(positions: coordinates, allowSpanningAntimeridian: true)
    
    XCTAssertFalse(bbox.contains(coordinate))
  }
  
  func testContainsAtBoundary() {
    let coordinate = GeoJSON.Position(latitude: 0, longitude: 2)
    let coordinates = [
      GeoJSON.Position(latitude: 0, longitude: 0),
      GeoJSON.Position(latitude: 2, longitude: 2)
    ]
    let bbox = GeoJSON.BoundingBox(positions: coordinates, allowSpanningAntimeridian: true)
    
    XCTAssertFalse(bbox.contains(coordinate, ignoreBoundary: true))
    XCTAssertTrue(bbox.contains(coordinate, ignoreBoundary: false))
    XCTAssertFalse(bbox.contains(coordinate))
  }
  
  func testAntimeridianContains() throws {
    let box = try GeoJSON.BoundingBox(coordinates: [175, 8, -179, 10])
    XCTAssertTrue(box.contains(.init(latitude: 9, longitude: 179)))
    XCTAssertTrue(box.contains(.init(latitude: 9, longitude: -179)))
  }

}
