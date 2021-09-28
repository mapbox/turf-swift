import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf

class PointTests: XCTestCase {

    func testPointFeature() {
        let data = try! Fixture.geojsonData(from: "point")!
        let geojson = try! JSONDecoder().decode(GeoJSONObject.self, from: data)
        let coordinate = LocationCoordinate2D(latitude: 26.194876675795218, longitude: 14.765625)

        guard case let .feature(feature) = geojson,
              case let .point(point) = feature.geometry else {
            XCTFail()
            return
        }
        XCTAssertEqual(point.coordinates, coordinate)
        if case let .number(number) = feature.identifier {
            XCTAssertEqual(number, 1)
        } else {
            XCTFail()
        }

        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! JSONDecoder().decode(GeoJSONObject.self, from: encodedData)
        
        guard case let .feature(decodedFeature) = decoded,
              case let .point(decodedPoint) = decodedFeature.geometry else {
            return XCTFail()
        }
        
        XCTAssertEqual(point, decodedPoint)
        
        if case let .number(number) = feature.identifier,
           case let .number(decodedNumber) = decodedFeature.identifier {
            XCTAssertEqual(number, decodedNumber)
        } else {
            XCTFail()
        }
    }
    
    func testUnkownPointFeature() {
        let data = try! Fixture.geojsonData(from: "point")!
        let geojson = try! JSONDecoder().decode(GeoJSONObject.self, from: data)
        
        guard case let .feature(feature) = geojson,
              case let .point(point) = feature.geometry else {
            return XCTFail()
        }
        
        var encodedData: Data?
        XCTAssertNoThrow(encodedData = try JSONEncoder().encode(GeoJSONObject.geometry(XCTUnwrap(feature.geometry))))
        XCTAssertNotNil(encodedData)
        
        var decoded: GeoJSONObject?
        XCTAssertNoThrow(decoded = try JSONDecoder().decode(GeoJSONObject.self, from: encodedData!))
        XCTAssertNotNil(decoded)
        
        guard case let .geometry(.point(decodedPoint)) = decoded else { return XCTFail() }
        XCTAssertEqual(point, decodedPoint)
    }
}
