import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf

class MultiLineStringTests: XCTestCase {

    func testMultiLineStringFeature() {
        let data = try! Fixture.geojsonData(from: "multiline")!
        let geojson = try! GeoJSON.parse(MultiLineStringFeature.self, from: data)
        
        let firstCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 6, longitude: 6)
        XCTAssert(geojson.geometry?.coordinates.first?.first == firstCoordinate)
        XCTAssert(geojson.geometry?.coordinates.last?.last == lastCoordinate)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(MultiLineStringFeature.self, from: encodedData)
        XCTAssert(decoded.geometry?.coordinates.first?.first == firstCoordinate)
        XCTAssert(decoded.geometry?.coordinates.last?.last == lastCoordinate)
    }
}
