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
        let firstCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let lastCoordinate = CLLocationCoordinate2D(latitude: 11, longitude: 11)
        
        let geojson = try! GeoJSON.parse(Feature.self, from: data)
        
        XCTAssert(geojson.geometry.type == .MultiPolygon)
        guard case let .multiPolygon(multipolygonCoordinates) = geojson.geometry else {
            XCTFail()
            return
        }
        
        XCTAssert(multipolygonCoordinates.coordinates.first?.first?.first == firstCoordinate)
        XCTAssert(multipolygonCoordinates.coordinates.last?.last?.last == lastCoordinate)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(Feature.self, from: encodedData)
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
        
        let multiPolygon = Geometry.multiPolygon(.init(coordinates))
        var multiPolygonFeature = Feature(geometry: multiPolygon)
        multiPolygonFeature.identifier = FeatureIdentifier.string("uniqueIdentifier")
        multiPolygonFeature.properties = ["some": "var"]

        let encodedData = try! JSONEncoder().encode(multiPolygonFeature)
        let decodedCustomMultiPolygon = try! GeoJSON.parse(Feature.self, from: encodedData)
        
        let data = try! Fixture.geojsonData(from: "multipolygon")!
        let bundledMultiPolygon = try! GeoJSON.parse(Feature.self, from: data)
        guard case let .multiPolygon(bundledMultipolygonCoordinates) = bundledMultiPolygon.geometry else {
            XCTFail()
            return
        }
        
        XCTAssert(decodedCustomMultiPolygon.geometry.type == .MultiPolygon)
        guard case let .multiPolygon(decodedMultipolygonCoordinates) = decodedCustomMultiPolygon.geometry else {
            XCTFail()
            return
        }
        XCTAssertEqual(decodedMultipolygonCoordinates, bundledMultipolygonCoordinates)
    }
    
    func testMultiPolygonContains() {
        let coordinate = CLLocationCoordinate2D(latitude: 44, longitude: -77)
        let multiPolygon = MultiPolygon( [
            Polygon([[
                CLLocationCoordinate2D(latitude: 0, longitude: 0),
                CLLocationCoordinate2D(latitude: 1, longitude: 0),
                CLLocationCoordinate2D(latitude: 1, longitude: 1),
                CLLocationCoordinate2D(latitude: 0, longitude: 1),
                CLLocationCoordinate2D(latitude: 0, longitude: 0),
                ]]),
            Polygon([[
                CLLocationCoordinate2D(latitude: 41, longitude: -81),
                CLLocationCoordinate2D(latitude: 47, longitude: -81),
                CLLocationCoordinate2D(latitude: 47, longitude: -72),
                CLLocationCoordinate2D(latitude: 41, longitude: -72),
                CLLocationCoordinate2D(latitude: 41, longitude: -81),
                ]])
            ]
        )
        XCTAssertTrue(multiPolygon.contains(coordinate))
    }
    
    func testMultiPolygonDoesNotContain() {
        let coordinate = CLLocationCoordinate2D(latitude: 44, longitude: -87)
        let multiPolygon = MultiPolygon( [
            Polygon([[
                CLLocationCoordinate2D(latitude: 0, longitude: 0),
                CLLocationCoordinate2D(latitude: 1, longitude: 0),
                CLLocationCoordinate2D(latitude: 1, longitude: 1),
                CLLocationCoordinate2D(latitude: 0, longitude: 1),
                CLLocationCoordinate2D(latitude: 0, longitude: 0),
                ]]),
            Polygon([[
                CLLocationCoordinate2D(latitude: 41, longitude: -81),
                CLLocationCoordinate2D(latitude: 47, longitude: -81),
                CLLocationCoordinate2D(latitude: 47, longitude: -72),
                CLLocationCoordinate2D(latitude: 41, longitude: -72),
                CLLocationCoordinate2D(latitude: 41, longitude: -81),
                ]])
            ]
        )
        XCTAssertFalse(multiPolygon.contains(coordinate))
    }
    
    func testMultiPolygonDoesNotContainWithHole() {
        let coordinate = CLLocationCoordinate2D(latitude: 44, longitude: -77)
        let polygon = Polygon([
            [
                CLLocationCoordinate2D(latitude: 41, longitude: -81),
                CLLocationCoordinate2D(latitude: 47, longitude: -81),
                CLLocationCoordinate2D(latitude: 47, longitude: -72),
                CLLocationCoordinate2D(latitude: 41, longitude: -72),
                CLLocationCoordinate2D(latitude: 41, longitude: -81),
            ],
            [
                CLLocationCoordinate2D(latitude: 43, longitude: -76),
                CLLocationCoordinate2D(latitude: 43, longitude: -78),
                CLLocationCoordinate2D(latitude: 45, longitude: -78),
                CLLocationCoordinate2D(latitude: 45, longitude: -76),
                CLLocationCoordinate2D(latitude: 43, longitude: -76),
            ],
        ])
        let multiPolygon = MultiPolygon( [
            polygon,
            Polygon([[
                CLLocationCoordinate2D(latitude: 0, longitude: 0),
                CLLocationCoordinate2D(latitude: 1, longitude: 0),
                CLLocationCoordinate2D(latitude: 1, longitude: 1),
                CLLocationCoordinate2D(latitude: 0, longitude: 1),
                CLLocationCoordinate2D(latitude: 0, longitude: 0),
                ]])
            ]
        )
        XCTAssertFalse(multiPolygon.contains(coordinate))
    }

    func testMultiPolygonContainsAtBoundary() {
        let coordinate = CLLocationCoordinate2D(latitude: 1, longitude: 1)
        let multiPolygon = MultiPolygon( [
            [[
                CLLocationCoordinate2D(latitude: 0, longitude: 0),
                CLLocationCoordinate2D(latitude: 1, longitude: 0),
                CLLocationCoordinate2D(latitude: 1, longitude: 1),
                CLLocationCoordinate2D(latitude: 0, longitude: 1),
                CLLocationCoordinate2D(latitude: 0, longitude: 0),
                ]],
            [[
                CLLocationCoordinate2D(latitude: 41, longitude: -81),
                CLLocationCoordinate2D(latitude: 47, longitude: -81),
                CLLocationCoordinate2D(latitude: 47, longitude: -72),
                CLLocationCoordinate2D(latitude: 41, longitude: -72),
                CLLocationCoordinate2D(latitude: 41, longitude: -81),
                ]]
            ]
        )

        XCTAssertFalse(multiPolygon.contains(coordinate, ignoreBoundary: true))
        XCTAssertTrue(multiPolygon.contains(coordinate, ignoreBoundary: false))
        XCTAssertTrue(multiPolygon.contains(coordinate))
    }

    func testMultiPolygonWithHoleContainsAtBoundary() {
        let coordinate = CLLocationCoordinate2D(latitude: 43, longitude: -78)
        let multiPolygon = MultiPolygon( [
            [
                [
                    CLLocationCoordinate2D(latitude: 41, longitude: -81),
                    CLLocationCoordinate2D(latitude: 47, longitude: -81),
                    CLLocationCoordinate2D(latitude: 47, longitude: -72),
                    CLLocationCoordinate2D(latitude: 41, longitude: -72),
                    CLLocationCoordinate2D(latitude: 41, longitude: -81),
                ],
                [
                    CLLocationCoordinate2D(latitude: 43, longitude: -76),
                    CLLocationCoordinate2D(latitude: 43, longitude: -78),
                    CLLocationCoordinate2D(latitude: 45, longitude: -78),
                    CLLocationCoordinate2D(latitude: 45, longitude: -76),
                    CLLocationCoordinate2D(latitude: 43, longitude: -76),
                ]
            ],
            [[
                CLLocationCoordinate2D(latitude: 0, longitude: 0),
                CLLocationCoordinate2D(latitude: 1, longitude: 0),
                CLLocationCoordinate2D(latitude: 1, longitude: 1),
                CLLocationCoordinate2D(latitude: 0, longitude: 1),
                CLLocationCoordinate2D(latitude: 0, longitude: 0),
                ]]
            ]
        )

        XCTAssertFalse(multiPolygon.contains(coordinate, ignoreBoundary: true))
        XCTAssertTrue(multiPolygon.contains(coordinate, ignoreBoundary: false))
        XCTAssertTrue(multiPolygon.contains(coordinate))
    }
}
