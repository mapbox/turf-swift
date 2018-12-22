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
        let coord1 = CLLocationCoordinate2D(latitude: 35, longitude: 35)
        let coord2 = CLLocationCoordinate2D(latitude: -10, longitude: -10)
        let a = coord1.direction(to: coord2)
        XCTAssertEqual(a, -128, accuracy: 1)
        
        let b = coord1.coordinate(at: 20, facing: 20)
        XCTAssertEqual(b.latitude, 35, accuracy: 0.1)
        XCTAssertEqual(b.longitude, 35, accuracy: 0.1)
    }
    
    func testIntersection() {
        let coord1 = CLLocationCoordinate2D(latitude: 30, longitude: 30)
        let a = Turf.intersection((CLLocationCoordinate2D(latitude: 20, longitude: 20), CLLocationCoordinate2D(latitude: 40, longitude: 40)), (CLLocationCoordinate2D(latitude: 20, longitude: 40), CLLocationCoordinate2D(latitude: 40, longitude: 20)))
        XCTAssertEqual(a, coord1)
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
    
    /// Note: All of the midpoint tests use an accuracy of 1 (equal to 1 meter)
    
    func testMidHorizEquator()
    {
        let coord1 = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let coord2 = CLLocationCoordinate2D(latitude: 0.0, longitude: 10.0)
        
        let midCoord = mid(coord1, coord2)
        XCTAssertEqual(coord1.distance(to: midCoord), coord2.distance(to: midCoord), accuracy: 1)
    }
    
    func testMidVertFromEquator()
    {
        let coord1 = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let coord2 = CLLocationCoordinate2D(latitude: 10.0, longitude: 0.0)
        
        let midCoord = mid(coord1, coord2)
        XCTAssertEqual(coord1.distance(to: midCoord), coord2.distance(to: midCoord), accuracy: 1)
    }
    
    func testMidVertToEquator()
    {
        let coord1 = CLLocationCoordinate2D(latitude: 10.0, longitude: 0.0)
        let coord2 = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        
        let midCoord = mid(coord1, coord2)
        XCTAssertEqual(coord1.distance(to: midCoord), coord2.distance(to: midCoord), accuracy: 1)
    }
    
    func testMidDiagonalBackOverEquator()
    {
        let coord1 = CLLocationCoordinate2D(latitude: 10.0, longitude: -1.0)
        let coord2 = CLLocationCoordinate2D(latitude: -1.0, longitude: 1.0)
        
        let midCoord = mid(coord1, coord2)
        XCTAssertEqual(coord1.distance(to: midCoord), coord2.distance(to: midCoord), accuracy: 1)
    }
    
    func testMidDiagonalForwardOverEquator()
    {
        let coord1 = CLLocationCoordinate2D(latitude: -1.0, longitude: -5.0)
        let coord2 = CLLocationCoordinate2D(latitude: 10.0, longitude: 5.0)
        
        let midCoord = mid(coord1, coord2)
        XCTAssertEqual(coord1.distance(to: midCoord), coord2.distance(to: midCoord), accuracy: 1)
    }
    
    func testMidLongDistance()
    {
        let coord1 = CLLocationCoordinate2D(latitude: 21.94304553343818, longitude: 22.5)
        let coord2 = CLLocationCoordinate2D(latitude: 46.800059446787316, longitude: 92.10937499999999)
        
        let midCoord = mid(coord1, coord2)
        XCTAssertEqual(coord1.distance(to: midCoord), coord2.distance(to: midCoord), accuracy: 1)
    }
    
}
