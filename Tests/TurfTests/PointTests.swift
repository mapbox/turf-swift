import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf

class PointTests: XCTestCase {

    func testPointFeature() {
        let data = try! Fixture.geojsonData(from: "point")!
        let geojson = try! GeoJSON.parse(PointFeature.self, from: data)
        let coordinate = CLLocationCoordinate2D(latitude: 26.194876675795218, longitude: 14.765625)
        XCTAssert(geojson.geometry.coordinates == coordinate)
        XCTAssert((geojson.identifier!.value as! Number).value! as! Int == 1)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(PointFeature.self, from: encodedData)
        XCTAssertEqual(geojson.geometry, decoded.geometry)
        XCTAssertEqual(geojson.identifier!.value as! Number, decoded.identifier!.value! as! Number)
    }
    
    func testUnkownPointFeature() {
        let data = try! Fixture.geojsonData(from: "point")!
        let geojson = try! GeoJSON.parse(data)
        XCTAssert(geojson.decoded is PointFeature)
    }
    
    func testMidPointHorizEquator()
    {
        let point1 = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let point2 = CLLocationCoordinate2D(latitude: 0.0, longitude: 10.0)
        
        let mid = midpoint(point1: point1, point2: point2)
        XCTAssertEqual(point1.distance(to: mid), point2.distance(to: mid), accuracy: 1)
    }
    
    func testMidPointVertEquator()
    {
        let point1 = CLLocationCoordinate2D(latitude: 10.0, longitude: 0.0)
        let point2 = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        
        let mid = midpoint(point1: point1, point2: point2)
        XCTAssertEqual(point1.distance(to: mid), point2.distance(to: mid), accuracy: 1)
    }
}
