import Turf
import XCTest

final class GeometryTests: XCTestCase {
    func testConvenienceAccessors() {
        let point = Point(LocationCoordinate2D(latitude: 1, longitude: 2))
        XCTAssertEqual(Geometry.point(point).point, point)
        XCTAssertEqual(Geometry.point(point).lineString, nil)

        let lineString = LineString([LocationCoordinate2D(latitude: 1, longitude: 2)])
        XCTAssertEqual(Geometry.lineString(lineString).lineString, lineString)
        XCTAssertEqual(Geometry.lineString(lineString).point, nil)

        let polygon = Polygon([[LocationCoordinate2D(latitude: 1, longitude: 2)]])
        XCTAssertEqual(Geometry.polygon(polygon).polygon, polygon)
        XCTAssertEqual(Geometry.polygon(polygon).point, nil)


        let multiPoint = MultiPoint([LocationCoordinate2D(latitude: 1, longitude: 2)])
        XCTAssertEqual(Geometry.multiPoint(multiPoint).multiPoint, multiPoint)
        XCTAssertEqual(Geometry.multiPoint(multiPoint).point, nil)

        let multiLineString = MultiLineString([[LocationCoordinate2D(latitude: 1, longitude: 2)]])
        XCTAssertEqual(Geometry.multiLineString(multiLineString).multiLineString, multiLineString)
        XCTAssertEqual(Geometry.multiLineString(multiLineString).point, nil)

        let multiPolygon = MultiPolygon([[[LocationCoordinate2D(latitude: 1, longitude: 2)]]])
        XCTAssertEqual(Geometry.multiPolygon(multiPolygon).multiPolygon, multiPolygon)
        XCTAssertEqual(Geometry.multiPolygon(multiPolygon).point, nil)

        let geometryCollection = GeometryCollection(geometries: [
            Geometry(point), Geometry(lineString)
        ])
        XCTAssertEqual(Geometry.geometryCollection(geometryCollection).geometryCollection, geometryCollection)
        XCTAssertEqual(Geometry.geometryCollection(geometryCollection).point, nil)
    }
}
