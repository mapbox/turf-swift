import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf

class PointTests: XCTestCase {

    func testPointFeature() {
        let data = try! Fixture.geojsonData(from: "point")!
        let geojson = try! GeoJSON.parse(Feature.self, from: data)
        let coordinate = LocationCoordinate2D(latitude: 26.194876675795218, longitude: 14.765625)

        guard case let .point(point) = geojson.geometry else {
            XCTFail()
            return
        }
        XCTAssertEqual(point.coordinates, coordinate)
        if case let .number(.int(int)) = geojson.identifier {
            XCTAssertEqual(int, 1)
        } else {
            XCTFail()
        }

        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(Feature.self, from: encodedData)
        
        if case let .point(point) = geojson.geometry,
           case let .point(decodedPoint) = decoded.geometry {
            XCTAssertEqual(point, decodedPoint)
        } else {
            XCTFail()
        }
        
        if case let .number(number) = geojson.identifier,
           case let .number(decodedNumber) = decoded.identifier {
            XCTAssertEqual(number, decodedNumber)
        } else {
            XCTFail()
        }
    }
    
    func testUnkownPointFeature() {
        let data = try! Fixture.geojsonData(from: "point")!
        let geojson = try! GeoJSON.parse(data)
        
        XCTAssert(geojson.decoded is Feature)
        guard case .point = geojson.decodedFeature?.geometry else { return XCTFail() }
    }
}
