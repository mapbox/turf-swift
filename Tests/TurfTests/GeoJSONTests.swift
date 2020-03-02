import XCTest
import Turf
import CoreLocation

class GeoJSONTests: XCTestCase {
    
    func testPoint() {
        let coordinate = CLLocationCoordinate2D(latitude: 10, longitude: 30)
        let geometry = Geometry.Point(coordinates: Geometry.PointRepresentation(coordinate))
        let pointFeature = Feature(geometry)
        
        XCTAssertEqual((pointFeature.geometry.value as! Geometry.PointRepresentation).coordinates, coordinate)
    }
    
    func testLineString() {
        let coordinates = [CLLocationCoordinate2D(latitude: 10, longitude: 30),
                           CLLocationCoordinate2D(latitude: 30, longitude: 10),
                           CLLocationCoordinate2D(latitude: 40, longitude: 40)]
        
        let lineString = Geometry.LineString(coordinates: Geometry.LineStringRepresentation(coordinates))
        let lineStringFeature = Feature(lineString)
        XCTAssertEqual((lineStringFeature.geometry.value as! Geometry.LineStringRepresentation).coordinates, coordinates)
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
        
        let polygon = Geometry.Polygon(coordinates: Geometry.PolygonRepresentation(coordinates))
        let polygonFeature = Feature(polygon)
        XCTAssertEqual((polygonFeature.geometry.value as! Geometry.PolygonRepresentation).coordinates, coordinates)
    }
    
    func testMultiPoint() {
        let coordinates = [CLLocationCoordinate2D(latitude: 40, longitude: 10),
                           CLLocationCoordinate2D(latitude: 30, longitude: 40),
                           CLLocationCoordinate2D(latitude: 20, longitude: 20),
                           CLLocationCoordinate2D(latitude: 10, longitude: 30)]
        
        let multiPoint = Geometry.MultiPoint(coordinates: Geometry.MultiPointRepresentation(coordinates))
        let multiPointFeature = Feature(multiPoint)
        XCTAssertEqual((multiPointFeature.geometry.value as! Geometry.MultiPointRepresentation).coordinates, coordinates)
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
        
        let multiLineString = Geometry.MultiLineString(coordinates: Geometry.MultiLineStringRepresentation(coordinates))
        let multiLineStringFeature = Feature(multiLineString)
        XCTAssertEqual((multiLineStringFeature.geometry.value as! Geometry.MultiLineStringRepresentation).coordinates, coordinates)
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
        
        let multiPolygon = Geometry.MultiPolygon(coordinates: Geometry.MultiPolygonRepresentation(coordinates))
        let multiPolygonFeature = Feature(multiPolygon)
        XCTAssertEqual((multiPolygonFeature.geometry.value as! Geometry.MultiPolygonRepresentation).coordinates, coordinates)
    }
}
