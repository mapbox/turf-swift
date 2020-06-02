import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf

class MultiLineStringTests: XCTestCase {
    
    func testMultiLineStringFeature() {
        let data = try! Fixture.geojsonData(from: "multiline")!
        let firstCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 6, longitude: 6)
        
        let geojson = try! GeoJSON.parse(Feature.self, from: data)
        
        XCTAssert(geojson.geometry.type == .MultiLineString)
        guard case let .multiLineString(multiLineStringCoordinates) = geojson.geometry else {
            XCTFail()
            return
        }
        XCTAssert(multiLineStringCoordinates.coordinates.first?.first == firstCoordinate)
        XCTAssert(multiLineStringCoordinates.coordinates.last?.last == lastCoordinate)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(Feature.self, from: encodedData)
        guard case let .multiLineString(decodedMultiLineStringCoordinates) = decoded.geometry else {
            XCTFail()
            return
        }
        
        XCTAssert(decodedMultiLineStringCoordinates.coordinates.first?.first == firstCoordinate)
        XCTAssert(decodedMultiLineStringCoordinates.coordinates.last?.last == lastCoordinate)
    }
}
