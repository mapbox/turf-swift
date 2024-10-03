import XCTest
import Turf
#if os(macOS)
import struct Turf.TurfPolygon
#endif

class GeoJSONTests: XCTestCase {
    func testConversion() {
        let nullIsland = TurfLocationCoordinate2D(latitude: 0, longitude: 0)
        XCTAssertEqual(TurfGeometry(TurfPoint(nullIsland)),
                       .point(TurfPoint(nullIsland)))
        XCTAssertEqual(TurfGeometry(TurfLineString([nullIsland, nullIsland])),
                       .lineString(TurfLineString([nullIsland, nullIsland])))
        XCTAssertEqual(TurfGeometry(TurfPolygon([[nullIsland, nullIsland, nullIsland]])),
                       .polygon(TurfPolygon([[nullIsland, nullIsland, nullIsland]])))
        XCTAssertEqual(TurfGeometry(TurfMultiPoint([nullIsland, nullIsland, nullIsland])),
                       .multiPoint(TurfMultiPoint([nullIsland, nullIsland, nullIsland])))
        XCTAssertEqual(TurfGeometry(TurfMultiLineString([[nullIsland, nullIsland, nullIsland]])),
                       .multiLineString(TurfMultiLineString([[nullIsland, nullIsland, nullIsland]])))
        XCTAssertEqual(TurfGeometry(TurfMultiPolygon([[[nullIsland, nullIsland, nullIsland]]])),
                       .multiPolygon(TurfMultiPolygon([[[nullIsland, nullIsland, nullIsland]]])))
        XCTAssertEqual(TurfGeometry(TurfGeometryCollection(geometries: [])),
                       .geometryCollection(TurfGeometryCollection(geometries: [])))
        
        XCTAssertEqual(TurfGeometry(TurfGeometry(TurfGeometry(TurfGeometry(TurfPoint(nullIsland))))), .point(.init(nullIsland)))
        
        XCTAssertEqual(TurfGeoJSONObject(TurfGeometry(TurfPoint(nullIsland))), .geometry(.point(.init(nullIsland))))
        XCTAssertEqual(TurfGeoJSONObject(TurfFeature(geometry: nil)), .feature(.init(geometry: nil)))
        let nullGeometry: TurfGeometry? = nil
        XCTAssertEqual(TurfGeoJSONObject(TurfFeature(geometry: nullGeometry)), .feature(.init(geometry: nil)))
        XCTAssertEqual(TurfGeoJSONObject(TurfFeatureCollection(features: [])), .featureCollection(.init(features: [])))
        
        XCTAssertEqual(TurfGeoJSONObject(TurfGeoJSONObject(TurfGeoJSONObject(TurfGeoJSONObject(TurfGeometry(TurfPoint(nullIsland)))))),
                       .geometry(.point(.init(nullIsland))))
    }
    
    func testPoint() {
        let coordinate = TurfLocationCoordinate2D(latitude: 10, longitude: 30)
        let feature = TurfFeature(geometry: .point(.init(coordinate)))
        
        guard case let .point(point) = feature.geometry else { return XCTFail() }
        XCTAssertEqual(point.coordinates, coordinate)
    }
    
    func testLineString() {
        let coordinates = [TurfLocationCoordinate2D(latitude: 10, longitude: 30),
                           TurfLocationCoordinate2D(latitude: 30, longitude: 10),
                           TurfLocationCoordinate2D(latitude: 40, longitude: 40)]
        
        let feature = TurfFeature(geometry: .lineString(.init(coordinates)))
        
        guard case let .lineString(lineString) = feature.geometry else { return XCTFail() }
        XCTAssertEqual(lineString.coordinates, coordinates)
    }
    
    func testPolygon() {
        let coordinates = [
            [
                TurfLocationCoordinate2D(latitude: 10, longitude: 30),
                TurfLocationCoordinate2D(latitude: 40, longitude: 40),
                TurfLocationCoordinate2D(latitude: 40, longitude: 20),
                TurfLocationCoordinate2D(latitude: 20, longitude: 10),
                TurfLocationCoordinate2D(latitude: 10, longitude: 30)
            ],
            [
                TurfLocationCoordinate2D(latitude: 30, longitude: 20),
                TurfLocationCoordinate2D(latitude: 35, longitude: 35),
                TurfLocationCoordinate2D(latitude: 20, longitude: 30),
                TurfLocationCoordinate2D(latitude: 30, longitude: 20)
            ]
        ]
        
        let feature = TurfFeature(geometry: .polygon(.init(coordinates)))
        
        guard case let .polygon(polygon) = feature.geometry else { return XCTFail() }
        XCTAssertEqual(polygon.coordinates, coordinates)
    }
    
