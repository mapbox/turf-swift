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
        XCTAssert(geoJSON.decoded is _Feature)
        
        guard let geometryCollectionFeature = geoJSON.decoded as? _Feature else {
            XCTFail()
            return
        }
        
        XCTAssert(geometryCollectionFeature.geometry.type == .GeometryCollection)
        XCTAssert(geometryCollectionFeature.geometry.value is [_Geometry])
        
        let geometries = geometryCollectionFeature.geometry.value as! [_Geometry]
        
        XCTAssert(geometries[2].type == .MultiPolygon)
        XCTAssertEqual((geometries[2].value as! [[[CLLocationCoordinate2D]]])[0][1][2], multiPolygonCoordinate)
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
        XCTAssert(encodedJSON.decoded is _Feature)
        
        guard let geometryCollectionFeature = encodedJSON.decoded as? _Feature else {
            XCTFail()
            return
        }
        
        XCTAssert(geometryCollectionFeature.geometry.type == .GeometryCollection)
        XCTAssert(geometryCollectionFeature.geometry.value is [_Geometry])
        
        let geometries = geometryCollectionFeature.geometry.value as! [_Geometry]
        
        XCTAssert(geometries[2].type == .MultiPolygon)
        XCTAssertEqual((geometries[2].value as! [[[CLLocationCoordinate2D]]])[0][1][2], multiPolygonCoordinate)
    }
}
