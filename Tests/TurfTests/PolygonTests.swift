import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf

class PolygonTests: XCTestCase {

    func testPolygonFeature() {
        let data = try! Fixture.geojsonData(from: "polygon")!
        let geojson = try! GeoJSON.parse(PolygonFeature.self, from: data)
        
        let firstCoordinate = CLLocationCoordinate2D(latitude: 37.00255267215955, longitude: -109.05029296875)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 40.6306300839918, longitude: -108.56689453125)
        
        XCTAssert((geojson.identifier!.value as! Number).value! as! Double == 1.01)
        XCTAssert(geojson.geometry.outerRing.coordinates.first == firstCoordinate)
        XCTAssert(geojson.geometry.innerRings!.last?.coordinates.last == lastCoordinate)
        XCTAssert(geojson.geometry.outerRing.coordinates.count == 5)
        XCTAssert(geojson.geometry.innerRings!.first?.coordinates.count == 5)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(PolygonFeature.self, from: encodedData)
        XCTAssertEqual(geojson.geometry, decoded.geometry)
        XCTAssertEqual(geojson.identifier!.value as! Number, decoded.identifier!.value! as! Number)
        XCTAssert(decoded.geometry.outerRing.coordinates.first == firstCoordinate)
        XCTAssert(decoded.geometry.innerRings!.last?.coordinates.last == lastCoordinate)
        XCTAssert(decoded.geometry.outerRing.coordinates.count == 5)
        XCTAssert(decoded.geometry.innerRings!.first?.coordinates.count == 5)
    }
}
