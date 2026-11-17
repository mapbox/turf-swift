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

    func testCenterAndSpans() {
        let bbox = BoundingBox(
            southWest: LocationCoordinate2D(latitude: 10, longitude: 20),
            northEast: LocationCoordinate2D(latitude: 30, longitude: 60)
        )
        XCTAssertEqual(bbox.center.latitude, 20, accuracy: 1e-6)
        XCTAssertEqual(bbox.center.longitude, 40, accuracy: 1e-6)
        XCTAssertEqual(bbox.latitudeSpan, 20, accuracy: 1e-6)
        XCTAssertEqual(bbox.longitudeSpan, 40, accuracy: 1e-6)
        XCTAssertEqual(bbox.southEast, LocationCoordinate2D(latitude: 10, longitude: 60))
        XCTAssertEqual(bbox.northWest, LocationCoordinate2D(latitude: 30, longitude: 20))
    }

    func testContainsOtherBoundingBox() {
        let outer = BoundingBox(
            southWest: LocationCoordinate2D(latitude: 0, longitude: 0),
            northEast: LocationCoordinate2D(latitude: 10, longitude: 10)
        )
        let inner = BoundingBox(
            southWest: LocationCoordinate2D(latitude: 2, longitude: 2),
            northEast: LocationCoordinate2D(latitude: 8, longitude: 8)
        )
        let sharingEdge = BoundingBox(
            southWest: LocationCoordinate2D(latitude: 0, longitude: 0),
            northEast: LocationCoordinate2D(latitude: 5, longitude: 5)
        )
        let overlapping = BoundingBox(
            southWest: LocationCoordinate2D(latitude: 5, longitude: 5),
            northEast: LocationCoordinate2D(latitude: 15, longitude: 15)
        )
        
        XCTAssertTrue(outer.contains(inner, ignoreBoundary: true))
        XCTAssertTrue(outer.contains(inner, ignoreBoundary: false))
        
        XCTAssertFalse(outer.contains(sharingEdge, ignoreBoundary: true))
        XCTAssertTrue(outer.contains(sharingEdge, ignoreBoundary: false))
        
        XCTAssertFalse(outer.contains(overlapping, ignoreBoundary: false))
    }

    func testIntersectsOtherBoundingBox() {
        let box1 = BoundingBox(
            southWest: LocationCoordinate2D(latitude: 0, longitude: 0),
            northEast: LocationCoordinate2D(latitude: 10, longitude: 10)
        )
        let box2 = BoundingBox(
            southWest: LocationCoordinate2D(latitude: 5, longitude: 5),
            northEast: LocationCoordinate2D(latitude: 15, longitude: 15)
        )
        let touchingBox = BoundingBox(
            southWest: LocationCoordinate2D(latitude: 10, longitude: 10),
            northEast: LocationCoordinate2D(latitude: 20, longitude: 20)
        )
        let separateBox = BoundingBox(
            southWest: LocationCoordinate2D(latitude: 20, longitude: 20),
            northEast: LocationCoordinate2D(latitude: 30, longitude: 30)
        )
        
        XCTAssertTrue(box1.intersects(box2, ignoreBoundary: true))
        XCTAssertTrue(box1.intersects(box2, ignoreBoundary: false))
        
        XCTAssertFalse(box1.intersects(touchingBox, ignoreBoundary: true))
        XCTAssertTrue(box1.intersects(touchingBox, ignoreBoundary: false))
        
        XCTAssertFalse(box1.intersects(separateBox, ignoreBoundary: false))
    }

    func testUnion() {
        let box1 = BoundingBox(
            southWest: LocationCoordinate2D(latitude: 0, longitude: 10),
            northEast: LocationCoordinate2D(latitude: 10, longitude: 20)
        )
        let box2 = BoundingBox(
            southWest: LocationCoordinate2D(latitude: -5, longitude: 15),
            northEast: LocationCoordinate2D(latitude: 5, longitude: 30)
        )
        let united = box1.union(box2)
        XCTAssertEqual(united.southWest, LocationCoordinate2D(latitude: -5, longitude: 10))
        XCTAssertEqual(united.northEast, LocationCoordinate2D(latitude: 10, longitude: 30))
    }

    func testIntersection() {
        let box1 = BoundingBox(
            southWest: LocationCoordinate2D(latitude: 0, longitude: 0),
            northEast: LocationCoordinate2D(latitude: 10, longitude: 10)
        )
        let box2 = BoundingBox(
            southWest: LocationCoordinate2D(latitude: 5, longitude: 5),
            northEast: LocationCoordinate2D(latitude: 15, longitude: 15)
        )
        let separateBox = BoundingBox(
            southWest: LocationCoordinate2D(latitude: 20, longitude: 20),
            northEast: LocationCoordinate2D(latitude: 30, longitude: 30)
        )
        
        let intersection = box1.intersection(box2)
        XCTAssertNotNil(intersection)
        XCTAssertEqual(intersection!.southWest, LocationCoordinate2D(latitude: 5, longitude: 5))
        XCTAssertEqual(intersection!.northEast, LocationCoordinate2D(latitude: 10, longitude: 10))
        
        XCTAssertNil(box1.intersection(separateBox))
    }
}
