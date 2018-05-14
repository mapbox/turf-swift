import XCTest
#if !os(Linux)
import CoreLocation
#endif
@testable import Turf

#if os(OSX)
import struct Turf.Polygon // Conflicts with MapKit’s Polygon
#endif

class GeoJSONTests: XCTestCase {
    
    func testPointFeature() {
        let data = try! Fixture.geojsonData(from: "point")!
        let geojson = try! GeoJSON.parse(PointFeature.self, from: data)
        let coordinate = CLLocationCoordinate2D(latitude: 26.194876675795218, longitude: 14.765625)
        XCTAssert(geojson.geometry?.coordinates == coordinate)
        XCTAssert((geojson.identifier!.value as! Number).value! as! Int == 1)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(PointFeature.self, from: encodedData)
        XCTAssertEqual(geojson.geometry, decoded.geometry)
        XCTAssertEqual(geojson.identifier!.value as! Number, decoded.identifier!.value! as! Number)
    }
    
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
    
    func testPolygonFeature() {
        let data = try! Fixture.geojsonData(from: "polygon")!
        let geojson = try! GeoJSON.parse(PolygonFeature.self, from: data)
        
        let firstCoordinate = CLLocationCoordinate2D(latitude: 37.00255267215955, longitude: -109.05029296875)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 40.6306300839918, longitude: -108.56689453125)
        
        XCTAssert((geojson.identifier!.value as! Number).value! as! Double == 1.01)
        XCTAssert(geojson.geometry?.outerRing.coordinates.first == firstCoordinate)
        XCTAssert(geojson.geometry?.innerRings!.last?.coordinates.last == lastCoordinate)
        XCTAssert(geojson.geometry?.outerRing.coordinates.count == 5)
        XCTAssert(geojson.geometry?.innerRings!.first?.coordinates.count == 5)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(PolygonFeature.self, from: encodedData)
        XCTAssertEqual(geojson.geometry, decoded.geometry)
        XCTAssertEqual(geojson.identifier!.value as! Number, decoded.identifier!.value! as! Number)
        XCTAssert(decoded.geometry?.outerRing.coordinates.first == firstCoordinate)
        XCTAssert(decoded.geometry?.innerRings!.last?.coordinates.last == lastCoordinate)
        XCTAssert(decoded.geometry?.outerRing.coordinates.count == 5)
        XCTAssert(decoded.geometry?.innerRings!.first?.coordinates.count == 5)
    }
    
    func testMultiPointFeature() {
        let data = try! Fixture.geojsonData(from: "multipoint")!
        let geojson = try! GeoJSON.parse(MultiPointFeature.self, from: data)
        
        let firstCoordinate = CLLocationCoordinate2D(latitude: 26.194876675795218, longitude: 14.765625)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 24.926294766395593, longitude: 17.75390625)
        XCTAssert(geojson.geometry?.coordinates.first == firstCoordinate)
        XCTAssert(geojson.geometry?.coordinates.last == lastCoordinate)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(MultiPointFeature.self, from: encodedData)
        XCTAssert(decoded.geometry?.coordinates.first == firstCoordinate)
        XCTAssert(decoded.geometry?.coordinates.last == lastCoordinate)
    }
    
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
    
    func testFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!
        let geojson = try! GeoJSON.parse(FeatureCollection.self, from: data)
        
        XCTAssert(geojson.features[0].value is LineStringFeature)
        XCTAssert(geojson.features[1].value is PolygonFeature)
        XCTAssert(geojson.features[2].value is PolygonFeature)
        XCTAssert(geojson.features[3].value is PointFeature)
        
        let lineStringFeature = geojson.features[0].value as! LineStringFeature
        XCTAssert(lineStringFeature.geometry.coordinates.count == 19)
        XCTAssert(lineStringFeature.properties!["id"]!.jsonValue as! Int == 1)
        XCTAssert(lineStringFeature.geometry.coordinates.first!.latitude == -26.17500493262446)
        XCTAssert(lineStringFeature.geometry.coordinates.first!.longitude == 27.977542877197266)
        
        let polygonFeature = geojson.features[1].value as! PolygonFeature
        XCTAssert(polygonFeature.properties!["id"]!.jsonValue as! Int == 2)
        XCTAssert(polygonFeature.geometry.coordinates[0].count == 21)
        XCTAssert(polygonFeature.geometry.coordinates[0].first!.latitude == -26.199035448897074)
        XCTAssert(polygonFeature.geometry.coordinates[0].first!.longitude == 27.972049713134762)
        
        let pointFeature = geojson.features[3].value as! PointFeature
        XCTAssert(pointFeature.properties!["id"]!.jsonValue as! Int == 4)
        XCTAssert(pointFeature.geometry.coordinates.latitude == -26.152510345365126)
        XCTAssert(pointFeature.geometry.coordinates.longitude == 27.95642852783203)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(FeatureCollection.self, from: encodedData)
        
        XCTAssert(decoded.features[0].value is LineStringFeature)
        XCTAssert(decoded.features[1].value is PolygonFeature)
        XCTAssert(decoded.features[2].value is PolygonFeature)
        XCTAssert(decoded.features[3].value is PointFeature)
        
        let decodedLineStringFeature = decoded.features[0].value as! LineStringFeature
        XCTAssert(decodedLineStringFeature.geometry.coordinates.count == 19)
        XCTAssert(decodedLineStringFeature.properties!["id"]!.jsonValue as! Int == 1)
        XCTAssert(decodedLineStringFeature.geometry.coordinates.first!.latitude == -26.17500493262446)
        XCTAssert(decodedLineStringFeature.geometry.coordinates.first!.longitude == 27.977542877197266)
        
        let decodedPolygonFeature = decoded.features[1].value as! PolygonFeature
        XCTAssert(decodedPolygonFeature.properties!["id"]!.jsonValue as! Int == 2)
        XCTAssert(decodedPolygonFeature.geometry.coordinates[0].count == 21)
        XCTAssert(decodedPolygonFeature.geometry.coordinates[0].first!.latitude == -26.199035448897074)
        XCTAssert(decodedPolygonFeature.geometry.coordinates[0].first!.longitude == 27.972049713134762)
        
        let decodedPointFeature = decoded.features[3].value as! PointFeature
        XCTAssert(decodedPointFeature.properties!["id"]!.jsonValue as! Int == 4)
        XCTAssert(decodedPointFeature.geometry.coordinates.latitude == -26.152510345365126)
        XCTAssert(decodedPointFeature.geometry.coordinates.longitude == 27.95642852783203)
    }
    
    func testUnkownPointFeature() {
        let data = try! Fixture.geojsonData(from: "point")!
        let geojson = try! GeoJSON.parse(data)
        XCTAssert(geojson.decoded is PointFeature)
    }
    
    func testUnkownFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!
        let geojson = try! GeoJSON.parse(data)
        XCTAssert(geojson.decoded is FeatureCollection)
    }
    
    func testPerformanceDecodeFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!
        
        measure {
            for _ in 0...1000 {
                _ = try! GeoJSON.parse(FeatureCollection.self, from: data)
            }
        }
    }
    
    func testPerformanceEncodeFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!
        let decoded = try! GeoJSON.parse(FeatureCollection.self, from: data)
        
        measure {
            for _ in 0...1000 {
                _ = try! JSONEncoder().encode(decoded)
            }
        }
    }
    
    func testPerformanceDecodeEncodeFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!
        
        measure {
            for _ in 0...1000 {
                let decoded = try! GeoJSON.parse(FeatureCollection.self, from: data)
                _ = try! JSONEncoder().encode(decoded)
            }
        }
    }
}

