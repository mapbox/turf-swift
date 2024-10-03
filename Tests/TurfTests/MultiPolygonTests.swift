import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf
#if os(OSX)
import struct Turf.TurfPolygon // Conflicts with MapKit’s TurfPolygon
#endif

class MultiPolygonTests: XCTestCase {
    
    func testMultiPolygonFeature() {
        let data = try! Fixture.geojsonData(from: "multipolygon")!
        let firstCoordinate = TurfLocationCoordinate2D(latitude: 0, longitude: 0)
        let lastCoordinate = TurfLocationCoordinate2D(latitude: 11, longitude: 11)
        
        let geojson = try! JSONDecoder().decode(TurfFeature.self, from: data)
        
        guard case let .multiPolygon(multipolygonCoordinates) = geojson.geometry else {
            XCTFail()
            return
        }
        
        XCTAssert(multipolygonCoordinates.coordinates.first?.first?.first == firstCoordinate)
        XCTAssert(multipolygonCoordinates.coordinates.last?.last?.last == lastCoordinate)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! JSONDecoder().decode(TurfFeature.self, from: encodedData)
        guard case let .multiPolygon(decodedMultipolygonCoordinates) = decoded.geometry else {
            XCTFail()
            return
        }
        XCTAssert(decodedMultipolygonCoordinates.coordinates.first?.first?.first == firstCoordinate)
        XCTAssert(decodedMultipolygonCoordinates.coordinates.last?.last?.last == lastCoordinate)
    }
    
    func testBuildMultiPolygonFeature() {
        let coordinates =
        [
            [
                [
                    TurfLocationCoordinate2D(latitude: 0, longitude: 0),
                    TurfLocationCoordinate2D(latitude: 0, longitude: 5),
                    TurfLocationCoordinate2D(latitude: 0, longitude: 5),
                    TurfLocationCoordinate2D(latitude: 0, longitude: 10),
                    TurfLocationCoordinate2D(latitude: 10, longitude: 10),
                    TurfLocationCoordinate2D(latitude: 10, longitude: 0),
                    TurfLocationCoordinate2D(latitude: 5, longitude: 0),
                    TurfLocationCoordinate2D(latitude: 0, longitude: 0),
                ],
                [
                    TurfLocationCoordinate2D(latitude: 5, longitude: 1),
                    TurfLocationCoordinate2D(latitude: 7, longitude: 1),
                    TurfLocationCoordinate2D(latitude: 8.5, longitude: 1),
                    TurfLocationCoordinate2D(latitude: 8.5, longitude: 4.5),
                    TurfLocationCoordinate2D(latitude: 7, longitude: 4.5),
                    TurfLocationCoordinate2D(latitude: 5, longitude: 4.5),
                    TurfLocationCoordinate2D(latitude: 5, longitude: 1),
                ]
            ],
            [
                [
                    TurfLocationCoordinate2D(latitude: 11, longitude: 11),
                    TurfLocationCoordinate2D(latitude: 11.5, longitude: 11.5),
                    TurfLocationCoordinate2D(latitude: 12, longitude: 12),
                    TurfLocationCoordinate2D(latitude: 11, longitude: 12),
                    TurfLocationCoordinate2D(latitude: 11, longitude: 11.5),
                    TurfLocationCoordinate2D(latitude: 11, longitude: 11),
                    TurfLocationCoordinate2D(latitude: 11, longitude: 11),
                ]
            ]
        ]
        
        let multiPolygon = TurfGeometry.multiPolygon(.init(coordinates))
        var multiPolygonFeature = TurfFeature(geometry: multiPolygon)
        multiPolygonFeature.identifier = "uniqueIdentifier"
        multiPolygonFeature.properties = ["some": "var"]

        let encodedData = try! JSONEncoder().encode(multiPolygonFeature)
        let decodedCustomMultiPolygon = try! JSONDecoder().decode(TurfFeature.self, from: encodedData)
        
        let data = try! Fixture.geojsonData(from: "multipolygon")!
        let bundledMultiPolygon = try! JSONDecoder().decode(TurfFeature.self, from: data)
        guard case let .multiPolygon(bundledMultipolygonCoordinates) = bundledMultiPolygon.geometry else {
            XCTFail()
            return
        }
        
        guard case let .multiPolygon(decodedMultipolygonCoordinates) = decodedCustomMultiPolygon.geometry else {
            XCTFail()
            return
        }
        XCTAssertEqual(decodedMultipolygonCoordinates, bundledMultipolygonCoordinates)
    }
    
    func testMultiPolygonContains() {
        let coordinate = TurfLocationCoordinate2D(latitude: 44, longitude: -77)
        let multiPolygon = TurfMultiPolygon([
            TurfPolygon([[
                TurfLocationCoordinate2D(latitude: 0, longitude: 0),
                TurfLocationCoordinate2D(latitude: 1, longitude: 0),
                TurfLocationCoordinate2D(latitude: 1, longitude: 1),
                TurfLocationCoordinate2D(latitude: 0, longitude: 1),
                TurfLocationCoordinate2D(latitude: 0, longitude: 0),
            ]]),
            TurfPolygon([[
                TurfLocationCoordinate2D(latitude: 41, longitude: -81),
                TurfLocationCoordinate2D(latitude: 47, longitude: -81),
                TurfLocationCoordinate2D(latitude: 47, longitude: -72),
                TurfLocationCoordinate2D(latitude: 41, longitude: -72),
                TurfLocationCoordinate2D(latitude: 41, longitude: -81),
            ]])
        ])
        XCTAssertTrue(multiPolygon.contains(coordinate))
    }
    
