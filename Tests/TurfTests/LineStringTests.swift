import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf

class LineStringTests: XCTestCase {
        
    func testLineStringFeature() {
        let data = try! Fixture.geojsonData(from: "simple-line")!
        let geojson = try! JSONDecoder().decode(TurfFeature.self, from: data)
        
        guard case let .lineString(lineStringCoordinates) = geojson.geometry else {
            XCTFail()
            return
        }
        
        XCTAssert(lineStringCoordinates.coordinates.count == 6)
        let first = TurfLocationCoordinate2D(latitude: 0, longitude: 0)
        let last = TurfLocationCoordinate2D(latitude: 10, longitude: 0)
        XCTAssert(lineStringCoordinates.coordinates.first == first)
        XCTAssert(lineStringCoordinates.coordinates.last == last)
        if case let .string(string) = geojson.identifier {
            XCTAssertEqual(string, "1")
        } else {
            XCTFail()
        }
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! JSONDecoder().decode(TurfFeature.self, from: encodedData)
        guard case let .lineString(decodedLineStringCoordinates) = decoded.geometry else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(lineStringCoordinates, decodedLineStringCoordinates)
        if case let .string(string) = geojson.identifier,
           case let .string(decodedString) = decoded.identifier {
            XCTAssertEqual(string, decodedString)
        } else {
            XCTFail()
        }
    }
    
