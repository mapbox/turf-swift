import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf


class WKTTests: XCTestCase {
    
    func testEmpty() {
        var wktString = "GEOMETRYCOLLECTION EMPTY"
        
        var geometry = try? GeometryCollection(wkt: wktString)
        
        XCTAssertNil(geometry)
        
        
        wktString = "GEOMETRYCOLLECTION (POINT EMPTY)"
        
        geometry = try? GeometryCollection(wkt: wktString)
        
        XCTAssertNil(geometry)
        
        
        wktString = "GEOMETRYCOLLECTION (POINT EMPTY, POINT(1 2))"
        
        geometry = try? GeometryCollection(wkt: wktString)
        
        XCTAssertNotNil(geometry)
        XCTAssertEqual(geometry?.geometries.count, 1)
    }
    
    func testPoint() {
        let wktString = "POINT(123.53 -12.12)"
        
        let point = try? Point(wkt: wktString)
        let geometry = try? Geometry(wkt: wktString)
        
        XCTAssertNotNil(point)
        XCTAssertNotNil(geometry)
        XCTAssertEqual(point?.coordinates, .init(latitude: -12.12, longitude: 123.53))
        
        guard case let .point(geometryPoint) = geometry else { XCTFail(); return }
        
        XCTAssertEqual(point, geometryPoint)
        
        let serializedString = point?.wkt
        
        XCTAssertEqual(serializedString, wktString)
    }
    
    func testMultiPoint() {
        let wktString = "MULTIPOINT(123.53 -12.12,10.0 20.0,-11.12 13.14)"
        let wktString2 = "MULTIPOINT ((123.53 -12.12), ( 10 20 ), (-11.12 13.14))"
        
        let multiPoint = try? MultiPoint(wkt: wktString)
        let multiPoint2 = try? MultiPoint(wkt: wktString2)
        let geometry = try? Geometry(wkt: wktString)
        
        XCTAssertNotNil(multiPoint)
        XCTAssertNotNil(multiPoint2)
        XCTAssertNotNil(geometry)
        XCTAssertEqual(multiPoint?.coordinates, [.init(latitude: -12.12, longitude: 123.53),
                                                 .init(latitude: 20, longitude: 10),
                                                 .init(latitude: 13.14, longitude: -11.12)])
        XCTAssertEqual(multiPoint, multiPoint2)
        
        guard case let .multiPoint(geometryMultiPoint) = geometry else { XCTFail(); return }
        
        XCTAssertEqual(multiPoint, geometryMultiPoint)
        
        let serializedString = multiPoint?.wkt
        
        XCTAssertEqual(serializedString, wktString)
    }
    
    func testLineString() {
        let wktString = "LINESTRING(123.53 -12.12,10.0 20.0,-11.12 13.14)"
        
        let lineString = try? LineString(wkt: wktString)
        let geometry = try? Geometry(wkt: wktString)
        
        XCTAssertNotNil(lineString)
        XCTAssertNotNil(geometry)
        XCTAssertEqual(lineString?.coordinates, [.init(latitude: -12.12, longitude: 123.53),
                                                 .init(latitude: 20, longitude: 10),
                                                 .init(latitude: 13.14, longitude: -11.12)])
        
        guard case let .lineString(geometryLineString) = geometry else { XCTFail(); return }
        
        XCTAssertEqual(lineString, geometryLineString)
        
        let serializedString = lineString?.wkt
        
        XCTAssertEqual(serializedString, wktString)
    }
    
    func testMultiLineString() {
        let wktString = "MULTILINESTRING((123.53 -12.12,10.0 20.0),(-11.12 13.14))"
        
        let multiLineString = try? MultiLineString(wkt: wktString)
        let geometry = try? Geometry(wkt: wktString)
        
        XCTAssertNotNil(multiLineString)
        XCTAssertNotNil(geometry)
        XCTAssertEqual(multiLineString?.coordinates, [[.init(latitude: -12.12, longitude: 123.53),
                                                       .init(latitude: 20, longitude: 10)],
                                                      [.init(latitude: 13.14, longitude: -11.12)]])
        
        guard case let .multiLineString(geometryMultiLineString) = geometry else { XCTFail(); return }
        
        XCTAssertEqual(multiLineString, geometryMultiLineString)
        
        let serializedString = multiLineString?.wkt
        
        XCTAssertEqual(serializedString, wktString)
    }
    
    func testPolygon() {
        let wktString = "POLYGON((123.53 -12.12,10.0 20.0),(-11.12 13.14))"
        
        let polygon = try? Polygon(wkt: wktString)
        let geometry = try? Geometry(wkt: wktString)
        
        XCTAssertNotNil(polygon)
        XCTAssertNotNil(geometry)
        XCTAssertEqual(polygon?.coordinates, [
            [
                .init(latitude: -12.12, longitude: 123.53),
                .init(latitude: 20, longitude: 10)
            ],
            [
                .init(latitude: 13.14, longitude: -11.12)
            ]
        ])
        
        guard case let .polygon(geometryPolygon) = geometry else { XCTFail(); return }
        
        XCTAssertEqual(polygon, geometryPolygon)
        
        let serializedString = polygon?.wkt
        
        XCTAssertEqual(serializedString, wktString)
    }
    