    func testMultiPoint() {
        let coordinates = [TurfLocationCoordinate2D(latitude: 40, longitude: 10),
                           TurfLocationCoordinate2D(latitude: 30, longitude: 40),
                           TurfLocationCoordinate2D(latitude: 20, longitude: 20),
                           TurfLocationCoordinate2D(latitude: 10, longitude: 30)]
        
        let feature = TurfFeature(geometry: .multiPoint(.init(coordinates)))
        
        guard case let .multiPoint(multiPoint) = feature.geometry else { return XCTFail() }
        XCTAssertEqual(multiPoint.coordinates, coordinates)
    }
    
    func testMultiLineString() {
        let coordinates = [
            [
                TurfLocationCoordinate2D(latitude: 10, longitude: 10),
                TurfLocationCoordinate2D(latitude: 20, longitude: 20),
                TurfLocationCoordinate2D(latitude: 40, longitude: 10)
            ],
            [
                TurfLocationCoordinate2D(latitude: 40, longitude: 40),
                TurfLocationCoordinate2D(latitude: 30, longitude: 30),
                TurfLocationCoordinate2D(latitude: 20, longitude: 40),
                TurfLocationCoordinate2D(latitude: 10, longitude: 30)
            ]
        ]
        
        let feature = TurfFeature(geometry: .multiLineString(.init(coordinates)))
        
        guard case let .multiLineString(multiLineString) = feature.geometry else { return XCTFail() }
        XCTAssertEqual(multiLineString.coordinates, coordinates)
    }
    
    func testMultiPolygon() {
        let coordinates = [
            [
                [
                    TurfLocationCoordinate2D(latitude: 40, longitude: 40),
                    TurfLocationCoordinate2D(latitude: 45, longitude: 20),
                    TurfLocationCoordinate2D(latitude: 45, longitude: 30),
                    TurfLocationCoordinate2D(latitude: 40, longitude: 40)
                ]
            ],
            [
                [
                    TurfLocationCoordinate2D(latitude: 35, longitude: 20),
                    TurfLocationCoordinate2D(latitude: 30, longitude: 10),
                    TurfLocationCoordinate2D(latitude: 10, longitude: 10),
                    TurfLocationCoordinate2D(latitude: 5, longitude: 30),
                    TurfLocationCoordinate2D(latitude: 20, longitude: 45),
                    TurfLocationCoordinate2D(latitude: 35, longitude: 20)
                ],
                [
                    TurfLocationCoordinate2D(latitude: 20, longitude: 30),
                    TurfLocationCoordinate2D(latitude: 15, longitude: 20),
                    TurfLocationCoordinate2D(latitude: 25, longitude: 25),
                    TurfLocationCoordinate2D(latitude: 20, longitude: 30)
                ]
            ]
        ]
        
        let feature = TurfFeature(geometry: .multiPolygon(.init(coordinates)))
        
        guard case let .multiPolygon(multiPolygon) = feature.geometry else { return XCTFail() }
        XCTAssertEqual(multiPolygon.coordinates, coordinates)
    }
    
    func testRawFeatureIdentifierValues() {
        XCTAssertEqual(TurfFeatureIdentifier(rawValue: "Jason" as NSString)?.rawValue as? String, "Jason")
        XCTAssertEqual(TurfFeatureIdentifier(rawValue: 42 as NSNumber)?.rawValue as? Double, 42)
        XCTAssertEqual(TurfFeatureIdentifier(rawValue: 3.1415 as NSNumber)?.rawValue as? Double, 3.1415)
    }
    
    func testFeatureIdentifierLiterals() {
        if case let TurfFeatureIdentifier.string(string) = "Jason" {
            XCTAssertEqual(string, "Jason")
        } else {
            XCTFail()
        }
        
        if case let TurfFeatureIdentifier.number(number) = 42 {
            XCTAssertEqual(number, 42)
        } else {
            XCTFail()
        }
        
        if case let TurfFeatureIdentifier.number(number) = 3.1415 {
            XCTAssertEqual(number, 3.1415)
        } else {
            XCTFail()
        }
    }
    
