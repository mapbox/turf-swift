import XCTest

@testable import GeoJSONKitTurf
import GeoJSONKit

class BoundingBoxTests: XCTestCase {
  
  func testAllPositive() {
    let coordinates = [
      GeoJSON.Position(latitude: 1, longitude: 2),
      GeoJSON.Position(latitude: 2, longitude: 1)
    ]
    let bbox = GeoJSON.BoundingBox(positions: coordinates)
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
    let bbox = GeoJSON.BoundingBox(positions: coordinates)
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
    let bbox = GeoJSON.BoundingBox(positions: coordinates)
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
    let bbox = GeoJSON.BoundingBox(positions: coordinates)
    XCTAssertEqual(bbox.southWesterlyLatitude, -2)
    XCTAssertEqual(bbox.southWesterlyLongitude, 1)
    XCTAssertEqual(bbox.northEasterlyLatitude, -1)
    XCTAssertEqual(bbox.northEasterlyLongitude, 2)
  }
  
  func testContains() {
    let coordinate = GeoJSON.Position(latitude: 1, longitude: 1)
    let coordinates = [
      GeoJSON.Position(latitude: 0, longitude: 0),
      GeoJSON.Position(latitude: 2, longitude: 2)
    ]
    let bbox = GeoJSON.BoundingBox(positions: coordinates)
    
    XCTAssertTrue(bbox.contains(coordinate))
  }
  
  func testDoesNotContain() {
    let coordinate = GeoJSON.Position(latitude: 2, longitude: 3)
    let coordinates = [
      GeoJSON.Position(latitude: 0, longitude: 0),
      GeoJSON.Position(latitude: 2, longitude: 2)
    ]
    let bbox = GeoJSON.BoundingBox(positions: coordinates)
    
    XCTAssertFalse(bbox.contains(coordinate))
  }
  
  func testContainsAtBoundary() {
    let coordinate = GeoJSON.Position(latitude: 0, longitude: 2)
    let coordinates = [
      GeoJSON.Position(latitude: 0, longitude: 0),
      GeoJSON.Position(latitude: 2, longitude: 2)
    ]
    let bbox = GeoJSON.BoundingBox(positions: coordinates)
    
    XCTAssertFalse(bbox.contains(coordinate, ignoreBoundary: true))
    XCTAssertTrue(bbox.contains(coordinate, ignoreBoundary: false))
    XCTAssertFalse(bbox.contains(coordinate))
  }
}
