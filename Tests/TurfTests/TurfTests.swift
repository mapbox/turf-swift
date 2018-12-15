import XCTest
#if !os(Linux)
import CoreLocation
#endif
@testable import Turf

let metersPerMile: CLLocationDistance = 1_609.344

#if swift(>=3.2)
#else
func XCTAssertEqual<T: FloatingPoint>(_ lhs: @autoclosure () throws -> T, _ rhs: @autoclosure () throws -> T, accuracy: T) {
    XCTAssertEqualWithAccuracy(lhs, rhs, accuracy: accuracy)
}
#endif

class TurfTests: XCTestCase {
    
    func testWrap() {
        let a = (380 as CLLocationDirection).wrap(min: 0, max: 360)
        XCTAssertEqual(a, 20)
        
        let b = (-30 as CLLocationDirection).wrap(min: 0, max: 360)
        XCTAssertEqual(b, 330)
    }
    
    func testCLLocationCoordinate2() {
        let point1 = CLLocationCoordinate2D(latitude: 35, longitude: 35)
        let point2 = CLLocationCoordinate2D(latitude: -10, longitude: -10)
        let a = point1.direction(to: point2)
        XCTAssertEqual(a, -128, accuracy: 1)
        
        let b = point1.coordinate(at: 20, facing: 20)
        XCTAssertEqual(b.latitude, 35, accuracy: 0.1)
        XCTAssertEqual(b.longitude, 35, accuracy: 0.1)
    }
    
    func testIntersection() {
        let point1 = CLLocationCoordinate2D(latitude: 30, longitude: 30)
        let a = Turf.intersection((CLLocationCoordinate2D(latitude: 20, longitude: 20), CLLocationCoordinate2D(latitude: 40, longitude: 40)), (CLLocationCoordinate2D(latitude: 20, longitude: 40), CLLocationCoordinate2D(latitude: 40, longitude: 20)))
        XCTAssertEqual(a, point1)
    }
    
    func testCLLocationDegrees() {
        let degree: CLLocationDegrees = 100
        let a = degree.toRadians()
        XCTAssertEqual(a, 2, accuracy: 1)
        
        let radian: LocationRadians = 4
        let b = radian.toDegrees()
        XCTAssertEqual(b, 229, accuracy: 1)
    }
    
    func testPolygonArea() {
        let json = Fixture.JSONFromFileNamed(name: "polygon")
        let geometry = json["geometry"] as! [String: Any]
        let geoJSONCoordinates = geometry["coordinates"] as! [[[Double]]]
        let coordinates = geoJSONCoordinates.map {
           $0.map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) }
        }
        
        let polygon = Polygon(coordinates)
        
        XCTAssertEqual(polygon.area, 78588446934.43, accuracy: 0.1)
    }
}
