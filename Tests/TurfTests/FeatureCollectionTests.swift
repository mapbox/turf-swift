import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf

class FeatureCollectionTests: XCTestCase {

    func testFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!
        let geojson = try! JSONDecoder().decode(GeoJSONObject.self, from: data)
        guard case let .featureCollection(featureCollection) = geojson else { return XCTFail() }
        
        if case .lineString = featureCollection.features[0].geometry {} else { XCTFail() }
        if case .polygon = featureCollection.features[1].geometry {} else { XCTFail() }
        if case .polygon = featureCollection.features[2].geometry {} else { XCTFail() }
        if case .point = featureCollection.features[3].geometry {} else { XCTFail() }
        
        let lineStringFeature = featureCollection.features[0]
        guard case let .lineString(lineStringCoordinates) = lineStringFeature.geometry else {
            XCTFail()
            return
        }
        XCTAssert(lineStringCoordinates.coordinates.count == 19)
        XCTAssert(lineStringFeature.properties!["id"] as! Int == 1)
        XCTAssert(lineStringCoordinates.coordinates.first!.latitude == -26.17500493262446)
        XCTAssert(lineStringCoordinates.coordinates.first!.longitude == 27.977542877197266)
        
        let polygonFeature = featureCollection.features[1]
        guard case let .polygon(polygonCoordinates) = polygonFeature.geometry else {
            XCTFail()
            return
        }
        XCTAssert(polygonFeature.properties!["id"] as! Int == 2)
        XCTAssert(polygonCoordinates.coordinates[0].count == 21)
        XCTAssert(polygonCoordinates.coordinates[0].first!.latitude == -26.199035448897074)
        XCTAssert(polygonCoordinates.coordinates[0].first!.longitude == 27.972049713134762)
        
        let pointFeature = featureCollection.features[3]
        guard case let .point(pointCoordinates) = pointFeature.geometry else {
            XCTFail()
            return
        }
        XCTAssert(pointFeature.properties!["id"] as! Int == 4)
        XCTAssert(pointCoordinates.coordinates.latitude == -26.152510345365126)
        XCTAssert(pointCoordinates.coordinates.longitude == 27.95642852783203)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! JSONDecoder().decode(GeoJSONObject.self, from: encodedData)
        guard case let .featureCollection(decodedFeatureCollection) = decoded else { return XCTFail() }
        
        if case .lineString = decodedFeatureCollection.features[0].geometry {} else { XCTFail() }
        if case .polygon = decodedFeatureCollection.features[1].geometry {} else { XCTFail() }
        if case .polygon = decodedFeatureCollection.features[2].geometry {} else { XCTFail() }
        if case .point = decodedFeatureCollection.features[3].geometry {} else { XCTFail() }
        
        let decodedLineStringFeature = decodedFeatureCollection.features[0]
        guard case let .lineString(decodedLineStringCoordinates) = decodedLineStringFeature.geometry else {
            XCTFail()
            return
        }
        XCTAssert(decodedLineStringCoordinates.coordinates.count == 19)
        XCTAssert(decodedLineStringFeature.properties!["id"] as! Int == 1)
        XCTAssert(decodedLineStringCoordinates.coordinates.first!.latitude == -26.17500493262446)
        XCTAssert(decodedLineStringCoordinates.coordinates.first!.longitude == 27.977542877197266)
        
        let decodedPolygonFeature = decodedFeatureCollection.features[1]
        guard case let .polygon(decodedPolygonCoordinates) = decodedPolygonFeature.geometry else {
            XCTFail()
            return
        }
        XCTAssert(decodedPolygonFeature.properties!["id"] as! Int == 2)
        XCTAssert(decodedPolygonCoordinates.coordinates[0].count == 21)
        XCTAssert(decodedPolygonCoordinates.coordinates[0].first!.latitude == -26.199035448897074)
        XCTAssert(decodedPolygonCoordinates.coordinates[0].first!.longitude == 27.972049713134762)
        
        let decodedPointFeature = decodedFeatureCollection.features[3]
        guard case let .point(decodedPointCoordinates) = decodedPointFeature.geometry else {
            XCTFail()
            return
        }
        XCTAssert(decodedPointFeature.properties!["id"] as! Int == 4)
        XCTAssert(decodedPointCoordinates.coordinates.latitude == -26.152510345365126)
        XCTAssert(decodedPointCoordinates.coordinates.longitude == 27.95642852783203)
    }
    
    func testFeatureCollectionDecodeWithoutProperties() {
        let data = try! Fixture.geojsonData(from: "featurecollection-no-properties")!
        let geojson = try! JSONDecoder().decode(GeoJSONObject.self, from: data)
        guard case .featureCollection = geojson else { return XCTFail() }
    }
    
    func testUnkownFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!
        let geojson = try! JSONDecoder().decode(GeoJSONObject.self, from: data)
        guard case .featureCollection = geojson else { return XCTFail() }
    }
    
    func testPerformanceDecodeFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!
        
        measure {
            for _ in 0...100 {
                _ = try! JSONDecoder().decode(FeatureCollection.self, from: data)
            }
        }
    }
    
    func testPerformanceEncodeFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!
        let decoded = try! JSONDecoder().decode(FeatureCollection.self, from: data)
        
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
                let decoded = try! JSONDecoder().decode(FeatureCollection.self, from: data)
                _ = try! JSONEncoder().encode(decoded)
            }
        }
    }
    
    func testDecodedFeatureCollection() {
        let data = try! Fixture.geojsonData(from: "featurecollection")!
        let geojson = try! JSONDecoder().decode(GeoJSONObject.self, from: data)
        
        guard case let .featureCollection(featureCollection) = geojson else { return XCTFail() }
        XCTAssertEqual(featureCollection.features.count, 4)
        XCTAssertEqual(featureCollection.properties?["tolerance"] as? Double, 0.01)
    }
}
