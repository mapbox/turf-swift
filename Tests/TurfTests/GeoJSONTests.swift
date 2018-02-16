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
        let geojson = try! JSONDecoder().decode(GeoJSON<Polygon>.self, from: data)
        
        let firstCoordinate = CLLocationCoordinate2D(latitude: 37.00255267215955, longitude: -109.05029296875)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 40.6306300839918, longitude: -108.56689453125)
        
        XCTAssert(geojson.geometry?.outerRing.coordinates.first == firstCoordinate)
        XCTAssert(geojson.geometry?.innerRings.last?.coordinates.last == lastCoordinate)
        XCTAssert(geojson.geometry?.outerRing.coordinates.count == 5)
        XCTAssert(geojson.geometry?.innerRings.first?.coordinates.count == 5)
    }
    
    func testGeoJSONMultiPoint() {
        let data = try! Fixture.geojsonData(from: "multipoint")!
        let geojson = try! JSONDecoder().decode(GeoJSON<MultiPoint>.self, from: data)
        
        let firstCoordinate = CLLocationCoordinate2D(latitude: 26.194876675795218, longitude: 14.765625)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 24.926294766395593, longitude: 17.75390625)
        XCTAssert(geojson.geometry?.coordinates.first == firstCoordinate)
        XCTAssert(geojson.geometry?.coordinates.last == lastCoordinate)
    }
    
    func testGeoJSONMultiLineString() {
        let data = try! Fixture.geojsonData(from: "multiline")!
        let geojson = try! JSONDecoder().decode(GeoJSON<MultiLineString>.self, from: data)
        
        let firstCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 6, longitude: 6)
        XCTAssert(geojson.geometry?.coordinates.first?.first == firstCoordinate)
        XCTAssert(geojson.geometry?.coordinates.last?.last == lastCoordinate)
    }
    
    func testGeoJSONMultiPolygon() {
        let data = try! Fixture.geojsonData(from: "multipolygon")!
        let geojson = try! JSONDecoder().decode(GeoJSON<MultiPolygon>.self, from: data)
        
        let firstCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 11, longitude: 11)
        XCTAssert(geojson.geometry?.coordinates.first?.first?.first == firstCoordinate)
        XCTAssert(geojson.geometry?.coordinates.last?.last?.last == lastCoordinate)
    }
}
