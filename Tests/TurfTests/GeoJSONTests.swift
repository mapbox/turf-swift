import XCTest
import CoreLocation
@testable import Turf

#if os(OSX)
import struct Turf.Polygon // Conflicts with MapKit’s Polygon
#endif

class GeoJSONTests: XCTestCase {
    
    func testPointFeature() {
        let data = try! Fixture.geojsonData(from: "point")!
        let geojson = try! JSONDecoder().decode(PointFeature.self, from: data)
        let coordinate = CLLocationCoordinate2D(latitude: 26.194876675795218, longitude: 14.765625)
        XCTAssert(geojson.geometry?.coordinates == coordinate)
    }
    
    func testLineStringFeature() {
        let data = try! Fixture.geojsonData(from: "simple-line")!
        let geojson = try! JSONDecoder().decode(LineStringFeature.self, from: data)
        
        XCTAssert(geojson.geometry.coordinates.count == 6)
        let first = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let last = CLLocationCoordinate2D(latitude: 10, longitude: 0)
        XCTAssert(geojson.geometry.coordinates.first == first)
        XCTAssert(geojson.geometry.coordinates.last == last)
    }
    
    func testPolygonFeature() {
        let data = try! Fixture.geojsonData(from: "polygon")!
        let geojson = try! JSONDecoder().decode(PolygonFeature.self, from: data)
        
        let firstCoordinate = CLLocationCoordinate2D(latitude: 37.00255267215955, longitude: -109.05029296875)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 40.6306300839918, longitude: -108.56689453125)
        
        XCTAssert(geojson.geometry?.outerRing!.coordinates.first == firstCoordinate)
        XCTAssert(geojson.geometry?.innerRings!.last?.coordinates.last == lastCoordinate)
        XCTAssert(geojson.geometry?.outerRing!.coordinates.count == 5)
        XCTAssert(geojson.geometry?.innerRings!.first?.coordinates.count == 5)
    }
    
    func testMultiPoint() {
        let data = try! Fixture.geojsonData(from: "multipoint")!
        let geojson = try! JSONDecoder().decode(MultiPointFeature.self, from: data)
        
        let firstCoordinate = CLLocationCoordinate2D(latitude: 26.194876675795218, longitude: 14.765625)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 24.926294766395593, longitude: 17.75390625)
        XCTAssert(geojson.geometry?.coordinates.first == firstCoordinate)
        XCTAssert(geojson.geometry?.coordinates.last == lastCoordinate)
    }
    
    func testMultiLineStringFeature() {
        let data = try! Fixture.geojsonData(from: "multiline")!
        let geojson = try! JSONDecoder().decode(MultiLineStringFeature.self, from: data)
        
        let firstCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 6, longitude: 6)
        XCTAssert(geojson.geometry?.coordinates.first?.first == firstCoordinate)
        XCTAssert(geojson.geometry?.coordinates.last?.last == lastCoordinate)
    }
    
    func testMultiPolygonFeature() {
        let data = try! Fixture.geojsonData(from: "multipolygon")!
        let geojson = try! JSONDecoder().decode(MultiPolygonFeature.self, from: data)
        
        let firstCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 11, longitude: 11)
        XCTAssert(geojson.geometry?.coordinates.first?.first?.first == firstCoordinate)
        XCTAssert(geojson.geometry?.coordinates.last?.last?.last == lastCoordinate)
    }
    
    func testGeoJSONFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!
        let geojson = try! JSONDecoder().decode(FeatureCollection.self, from: data)
        
        XCTAssert(geojson.features[0] is LineStringFeature)
        XCTAssert(geojson.features[1] is PolygonFeature)
        XCTAssert(geojson.features[2] is PolygonFeature)
        XCTAssert(geojson.features[3] is PointFeature)
        
        let lineStringFeature = geojson.features[0] as! LineStringFeature
        XCTAssert(lineStringFeature.geometry.coordinates.count == 19)
        XCTAssert(lineStringFeature.properties!["id"]!.jsonValue as! Int == 1)
        XCTAssert(lineStringFeature.geometry.coordinates.first!.latitude == -26.17500493262446)
        XCTAssert(lineStringFeature.geometry.coordinates.first!.longitude == 27.977542877197266)
        
        let polygonFeature = geojson.features[1] as! PolygonFeature
        XCTAssert(polygonFeature.properties!["id"]!.jsonValue as! Int == 2)
        XCTAssert(polygonFeature.geometry.coordinates[0].count == 21)
        XCTAssert(polygonFeature.geometry.coordinates[0].first!.latitude == -26.199035448897074)
        XCTAssert(polygonFeature.geometry.coordinates[0].first!.longitude == 27.972049713134762)
        
        let pointFeature = geojson.features[3] as! PointFeature
        XCTAssert(pointFeature.properties!["id"]!.jsonValue as! Int == 4)
        XCTAssert(pointFeature.geometry.coordinates.latitude == -26.152510345365126)
        XCTAssert(pointFeature.geometry.coordinates.longitude == 27.95642852783203)
    }
}

