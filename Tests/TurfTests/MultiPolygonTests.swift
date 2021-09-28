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
        let firstCoordinate = LocationCoordinate2D(latitude: 0, longitude: 0)
        let lastCoordinate = LocationCoordinate2D(latitude: 11, longitude: 11)
        
        let geojson = try! JSONDecoder().decode(Feature.self, from: data)
        
        guard case let .multiPolygon(multipolygonCoordinates) = geojson.geometry else {
            XCTFail()
            return
        }
        
        XCTAssert(multipolygonCoordinates.coordinates.first?.first?.first == firstCoordinate)
        XCTAssert(multipolygonCoordinates.coordinates.last?.last?.last == lastCoordinate)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! JSONDecoder().decode(Feature.self, from: encodedData)
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
                    LocationCoordinate2D(latitude: 0, longitude: 0),
                    LocationCoordinate2D(latitude: 0, longitude: 5),
                    LocationCoordinate2D(latitude: 0, longitude: 5),
                    LocationCoordinate2D(latitude: 0, longitude: 10),
                    LocationCoordinate2D(latitude: 10, longitude: 10),
                    LocationCoordinate2D(latitude: 10, longitude: 0),
                    LocationCoordinate2D(latitude: 5, longitude: 0),
                    LocationCoordinate2D(latitude: 0, longitude: 0),
                ],
                [
                    LocationCoordinate2D(latitude: 5, longitude: 1),
                    LocationCoordinate2D(latitude: 7, longitude: 1),
                    LocationCoordinate2D(latitude: 8.5, longitude: 1),
                    LocationCoordinate2D(latitude: 8.5, longitude: 4.5),
                    LocationCoordinate2D(latitude: 7, longitude: 4.5),
                    LocationCoordinate2D(latitude: 5, longitude: 4.5),
                    LocationCoordinate2D(latitude: 5, longitude: 1),
                ]
            ],
            [
                [
                    LocationCoordinate2D(latitude: 11, longitude: 11),
                    LocationCoordinate2D(latitude: 11.5, longitude: 11.5),
                    LocationCoordinate2D(latitude: 12, longitude: 12),
                    LocationCoordinate2D(latitude: 11, longitude: 12),
                    LocationCoordinate2D(latitude: 11, longitude: 11.5),
                    LocationCoordinate2D(latitude: 11, longitude: 11),
                    LocationCoordinate2D(latitude: 11, longitude: 11),
                ]
            ]
        ]
        
        let multiPolygon = Geometry.multiPolygon(.init(coordinates))
        var multiPolygonFeature = Feature(geometry: multiPolygon)
        multiPolygonFeature.identifier = "uniqueIdentifier"
        multiPolygonFeature.properties = ["some": "var"]

        let encodedData = try! JSONEncoder().encode(multiPolygonFeature)
        let decodedCustomMultiPolygon = try! JSONDecoder().decode(Feature.self, from: encodedData)
        
        let data = try! Fixture.geojsonData(from: "multipolygon")!
        let bundledMultiPolygon = try! JSONDecoder().decode(Feature.self, from: data)
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
        let coordinate = LocationCoordinate2D(latitude: 44, longitude: -77)
        let multiPolygon = MultiPolygon([
            Polygon([[
                LocationCoordinate2D(latitude: 0, longitude: 0),
                LocationCoordinate2D(latitude: 1, longitude: 0),
                LocationCoordinate2D(latitude: 1, longitude: 1),
                LocationCoordinate2D(latitude: 0, longitude: 1),
                LocationCoordinate2D(latitude: 0, longitude: 0),
            ]]),
            Polygon([[
                LocationCoordinate2D(latitude: 41, longitude: -81),
                LocationCoordinate2D(latitude: 47, longitude: -81),
                LocationCoordinate2D(latitude: 47, longitude: -72),
                LocationCoordinate2D(latitude: 41, longitude: -72),
                LocationCoordinate2D(latitude: 41, longitude: -81),
            ]])
        ])
        XCTAssertTrue(multiPolygon.contains(coordinate))
    }
    
    func testMultiPolygonDoesNotContain() {
        let coordinate = LocationCoordinate2D(latitude: 44, longitude: -87)
        let multiPolygon = MultiPolygon([
            Polygon([[
                LocationCoordinate2D(latitude: 0, longitude: 0),
                LocationCoordinate2D(latitude: 1, longitude: 0),
                LocationCoordinate2D(latitude: 1, longitude: 1),
                LocationCoordinate2D(latitude: 0, longitude: 1),
                LocationCoordinate2D(latitude: 0, longitude: 0),
            ]]),
            Polygon([[
                LocationCoordinate2D(latitude: 41, longitude: -81),
                LocationCoordinate2D(latitude: 47, longitude: -81),
                LocationCoordinate2D(latitude: 47, longitude: -72),
                LocationCoordinate2D(latitude: 41, longitude: -72),
                LocationCoordinate2D(latitude: 41, longitude: -81),
            ]])
        ])
        XCTAssertFalse(multiPolygon.contains(coordinate))
    }
    
    func testMultiPolygonDoesNotContainWithHole() {
        let coordinate = LocationCoordinate2D(latitude: 44, longitude: -77)
        let polygon = Polygon([
            [
                LocationCoordinate2D(latitude: 41, longitude: -81),
                LocationCoordinate2D(latitude: 47, longitude: -81),
                LocationCoordinate2D(latitude: 47, longitude: -72),
                LocationCoordinate2D(latitude: 41, longitude: -72),
                LocationCoordinate2D(latitude: 41, longitude: -81),
            ],
            [
                LocationCoordinate2D(latitude: 43, longitude: -76),
                LocationCoordinate2D(latitude: 43, longitude: -78),
                LocationCoordinate2D(latitude: 45, longitude: -78),
                LocationCoordinate2D(latitude: 45, longitude: -76),
                LocationCoordinate2D(latitude: 43, longitude: -76),
            ],
        ])
        let multiPolygon = MultiPolygon([
            polygon,
            Polygon([[
                LocationCoordinate2D(latitude: 0, longitude: 0),
                LocationCoordinate2D(latitude: 1, longitude: 0),
                LocationCoordinate2D(latitude: 1, longitude: 1),
                LocationCoordinate2D(latitude: 0, longitude: 1),
                LocationCoordinate2D(latitude: 0, longitude: 0),
            ]])
        ])
        XCTAssertFalse(multiPolygon.contains(coordinate))
    }

    func testMultiPolygonContainsAtBoundary() {
        let coordinate = LocationCoordinate2D(latitude: 1, longitude: 1)
        let multiPolygon = MultiPolygon([
            [[
                LocationCoordinate2D(latitude: 0, longitude: 0),
                LocationCoordinate2D(latitude: 1, longitude: 0),
                LocationCoordinate2D(latitude: 1, longitude: 1),
                LocationCoordinate2D(latitude: 0, longitude: 1),
                LocationCoordinate2D(latitude: 0, longitude: 0),
            ]],
            [[
                LocationCoordinate2D(latitude: 41, longitude: -81),
                LocationCoordinate2D(latitude: 47, longitude: -81),
                LocationCoordinate2D(latitude: 47, longitude: -72),
                LocationCoordinate2D(latitude: 41, longitude: -72),
                LocationCoordinate2D(latitude: 41, longitude: -81),
            ]]
        ])

        XCTAssertFalse(multiPolygon.contains(coordinate, ignoreBoundary: true))
        XCTAssertTrue(multiPolygon.contains(coordinate, ignoreBoundary: false))
        XCTAssertTrue(multiPolygon.contains(coordinate))
    }

    func testMultiPolygonWithHoleContainsAtBoundary() {
        let coordinate = LocationCoordinate2D(latitude: 43, longitude: -78)
        let multiPolygon = MultiPolygon( [
            [
                [
                    LocationCoordinate2D(latitude: 41, longitude: -81),
                    LocationCoordinate2D(latitude: 47, longitude: -81),
                    LocationCoordinate2D(latitude: 47, longitude: -72),
                    LocationCoordinate2D(latitude: 41, longitude: -72),
                    LocationCoordinate2D(latitude: 41, longitude: -81),
                ],
                [
                    LocationCoordinate2D(latitude: 43, longitude: -76),
                    LocationCoordinate2D(latitude: 43, longitude: -78),
                    LocationCoordinate2D(latitude: 45, longitude: -78),
                    LocationCoordinate2D(latitude: 45, longitude: -76),
                    LocationCoordinate2D(latitude: 43, longitude: -76),
                ]
            ],
            [[
                LocationCoordinate2D(latitude: 0, longitude: 0),
                LocationCoordinate2D(latitude: 1, longitude: 0),
                LocationCoordinate2D(latitude: 1, longitude: 1),
                LocationCoordinate2D(latitude: 0, longitude: 1),
                LocationCoordinate2D(latitude: 0, longitude: 0),
            ]]
        ])

        XCTAssertFalse(multiPolygon.contains(coordinate, ignoreBoundary: true))
        XCTAssertTrue(multiPolygon.contains(coordinate, ignoreBoundary: false))
        XCTAssertTrue(multiPolygon.contains(coordinate))
    }
}