    func testClosestCoordinate() {
        // Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-point-on-line/test/test.js#L117-L118
        
        // turf-point-on-line - first point
        var line = [
            TurfLocationCoordinate2D(latitude: 37.72003306385638, longitude: -122.45717525482178),
            TurfLocationCoordinate2D(latitude: 37.718242366859215, longitude: -122.45717525482178),
        ]
        let point = TurfLocationCoordinate2D(latitude: 37.72003306385638, longitude: -122.45717525482178)
        var snapped = TurfLineString(line).closestCoordinate(to: point)
        XCTAssertEqual(point, snapped?.coordinate, "point on start should not move")
        
        // turf-point-on-line - points behind first point
        line = [
            TurfLocationCoordinate2D(latitude: 37.72003306385638, longitude: -122.45717525482178),
            TurfLocationCoordinate2D(latitude: 37.718242366859215, longitude: -122.45717525482178),
        ]
        var points = [
            TurfLocationCoordinate2D(latitude: 37.72009306385638, longitude: -122.45717525482178),
            TurfLocationCoordinate2D(latitude: 37.82009306385638, longitude: -122.45717525482178),
            TurfLocationCoordinate2D(latitude: 37.72009306385638, longitude: -122.45716525482178),
            TurfLocationCoordinate2D(latitude: 37.72009306385638, longitude: -122.45516525482178),
        ]
        for point in points {
            snapped = TurfLineString(line).closestCoordinate(to: point)
            XCTAssertEqual(line.first, snapped?.coordinate, "point behind start should move to first vertex")
        }
        
        // turf-point-on-line - points in front of last point
        line = [
            TurfLocationCoordinate2D(latitude: 37.72125936929241, longitude: -122.45616137981413),
            TurfLocationCoordinate2D(latitude: 37.72003306385638, longitude: -122.45717525482178),
            TurfLocationCoordinate2D(latitude: 37.718242366859215, longitude: -122.45717525482178),
        ]
        points = [
            TurfLocationCoordinate2D(latitude: 37.71814052497085, longitude: -122.45696067810057),
            TurfLocationCoordinate2D(latitude: 37.71813203814049, longitude: -122.4573630094528),
            TurfLocationCoordinate2D(latitude: 37.71797927502795, longitude: -122.45730936527252),
            TurfLocationCoordinate2D(latitude: 37.71704571582896, longitude: -122.45718061923981),
        ]
        for point in points {
            snapped = TurfLineString(line).closestCoordinate(to: point)
            XCTAssertEqual(line.last, snapped?.coordinate, "point behind start should move to last vertex")
        }
        
        // turf-point-on-line - points on joints
        let lines = [
            [
                TurfLocationCoordinate2D(latitude: 37.72125936929241, longitude: -122.45616137981413),
                TurfLocationCoordinate2D(latitude: 37.72003306385638, longitude: -122.45717525482178),
                TurfLocationCoordinate2D(latitude: 37.718242366859215, longitude: -122.45717525482178)
            ],
            [
                TurfLocationCoordinate2D(latitude: 31.728167146023935, longitude: 26.279296875),
                TurfLocationCoordinate2D(latitude: 32.69486597787505, longitude: 21.796875),
                TurfLocationCoordinate2D(latitude: 29.99300228455108, longitude: 18.80859375),
                TurfLocationCoordinate2D(latitude: 33.137551192346145, longitude: 12.919921874999998),
                TurfLocationCoordinate2D(latitude: 35.60371874069731, longitude: 10.1953125),
                TurfLocationCoordinate2D(latitude: 36.527294814546245, longitude: 4.921875),
                TurfLocationCoordinate2D(latitude: 36.527294814546245, longitude: -1.669921875),
                TurfLocationCoordinate2D(latitude: 34.74161249883172, longitude: -5.44921875),
                TurfLocationCoordinate2D(latitude: 32.99023555965106, longitude: -8.7890625)
            ],
            [
                TurfLocationCoordinate2D(latitude: 51.52204224896724, longitude: -0.10919809341430663),
                TurfLocationCoordinate2D(latitude: 51.521942114455435, longitude: -0.10923027992248535),
                TurfLocationCoordinate2D(latitude: 51.52186200668747, longitude: -0.10916590690612793),
                TurfLocationCoordinate2D(latitude: 51.52177522311313, longitude: -0.10904788970947266),
                TurfLocationCoordinate2D(latitude: 51.521601655468345, longitude: -0.10886549949645996),
                TurfLocationCoordinate2D(latitude: 51.52138135712038, longitude: -0.10874748229980469),
                TurfLocationCoordinate2D(latitude: 51.5206870765674, longitude: -0.10855436325073242),
                TurfLocationCoordinate2D(latitude: 51.52027984939518, longitude: -0.10843634605407713),
                TurfLocationCoordinate2D(latitude: 51.519952729849024, longitude: -0.10839343070983887),
                TurfLocationCoordinate2D(latitude: 51.51957887606202, longitude: -0.10817885398864746),
                TurfLocationCoordinate2D(latitude: 51.51928513164789, longitude: -0.10814666748046874),
                TurfLocationCoordinate2D(latitude: 51.518624199789016, longitude: -0.10789990425109863),
                TurfLocationCoordinate2D(latitude: 51.51778299991493, longitude: -0.10759949684143065)
            ]
        ];
        for line in lines {
            for point in line {
                snapped = TurfLineString(line).closestCoordinate(to: point)
                XCTAssertEqual(point, snapped?.coordinate, "point on joint should stay in place")
            }
        }
        
        // turf-point-on-line - points on top of line
        line = [
            TurfLocationCoordinate2D(latitude: 51.52204224896724, longitude: -0.10919809341430663),
            TurfLocationCoordinate2D(latitude: 51.521942114455435, longitude: -0.10923027992248535),
            TurfLocationCoordinate2D(latitude: 51.52186200668747, longitude: -0.10916590690612793),
            TurfLocationCoordinate2D(latitude: 51.52177522311313, longitude: -0.10904788970947266),
            TurfLocationCoordinate2D(latitude: 51.521601655468345, longitude: -0.10886549949645996),
            TurfLocationCoordinate2D(latitude: 51.52138135712038, longitude: -0.10874748229980469),
            TurfLocationCoordinate2D(latitude: 51.5206870765674, longitude: -0.10855436325073242),
            TurfLocationCoordinate2D(latitude: 51.52027984939518, longitude: -0.10843634605407713),
            TurfLocationCoordinate2D(latitude: 51.519952729849024, longitude: -0.10839343070983887),
            TurfLocationCoordinate2D(latitude: 51.51957887606202, longitude: -0.10817885398864746),
            TurfLocationCoordinate2D(latitude: 51.51928513164789, longitude: -0.10814666748046874),
            TurfLocationCoordinate2D(latitude: 51.518624199789016, longitude: -0.10789990425109863),
            TurfLocationCoordinate2D(latitude: 51.51778299991493, longitude: -0.10759949684143065),
        ]
        let dist = TurfLineString(line).distance()!
        let increment = dist / metersPerMile / 10
        for i in 0..<10 {
            let point = TurfLineString(line).coordinateFromStart(distance: increment * Double(i) * metersPerMile)
            XCTAssertNotNil(point)
            if let point = point {
                let snapped = TurfLineString(line).closestCoordinate(to: point)
                XCTAssertNotNil(snapped)
                if let snapped = snapped {
                    let shift = point.distance(to: snapped.coordinate)
                    XCTAssertLessThan(shift / metersPerMile, 0.000001, "point should not shift far")
                }
            }
        }
        
        // turf-point-on-line - point along line
        line = [
            TurfLocationCoordinate2D(latitude: 37.72003306385638, longitude: -122.45717525482178),
            TurfLocationCoordinate2D(latitude: 37.718242366859215, longitude: -122.45717525482178),
        ]
        let pointAlong = TurfLineString(line).coordinateFromStart(distance: 0.019 * metersPerMile)
        XCTAssertNotNil(pointAlong)
        if let point = pointAlong {
            let snapped = TurfLineString(line).closestCoordinate(to: point)
            XCTAssertNotNil(snapped)
            if let snapped = snapped {
                let shift = point.distance(to: snapped.coordinate)
                XCTAssertLessThan(shift / metersPerMile, 0.00001, "point should not shift far")
            }
        }
        
        // turf-point-on-line - points on sides of lines
        line = [
            TurfLocationCoordinate2D(latitude: 37.72125936929241, longitude: -122.45616137981413),
            TurfLocationCoordinate2D(latitude: 37.718242366859215, longitude: -122.45717525482178),
        ]
        points = [
            TurfLocationCoordinate2D(latitude: 37.71881098149625, longitude: -122.45702505111694),
            TurfLocationCoordinate2D(latitude: 37.719235317933844, longitude: -122.45733618736267),
            TurfLocationCoordinate2D(latitude: 37.72027068864082, longitude: -122.45686411857605),
            TurfLocationCoordinate2D(latitude: 37.72063561093274, longitude: -122.45652079582213),
        ]
        for point in points {
            let snapped = TurfLineString(line).closestCoordinate(to: point)
            XCTAssertNotNil(snapped)
            if let snapped = snapped {
                XCTAssertNotEqual(snapped.coordinate, points.first, "point should not snap to first vertex")
                XCTAssertNotEqual(snapped.coordinate, points.last, "point should not snap to last vertex")
            }
        }
        
        let lineString = TurfLineString([
            TurfLocationCoordinate2D(latitude: 49.120689999999996, longitude: -122.65401),
            TurfLocationCoordinate2D(latitude: 49.120619999999995, longitude: -122.65352),
            TurfLocationCoordinate2D(latitude: 49.120189999999994, longitude: -122.65237),
        ])
        
        // https://github.com/mapbox/turf-swift/issues/27
        let short = TurfLocationCoordinate2D(latitude: 49.120403526377203, longitude: -122.6529443631224)
        let long = TurfLocationCoordinate2D(latitude: 49.120405, longitude: -122.652945)
        XCTAssertLessThan(short.distance(to: long), 1)
        
        let closestToShort = lineString.closestCoordinate(to: short)
        XCTAssertNotNil(closestToShort)
        XCTAssertEqual(closestToShort?.coordinate.latitude ?? 0, short.latitude, accuracy: 1e-5)
        XCTAssertEqual(closestToShort?.coordinate.longitude ?? 0, short.longitude, accuracy: 1e-5)
        XCTAssertEqual(closestToShort?.index, 1, "Coordinate closer to earlier vertex is indexed with earlier vertex")
        
        let closestToLong = lineString.closestCoordinate(to: long)
        XCTAssertNotNil(closestToLong)
        XCTAssertEqual(closestToLong?.coordinate.latitude ?? 0, long.latitude, accuracy: 1e-5)
        XCTAssertEqual(closestToLong?.coordinate.longitude ?? 0, long.longitude, accuracy: 1e-5)
        XCTAssertEqual(closestToLong?.index, 1, "Coordinate closer to later vertex is indexed with earlier vertex")
        
        // turf-point-on-line - check dist and index
        let indexLineString = TurfLineString([
            [0.0, 0.0],
            [1.0, 1.0],
            [2.0, 2.0],
            [3.0, 3.0],
            [4.0, 4.0],
            [5.0, 5.0]
        ].map {
            TurfLocationCoordinate2D(latitude: $0.first!, longitude: $0.last!)
        })

        let pointToSnap = TurfLocationCoordinate2D(latitude: 2.0, longitude: 3.0)
        let snappedIndex = indexLineString.closestCoordinate(to: pointToSnap)

        XCTAssertEqual(snappedIndex?.index, 2)
        XCTAssertEqual(snappedIndex!.coordinate.latitude, 2.50, accuracy: 1e-3)
        XCTAssertEqual(snappedIndex!.coordinate.longitude, 2.50, accuracy: 1e-3)
        XCTAssertGreaterThan(Double(snappedIndex!.distance),
                             indexLineString.coordinates[2].distance(to: indexLineString.coordinates.first!))
        XCTAssertLessThan(Double(snappedIndex!.distance),
                          indexLineString.coordinates[3].distance(to: indexLineString.coordinates.first!))
    }
    