    func testFeatureCoding() {
        let feature = TurfFeature(geometry: nil)
        XCTAssertNil(feature.geometry)
        
        var encodedFeature: Data?
        XCTAssertNoThrow(encodedFeature = try JSONEncoder().encode(feature))
        guard let encodedData = encodedFeature else { return XCTFail() }
        
        var deserializedFeature: JSONObject?
        XCTAssertNoThrow(deserializedFeature = try JSONSerialization.jsonObject(with: encodedData, options: []) as? JSONObject)
        if let geometry = deserializedFeature?["geometry"] {
            XCTAssertNil(geometry)
        }
        
        var decodedFeature: TurfFeature?
        XCTAssertNoThrow(decodedFeature = try JSONDecoder().decode(TurfFeature.self, from: encodedData))
        XCTAssertNotNil(decodedFeature)
        
        XCTAssertNil(feature.geometry)
        XCTAssertEqual(decodedFeature, feature)
    }
    
    func testPropertiesCoding() {
        let coordinate = TurfLocationCoordinate2D(latitude: 10, longitude: 30)
        var feature = TurfFeature(geometry: .point(.init(coordinate)))
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
        
        var decodedFeature: TurfFeature?
        XCTAssertNoThrow(decodedFeature = try JSONDecoder().decode(TurfFeature.self, from: encodedData))
        XCTAssertNotNil(decodedFeature)
        
        XCTAssertEqual(decodedFeature, feature)
    }
    
    func testForeignMemberCoding(in object: TurfGeoJSONObject) throws {
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
        let modifiedObject = try decoder.decode(TurfGeoJSONObject.self, from: modifiedData)
        
        let roundTrippedData = try encoder.encode(modifiedObject)
        let roundTrippedJSON = try JSONSerialization.jsonObject(with: roundTrippedData, options: []) as? [String: Any?]
        
        let when = try XCTUnwrap(roundTrippedJSON?["when"] as? [String: Any?])
        XCTAssertEqual(when as NSDictionary, json["when"] as? NSDictionary)
    }
    
    func testForeignMemberCoding() throws {
        let nullIsland = TurfLocationCoordinate2D(latitude: 0, longitude: 0)
        try testForeignMemberCoding(in: .geometry(.point(TurfPoint(nullIsland))))
        try testForeignMemberCoding(in: .geometry(.lineString(TurfLineString([nullIsland, nullIsland]))))
        try testForeignMemberCoding(in: .geometry(.polygon(TurfPolygon([[nullIsland, nullIsland, nullIsland]]))))
        try testForeignMemberCoding(in: .geometry(.multiPoint(TurfMultiPoint([nullIsland, nullIsland, nullIsland]))))
        try testForeignMemberCoding(in: .geometry(.multiLineString(TurfMultiLineString([[nullIsland, nullIsland, nullIsland]]))))
        try testForeignMemberCoding(in: .geometry(.multiPolygon(TurfMultiPolygon([[[nullIsland, nullIsland, nullIsland]]]))))
        try testForeignMemberCoding(in: .geometry(.geometryCollection(TurfGeometryCollection(geometries: []))))
        try testForeignMemberCoding(in: .feature(.init(geometry: nil)))
        try testForeignMemberCoding(in: .featureCollection(.init(features: [])))
    }

    func testConvenienceAccessors() {
        let point = TurfPoint(TurfLocationCoordinate2D(latitude: 0, longitude: 1))
        XCTAssertEqual(TurfGeoJSONObject.geometry(point.geometry).geometry, point.geometry)
        XCTAssertEqual(TurfGeoJSONObject.geometry(point.geometry).feature, nil)
     
        let feature = TurfFeature(geometry: point)
        XCTAssertEqual(TurfGeoJSONObject.feature(feature).feature, feature)
        XCTAssertEqual(TurfGeoJSONObject.feature(feature).geometry, nil)
        
        let featureCollection = TurfFeatureCollection(features: [feature])
        XCTAssertEqual(TurfGeoJSONObject.featureCollection(featureCollection).featureCollection, featureCollection)   
        XCTAssertEqual(TurfGeoJSONObject.featureCollection(featureCollection).geometry, nil)
    }
}
