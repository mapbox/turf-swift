import XCTest
import CoreLocation
@testable import Turf

class GeoJSONTests: XCTestCase {
    
    func testGeoJSONPoint() {
        let data = try! Fixture.geojsonData(from: "point")!
        let geojson = try! JSONDecoder().decode(GeoJSON<Point>.self, from: data)
        let coordinate = CLLocationCoordinate2D(latitude: 26.194876675795218, longitude: 14.765625)
        XCTAssert(geojson.geometry?.coordinates == coordinate)
    }
    
    func testGeoJSONLineString() {
        let data = try! Fixture.geojsonData(from: "simple-line")!
        let geojson = try! JSONDecoder().decode(GeoJSON<LineString>.self, from: data)

        XCTAssert(geojson.geometry?.coordinates.count == 6)
        let first = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let last = CLLocationCoordinate2D(latitude: 10, longitude: 0)
        XCTAssert(geojson.geometry?.coordinates.first == first)
        XCTAssert(geojson.geometry?.coordinates.last == last)
    }
    
    func testGeoJSONPolygon() {
        let data = try! Fixture.geojsonData(from: "polygon")!
        let geojson = try! JSONDecoder().decode(GeoJSON<GeoJSONPolygon>.self, from: data)
        
        let firstCoordinate = CLLocationCoordinate2D(latitude: 37.00255267215955, longitude: -109.05029296875)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 40.6306300839918, longitude: -108.56689453125)
        XCTAssert(geojson.geometry?.coordinates.first?.first == firstCoordinate)
        XCTAssert(geojson.geometry?.coordinates.last?.last == lastCoordinate)
        XCTAssert(geojson.geometry?.coordinates[0].count == 5)
        XCTAssert(geojson.geometry?.coordinates[1].count == 5)
    }
    
    func testGeoJSONMultiPoint() {
        // TODO:
    }
    
    func testGeoJSONMultiLineString() {
        // TODO:
    }
    
    func testGeoJSONMultiPolygon() {
        // TODO:
    }
}
