import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf

class PointTests: XCTestCase {

    func testPointFeature() {
        let data = try! Fixture.geojsonData(from: "point")!
        let geojson = try! GeoJSON.parse(_Feature.self, from: data)
        let coordinate = CLLocationCoordinate2D(latitude: 26.194876675795218, longitude: 14.765625)
        XCTAssertEqual(geojson.geometry.value as! CLLocationCoordinate2D, coordinate)
//        XCTAssert(geojson.geometry.coordinates == coordinate)
        XCTAssert((geojson.identifier!.value as! Number).value! as! Int == 1)

        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(_Feature.self, from: encodedData)
//        XCTAssertEqual(geojson.geometry, decoded.geometry)
        XCTAssertEqual(geojson.geometry.value as! CLLocationCoordinate2D, decoded.geometry.value as! CLLocationCoordinate2D)
        XCTAssertEqual(geojson.identifier!.value as! Number, decoded.identifier!.value! as! Number)
    }
    
    func testUnkownPointFeature() {
        let data = try! Fixture.geojsonData(from: "point")!
        let geojson = try! GeoJSON.parse(data)
        XCTAssert(geojson.decoded is _Feature)
    }
}
