import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf

class FeatureCollectionTests: XCTestCase {

    func testFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!
        let geojson = try! GeoJSON.parse(FeatureCollection.self, from: data)
        
        XCTAssert(geojson.features[0].geometry.type == .LineString)
        XCTAssert(geojson.features[1].geometry.type == .Polygon)
        XCTAssert(geojson.features[2].geometry.type == .Polygon)
        XCTAssert(geojson.features[3].geometry.type == .Point)
        
        let lineStringFeature = geojson.features[0]
        let lineStringCoordinates = lineStringFeature.geometry.lineString
        XCTAssert(lineStringCoordinates?.count == 19)
        XCTAssert(lineStringFeature.properties!["id"]!.jsonValue as! Int == 1)
        XCTAssert(lineStringCoordinates?.first!.latitude == -26.17500493262446)
        XCTAssert(lineStringCoordinates?.first!.longitude == 27.977542877197266)
        
        let polygonFeature = geojson.features[1]
        let polygonCoordinates = polygonFeature.geometry.polygon
        XCTAssert(polygonFeature.properties!["id"]!.jsonValue as! Int == 2)
        XCTAssert(polygonCoordinates?[0].count == 21)
        XCTAssert(polygonCoordinates?[0].first!.latitude == -26.199035448897074)
        XCTAssert(polygonCoordinates?[0].first!.longitude == 27.972049713134762)
        
        let pointFeature = geojson.features[3]
        let pointCoordinates = pointFeature.geometry.value as? CLLocationCoordinate2D
        XCTAssert(pointFeature.properties!["id"]!.jsonValue as! Int == 4)
        XCTAssert(pointCoordinates?.latitude == -26.152510345365126)
        XCTAssert(pointCoordinates?.longitude == 27.95642852783203)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(FeatureCollection.self, from: encodedData)
        
        XCTAssert(decoded.features[0].geometry.type == .LineString)
        XCTAssert(decoded.features[1].geometry.type == .Polygon)
        XCTAssert(decoded.features[2].geometry.type == .Polygon)
        XCTAssert(decoded.features[3].geometry.type == .Point)
        
        let decodedLineStringFeature = decoded.features[0]
        let decodedLineStringCoordinates = decodedLineStringFeature.geometry.lineString
        XCTAssert(decodedLineStringCoordinates?.count == 19)
        XCTAssert(decodedLineStringFeature.properties!["id"]!.jsonValue as! Int == 1)
        XCTAssert(decodedLineStringCoordinates?.first!.latitude == -26.17500493262446)
        XCTAssert(decodedLineStringCoordinates?.first!.longitude == 27.977542877197266)
        
        let decodedPolygonFeature = decoded.features[1]
        let decodedPolygonCoordinates = decodedPolygonFeature.geometry.polygon
        XCTAssert(decodedPolygonFeature.properties!["id"]!.jsonValue as! Int == 2)
        XCTAssert(decodedPolygonCoordinates?[0].count == 21)
        XCTAssert(decodedPolygonCoordinates?[0].first!.latitude == -26.199035448897074)
        XCTAssert(decodedPolygonCoordinates?[0].first!.longitude == 27.972049713134762)
        
        let decodedPointFeature = decoded.features[3]
        let decodedPointCoordinates = decodedPointFeature.geometry.value as? CLLocationCoordinate2D
        XCTAssert(decodedPointFeature.properties!["id"]!.jsonValue as! Int == 4)
        XCTAssert(decodedPointCoordinates?.latitude == -26.152510345365126)
        XCTAssert(decodedPointCoordinates?.longitude == 27.95642852783203)
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