    func testMultiPolygonDoesNotContain() {
        let coordinate = TurfLocationCoordinate2D(latitude: 44, longitude: -87)
        let multiPolygon = TurfMultiPolygon([
            TurfPolygon([[
                TurfLocationCoordinate2D(latitude: 0, longitude: 0),
                TurfLocationCoordinate2D(latitude: 1, longitude: 0),
                TurfLocationCoordinate2D(latitude: 1, longitude: 1),
                TurfLocationCoordinate2D(latitude: 0, longitude: 1),
                TurfLocationCoordinate2D(latitude: 0, longitude: 0),
            ]]),
            TurfPolygon([[
                TurfLocationCoordinate2D(latitude: 41, longitude: -81),
                TurfLocationCoordinate2D(latitude: 47, longitude: -81),
                TurfLocationCoordinate2D(latitude: 47, longitude: -72),
                TurfLocationCoordinate2D(latitude: 41, longitude: -72),
                TurfLocationCoordinate2D(latitude: 41, longitude: -81),
            ]])
        ])
        XCTAssertFalse(multiPolygon.contains(coordinate))
    }
    
    func testMultiPolygonDoesNotContainWithHole() {
        let coordinate = TurfLocationCoordinate2D(latitude: 44, longitude: -77)
        let polygon = TurfPolygon([
            [
                TurfLocationCoordinate2D(latitude: 41, longitude: -81),
                TurfLocationCoordinate2D(latitude: 47, longitude: -81),
                TurfLocationCoordinate2D(latitude: 47, longitude: -72),
                TurfLocationCoordinate2D(latitude: 41, longitude: -72),
                TurfLocationCoordinate2D(latitude: 41, longitude: -81),
            ],
            [
                TurfLocationCoordinate2D(latitude: 43, longitude: -76),
                TurfLocationCoordinate2D(latitude: 43, longitude: -78),
                TurfLocationCoordinate2D(latitude: 45, longitude: -78),
                TurfLocationCoordinate2D(latitude: 45, longitude: -76),
                TurfLocationCoordinate2D(latitude: 43, longitude: -76),
            ],
        ])
        let multiPolygon = TurfMultiPolygon([
            polygon,
            TurfPolygon([[
                TurfLocationCoordinate2D(latitude: 0, longitude: 0),
                TurfLocationCoordinate2D(latitude: 1, longitude: 0),
                TurfLocationCoordinate2D(latitude: 1, longitude: 1),
                TurfLocationCoordinate2D(latitude: 0, longitude: 1),
                TurfLocationCoordinate2D(latitude: 0, longitude: 0),
            ]])
        ])
        XCTAssertFalse(multiPolygon.contains(coordinate))
    }

    func testMultiPolygonContainsAtBoundary() {
        let coordinate = TurfLocationCoordinate2D(latitude: 1, longitude: 1)
        let multiPolygon = TurfMultiPolygon([
            [[
                TurfLocationCoordinate2D(latitude: 0, longitude: 0),
                TurfLocationCoordinate2D(latitude: 1, longitude: 0),
                TurfLocationCoordinate2D(latitude: 1, longitude: 1),
                TurfLocationCoordinate2D(latitude: 0, longitude: 1),
                TurfLocationCoordinate2D(latitude: 0, longitude: 0),
            ]],
            [[
                TurfLocationCoordinate2D(latitude: 41, longitude: -81),
                TurfLocationCoordinate2D(latitude: 47, longitude: -81),
                TurfLocationCoordinate2D(latitude: 47, longitude: -72),
                TurfLocationCoordinate2D(latitude: 41, longitude: -72),
                TurfLocationCoordinate2D(latitude: 41, longitude: -81),
            ]]
        ])

        XCTAssertFalse(multiPolygon.contains(coordinate, ignoreBoundary: true))
        XCTAssertTrue(multiPolygon.contains(coordinate, ignoreBoundary: false))
        XCTAssertTrue(multiPolygon.contains(coordinate))
    }

    func testMultiPolygonWithHoleContainsAtBoundary() {
        let coordinate = TurfLocationCoordinate2D(latitude: 43, longitude: -78)
        let multiPolygon = TurfMultiPolygon( [
            [
                [
                    TurfLocationCoordinate2D(latitude: 41, longitude: -81),
                    TurfLocationCoordinate2D(latitude: 47, longitude: -81),
                    TurfLocationCoordinate2D(latitude: 47, longitude: -72),
                    TurfLocationCoordinate2D(latitude: 41, longitude: -72),
                    TurfLocationCoordinate2D(latitude: 41, longitude: -81),
                ],
                [
                    TurfLocationCoordinate2D(latitude: 43, longitude: -76),
                    TurfLocationCoordinate2D(latitude: 43, longitude: -78),
                    TurfLocationCoordinate2D(latitude: 45, longitude: -78),
                    TurfLocationCoordinate2D(latitude: 45, longitude: -76),
                    TurfLocationCoordinate2D(latitude: 43, longitude: -76),
                ]
            ],
            [[
                TurfLocationCoordinate2D(latitude: 0, longitude: 0),
                TurfLocationCoordinate2D(latitude: 1, longitude: 0),
                TurfLocationCoordinate2D(latitude: 1, longitude: 1),
                TurfLocationCoordinate2D(latitude: 0, longitude: 1),
                TurfLocationCoordinate2D(latitude: 0, longitude: 0),
            ]]
        ])

        XCTAssertFalse(multiPolygon.contains(coordinate, ignoreBoundary: true))
        XCTAssertTrue(multiPolygon.contains(coordinate, ignoreBoundary: false))
        XCTAssertTrue(multiPolygon.contains(coordinate))
    }
}