    func testCoordinateFromStart() {
        // Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-along/test.js
        
        let json = Fixture.JSONFromGEOJSONFileNamed(name: "dc-line")
        let line = ((json["geometry"] as! [String: Any])["coordinates"] as! [[Double]]).map { TurfLocationCoordinate2D(latitude: $0[0], longitude: $0[1]) }
        
        let pointsAlong = [
            TurfLineString(line).coordinateFromStart(distance: 1 * metersPerMile),
            TurfLineString(line).coordinateFromStart(distance: 1.2 * metersPerMile),
            TurfLineString(line).coordinateFromStart(distance: 1.4 * metersPerMile),
            TurfLineString(line).coordinateFromStart(distance: 1.6 * metersPerMile),
            TurfLineString(line).coordinateFromStart(distance: 1.8 * metersPerMile),
            TurfLineString(line).coordinateFromStart(distance: 2 * metersPerMile),
            TurfLineString(line).coordinateFromStart(distance: 100 * metersPerMile),
            TurfLineString(line).coordinateFromStart(distance: 0 * metersPerMile)
        ]
        for point in pointsAlong {
            XCTAssertNotNil(point)
        }
        XCTAssertEqual(pointsAlong.count, 8)
        XCTAssertEqual(pointsAlong.last!, line.first!)
    }
    
