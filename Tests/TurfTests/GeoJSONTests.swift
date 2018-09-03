import XCTest
import Turf
import CoreLocation

class GeoJSONTests: XCTestCase {
    
    func testPoint() {
        let coordinate = CLLocationCoordinate2D(latitude: 10, longitude: 30)
        let point = Point(coordinate)
        let pointFeature = PointFeature(point)
        XCTAssertEqual(pointFeature.geometry.coordinates, coordinate)
    }
    
    func testLineString() {
        let coordinates = [CLLocationCoordinate2D(latitude: 10, longitude: 30),
                           CLLocationCoordinate2D(latitude: 30, longitude: 10),
                           CLLocationCoordinate2D(latitude: 40, longitude: 40)]
        
        let lineString = LineString(coordinates)
        let lineStringFeature = LineStringFeature(lineString)
        XCTAssertEqual(lineStringFeature.geometry.coordinates, coordinates)
    }
    
    func testPolygon() {
        let coordinates = [
            [
                CLLocationCoordinate2D(latitude: 10, longitude: 30),
                CLLocationCoordinate2D(latitude: 40, longitude: 40),
                CLLocationCoordinate2D(latitude: 40, longitude: 20),
                CLLocationCoordinate2D(latitude: 20, longitude: 10),
                CLLocationCoordinate2D(latitude: 10, longitude: 30)
            ],
            [
                CLLocationCoordinate2D(latitude: 30, longitude: 20),
                CLLocationCoordinate2D(latitude: 35, longitude: 35),
                CLLocationCoordinate2D(latitude: 20, longitude: 30),
                CLLocationCoordinate2D(latitude: 30, longitude: 20)
            ]
        ]
        
        let polygon = Polygon(coordinates)
        let polygonFeature = PolygonFeature(polygon)
        XCTAssertEqual(polygonFeature.geometry.coordinates, coordinates)
    }
    
    func testMultiPoint() {
        let coordinates = [CLLocationCoordinate2D(latitude: 40, longitude: 10),
                           CLLocationCoordinate2D(latitude: 30, longitude: 40),
                           CLLocationCoordinate2D(latitude: 20, longitude: 20),
                           CLLocationCoordinate2D(latitude: 10, longitude: 30)]
        
        let multiPoint = MultiPoint(coordinates)
        let multiPointFeature = MultiPointFeature(multiPoint)
        XCTAssertEqual(multiPointFeature.geometry.coordinates, coordinates)
    }
    
    func testMultiLineString() {
        let coordinates = [
            [
                CLLocationCoordinate2D(latitude: 10, longitude: 10),
                CLLocationCoordinate2D(latitude: 20, longitude: 20),
                CLLocationCoordinate2D(latitude: 40, longitude: 10)
            ],
            [
                CLLocationCoordinate2D(latitude: 40, longitude: 40),
                CLLocationCoordinate2D(latitude: 30, longitude: 30),
                CLLocationCoordinate2D(latitude: 20, longitude: 40),
                CLLocationCoordinate2D(latitude: 10, longitude: 30)
            ]
        ]
        
        let multiLineString = MultiLineString(coordinates)
        let multiLineStringFeature = MultiLineStringFeature(multiLineString)
        XCTAssertEqual(multiLineStringFeature.geometry.coordinates, coordinates)
    }
    
    func testMultiPolygon() {
        let coordinates = [
            [
                [
                    CLLocationCoordinate2D(latitude: 40, longitude: 40),
                    CLLocationCoordinate2D(latitude: 45, longitude: 20),
                    CLLocationCoordinate2D(latitude: 45, longitude: 30),
                    CLLocationCoordinate2D(latitude: 40, longitude: 40)
                ]
            ],
            [
                [
                    CLLocationCoordinate2D(latitude: 35, longitude: 20),
                    CLLocationCoordinate2D(latitude: 30, longitude: 10),
                    CLLocationCoordinate2D(latitude: 10, longitude: 10),
                    CLLocationCoordinate2D(latitude: 5, longitude: 30),
                    CLLocationCoordinate2D(latitude: 20, longitude: 45),
                    CLLocationCoordinate2D(latitude: 35, longitude: 20)
                ],
                [
                    CLLocationCoordinate2D(latitude: 20, longitude: 30),
                    CLLocationCoordinate2D(latitude: 15, longitude: 20),
                    CLLocationCoordinate2D(latitude: 25, longitude: 25),
                    CLLocationCoordinate2D(latitude: 20, longitude: 30)
                ]
            ]
        ]
        
        let multiPolygon = MultiPolygon(coordinates)
        let multiPolygonFeature = MultiPolygonFeature(multiPolygon)
        XCTAssertEqual(multiPolygonFeature.geometry.coordinates, coordinates)
    }
}
