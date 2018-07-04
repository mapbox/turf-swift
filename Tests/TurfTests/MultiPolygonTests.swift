import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf
#if os(OSX)
import struct Turf.Polygon // Conflicts with MapKit’s Polygon
#endif

class MultiPolygonTests: XCTestCase {

    func testMultiPolygonFeature() {
        let data = try! Fixture.geojsonData(from: "multipolygon")!
        let geojson = try! GeoJSON.parse(MultiPolygonFeature.self, from: data)
        
        let firstCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 11, longitude: 11)
        XCTAssert(geojson.geometry.coordinates.first?.first?.first == firstCoordinate)
        XCTAssert(geojson.geometry.coordinates.last?.last?.last == lastCoordinate)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(MultiPolygonFeature.self, from: encodedData)
        XCTAssert(decoded.geometry.coordinates.first?.first?.first == firstCoordinate)
        XCTAssert(decoded.geometry.coordinates.last?.last?.last == lastCoordinate)
    }
    
    func testBuildMultiPolygonFeature() {
        let coordinates =
        [
            [
                [
                    CLLocationCoordinate2D(latitude: 0, longitude: 0),
                    CLLocationCoordinate2D(latitude: 0, longitude: 5),
                    CLLocationCoordinate2D(latitude: 0, longitude: 5),
                    CLLocationCoordinate2D(latitude: 0, longitude: 10),
                    CLLocationCoordinate2D(latitude: 10, longitude: 10),
                    CLLocationCoordinate2D(latitude: 10, longitude: 0),
                    CLLocationCoordinate2D(latitude: 5, longitude: 0),
                    CLLocationCoordinate2D(latitude: 0, longitude: 0),
                ],[
                    CLLocationCoordinate2D(latitude: 5, longitude: 1),
                    CLLocationCoordinate2D(latitude: 7, longitude: 1),
                    CLLocationCoordinate2D(latitude: 8.5, longitude: 1),
                    CLLocationCoordinate2D(latitude: 8.5, longitude: 4.5),
                    CLLocationCoordinate2D(latitude: 7, longitude: 4.5),
                    CLLocationCoordinate2D(latitude: 5, longitude: 4.5),
                    CLLocationCoordinate2D(latitude: 5, longitude: 1)
                ]
            ],[
                [
                    CLLocationCoordinate2D(latitude: 11, longitude: 11),
                    CLLocationCoordinate2D(latitude: 11.5, longitude: 11.5),
                    CLLocationCoordinate2D(latitude: 12, longitude: 12),
                    CLLocationCoordinate2D(latitude: 11, longitude: 12),
                    CLLocationCoordinate2D(latitude: 11, longitude: 11.5),
                    CLLocationCoordinate2D(latitude: 11, longitude: 11),
                    CLLocationCoordinate2D(latitude: 11, longitude: 11)
                ]
            ]
        ]
        
        let multiPolygon = MultiPolygon(coordinates)
        var multiPolygonFeature = MultiPolygonFeature(multiPolygon)
        multiPolygonFeature.identifier = FeatureIdentifier.string("uniqueIdentifier")
        multiPolygonFeature.properties = ["some": AnyJSONType("var")]

        let encodedData = try! JSONEncoder().encode(multiPolygonFeature)
        let decodedCustomMultiPolygon = try! GeoJSON.parse(MultiPolygonFeature.self, from: encodedData)
        
        let data = try! Fixture.geojsonData(from: "multipolygon")!
        let bundledMultiPolygon = try! GeoJSON.parse(MultiPolygonFeature.self, from: data)
        
        XCTAssertEqual(decodedCustomMultiPolygon.geometry.coordinates, bundledMultiPolygon.geometry.coordinates)
    }
}