    func testDistance() {
        let point1 = TurfLocationCoordinate2D(latitude: 39.984, longitude: -75.343)
        let point2 = TurfLocationCoordinate2D(latitude: 39.123, longitude: -75.534)
        let line = [point1, point2]
        
        // https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-distance/test.js
        let a = TurfLineString(line).distance()!
        XCTAssertEqual(a, 97_159.57803131901, accuracy: 1)
        
        let point3 = TurfLocationCoordinate2D(latitude: 20, longitude: 20)
        let point4 = TurfLocationCoordinate2D(latitude: 40, longitude: 40)
        let line2 = [point3, point4]
        
        let c = TurfLineString(line2).distance()!
        XCTAssertEqual(c, 2_928_304, accuracy: 1)
        
        // Adapted from: https://gist.github.com/bsudekum/2604b72ae42b6f88aa55398b2ff0dc22
        let d = TurfLineString(line2).distance(from: TurfLocationCoordinate2D(latitude: 30, longitude: 30), to: TurfLocationCoordinate2D(latitude: 40, longitude: 40))!
        XCTAssertEqual(d, 1_546_971, accuracy: 1)
        
        // https://github.com/mapbox/turf-swift/issues/27
        let short = TurfLocationCoordinate2D(latitude: 49.120403526377203, longitude: -122.6529443631224)
        let long = TurfLocationCoordinate2D(latitude: 49.120405, longitude: -122.652945)
        XCTAssertLessThan(short.distance(to: long), 1)
        
        XCTAssertEqual(0, TurfLineString([
            TurfLocationCoordinate2D(latitude: 49.120689999999996, longitude: -122.65401),
            TurfLocationCoordinate2D(latitude: 49.120619999999995, longitude: -122.65352),
        ]).distance(from: short, to: long), "Distance between two coordinates past the end of the line string should be 0")
        XCTAssertEqual(short.distance(to: long), TurfLineString([
            TurfLocationCoordinate2D(latitude: 49.120689999999996, longitude: -122.65401),
            TurfLocationCoordinate2D(latitude: 49.120619999999995, longitude: -122.65352),
            TurfLocationCoordinate2D(latitude: 49.120189999999994, longitude: -122.65237),
        ]).distance(from: short, to: long)!, accuracy: 0.1, "Distance between two coordinates between the same vertices should be roughly the same as the distance between those two coordinates")
    }
    
