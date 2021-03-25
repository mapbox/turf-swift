import XCTest
#if !os(Linux)
import CoreLocation
#endif

@testable import Turf

class BoundingBoxTests: XCTestCase {
    
    func testAllPositive() {
        let coordinates = [
            LocationCoordinate2D(latitude: 1, longitude: 2),
            LocationCoordinate2D(latitude: 2, longitude: 1)
        ]
        let bbox = BoundingBox(from: coordinates)
        XCTAssertEqual(bbox!.southWest, LocationCoordinate2D(latitude: 1, longitude: 1))
        XCTAssertEqual(bbox!.northEast, LocationCoordinate2D(latitude: 2, longitude: 2))
    }
    
    func testAllNegative() {
        let coordinates = [
            LocationCoordinate2D(latitude: -1, longitude: -2),
            LocationCoordinate2D(latitude: -2, longitude: -1)
        ]
        let bbox = BoundingBox(from: coordinates)
        XCTAssertEqual(bbox!.southWest, LocationCoordinate2D(latitude: -2, longitude: -2))
        XCTAssertEqual(bbox!.northEast, LocationCoordinate2D(latitude: -1, longitude: -1))
    }
    
    func testPositiveLatNegativeLon() {
        let coordinates = [
            LocationCoordinate2D(latitude: 1, longitude: -2),
            LocationCoordinate2D(latitude: 2, longitude: -1)
        ]
        let bbox = BoundingBox(from: coordinates)
        XCTAssertEqual(bbox!.southWest, LocationCoordinate2D(latitude: 1, longitude: -2))
        XCTAssertEqual(bbox!.northEast, LocationCoordinate2D(latitude: 2, longitude: -1))
    }
    
    func testNegativeLatPositiveLon() {
        let coordinates = [
            LocationCoordinate2D(latitude: -1, longitude: 2),
            LocationCoordinate2D(latitude: -2, longitude: 1)
        ]
        let bbox = BoundingBox(from: coordinates)
        XCTAssertEqual(bbox!.southWest, LocationCoordinate2D(latitude: -2, longitude: 1))
        XCTAssertEqual(bbox!.northEast, LocationCoordinate2D(latitude: -1, longitude: 2))
    }

    func testContains() {
        let coordinate = LocationCoordinate2D(latitude: 1, longitude: 1)
        let coordinates = [
            LocationCoordinate2D(latitude: 0, longitude: 0),
            LocationCoordinate2D(latitude: 2, longitude: 2)
        ]
        let bbox = BoundingBox(from: coordinates)

        XCTAssertTrue(bbox!.contains(coordinate))
    }

    func testDoesNotContain() {
        let coordinate = LocationCoordinate2D(latitude: 2, longitude: 3)
        let coordinates = [
            LocationCoordinate2D(latitude: 0, longitude: 0),
            LocationCoordinate2D(latitude: 2, longitude: 2)
        ]
        let bbox = BoundingBox(from: coordinates)

        XCTAssertFalse(bbox!.contains(coordinate))
    }

    func testContainsAtBoundary() {
        let coordinate = LocationCoordinate2D(latitude: 0, longitude: 2)
        let coordinates = [
            LocationCoordinate2D(latitude: 0, longitude: 0),
            LocationCoordinate2D(latitude: 2, longitude: 2)
        ]
        let bbox = BoundingBox(from: coordinates)

        XCTAssertFalse(bbox!.contains(coordinate, ignoreBoundary: true))
        XCTAssertTrue(bbox!.contains(coordinate, ignoreBoundary: false))
        XCTAssertFalse(bbox!.contains(coordinate))
    }
}