    func testMultiPolygon() {
        let wktString = "MULTIPOLYGON(((123.53 -12.12,10.0 20.0),(-11.12 13.14)),((-15.16 -17.18)))"
        
        let multiPolygon = try? MultiPolygon(wkt: wktString)
        let geometry = try? Geometry(wkt: wktString)
        
        XCTAssertNotNil(multiPolygon)
        XCTAssertNotNil(geometry)
        XCTAssertEqual(multiPolygon?.coordinates, [
            [
                [.init(latitude: -12.12, longitude: 123.53),
                 .init(latitude: 20, longitude: 10)],
                [
                    .init(latitude: 13.14, longitude: -11.12)
                ]
            ],
            [
                [
                    .init(latitude: -17.18, longitude: -15.16)
                ]
            ]
        ])
        
        guard case let .multiPolygon(geometryMultiPolygon) = geometry else { XCTFail(); return }
        
        XCTAssertEqual(multiPolygon, geometryMultiPolygon)
        
        let serializedString = multiPolygon?.wkt
        
        XCTAssertEqual(serializedString, wktString)
    }
    
    func assertGeometryTypesEqual(_ lhs: Geometry?, _ rhs: Geometry?) {
        switch lhs {
        case .point(_):
            guard case .point(_) = rhs else { XCTFail(); return }
            return
        case .lineString(_):
            guard case .lineString(_) = rhs else { XCTFail(); return }
            return
        case .polygon(_):
            guard case .polygon(_) = rhs else { XCTFail(); return }
            return
        case .multiPoint(_):
            guard case .multiPoint(_) = rhs else { XCTFail(); return }
            return
        case .multiLineString(_):
            guard case .multiLineString(_) = rhs else { XCTFail(); return }
            return
        case .multiPolygon(_):
            guard case .multiPolygon(_) = rhs else { XCTFail(); return }
            return
        case .geometryCollection(_):
            guard case .geometryCollection(_) = rhs else { XCTFail(); return }
            return
        case .none:
            XCTAssertNil(rhs)
            return
        case .some(_):
            XCTFail("Unknown geometry type coded.")
        }
    }
    
    func testGeometryCollection() {
        let wktString = """
GEOMETRYCOLLECTION(
POINT(123.53 -12.12),
MULTIPOINT(123.53 -12.12,10.0 20.0,-11.12 13.14),
LINESTRING(123.53 -12.12,10.0 20.0,-11.12 13.14),
MULTILINESTRING((123.53 -12.12,10.0 20.0),(-11.12 13.14)),
POLYGON((123.53 -12.12,10.0 20.0),(-11.12 13.14)),
MULTIPOLYGON(((123.53 -12.12,10.0 20.0),(-11.12 13.14)),((-15.16 -17.18))))
"""
        
        let geometryCollection = try? GeometryCollection(wkt: wktString)
        
        XCTAssertNotNil(geometryCollection)
        XCTAssertEqual(geometryCollection?.geometries.count, 6)
        
        assertGeometryTypesEqual(geometryCollection?.geometries[0], .point(Point(LocationCoordinate2D(latitude: 0, longitude: 0))))
        assertGeometryTypesEqual(geometryCollection?.geometries[1], .multiPoint(MultiPoint([])))
        assertGeometryTypesEqual(geometryCollection?.geometries[2], .lineString(LineString([])))
        assertGeometryTypesEqual(geometryCollection?.geometries[3], .multiLineString(MultiLineString([])))
        assertGeometryTypesEqual(geometryCollection?.geometries[4], .polygon(Polygon([])))
        assertGeometryTypesEqual(geometryCollection?.geometries[5], .multiPolygon(MultiPolygon([Polygon([])])))
        
        let serializedString = geometryCollection?.wkt
        
        XCTAssertEqual(serializedString, wktString.replacingOccurrences(of: "\n", with: ""))
    }
    
    func testUnrecognizedToken() {
        let wktString = "UNRECOGNIZEDGEOMETRY (1 2)"
        do {
            _ = try Geometry(wkt: wktString)
            
            XCTFail("Unknown token not detected.")
        }
        catch {}
    }
    
    func testIncorrectCoordinatesCount() {
        let  wktString = "POINT (1 2 3)"
        do {
            _ = try Geometry(wkt: wktString)
            
            XCTFail("Incorrect coordinates count not detected.")
        } catch {}
    }
     
    func testIncorrectCoordinateTypes() {
        let wktString = "POINT (here there)"
        do {
            _ = try Geometry(wkt: wktString)
            
            XCTFail("Incorrect coordinates types not detected.")
        } catch {}
    }
     
    func testEmptyInput() { // empty output
        let wktString = ""
        do {
            _ = try Geometry(wkt: wktString)
            
            XCTFail("Empty input not detected.")
        } catch {}
    }
     
    func testInsufficientNesting() {
        let wktString = "MULTIPOLYGON((123.53 -12.12,10.0 20.0),(-11.12 13.14)),((-15.16 -17.18))"
        do {
            _ = try Geometry(wkt: wktString)
            
            XCTFail("Insufficient nesting not detected.")
        } catch {}
    }
     
    func testExcessiveNesting() {
        let wktString = "MULTIPOLYGON((((123.53 -12.12,10.0 20.0),(-11.12 13.14)),((-15.16 -17.18)))"
        do {
            _ = try Geometry(wkt: wktString)
            
            XCTFail("Excessive nesting not detected.")
        } catch {}
    }
}
