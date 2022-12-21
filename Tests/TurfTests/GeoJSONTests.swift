import XCTest
import Turf
#if os(macOS)
import struct Turf.Polygon
#endif

class GeoJSONTests: XCTestCase {
    func testConversion() {
        let nullIsland = LocationCoordinate2D(latitude: 0, longitude: 0)
        XCTAssertEqual(Geometry(Point(nullIsland)),
                       .point(Point(nullIsland)))
        XCTAssertEqual(Geometry(LineString([nullIsland, nullIsland])),
                       .lineString(LineString([nullIsland, nullIsland])))
        XCTAssertEqual(Geometry(Polygon([[nullIsland, nullIsland, nullIsland]])),
                       .polygon(Polygon([[nullIsland, nullIsland, nullIsland]])))
        XCTAssertEqual(Geometry(MultiPoint([nullIsland, nullIsland, nullIsland])),
                       .multiPoint(MultiPoint([nullIsland, nullIsland, nullIsland])))
        XCTAssertEqual(Geometry(MultiLineString([[nullIsland, nullIsland, nullIsland]])),
                       .multiLineString(MultiLineString([[nullIsland, nullIsland, nullIsland]])))
        XCTAssertEqual(Geometry(MultiPolygon([[[nullIsland, nullIsland, nullIsland]]])),
                       .multiPolygon(MultiPolygon([[[nullIsland, nullIsland, nullIsland]]])))
        XCTAssertEqual(Geometry(GeometryCollection(geometries: [])),
                       .geometryCollection(GeometryCollection(geometries: [])))
        
        XCTAssertEqual(Geometry(Geometry(Geometry(Geometry(Point(nullIsland))))), .point(.init(nullIsland)))
        
        XCTAssertEqual(GeoJSONObject(Geometry(Point(nullIsland))), .geometry(.point(.init(nullIsland))))
        XCTAssertEqual(GeoJSONObject(Feature(geometry: nil)), .feature(.init(geometry: nil)))
        let nullGeometry: Geometry? = nil
        XCTAssertEqual(GeoJSONObject(Feature(geometry: nullGeometry)), .feature(.init(geometry: nil)))
        XCTAssertEqual(GeoJSONObject(FeatureCollection(features: [])), .featureCollection(.init(features: [])))
        
        XCTAssertEqual(GeoJSONObject(GeoJSONObject(GeoJSONObject(GeoJSONObject(Geometry(Point(nullIsland)))))),
                       .geometry(.point(.init(nullIsland))))
    }
    
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
    
    func testRawFeatureIdentifierValues() {
        XCTAssertEqual(FeatureIdentifier(rawValue: "Jason" as NSString)?.rawValue as? String, "Jason")
        XCTAssertEqual(FeatureIdentifier(rawValue: 42 as NSNumber)?.rawValue as? Double, 42)
        XCTAssertEqual(FeatureIdentifier(rawValue: 3.1415 as NSNumber)?.rawValue as? Double, 3.1415)
    }
    
    func testFeatureIdentifierLiterals() {
        if case let FeatureIdentifier.string(string) = "Jason" {
            XCTAssertEqual(string, "Jason")
        } else {
            XCTFail()
        }
        
        if case let FeatureIdentifier.number(number) = 42 {
            XCTAssertEqual(number, 42)
        } else {
            XCTFail()
        }
        
        if case let FeatureIdentifier.number(number) = 3.1415 {
            XCTAssertEqual(number, 3.1415)
        } else {
            XCTFail()
        }
    }
    
