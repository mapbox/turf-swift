import XCTest
import Turf
#if os(macOS)
import struct Turf.Polygon
#endif
import CoreLocation

class GeoJSONTests: XCTestCase {
    
    func testPoint() {
        let coordinate = LocationCoordinate2D(latitude: 10, longitude: 30)
        let feature = Feature(geometry: .point(.init(coordinate)))
        
        guard case let .point(point) = feature.geometry else { return XCTFail() }
        XCTAssertEqual(point.coordinates, coordinate)
    }
    
    func testLineString() {
        let coordinates = [LocationCoordinate2D(latitude: 10, longitude: 30),
                           LocationCoordinate2D(latitude: 30, longitude: 10),
                           LocationCoordinate2D(latitude: 40, longitude: 40)]
        
        let feature = Feature(geometry: .lineString(.init(coordinates)))
        
        guard case let .lineString(lineString) = feature.geometry else { return XCTFail() }
        XCTAssertEqual(lineString.coordinates, coordinates)
    }
    
    func testPolygon() {
        let coordinates = [
            [
                LocationCoordinate2D(latitude: 10, longitude: 30),
                LocationCoordinate2D(latitude: 40, longitude: 40),
                LocationCoordinate2D(latitude: 40, longitude: 20),
                LocationCoordinate2D(latitude: 20, longitude: 10),
                LocationCoordinate2D(latitude: 10, longitude: 30)
            ],
            [
                LocationCoordinate2D(latitude: 30, longitude: 20),
                LocationCoordinate2D(latitude: 35, longitude: 35),
                LocationCoordinate2D(latitude: 20, longitude: 30),
                LocationCoordinate2D(latitude: 30, longitude: 20)
            ]
        ]
        
        let feature = Feature(geometry: .polygon(.init(coordinates)))
        
        guard case let .polygon(polygon) = feature.geometry else { return XCTFail() }
        XCTAssertEqual(polygon.coordinates, coordinates)
    }
    
    func testMultiPoint() {
        let coordinates = [LocationCoordinate2D(latitude: 40, longitude: 10),
                           LocationCoordinate2D(latitude: 30, longitude: 40),
                           LocationCoordinate2D(latitude: 20, longitude: 20),
                           LocationCoordinate2D(latitude: 10, longitude: 30)]
        
        let feature = Feature(geometry: .multiPoint(.init(coordinates)))
        
        guard case let .multiPoint(multiPoint) = feature.geometry else { return XCTFail() }
        XCTAssertEqual(multiPoint.coordinates, coordinates)
    }
    
    func testMultiLineString() {
        let coordinates = [
            [
                LocationCoordinate2D(latitude: 10, longitude: 10),
                LocationCoordinate2D(latitude: 20, longitude: 20),
                LocationCoordinate2D(latitude: 40, longitude: 10)
            ],
            [
                LocationCoordinate2D(latitude: 40, longitude: 40),
                LocationCoordinate2D(latitude: 30, longitude: 30),
                LocationCoordinate2D(latitude: 20, longitude: 40),
                LocationCoordinate2D(latitude: 10, longitude: 30)
            ]
        ]
        
        let feature = Feature(geometry: .multiLineString(.init(coordinates)))
        
        guard case let .multiLineString(multiLineString) = feature.geometry else { return XCTFail() }
        XCTAssertEqual(multiLineString.coordinates, coordinates)
    }
    
    func testMultiPolygon() {
        let coordinates = [
            [
                [
                    LocationCoordinate2D(latitude: 40, longitude: 40),
                    LocationCoordinate2D(latitude: 45, longitude: 20),
                    LocationCoordinate2D(latitude: 45, longitude: 30),
                    LocationCoordinate2D(latitude: 40, longitude: 40)
                ]
            ],
            [
                [
                    LocationCoordinate2D(latitude: 35, longitude: 20),
                    LocationCoordinate2D(latitude: 30, longitude: 10),
                    LocationCoordinate2D(latitude: 10, longitude: 10),
                    LocationCoordinate2D(latitude: 5, longitude: 30),
                    LocationCoordinate2D(latitude: 20, longitude: 45),
                    LocationCoordinate2D(latitude: 35, longitude: 20)
                ],
                [
                    LocationCoordinate2D(latitude: 20, longitude: 30),
                    LocationCoordinate2D(latitude: 15, longitude: 20),
                    LocationCoordinate2D(latitude: 25, longitude: 25),
                    LocationCoordinate2D(latitude: 20, longitude: 30)
                ]
            ]
        ]
        
        let feature = Feature(geometry: .multiPolygon(.init(coordinates)))
        
        guard case let .multiPolygon(multiPolygon) = feature.geometry else { return XCTFail() }
        XCTAssertEqual(multiPolygon.coordinates, coordinates)
    }
}