    func testSliced() {
        // https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-line-slice/test.js
        
        // turf-line-slice -- line1
        let line1 = [
            TurfLocationCoordinate2D(latitude: 22.466878364528448, longitude: -97.88131713867188),
            TurfLocationCoordinate2D(latitude: 22.175960091218524, longitude: -97.82089233398438),
            TurfLocationCoordinate2D(latitude: 21.8704201873689, longitude: -97.6190185546875),
        ]
        var start = TurfLocationCoordinate2D(latitude: 22.254624939561698, longitude: -97.79617309570312)
        var stop = TurfLocationCoordinate2D(latitude: 22.057641623615734, longitude: -97.72750854492188)
        var sliced = TurfLineString(line1).sliced(from: start, to: stop)
        var slicedCoordinates = sliced?.coordinates
        let line1Out = [
            TurfLocationCoordinate2D(latitude: 22.247393614241204, longitude: -97.83572934173804),
            TurfLocationCoordinate2D(latitude: 22.175960091218524, longitude: -97.82089233398438),
            TurfLocationCoordinate2D(latitude: 22.051208078134735, longitude: -97.7384672234217),
        ]
        XCTAssertEqual(line1Out.first!.latitude, 22.247393614241204, accuracy: 0.001)
        XCTAssertEqual(line1Out.first!.longitude, -97.83572934173804, accuracy: 0.001)
        
        XCTAssertEqual(line1Out[1], line1[1])
        
        XCTAssertEqual(line1Out.last!.latitude, 22.051208078134735, accuracy: 0.001)
        XCTAssertEqual(line1Out.last!.longitude, -97.7384672234217, accuracy: 0.001)
        XCTAssertEqual(slicedCoordinates?.count, 3)
        
        // turf-line-slice -- vertical
        let vertical = [
            TurfLocationCoordinate2D(latitude: 38.70582415504791, longitude: -121.25447809696198),
            TurfLocationCoordinate2D(latitude: 38.709767459877554, longitude: -121.25449419021606),
        ]
        start = TurfLocationCoordinate2D(latitude: 38.70582415504791, longitude: -121.25447809696198)
        stop = TurfLocationCoordinate2D(latitude: 38.70634324369764, longitude: -121.25447809696198)
        sliced = TurfLineString(vertical).sliced(from: start, to: stop)
        slicedCoordinates = sliced?.coordinates
        XCTAssertEqual(slicedCoordinates?.count, 2, "no duplicated coords")
        XCTAssertNotEqual(slicedCoordinates?.first, slicedCoordinates?.last, "vertical slice should not collapse to first coordinate")
        
        sliced = TurfLineString(vertical).sliced(from: vertical[0], to: vertical[1])
        slicedCoordinates = sliced?.coordinates
        XCTAssertEqual(slicedCoordinates?.count, 2, "no duplicated coords")
        XCTAssertNotEqual(slicedCoordinates?.first, slicedCoordinates?.last, "vertical slice should not collapse to first coordinate")
        
        sliced = TurfLineString(vertical).sliced()
        slicedCoordinates = sliced?.coordinates
        XCTAssertEqual(slicedCoordinates?.count, 2, "no duplicated coords")
        XCTAssertNotEqual(slicedCoordinates?.first, slicedCoordinates?.last, "vertical slice should not collapse to first coordinate")
    }
    
