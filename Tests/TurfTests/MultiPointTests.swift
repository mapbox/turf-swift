import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf

class MultiPointTests: XCTestCase {
    
    func testMultiPointFeature() {
        let data = try! Fixture.geojsonData(from: "multipoint")!
        let firstCoordinate = CLLocationCoordinate2D(latitude: 26.194876675795218, longitude: 14.765625)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 24.926294766395593, longitude: 17.75390625)
        
        let geojson = try! GeoJSON.parse(Feature.self, from: data)
                
        XCTAssert(geojson.geometry.type == .MultiPoint)
        let multipointCoordinates = geojson.geometry.multiPoint
        XCTAssert(multipointCoordinates?.first == firstCoordinate)
        XCTAssert(multipointCoordinates?.last == lastCoordinate)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(Feature.self, from: encodedData)
        let decodedMultipointCoordinates = decoded.geometry.multiPoint
        XCTAssert(decodedMultipointCoordinates?.first == firstCoordinate)
        XCTAssert(decodedMultipointCoordinates?.last == lastCoordinate)
    }
}
