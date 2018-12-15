import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf

class LineStringTests: XCTestCase {
    
    func testLineStringFeature() {
        let data = try! Fixture.geojsonData(from: "simple-line")!
        let geojson = try! GeoJSON.parse(LineStringFeature.self, from: data)
        
        XCTAssert(geojson.geometry.coordinates.count == 6)
        let first = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let last = CLLocationCoordinate2D(latitude: 10, longitude: 0)
        XCTAssert(geojson.geometry.coordinates.first == first)
        XCTAssert(geojson.geometry.coordinates.last == last)
        XCTAssert(geojson.identifier!.value as! String == "1")
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(LineStringFeature.self, from: encodedData)
        XCTAssertEqual(geojson.geometry, decoded.geometry)
        XCTAssertEqual(geojson.identifier!.value as! String, decoded.identifier!.value! as! String)
    }
    
    func testClosestCoordinate() {
        let lineString = LineString([
            CLLocationCoordinate2D(latitude: 49.120689999999996, longitude: -122.65401),
            CLLocationCoordinate2D(latitude: 49.120619999999995, longitude: -122.65352),
            CLLocationCoordinate2D(latitude: 49.120189999999994, longitude: -122.65237),
        ])
        
        let short = CLLocationCoordinate2D(latitude: 49.120403526377203, longitude: -122.6529443631224)
        let long = CLLocationCoordinate2D(latitude: 49.120405, longitude: -122.652945)
        XCTAssertLessThan(short.distance(to: long), 1)
        
        let closestToShort = lineString.closestCoordinate(to: short)
        XCTAssertNotNil(closestToShort)
        XCTAssertEqual(closestToShort?.coordinate.latitude ?? 0, short.latitude, accuracy: 1e-5)
        XCTAssertEqual(closestToShort?.coordinate.longitude ?? 0, short.longitude, accuracy: 1e-5)
        XCTAssertEqual(closestToShort?.index, 1, "Coordinate closer to earlier vertex is indexed with earlier vertex")
        
        let closestToLong = lineString.closestCoordinate(to: long)
        XCTAssertNotNil(closestToLong)
        XCTAssertEqual(closestToLong?.coordinate.latitude ?? 0, long.latitude, accuracy: 1e-5)
        XCTAssertEqual(closestToLong?.coordinate.longitude ?? 0, long.longitude, accuracy: 1e-5)
        XCTAssertEqual(closestToLong?.index, 1, "Coordinate closer to later vertex is indexed with earlier vertex")
    }
    
    func testDistance() {
        // https://github.com/mapbox/turf-swift/issues/27
        let short = CLLocationCoordinate2D(latitude: 49.120403526377203, longitude: -122.6529443631224)
        let long = CLLocationCoordinate2D(latitude: 49.120405, longitude: -122.652945)
        XCTAssertLessThan(short.distance(to: long), 1)
        
        XCTAssertEqual(0, LineString([
            CLLocationCoordinate2D(latitude: 49.120689999999996, longitude: -122.65401),
            CLLocationCoordinate2D(latitude: 49.120619999999995, longitude: -122.65352),
        ]).distance(from: short, to: long), "Distance between two coordinates past the end of the line string should be 0")
        XCTAssertEqual(short.distance(to: long), LineString([
            CLLocationCoordinate2D(latitude: 49.120689999999996, longitude: -122.65401),
            CLLocationCoordinate2D(latitude: 49.120619999999995, longitude: -122.65352),
            CLLocationCoordinate2D(latitude: 49.120189999999994, longitude: -122.65237),
        ]).distance(from: short, to: long), accuracy: 0.1, "Distance between two coordinates between the same vertices should be roughly the same as the distance between those two coordinates")
    }
}
