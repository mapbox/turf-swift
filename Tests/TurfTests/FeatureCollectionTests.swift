import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf

class FeatureCollectionTests: XCTestCase {

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
    
    func testFeatureCollectionDecodeWithoutProperties() {
        let data = try! Fixture.geojsonData(from: "featurecollection-no-properties")!
        let geojson = try! GeoJSON.parse(data)
        XCTAssert(geojson.decoded is FeatureCollection)
    }
    
    func testUnkownFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!
        let geojson = try! GeoJSON.parse(data)
        XCTAssert(geojson.decoded is FeatureCollection)
    }
    
    func testPerformanceDecodeFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!
        
        measure {
            for _ in 0...100 {
                _ = try! GeoJSON.parse(FeatureCollection.self, from: data)
            }
        }
    }
    
    func testPerformanceEncodeFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!
        let decoded = try! GeoJSON.parse(FeatureCollection.self, from: data)
        
        measure {
            for _ in 0...100 {
                _ = try! JSONEncoder().encode(decoded)
            }
        }
    }
    
    func testPerformanceDecodeEncodeFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!
        
        measure {
            for _ in 0...100 {
                let decoded = try! GeoJSON.parse(FeatureCollection.self, from: data)
                _ = try! JSONEncoder().encode(decoded)
            }
        }
    }
}
