import XCTest
#if !os(Linux)
import CoreLocation
#endif
@testable import Turf

class RadianCoordinate2DTests: XCTestCase {

    func testCalculatesDirection() {
        let startCoordinate = RadianCoordinate2D(latitude: 35, longitude: 35)
        let endCoordianate = RadianCoordinate2D(latitude: -10, longitude: -10)
        let angle = startCoordinate.direction(to: endCoordianate)
        XCTAssertEqual(angle.value, 2.3, accuracy: 0.1)
        XCTAssertEqual(angle.unit, .radians)
    }

    func testCalculatesCoordinateFacingDirectionInDegrees() {
        let startCoordianate = RadianCoordinate2D(latitude: 35, longitude: 35)
        let angleInDegrees = Measurement<UnitAngle>(value: 45, unit: .degrees)
        let endCoordinate = startCoordianate.coordinate(at: 20, facing: angleInDegrees)
        XCTAssertEqual(endCoordinate.latitude, -0.8, accuracy: 0.1)
        XCTAssertEqual(endCoordinate.longitude, 33.6, accuracy: 0.1)
    }

    func testCalculatesCoordinateFacingDirectionInRadians() {
        let startCoordianate = RadianCoordinate2D(latitude: 35, longitude: 35)
        let angleInRadians = Measurement<UnitAngle>(value: 0.35, unit: .radians)
        let endCoordinate = startCoordianate.coordinate(at: 20, facing: angleInRadians)
        XCTAssertEqual(endCoordinate.latitude, -1.25, accuracy: 0.1)
        XCTAssertEqual(endCoordinate.longitude, 33.4, accuracy: 0.1)
    }

    func testCalculatesDistanceBetweenCoordinates() {
        let startCoordianate = RadianCoordinate2D(latitude: 35, longitude: 35)
        let endCoordianate = RadianCoordinate2D(latitude: -10, longitude: -10)
        let distance = startCoordianate.distance(to: endCoordianate)
        XCTAssertEqual(distance, 1.4, accuracy: 0.1)
    }
}