    func testTrimmed() {
        // https://github.com/Turfjs/turf/blob/5375941072b90d489389db22b43bfe809d5e451e/packages/turf-line-slice-along/test.js
        
        // turf-line-slice-along -- line1
        let coordinates = [
            [113.99414062499999, 22.350075806124867],
            [116.76269531249999, 23.241346102386135],
            [117.7734375, 24.367113562651276],
            [118.828125, 25.20494115356912],
            [119.794921875, 26.78484736105119],
            [120.80566406250001, 28.110748760633534],
            [121.59667968749999, 29.49698759653577],
            [121.59667968749999, 31.12819929911196],
            [120.84960937499999, 32.84267363195431],
            [119.83886718750001, 34.125447565116126],
            [118.69628906249999, 35.31736632923788],
            [121.4208984375, 36.80928470205937],
            [122.82714843749999, 37.37015718405753]
          ]
        let line1 = TurfLineString(coordinates.map{
            TurfLocationCoordinate2D(latitude: $0.last!, longitude: $0.first!)
        })
        
        var startDistance = 804672.0
        var stopDistance = 1207008.0
        
        var startPoint = line1.coordinateFromStart(distance: startDistance)
        var endPoint = line1.coordinateFromStart(distance: stopDistance)
        var sliced = line1.trimmed(from: startDistance, to: stopDistance)
        XCTAssertNotNil(sliced, "should return valid lineString")
        XCTAssertEqual(sliced!.coordinates.first!, startPoint)
        XCTAssertEqual(sliced!.coordinates.last!, endPoint)
        
        stopDistance = 2414016.0
        endPoint = line1.coordinateFromStart(distance: stopDistance)
        sliced = line1.trimmed(from: startDistance, to: stopDistance)
        XCTAssertNotNil(sliced, "should return valid lineString")
        XCTAssertEqual(sliced!.coordinates.first!, startPoint)
        XCTAssertEqual(sliced!.coordinates.last!, endPoint)
        
        startDistance = 8046720
        stopDistance = 12874752.0
        sliced = line1.trimmed(from: startDistance, to: stopDistance)
        XCTAssertNil(sliced, "should return nil")
        
        startDistance = line1.distance()!
        stopDistance = startDistance + 100.0
        startPoint = line1.coordinateFromStart(distance: startDistance)
        endPoint = line1.coordinateFromStart(distance: stopDistance)
        sliced = line1.trimmed(from: startDistance, to: stopDistance)
        XCTAssertNotNil(sliced, "should return valid lineString")
        XCTAssertEqual(sliced!.coordinates.first!, startPoint)
        XCTAssertEqual(sliced!.coordinates.last!, endPoint)
        
        startDistance = -0.376
        stopDistance = 543.0
        sliced = line1.trimmed(from: startDistance, to: stopDistance)
        XCTAssertNil(sliced, "should return nil")
    }
    
    func testIntersections() {
        let lineString = TurfLineString([.init(latitude: 2, longitude: 1),
                                     .init(latitude: 2, longitude: 5),
                                     .init(latitude: 2, longitude: 9)])
        
        let intersectingLineString = TurfLineString([.init(latitude: 4, longitude: 1),
                                                 .init(latitude: 0, longitude: 5),
                                                 .init(latitude: 2, longitude: 9)])
        
        var intersections = lineString.intersections(with: intersectingLineString)
        
        XCTAssertEqual(intersections.sorted(by: { $0.longitude < $1.longitude }),
                       [.init(latitude: 2, longitude: 3),
                        .init(latitude: 2, longitude: 9)],
                       accuracy: 0, "TurfLineString intersections are not correct.")
        
        let notIntersectingLineString = TurfLineString([.init(latitude: 1, longitude: 1),
                                                    .init(latitude: 1, longitude: 5),
                                                    .init(latitude: 1, longitude: 9)])
        
        intersections = lineString.intersections(with: notIntersectingLineString)
        
        XCTAssertTrue(intersections.isEmpty, "Found impossible TurfLineString intersection(s).")
        
        let emptyLineString = TurfLineString([])
        
        intersections = lineString.intersections(with: emptyLineString)
        
        XCTAssertTrue(intersections.isEmpty, "Found impossible TurfLineString intersection(s).")
    }
}
