import XCTest
import Turf
import CoreLocation

class GeoJSONTests: XCTestCase {
    
    func testDeprecatedPoint() {
        let coordinate = CLLocationCoordinate2D(latitude: 10, longitude: 30)
        let geometry = Point(coordinate)
        let pointFeature = PointFeature(geometry)
        
        XCTAssertEqual(pointFeature.geometry.coordinates, coordinate)
    }
    
    func testPoint() {
        let coordinate = CLLocationCoordinate2D(latitude: 10, longitude: 30)
        let geometry = Geometry.Point(coordinates: coordinate)
        let pointFeature = Feature(geometry)
        
        XCTAssertEqual(pointFeature.geometry.value as! CLLocationCoordinate2D, coordinate)
    }
    
    func testDeprecatedLineString() {
        let coordinates = [CLLocationCoordinate2D(latitude: 10, longitude: 30),
                           CLLocationCoordinate2D(latitude: 30, longitude: 10),
                           CLLocationCoordinate2D(latitude: 40, longitude: 40)]
        
        let lineString = LineString(coordinates)
        let lineStringFeature = LineStringFeature(lineString)
        XCTAssertEqual(lineStringFeature.geometry.coordinates, coordinates)
    }
    
    func testLineString() {
        let coordinates = [CLLocationCoordinate2D(latitude: 10, longitude: 30),
                           CLLocationCoordinate2D(latitude: 30, longitude: 10),
                           CLLocationCoordinate2D(latitude: 40, longitude: 40)]
        
        let lineString = Geometry.LineString(coordinates: coordinates)
        let lineStringFeature = Feature(lineString)
        XCTAssertEqual(lineStringFeature.geometry.lineString, coordinates)
    }
    
    func testDeprecatedPolygon() {
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
        
        let polygon = Geometry.Polygon(coordinates: coordinates)
        let polygonFeature = Feature(polygon)
        XCTAssertEqual(polygonFeature.geometry.polygon, coordinates)
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
    
    func testDeprecatedMultiLineString() {
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
        
        let multiLineString = Geometry.MultiLineString(coordinates: coordinates)
        let multiLineStringFeature = Feature(multiLineString)
        XCTAssertEqual(multiLineStringFeature.geometry.multiLineString, coordinates)
    }
    
    func testDeprecatedMultiPolygon() {
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
        
        let multiPolygon = Geometry.MultiPolygon(coordinates: coordinates)
        let multiPolygonFeature = Feature(multiPolygon)
        XCTAssertEqual(multiPolygonFeature.geometry.multiPolygon, coordinates)
    }
}
