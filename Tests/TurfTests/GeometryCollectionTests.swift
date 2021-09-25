import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf

class GeometryCollectionTests: XCTestCase {
    
    func testGeometryCollectionFeatureDeserialization() {
        // Arrange
        let data = try! Fixture.geojsonData(from: "geometry-collection")!
        let multiPolygonCoordinate = LocationCoordinate2D(latitude: 8.5, longitude: 1)
        
        // Act
        let geoJSON = try! JSONDecoder().decode(GeoJSONObject.self, from: data)
        
        // Assert
        guard case let .feature(geometryCollectionFeature) = geoJSON else {
            XCTFail()
            return
        }
        
        guard case let .geometryCollection(geometries) = geometryCollectionFeature.geometry else {
            XCTFail()
            return
        }
        
        guard case let .multiPolygon(decodedMultiPolygonCoordinate) = geometries.geometries[2] else {
            XCTFail()
            return
        }
        XCTAssertEqual(decodedMultiPolygonCoordinate.coordinates[0][1][2], multiPolygonCoordinate)
    }
    
    func testGeometryCollectionFeatureSerialization() {
        // Arrange
        let multiPolygonCoordinate = LocationCoordinate2D(latitude: 8.5, longitude: 1)
        let data = try! Fixture.geojsonData(from: "geometry-collection")!
        let geoJSON = try! JSONDecoder().decode(GeoJSONObject.self, from: data)
        
        // Act
        let encodedData = try! JSONEncoder().encode(geoJSON)
        let encodedJSON = try! JSONDecoder().decode(GeoJSONObject.self, from: encodedData)
        
        // Assert
        guard case let .feature(geometryCollectionFeature) = encodedJSON else {
            XCTFail()
            return
        }
        
        guard case let .geometryCollection(geometries) = geometryCollectionFeature.geometry else {
            XCTFail()
            return
        }
        
        guard case let .multiPolygon(decodedMultiPolygonCoordinate) = geometries.geometries[2] else {
            XCTFail()
            return
        }
        XCTAssertEqual(decodedMultiPolygonCoordinate.coordinates[0][1][2], multiPolygonCoordinate)
    }
}
