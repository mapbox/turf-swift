import XCTest
#if !os(Linux)
import CoreLocation
#endif

@testable import Turf

class BoundingBoxTests: XCTestCase {
    
    func testAllPositive() {
        let coordinates = [
            CLLocationCoordinate2D(latitude: 1, longitude: 2),
            CLLocationCoordinate2D(latitude: 2, longitude: 1)
        ]
        let bbox = BoundingBox(from: coordinates)
        XCTAssertEqual(bbox!.northWest, CLLocationCoordinate2D(latitude: 2, longitude: 1))
        XCTAssertEqual(bbox!.southEast, CLLocationCoordinate2D(latitude: 1, longitude: 2))
    }
    
    func testAllNegative() {
        let coordinates = [
            CLLocationCoordinate2D(latitude: -1, longitude: -2),
            CLLocationCoordinate2D(latitude: -2, longitude: -1)
        ]
        let bbox = BoundingBox(from: coordinates)
        XCTAssertEqual(bbox!.northWest, CLLocationCoordinate2D(latitude: -1, longitude: -2))
        XCTAssertEqual(bbox!.southEast, CLLocationCoordinate2D(latitude: -2, longitude: -1))
    }
    
    func testPositiveLatNegativeLon() {
        let coordinates = [
            CLLocationCoordinate2D(latitude: 1, longitude: -2),
            CLLocationCoordinate2D(latitude: 2, longitude: -1)
        ]
        let bbox = BoundingBox(from: coordinates)
        XCTAssertEqual(bbox!.northWest, CLLocationCoordinate2D(latitude: 2, longitude: -2))
        XCTAssertEqual(bbox!.southEast, CLLocationCoordinate2D(latitude: 1, longitude: -1))
    }
    
    func testNegativeLatPositiveLon() {
        let coordinates = [
            CLLocationCoordinate2D(latitude: -1, longitude: 2),
            CLLocationCoordinate2D(latitude: -2, longitude: 1)
        ]
        let bbox = BoundingBox(from: coordinates)
        XCTAssertEqual(bbox!.northWest, CLLocationCoordinate2D(latitude: -1, longitude: 1))
        XCTAssertEqual(bbox!.southEast, CLLocationCoordinate2D(latitude: -2, longitude: 2))
    }
}
