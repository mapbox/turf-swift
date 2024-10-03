import XCTest
#if !os(Linux)
import CoreLocation
#endif

@testable import Turf

class BoundingBoxTests: XCTestCase {
    
    func testAllPositive() {
        let coordinates = [
            TurfLocationCoordinate2D(latitude: 1, longitude: 2),
            TurfLocationCoordinate2D(latitude: 2, longitude: 1)
        ]
        let bbox = TurfBoundingBox(from: coordinates)
        XCTAssertEqual(bbox!.southWest, TurfLocationCoordinate2D(latitude: 1, longitude: 1))
        XCTAssertEqual(bbox!.northEast, TurfLocationCoordinate2D(latitude: 2, longitude: 2))
    }
    
    func testAllNegative() {
        let coordinates = [
            TurfLocationCoordinate2D(latitude: -1, longitude: -2),
            TurfLocationCoordinate2D(latitude: -2, longitude: -1)
        ]
        let bbox = TurfBoundingBox(from: coordinates)
        XCTAssertEqual(bbox!.southWest, TurfLocationCoordinate2D(latitude: -2, longitude: -2))
        XCTAssertEqual(bbox!.northEast, TurfLocationCoordinate2D(latitude: -1, longitude: -1))
    }
    
    func testPositiveLatNegativeLon() {
        let coordinates = [
            TurfLocationCoordinate2D(latitude: 1, longitude: -2),
            TurfLocationCoordinate2D(latitude: 2, longitude: -1)
        ]
        let bbox = TurfBoundingBox(from: coordinates)
        XCTAssertEqual(bbox!.southWest, TurfLocationCoordinate2D(latitude: 1, longitude: -2))
        XCTAssertEqual(bbox!.northEast, TurfLocationCoordinate2D(latitude: 2, longitude: -1))
    }
    
    func testNegativeLatPositiveLon() {
        let coordinates = [
            TurfLocationCoordinate2D(latitude: -1, longitude: 2),
            TurfLocationCoordinate2D(latitude: -2, longitude: 1)
        ]
        let bbox = TurfBoundingBox(from: coordinates)
        XCTAssertEqual(bbox!.southWest, TurfLocationCoordinate2D(latitude: -2, longitude: 1))
        XCTAssertEqual(bbox!.northEast, TurfLocationCoordinate2D(latitude: -1, longitude: 2))
    }

    func testContains() {
        let coordinate = TurfLocationCoordinate2D(latitude: 1, longitude: 1)
        let coordinates = [
            TurfLocationCoordinate2D(latitude: 0, longitude: 0),
            TurfLocationCoordinate2D(latitude: 2, longitude: 2)
        ]
        let bbox = TurfBoundingBox(from: coordinates)

        XCTAssertTrue(bbox!.contains(coordinate))
    }

    func testDoesNotContain() {
        let coordinate = TurfLocationCoordinate2D(latitude: 2, longitude: 3)
        let coordinates = [
            TurfLocationCoordinate2D(latitude: 0, longitude: 0),
            TurfLocationCoordinate2D(latitude: 2, longitude: 2)
        ]
        let bbox = TurfBoundingBox(from: coordinates)

        XCTAssertFalse(bbox!.contains(coordinate))
    }

    func testContainsAtBoundary() {
        let coordinate = TurfLocationCoordinate2D(latitude: 0, longitude: 2)
        let coordinates = [
            TurfLocationCoordinate2D(latitude: 0, longitude: 0),
            TurfLocationCoordinate2D(latitude: 2, longitude: 2)
        ]
        let bbox = TurfBoundingBox(from: coordinates)

        XCTAssertFalse(bbox!.contains(coordinate, ignoreBoundary: true))
        XCTAssertTrue(bbox!.contains(coordinate, ignoreBoundary: false))
        XCTAssertFalse(bbox!.contains(coordinate))
    }
}
