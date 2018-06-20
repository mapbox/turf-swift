import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf

class LineStringTests: XCTestCase {
    
    func testLineStringFeature() {
        let data = try! Fixture.geojsonData(from: "simple-line")!
        let geojson = try! GeoJSON.parse(LineStringFeature.self, from: data)
        
        XCTAssert(geojson.geometry.coordinates.count == 6)
        let first = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let last = CLLocationCoordinate2D(latitude: 10, longitude: 0)
        XCTAssert(geojson.geometry.coordinates.first == first)
        XCTAssert(geojson.geometry.coordinates.last == last)
        XCTAssert(geojson.identifier!.value as! String == "1")
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(LineStringFeature.self, from: encodedData)
        XCTAssertEqual(geojson.geometry, decoded.geometry)
        XCTAssertEqual(geojson.identifier!.value as! String, decoded.identifier!.value! as! String)
    }
}
