import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf
#if os(OSX)
import struct Turf.Polygon // Conflicts with MapKit’s Polygon
#endif

class MultiPolygonTests: XCTestCase {

    func testMultiPolygonFeature() {
        let data = try! Fixture.geojsonData(from: "multipolygon")!
        let geojson = try! GeoJSON.parse(MultiPolygonFeature.self, from: data)
        
        let firstCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 11, longitude: 11)
        XCTAssert(geojson.geometry?.coordinates.first?.first?.first == firstCoordinate)
        XCTAssert(geojson.geometry?.coordinates.last?.last?.last == lastCoordinate)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(MultiPolygonFeature.self, from: encodedData)
        XCTAssert(decoded.geometry?.coordinates.first?.first?.first == firstCoordinate)
        XCTAssert(decoded.geometry?.coordinates.last?.last?.last == lastCoordinate)
    }
}
