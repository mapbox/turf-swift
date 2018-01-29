import XCTest
import CoreLocation
@testable import Turf

class GeoJSONTests: XCTestCase {
    
    func testGeoJSONPoint() {
        let data = try! Fixture.geosjonData(from: "point")!
        let geojson = try! JSONDecoder().decode(GeoJSON.self, from: data)
        
        XCTAssert(geojson.geoJSONType == GeoJSON.GeoJSONType.Feature)
        XCTAssert(geojson.geometry.geometryType == .Point)
        let coordinate = CLLocationCoordinate2D(latitude: 26.194876675795218, longitude: 14.765625)
        XCTAssert(geojson.geometry.coordinates.first == coordinate)
    }
    
    func testGeoJSONLineString() {
        let data = try! Fixture.geosjonData(from: "simple-line")!
        let geojson = try! JSONDecoder().decode(GeoJSON.self, from: data)
        
        XCTAssert(geojson.geometry.geometryType == .LineString)
        XCTAssert(geojson.geometry.coordinates.count == 6)
        let first = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let last = CLLocationCoordinate2D(latitude: 10, longitude: 0)
        XCTAssert(geojson.geometry.coordinates.first == first)
        XCTAssert(geojson.geometry.coordinates.last == last)
    }
    
    func testGeoJSONPolygon() {
        // TODO:
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
