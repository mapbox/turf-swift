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
        let multiLineStringCoordinates = geojson.geometry.value as? [[CLLocationCoordinate2D]]
        XCTAssert(multiLineStringCoordinates?.first?.first == firstCoordinate)
        XCTAssert(multiLineStringCoordinates?.last?.last == lastCoordinate)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(Feature.self, from: encodedData)
        let decodedMultiLineStringCoordinates = decoded.geometry.value as? [[CLLocationCoordinate2D]]
        
        XCTAssert(decodedMultiLineStringCoordinates?.first?.first == firstCoordinate)
        XCTAssert(decodedMultiLineStringCoordinates?.last?.last == lastCoordinate)
    }
}