    func testFeatureCoding() {
        let feature = Feature(geometry: nil)
        XCTAssertNil(feature.geometry)
        
        var encodedFeature: Data?
        XCTAssertNoThrow(encodedFeature = try JSONEncoder().encode(feature))
        guard let encodedData = encodedFeature else { return XCTFail() }
        
        var deserializedFeature: JSONObject?
        XCTAssertNoThrow(deserializedFeature = try JSONSerialization.jsonObject(with: encodedData, options: []) as? JSONObject)
        if let geometry = deserializedFeature?["geometry"] {
            XCTAssertNil(geometry)
        }
        
        var decodedFeature: Feature?
        XCTAssertNoThrow(decodedFeature = try JSONDecoder().decode(Feature.self, from: encodedData))
        XCTAssertNotNil(decodedFeature)
        
        XCTAssertNil(feature.geometry)
        XCTAssertEqual(decodedFeature, feature)
    }
    
    func testPropertiesCoding() {
        let coordinate = LocationCoordinate2D(latitude: 10, longitude: 30)
        var feature = Feature(geometry: .point(.init(coordinate)))
        feature.properties = [
            "string": "Jason",
            "integer": 42,
            "float": 3.1415,
            "false": false,
            "true": true,
            "nil": nil,
            "array": [],
            "dictionary": [:],
        ]
        
        var encodedFeature: Data?
        XCTAssertNoThrow(encodedFeature = try JSONEncoder().encode(feature))
        guard let encodedData = encodedFeature else { return XCTFail() }
        
        var decodedFeature: Feature?
        XCTAssertNoThrow(decodedFeature = try JSONDecoder().decode(Feature.self, from: encodedData))
        XCTAssertNotNil(decodedFeature)
        
        XCTAssertEqual(decodedFeature, feature)
    }
    
    func testForeignMemberCoding(in object: GeoJSONObject) throws {
        let today = ISO8601DateFormatter().string(from: Date())
        
        let encoder = JSONEncoder()
        encoder.userInfo[.includesForeignMembers] = true
        
        let data = try encoder.encode(object)
        guard var json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any?] else {
            return
        }
        
        // Convert the GeoJSON object to valid GeoJSON-T <https://github.com/kgeographer/geojson-t/>.
        XCTAssert(json["when"] == nil)
        json["when"] = [
            "timespans": [
                [
                    // Starts and ends sometime today.
                    "start": [
                        "in": today,
                    ],
                    "end": [
                        "in": today,
                    ],
                ],
            ],
            "duration": "PT1M", // 1 minute long
            "label": "Today",
        ]
        
        let decoder = JSONDecoder()
        decoder.userInfo[.includesForeignMembers] = true
        
        let modifiedData = try JSONSerialization.data(withJSONObject: json, options: [])
        let modifiedObject = try decoder.decode(GeoJSONObject.self, from: modifiedData)
        
        let roundTrippedData = try encoder.encode(modifiedObject)
        let roundTrippedJSON = try JSONSerialization.jsonObject(with: roundTrippedData, options: []) as? [String: Any?]
        
        let when = try XCTUnwrap(roundTrippedJSON?["when"] as? [String: Any?])
        XCTAssertEqual(when as NSDictionary, json["when"] as? NSDictionary)
    }
    
    func testForeignMemberCoding() throws {
        let nullIsland = LocationCoordinate2D(latitude: 0, longitude: 0)
        try testForeignMemberCoding(in: .geometry(.point(Point(nullIsland))))
        try testForeignMemberCoding(in: .geometry(.lineString(LineString([nullIsland, nullIsland]))))
        try testForeignMemberCoding(in: .geometry(.polygon(Polygon([[nullIsland, nullIsland, nullIsland]]))))
        try testForeignMemberCoding(in: .geometry(.multiPoint(MultiPoint([nullIsland, nullIsland, nullIsland]))))
        try testForeignMemberCoding(in: .geometry(.multiLineString(MultiLineString([[nullIsland, nullIsland, nullIsland]]))))
        try testForeignMemberCoding(in: .geometry(.multiPolygon(MultiPolygon([[[nullIsland, nullIsland, nullIsland]]]))))
        try testForeignMemberCoding(in: .geometry(.geometryCollection(GeometryCollection(geometries: []))))
        try testForeignMemberCoding(in: .feature(.init(geometry: nil)))
        try testForeignMemberCoding(in: .featureCollection(.init(features: [])))
    }
}
