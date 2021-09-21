import XCTest

import GeoJSONKit
@testable import GeoJSONKitTurf

class PositionTests: XCTestCase {
  
  func testCalculatesDirection() {
    let startCoordinate = GeoJSON.Position(latitude: 35, longitude: 35)
    let endCoordianate = GeoJSON.Position(latitude: -10, longitude: -10)
    let angle = startCoordinate.direction(to: endCoordianate)
    XCTAssertEqual(angle, -128, accuracy: 1)
  }
  
  func testCalculatesCoordinateFacingDirectionInDegrees() {
    let startCoordianate = GeoJSON.Position(latitude: 35, longitude: 35)
    let angleInDegrees = Measurement<UnitAngle>(value: 45, unit: .degrees)
    let endCoordinate = startCoordianate.coordinate(at: 20 * metersPerRadian, facing: angleInDegrees)
    XCTAssertEqual(endCoordinate.latitude, 49.7, accuracy: 0.1)
    XCTAssertEqual(endCoordinate.longitude, 128.2, accuracy: 0.1)
  }
  
  func testCalculatesCoordinateFacingDirectionInRadians() {
    let startCoordianate = GeoJSON.Position(latitude: 35, longitude: 35)
    let angleInRadians = Measurement<UnitAngle>(value: 0.35, unit: .radians)
    let endCoordinate = startCoordianate.coordinate(at: 20 * metersPerRadian, facing: angleInRadians)
    XCTAssertEqual(endCoordinate.latitude, 69.5, accuracy: 0.1)
    XCTAssertEqual(endCoordinate.longitude, 151.7, accuracy: 0.1)
  }
  
  func testDeprecatedCalculationOfCoordinateFacingDirectionInDegrees() {
    let startCoordianate = GeoJSON.Position(latitude: 35, longitude: 35)
    let endCoordinate = startCoordianate.coordinate(at: 20 * metersPerRadian, facing: 0)
    XCTAssertEqual(endCoordinate.latitude, 79, accuracy: 0.1)
    XCTAssertEqual(endCoordinate.longitude, 215, accuracy: 0.1)
  }
}
