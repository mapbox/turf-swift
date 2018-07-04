import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf

class MultiPointTests: XCTestCase {

    func testMultiPointFeature() {
        let data = try! Fixture.geojsonData(from: "multipoint")!
        let geojson = try! GeoJSON.parse(MultiPointFeature.self, from: data)
        
        let firstCoordinate = CLLocationCoordinate2D(latitude: 26.194876675795218, longitude: 14.765625)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 24.926294766395593, longitude: 17.75390625)
        XCTAssert(geojson.geometry.coordinates.first == firstCoordinate)
        XCTAssert(geojson.geometry.coordinates.last == lastCoordinate)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(MultiPointFeature.self, from: encodedData)
        XCTAssert(decoded.geometry.coordinates.first == firstCoordinate)
        XCTAssert(decoded.geometry.coordinates.last == lastCoordinate)
    }
}
