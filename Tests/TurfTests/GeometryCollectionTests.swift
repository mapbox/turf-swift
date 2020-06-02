import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf

class GeometryCollectionTests: XCTestCase {
    
    func testGeometryCollectionFeatureDeserialization() {
        // Arrange
        let data = try! Fixture.geojsonData(from: "geometry-collection")!
        let multiPolygonCoordinate = CLLocationCoordinate2D(latitude: 8.5, longitude: 1)
        
        // Act
        let geoJSON = try! GeoJSON.parse(data)
        
        // Assert
        XCTAssert(geoJSON.decoded is Feature)
        
        guard let geometryCollectionFeature = geoJSON.decoded as? Feature else {
            XCTFail()
            return
        }
        
        XCTAssert(geometryCollectionFeature.geometry.type == .GeometryCollection)
        XCTAssert(geometryCollectionFeature.geometry.value is GeometryCollection)
        
        guard case let .geometryCollection(geometries) = geometryCollectionFeature.geometry else {
            XCTFail()
            return
        }
        
        XCTAssert(geometries.geometries[2].type == .MultiPolygon)
        guard case let .multiPolygon(decodedMultiPolygonCoordinate) = geometries.geometries[2] else {
            XCTFail()
            return
        }
        XCTAssertEqual(decodedMultiPolygonCoordinate.coordinates[0][1][2], multiPolygonCoordinate)
    }
    
    func testGeometryCollectionFeatureSerialization() {
        // Arrange
        let multiPolygonCoordinate = CLLocationCoordinate2D(latitude: 8.5, longitude: 1)
        let data = try! Fixture.geojsonData(from: "geometry-collection")!
        let geoJSON = try! GeoJSON.parse(data)
        
        // Act
        let encodedData = try! JSONEncoder().encode(geoJSON)
        let encodedJSON = try! GeoJSON.parse(encodedData)
        
        // Assert
        XCTAssert(encodedJSON.decoded is Feature)
        
        guard let geometryCollectionFeature = encodedJSON.decoded as? Feature else {
            XCTFail()
            return
        }
        
        XCTAssert(geometryCollectionFeature.geometry.type == .GeometryCollection)
        XCTAssert(geometryCollectionFeature.geometry.value is GeometryCollection)
        
        guard case let .geometryCollection(geometries) = geometryCollectionFeature.geometry else {
            XCTFail()
            return
        }
        
        XCTAssert(geometries.geometries[2].type == .MultiPolygon)
        guard case let .multiPolygon(decodedMultiPolygonCoordinate) = geometries.geometries[2] else {
            XCTFail()
            return
        }
        XCTAssertEqual(decodedMultiPolygonCoordinate.coordinates[0][1][2], multiPolygonCoordinate)
    }
}
