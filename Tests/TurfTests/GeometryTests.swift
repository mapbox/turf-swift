import Turf
import XCTest

final class GeometryTests: XCTestCase {
    func testConvenienceAccessors() {
        let point = TurfPoint(TurfLocationCoordinate2D(latitude: 1, longitude: 2))
        XCTAssertEqual(TurfGeometry.point(point).point, point)
        XCTAssertEqual(TurfGeometry.point(point).lineString, nil)

        let lineString = TurfLineString([TurfLocationCoordinate2D(latitude: 1, longitude: 2)])
        XCTAssertEqual(TurfGeometry.lineString(lineString).lineString, lineString)
        XCTAssertEqual(TurfGeometry.lineString(lineString).point, nil)

        let polygon = TurfPolygon([[TurfLocationCoordinate2D(latitude: 1, longitude: 2)]])
        XCTAssertEqual(TurfGeometry.polygon(polygon).polygon, polygon)
        XCTAssertEqual(TurfGeometry.polygon(polygon).point, nil)


        let multiPoint = TurfMultiPoint([TurfLocationCoordinate2D(latitude: 1, longitude: 2)])
        XCTAssertEqual(TurfGeometry.multiPoint(multiPoint).multiPoint, multiPoint)
        XCTAssertEqual(TurfGeometry.multiPoint(multiPoint).point, nil)

        let multiLineString = TurfMultiLineString([[TurfLocationCoordinate2D(latitude: 1, longitude: 2)]])
        XCTAssertEqual(TurfGeometry.multiLineString(multiLineString).multiLineString, multiLineString)
        XCTAssertEqual(TurfGeometry.multiLineString(multiLineString).point, nil)

        let multiPolygon = TurfMultiPolygon([[[TurfLocationCoordinate2D(latitude: 1, longitude: 2)]]])
        XCTAssertEqual(TurfGeometry.multiPolygon(multiPolygon).multiPolygon, multiPolygon)
        XCTAssertEqual(TurfGeometry.multiPolygon(multiPolygon).point, nil)

        let geometryCollection = TurfGeometryCollection(geometries: [
            TurfGeometry(point), TurfGeometry(lineString)
        ])
        XCTAssertEqual(TurfGeometry.geometryCollection(geometryCollection).geometryCollection, geometryCollection)
        XCTAssertEqual(TurfGeometry.geometryCollection(geometryCollection).point, nil)
    }
}
