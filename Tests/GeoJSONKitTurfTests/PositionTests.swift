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
  
  func testConvexHull() throws {
    try Fixture.fixtures(folder: "convex") { name, input, expected in
      let actual = input.convexHull()
      
      guard
        case .featureCollection(let features) = expected.object,
        case .single(.polygon(let expectedPolygon)) = features.last?.geometry
      else {
        return XCTFail("Unexpected expected output. Should have a polygon last.")
      }

      if actual != expectedPolygon {
        // Give it another chance on the data-level, too
        do {
          var options: JSONSerialization.WritingOptions = [.prettyPrinted]
          if #available(iOS 11.0, OSX 10.13, *) {
            options.insert(.sortedKeys)
          }
          let newData = try GeoJSON(geometry: .single(.polygon(actual))).toData(options: options)
          let oldData = try GeoJSON(geometry: .single(.polygon(expectedPolygon))).toData(options: options)
          if newData != oldData {
            if true {
              try Self.save(newData, filename: "out_actual", extension: "geojson")
              try Self.save(oldData, filename: "out_expected", extension: "geojson")
            }
            XCTFail("Fixture check failed for \(name)!")
          }
          
        } catch {
          XCTFail("Fixture check failed for \(name)! Also: Generating JSON failed with: \(error)")
        }
      }
      
    }
  }
}
