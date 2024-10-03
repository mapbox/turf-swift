import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf

class PolygonTests: XCTestCase {
    
    func testPolygonFeature() {
        let data = try! Fixture.geojsonData(from: "polygon")!
        let geojson = try! JSONDecoder().decode(TurfFeature.self, from: data)
        
        let firstCoordinate = TurfLocationCoordinate2D(latitude: 37.00255267215955, longitude: -109.05029296875)
        let lastCoordinate = TurfLocationCoordinate2D(latitude: 40.6306300839918, longitude: -108.56689453125)
        
        if case let .number(number) = geojson.identifier {
            XCTAssertEqual(number, 1.01)
        } else {
            XCTFail()
        }
        
        guard case let .polygon(polygon) = geojson.geometry else {
            XCTFail()
            return
        }
        XCTAssert(polygon.outerRing.coordinates.first == firstCoordinate)
        XCTAssert(polygon.innerRings.last?.coordinates.last == lastCoordinate)
        XCTAssert(polygon.outerRing.coordinates.count == 5)
        XCTAssert(polygon.innerRings.first?.coordinates.count == 5)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! JSONDecoder().decode(TurfFeature.self, from: encodedData)
        guard case let .polygon(decodedPolygon) = decoded.geometry else {
                   XCTFail()
                   return
               }
        
        XCTAssertEqual(polygon, decodedPolygon)
        if case let .number(number) = geojson.identifier,
           case let .number(decodedNumber) = decoded.identifier {
            XCTAssertEqual(number, decodedNumber)
        } else {
            XCTFail()
        }
        XCTAssert(decodedPolygon.outerRing.coordinates.first == firstCoordinate)
        XCTAssert(decodedPolygon.innerRings.last?.coordinates.last == lastCoordinate)
        XCTAssert(decodedPolygon.outerRing.coordinates.count == 5)
        XCTAssert(decodedPolygon.innerRings.first?.coordinates.count == 5)
    }
    
    func testPolygonContains() {
        let coordinate = TurfLocationCoordinate2D(latitude: 44, longitude: -77)
        let polygon = TurfPolygon([[
            TurfLocationCoordinate2D(latitude: 41, longitude: -81),
            TurfLocationCoordinate2D(latitude: 47, longitude: -81),
            TurfLocationCoordinate2D(latitude: 47, longitude: -72),
            TurfLocationCoordinate2D(latitude: 41, longitude: -72),
            TurfLocationCoordinate2D(latitude: 41, longitude: -81),
        ]])
        XCTAssertTrue(polygon.contains(coordinate))
    }
    
    func testPolygonDoesNotContain() {
        let coordinate = TurfLocationCoordinate2D(latitude: 44, longitude: -77)
        let polygon = TurfPolygon([[
            TurfLocationCoordinate2D(latitude: 41, longitude: -51),
            TurfLocationCoordinate2D(latitude: 47, longitude: -51),
            TurfLocationCoordinate2D(latitude: 47, longitude: -42),
            TurfLocationCoordinate2D(latitude: 41, longitude: -42),
            TurfLocationCoordinate2D(latitude: 41, longitude: -51),
        ]])
        XCTAssertFalse(polygon.contains(coordinate))
    }
    
    func testPolygonDoesNotContainWithHole() {
        let coordinate = TurfLocationCoordinate2D(latitude: 44, longitude: -77)
        let polygon = TurfPolygon([
            [
                TurfLocationCoordinate2D(latitude: 41, longitude: -81),
                TurfLocationCoordinate2D(latitude: 47, longitude: -81),
                TurfLocationCoordinate2D(latitude: 47, longitude: -72),
                TurfLocationCoordinate2D(latitude: 41, longitude: -72),
                TurfLocationCoordinate2D(latitude: 41, longitude: -81),
            ],
            [
                TurfLocationCoordinate2D(latitude: 43, longitude: -76),
                TurfLocationCoordinate2D(latitude: 43, longitude: -78),
                TurfLocationCoordinate2D(latitude: 45, longitude: -78),
                TurfLocationCoordinate2D(latitude: 45, longitude: -76),
                TurfLocationCoordinate2D(latitude: 43, longitude: -76),
            ],
        ])
        XCTAssertFalse(polygon.contains(coordinate))
    }

    func testPolygonContainsAtBoundary() {
        let coordinate = TurfLocationCoordinate2D(latitude: 1, longitude: 1)
        let polygon = TurfPolygon([[
            TurfLocationCoordinate2D(latitude: 0, longitude: 0),
            TurfLocationCoordinate2D(latitude: 1, longitude: 0),
            TurfLocationCoordinate2D(latitude: 1, longitude: 1),
            TurfLocationCoordinate2D(latitude: 0, longitude: 1),
            TurfLocationCoordinate2D(latitude: 0, longitude: 0),
        ]])

        XCTAssertFalse(polygon.contains(coordinate, ignoreBoundary: true))
        XCTAssertTrue(polygon.contains(coordinate, ignoreBoundary: false))
        XCTAssertTrue(polygon.contains(coordinate))
    }

    func testPolygonWithHoleContainsAtBoundary() {
        let coordinate = TurfLocationCoordinate2D(latitude: 43, longitude: -78)
        let polygon = TurfPolygon([
            [
                TurfLocationCoordinate2D(latitude: 41, longitude: -81),
                TurfLocationCoordinate2D(latitude: 47, longitude: -81),
                TurfLocationCoordinate2D(latitude: 47, longitude: -72),
                TurfLocationCoordinate2D(latitude: 41, longitude: -72),
                TurfLocationCoordinate2D(latitude: 41, longitude: -81),
            ],
            [
                TurfLocationCoordinate2D(latitude: 43, longitude: -76),
                TurfLocationCoordinate2D(latitude: 43, longitude: -78),
                TurfLocationCoordinate2D(latitude: 45, longitude: -78),
                TurfLocationCoordinate2D(latitude: 45, longitude: -76),
                TurfLocationCoordinate2D(latitude: 43, longitude: -76),
            ],
        ])

        XCTAssertFalse(polygon.contains(coordinate, ignoreBoundary: true))
        XCTAssertTrue(polygon.contains(coordinate, ignoreBoundary: false))
        XCTAssertTrue(polygon.contains(coordinate))
    }

    func testCirclePolygon()
    {
        let coord = TurfLocationCoordinate2D(latitude: 10.0, longitude: 5.0)
        let radius = 500
        let circleShape = TurfPolygon(center: coord, radius: LocationDistance(radius), vertices: 64)

        // Test number of vertices is 64.
        let expctedNumberOfSteps = circleShape.coordinates[0].count - 1
        XCTAssertEqual(expctedNumberOfSteps, 64)

        // Test the diameter of the circle is 2x its radius.
        let startingCoord = circleShape.coordinates[0][0]
        let oppositeCoord = circleShape.coordinates[0][circleShape.coordinates[0].count / 2]

        let expectedDiameter = LocationDistance(radius * 2)
        let diameter = startingCoord.distance(to: oppositeCoord)

        XCTAssertEqual(expectedDiameter, diameter, accuracy: 0.25)
    }
    
    func testPolygonCentre() {
        // Adopted from https://github.com/Turfjs/turf/blob/3b20c568e5638f680cde39c26b56fbcf034133f2/packages/turf-center/test.js
        let coordinate = TurfLocationCoordinate2D(latitude: 45.7536760235992, longitude: 4.841880798339844)
        let polygon = TurfPolygon([
            [
                TurfLocationCoordinate2D(latitude: 45.79398056386735, longitude: 4.8250579833984375),
                TurfLocationCoordinate2D(latitude: 45.79254427435898, longitude: 4.882392883300781),
                TurfLocationCoordinate2D(latitude: 45.76081677972451, longitude: 4.910373687744141),
                TurfLocationCoordinate2D(latitude: 45.7271539426975, longitude: 4.894924163818359),
                TurfLocationCoordinate2D(latitude: 45.71337148333104, longitude: 4.824199676513671),
                TurfLocationCoordinate2D(latitude: 45.74021417890731, longitude: 4.773387908935547),
                TurfLocationCoordinate2D(latitude: 45.778418789239055, longitude: 4.778022766113281),
                TurfLocationCoordinate2D(latitude: 45.79398056386735, longitude: 4.8250579833984375),
            ],
        ])
        let center = polygon.center!
        XCTAssertLessThan(center.distance(to: coordinate), 1)
    }
    
    func testPolygonImbalancedCentre() {
        // Adopted from https://github.com/Turfjs/turf/blob/3b20c568e5638f680cde39c26b56fbcf034133f2/packages/turf-center/test.js
        let coordinate = TurfLocationCoordinate2D(latitude: 45.778762648296855, longitude: 4.851944446563721)
        let polygon = TurfPolygon([
            [
                TurfLocationCoordinate2D(latitude: 45.77258200374433, longitude: 4.854240417480469),
                TurfLocationCoordinate2D(latitude: 45.777431068484894, longitude: 4.8445844650268555),
                TurfLocationCoordinate2D(latitude: 45.778658234059755, longitude: 4.845442771911621),
                TurfLocationCoordinate2D(latitude: 45.779376562352425, longitude: 4.845914840698242),
                TurfLocationCoordinate2D(latitude: 45.78021460033108, longitude: 4.846644401550292),
                TurfLocationCoordinate2D(latitude: 45.78078326178593, longitude: 4.847245216369629),
                TurfLocationCoordinate2D(latitude: 45.78138184652523, longitude: 4.848060607910156),
                TurfLocationCoordinate2D(latitude: 45.78186070968964, longitude: 4.8487043380737305),
                TurfLocationCoordinate2D(latitude: 45.78248921135124, longitude: 4.849562644958495),
                TurfLocationCoordinate2D(latitude: 45.78302792142197, longitude: 4.850893020629883),
                TurfLocationCoordinate2D(latitude: 45.78374619341895, longitude: 4.852008819580077),
                TurfLocationCoordinate2D(latitude: 45.784075398324866, longitude: 4.852995872497559),
                TurfLocationCoordinate2D(latitude: 45.78443452873236, longitude: 4.853854179382324),
                TurfLocationCoordinate2D(latitude: 45.78470387501975, longitude: 4.8549699783325195),
                TurfLocationCoordinate2D(latitude: 45.784793656826345, longitude: 4.85569953918457),
                TurfLocationCoordinate2D(latitude: 45.784853511283764, longitude: 4.857330322265624),
                TurfLocationCoordinate2D(latitude: 45.78494329284938, longitude: 4.858231544494629),
                TurfLocationCoordinate2D(latitude: 45.784883438488365, longitude: 4.859304428100585),
                TurfLocationCoordinate2D(latitude: 45.77294120818474, longitude: 4.858360290527344),
                TurfLocationCoordinate2D(latitude: 45.77258200374433, longitude: 4.854240417480469)
            ],
        ])
        let center = polygon.center!
        XCTAssertLessThan(center.distance(to: coordinate), 1)
    }
    
    func testPolygonCentroid() {
        // Adopted from https://github.com/Turfjs/turf/blob/3b20c568e5638f680cde39c26b56fbcf034133f2/packages/turf-centroid/test.js
        let coordinate = TurfLocationCoordinate2D(latitude: 45.75807143030368, longitude: 4.841194152832031)
        let polygon = TurfPolygon([
            [
                TurfLocationCoordinate2D(latitude: 45.79398056386735, longitude: 4.8250579833984375),
                TurfLocationCoordinate2D(latitude: 45.79254427435898, longitude: 4.882392883300781),
                TurfLocationCoordinate2D(latitude: 45.76081677972451, longitude: 4.910373687744141),
                TurfLocationCoordinate2D(latitude: 45.7271539426975, longitude: 4.894924163818359),
                TurfLocationCoordinate2D(latitude: 45.71337148333104, longitude: 4.824199676513671),
                TurfLocationCoordinate2D(latitude: 45.74021417890731, longitude: 4.773387908935547),
                TurfLocationCoordinate2D(latitude: 45.778418789239055, longitude: 4.778022766113281),
                TurfLocationCoordinate2D(latitude: 45.79398056386735, longitude: 4.8250579833984375),
            ],
        ])
        XCTAssertLessThan(polygon.centroid!.distance(to: coordinate), 1)
    }
    
    func testPolygonImbalancedCentroid() {
        // Adopted from https://github.com/Turfjs/turf/blob/3b20c568e5638f680cde39c26b56fbcf034133f2/packages/turf-centroid/test.js
        let coordinate = TurfLocationCoordinate2D(latitude: 45.78143055383553, longitude: 4.851791984156558)
        let polygon = TurfPolygon([
            [
                TurfLocationCoordinate2D(latitude: 45.77258200374433, longitude: 4.854240417480469),
                TurfLocationCoordinate2D(latitude: 45.777431068484894, longitude: 4.8445844650268555),
                TurfLocationCoordinate2D(latitude: 45.778658234059755, longitude: 4.845442771911621),
                TurfLocationCoordinate2D(latitude: 45.779376562352425, longitude: 4.845914840698242),
                TurfLocationCoordinate2D(latitude: 45.78021460033108, longitude: 4.846644401550292),
                TurfLocationCoordinate2D(latitude: 45.78078326178593, longitude: 4.847245216369629),
                TurfLocationCoordinate2D(latitude: 45.78138184652523, longitude: 4.848060607910156),
                TurfLocationCoordinate2D(latitude: 45.78186070968964, longitude: 4.8487043380737305),
                TurfLocationCoordinate2D(latitude: 45.78248921135124, longitude: 4.849562644958495),
                TurfLocationCoordinate2D(latitude: 45.78302792142197, longitude: 4.850893020629883),
                TurfLocationCoordinate2D(latitude: 45.78374619341895, longitude: 4.852008819580077),
                TurfLocationCoordinate2D(latitude: 45.784075398324866, longitude: 4.852995872497559),
                TurfLocationCoordinate2D(latitude: 45.78443452873236, longitude: 4.853854179382324),
                TurfLocationCoordinate2D(latitude: 45.78470387501975, longitude: 4.8549699783325195),
                TurfLocationCoordinate2D(latitude: 45.784793656826345, longitude: 4.85569953918457),
                TurfLocationCoordinate2D(latitude: 45.784853511283764, longitude: 4.857330322265624),
                TurfLocationCoordinate2D(latitude: 45.78494329284938, longitude: 4.858231544494629),
                TurfLocationCoordinate2D(latitude: 45.784883438488365, longitude: 4.859304428100585),
                TurfLocationCoordinate2D(latitude: 45.77294120818474, longitude: 4.858360290527344),
                TurfLocationCoordinate2D(latitude: 45.77258200374433, longitude: 4.854240417480469)
            ],
        ])
        XCTAssertLessThan(polygon.centroid!.distance(to: coordinate), 1)
    }
    
    func testPolygonCentreOfMass() {
        // Adopted from https://github.com/Turfjs/turf/blob/3b20c568e5638f680cde39c26b56fbcf034133f2/packages/turf-center-of-mass/test.js
        let coordinate = TurfLocationCoordinate2D(latitude: 45.75581209996416, longitude: 4.840728965137111)
        let polygon = TurfPolygon([
            [
                TurfLocationCoordinate2D(latitude: 45.79398056386735, longitude: 4.8250579833984375),
                TurfLocationCoordinate2D(latitude: 45.79254427435898, longitude: 4.882392883300781),
                TurfLocationCoordinate2D(latitude: 45.76081677972451, longitude: 4.910373687744141),
                TurfLocationCoordinate2D(latitude: 45.7271539426975, longitude: 4.894924163818359),
                TurfLocationCoordinate2D(latitude: 45.71337148333104, longitude: 4.824199676513671),
                TurfLocationCoordinate2D(latitude: 45.74021417890731, longitude: 4.773387908935547),
                TurfLocationCoordinate2D(latitude: 45.778418789239055, longitude: 4.778022766113281),
                TurfLocationCoordinate2D(latitude: 45.79398056386735, longitude: 4.8250579833984375),
            ],
        ])
        XCTAssertLessThan(polygon.centerOfMass!.distance(to: coordinate), 1)
    }
    
    func testPolygonImbalancedCentreOfMass() {
        // Adopted from https://github.com/Turfjs/turf/blob/3b20c568e5638f680cde39c26b56fbcf034133f2/packages/turf-center-of-mass/test.js
        let coordinate = TurfLocationCoordinate2D(latitude: 45.77877742486245, longitude: 4.853372894819807)
        let polygon = TurfPolygon([
            [
                TurfLocationCoordinate2D(latitude: 45.77258200374433, longitude: 4.854240417480469),
                TurfLocationCoordinate2D(latitude: 45.777431068484894, longitude: 4.8445844650268555),
                TurfLocationCoordinate2D(latitude: 45.778658234059755, longitude: 4.845442771911621),
                TurfLocationCoordinate2D(latitude: 45.779376562352425, longitude: 4.845914840698242),
                TurfLocationCoordinate2D(latitude: 45.78021460033108, longitude: 4.846644401550292),
                TurfLocationCoordinate2D(latitude: 45.78078326178593, longitude: 4.847245216369629),
                TurfLocationCoordinate2D(latitude: 45.78138184652523, longitude: 4.848060607910156),
                TurfLocationCoordinate2D(latitude: 45.78186070968964, longitude: 4.8487043380737305),
                TurfLocationCoordinate2D(latitude: 45.78248921135124, longitude: 4.849562644958495),
                TurfLocationCoordinate2D(latitude: 45.78302792142197, longitude: 4.850893020629883),
                TurfLocationCoordinate2D(latitude: 45.78374619341895, longitude: 4.852008819580077),
                TurfLocationCoordinate2D(latitude: 45.784075398324866, longitude: 4.852995872497559),
                TurfLocationCoordinate2D(latitude: 45.78443452873236, longitude: 4.853854179382324),
                TurfLocationCoordinate2D(latitude: 45.78470387501975, longitude: 4.8549699783325195),
                TurfLocationCoordinate2D(latitude: 45.784793656826345, longitude: 4.85569953918457),
                TurfLocationCoordinate2D(latitude: 45.784853511283764, longitude: 4.857330322265624),
                TurfLocationCoordinate2D(latitude: 45.78494329284938, longitude: 4.858231544494629),
                TurfLocationCoordinate2D(latitude: 45.784883438488365, longitude: 4.859304428100585),
                TurfLocationCoordinate2D(latitude: 45.77294120818474, longitude: 4.858360290527344),
                TurfLocationCoordinate2D(latitude: 45.77258200374433, longitude: 4.854240417480469)
            ],
        ])
        let center = polygon.centerOfMass!
        XCTAssertLessThan(center.distance(to: coordinate), 1)
    }

    func testSmoothClose() {
        let original = [
            [
                TurfLocationCoordinate2D(latitude: 18.28125, longitude: 39.095962936305476),
                TurfLocationCoordinate2D(latitude: 32.34375, longitude: 31.653381399664),
                TurfLocationCoordinate2D(latitude: 19.6875, longitude: 17.97873309555617),
                TurfLocationCoordinate2D(latitude: 35.15625, longitude: 10.833305983642491),
                TurfLocationCoordinate2D(latitude: 19.6875, longitude: 0),
                TurfLocationCoordinate2D(latitude: 32.6953125, longitude: -2.811371193331128),
                TurfLocationCoordinate2D(latitude: 40.78125, longitude: 13.923403897723347),
                TurfLocationCoordinate2D(latitude: 24.2578125, longitude: 17.97873309555617),
                TurfLocationCoordinate2D(latitude: 33.75, longitude: 31.952162238024975),
                TurfLocationCoordinate2D(latitude: 29.53125, longitude: 40.713955826286046),
                TurfLocationCoordinate2D(latitude: 22.8515625, longitude: 40.713955826286046),
                TurfLocationCoordinate2D(latitude: 18.28125, longitude: 39.095962936305476),
            ]
        ]
        let expected = [
            [
                TurfLocationCoordinate2D(latitude: 24.43359375, longitude: 35.83983351402483),
                TurfLocationCoordinate2D(latitude: 26.19140625, longitude: 34.90951082194465),
                TurfLocationCoordinate2D(latitude: 27.53173828125, longitude: 33.8818120866228),
                TurfLocationCoordinate2D(latitude: 28.45458984375, longitude: 32.7567373080593),
                TurfLocationCoordinate2D(latitude: 28.9599609375, longitude: 31.534286486254125),
                TurfLocationCoordinate2D(latitude: 29.0478515625, longitude: 30.21445962120729),
                TurfLocationCoordinate2D(latitude: 28.71826171875, longitude: 28.797256712918795),
                TurfLocationCoordinate2D(latitude: 27.97119140625, longitude: 27.28267776138864),
                TurfLocationCoordinate2D(latitude: 26.806640625, longitude: 25.670722766616823),
                TurfLocationCoordinate2D(latitude: 25.224609375, longitude: 23.961391728603346),
                TurfLocationCoordinate2D(latitude: 24.08203125, longitude: 22.3540797717179),
                TurfLocationCoordinate2D(latitude: 23.37890625, longitude: 20.84878689596049),
                TurfLocationCoordinate2D(latitude: 23.115234375, longitude: 19.445513101331112),
                TurfLocationCoordinate2D(latitude: 23.291015625, longitude: 18.144258387829765),
                TurfLocationCoordinate2D(latitude: 23.90625, longitude: 16.945022755456456),
                TurfLocationCoordinate2D(latitude: 24.9609375, longitude: 15.847806204211178),
                TurfLocationCoordinate2D(latitude: 26.455078125, longitude: 14.852608734093936),
                TurfLocationCoordinate2D(latitude: 28.388671875, longitude: 13.959430345104726),
                TurfLocationCoordinate2D(latitude: 29.8388671875, longitude: 13.008628848744754),
                TurfLocationCoordinate2D(latitude: 30.8056640625, longitude: 12.000204245014018),
                TurfLocationCoordinate2D(latitude: 31.2890625, longitude: 10.934156533912521),
                TurfLocationCoordinate2D(latitude: 31.2890625, longitude: 9.81048571544026),
                TurfLocationCoordinate2D(latitude: 30.8056640625, longitude: 8.629191789597236),
                TurfLocationCoordinate2D(latitude: 29.8388671875, longitude: 7.39027475638345),
                TurfLocationCoordinate2D(latitude: 28.388671875, longitude: 6.093734615798901),
                TurfLocationCoordinate2D(latitude: 26.455078125, longitude: 4.73957136784359),
                TurfLocationCoordinate2D(latitude: 24.9664306640625, longitude: 3.5107508509868937),
                TurfLocationCoordinate2D(latitude: 23.9227294921875, longitude: 2.4072730652288126),
                TurfLocationCoordinate2D(latitude: 23.323974609375, longitude: 1.429138010569346),
                TurfLocationCoordinate2D(latitude: 23.170166015625, longitude: 0.5763456870084949),
                TurfLocationCoordinate2D(latitude: 23.4613037109375, longitude: -0.15110390545374128),
                TurfLocationCoordinate2D(latitude: 24.1973876953125, longitude: -0.7532107668173623),
                TurfLocationCoordinate2D(latitude: 25.37841796875, longitude: -1.2299748970823683),
                TurfLocationCoordinate2D(latitude: 27.00439453125, longitude: -1.581396296248759),
                TurfLocationCoordinate2D(latitude: 28.553466796875, longitude: -1.6274091597216251),
                TurfLocationCoordinate2D(latitude: 30.025634765625, longitude: -1.3680134875009662),
                TurfLocationCoordinate2D(latitude: 31.4208984375, longitude: -0.803209279586782),
                TurfLocationCoordinate2D(latitude: 32.7392578125, longitude: 0.06700346402092716),
                TurfLocationCoordinate2D(latitude: 33.980712890625, longitude: 1.2426247433221613),
                TurfLocationCoordinate2D(latitude: 35.145263671875, longitude: 2.7236545583169205),
                TurfLocationCoordinate2D(latitude: 36.23291015625, longitude: 4.510092909005205),
                TurfLocationCoordinate2D(latitude: 37.24365234375, longitude: 6.601939795387015),
                TurfLocationCoordinate2D(latitude: 37.869873046875, longitude: 8.495670339687235),
                TurfLocationCoordinate2D(latitude: 38.111572265625, longitude: 10.191284541905867),
                TurfLocationCoordinate2D(latitude: 37.96875, longitude: 11.68878240204291),
                TurfLocationCoordinate2D(latitude: 37.44140625, longitude: 12.98816392009837),
                TurfLocationCoordinate2D(latitude: 36.529541015625, longitude: 14.089429096072237),
                TurfLocationCoordinate2D(latitude: 35.233154296875, longitude: 14.992577929964515),
                TurfLocationCoordinate2D(latitude: 33.55224609375, longitude: 15.697610421775206),
                TurfLocationCoordinate2D(latitude: 31.48681640625, longitude: 16.20452657150431),
                TurfLocationCoordinate2D(latitude: 29.827880859375, longitude: 16.86641303286835),
                TurfLocationCoordinate2D(latitude: 28.575439453125, longitude: 17.683269805867326),
                TurfLocationCoordinate2D(latitude: 27.7294921875, longitude: 18.65509689050124),
                TurfLocationCoordinate2D(latitude: 27.2900390625, longitude: 19.781894286770097),
                TurfLocationCoordinate2D(latitude: 27.257080078125, longitude: 21.063661994673886),
                TurfLocationCoordinate2D(latitude: 27.630615234375, longitude: 22.50040001421261),
                TurfLocationCoordinate2D(latitude: 28.41064453125, longitude: 24.092108345386272),
                TurfLocationCoordinate2D(latitude: 29.59716796875, longitude: 25.838786988194872),
                TurfLocationCoordinate2D(latitude: 30.5694580078125, longitude: 27.504033825468973),
                TurfLocationCoordinate2D(latitude: 31.3275146484375, longitude: 29.087848857208584),
                TurfLocationCoordinate2D(latitude: 31.871337890625, longitude: 30.590232083413696),
                TurfLocationCoordinate2D(latitude: 32.200927734375, longitude: 32.011183504084315),
                TurfLocationCoordinate2D(latitude: 32.3162841796875, longitude: 33.35070311922044),
                TurfLocationCoordinate2D(latitude: 32.2174072265625, longitude: 34.60879092882206),
                TurfLocationCoordinate2D(latitude: 31.904296875, longitude: 35.785446932889194),
                TurfLocationCoordinate2D(latitude: 31.376953125, longitude: 36.88067113142183),
                TurfLocationCoordinate2D(latitude: 30.8111572265625, longitude: 37.83899230513788),
                TurfLocationCoordinate2D(latitude: 30.2069091796875, longitude: 38.66041045403736),
                TurfLocationCoordinate2D(latitude: 29.564208984375, longitude: 39.344925578120254),
                TurfLocationCoordinate2D(latitude: 28.883056640625, longitude: 39.89253767738657),
                TurfLocationCoordinate2D(latitude: 28.1634521484375, longitude: 40.30324675183631),
                TurfLocationCoordinate2D(latitude: 27.4053955078125, longitude: 40.57705280146946),
                TurfLocationCoordinate2D(latitude: 26.60888671875, longitude: 40.713955826286046),
                TurfLocationCoordinate2D(latitude: 25.77392578125, longitude: 40.713955826286046),
                TurfLocationCoordinate2D(latitude: 24.971923828125, longitude: 40.6886746873801),
                TurfLocationCoordinate2D(latitude: 24.202880859375, longitude: 40.6381124095682),
                TurfLocationCoordinate2D(latitude: 23.466796875, longitude: 40.56226899285036),
                TurfLocationCoordinate2D(latitude: 22.763671875, longitude: 40.46114443722658),
                TurfLocationCoordinate2D(latitude: 22.093505859375, longitude: 40.33473874269685),
                TurfLocationCoordinate2D(latitude: 21.456298828125, longitude: 40.183051909261174),
                TurfLocationCoordinate2D(latitude: 20.85205078125, longitude: 40.00608393691955),
                TurfLocationCoordinate2D(latitude: 20.28076171875, longitude: 39.80383482567197),
                TurfLocationCoordinate2D(latitude: 20.0006103515625, longitude: 39.51057651682032),
                TurfLocationCoordinate2D(latitude: 20.0115966796875, longitude: 39.12630901036461),
                TurfLocationCoordinate2D(latitude: 20.313720703125, longitude: 38.6510323063048),
                TurfLocationCoordinate2D(latitude: 20.906982421875, longitude: 38.084746404640924),
                TurfLocationCoordinate2D(latitude: 21.7913818359375, longitude: 37.42745130537297),
                TurfLocationCoordinate2D(latitude: 22.9669189453125, longitude: 36.679147008500934),
                TurfLocationCoordinate2D(latitude: 24.43359375, longitude: 35.83983351402483),
            ]
        ]

        let polygon = TurfPolygon(original)
        let smoothed = polygon.smooth()

        XCTAssertEqual(smoothed.coordinates, expected)
    }

    func testSmoothGeometry() {
        let original = [
            [
                TurfLocationCoordinate2D(latitude: 2.28515625, longitude: 27.761329874505233),
                TurfLocationCoordinate2D(latitude: -5.537109374999999, longitude: 21.616579336740603),
                TurfLocationCoordinate2D(latitude: -0.087890625, longitude: 17.14079039331665),
                TurfLocationCoordinate2D(latitude: 0.87890625, longitude: 21.37124437061831),
                TurfLocationCoordinate2D(latitude: 4.482421875, longitude: 19.72534224805787),
                TurfLocationCoordinate2D(latitude: 5.09765625, longitude: 22.51255695405145),
                TurfLocationCoordinate2D(latitude: 10.458984375, longitude: 24.607069137709683),
                TurfLocationCoordinate2D(latitude: 3.076171875, longitude: 26.194876675795218),
                TurfLocationCoordinate2D(latitude: 6.15234375, longitude: 29.305561325527698),
                TurfLocationCoordinate2D(latitude: 2.28515625, longitude: 27.761329874505233),
            ]
        ]

        let expected = [
            [
                TurfLocationCoordinate2D(latitude: -1.1370849609374996, longitude: 25.073001514233205),
                TurfLocationCoordinate2D(latitude: -2.114868164062499, longitude: 24.30490769701263),
                TurfLocationCoordinate2D(latitude: -2.885284423828124, longitude: 23.562891404703624),
                TurfLocationCoordinate2D(latitude: -3.448333740234374, longitude: 22.84695263730619),
                TurfLocationCoordinate2D(latitude: -3.804016113281249, longitude: 22.157091394820334),
                TurfLocationCoordinate2D(latitude: -3.952331542968749, longitude: 21.493307677246044),
                TurfLocationCoordinate2D(latitude: -3.893280029296874, longitude: 20.85560148458333),
                TurfLocationCoordinate2D(latitude: -3.626861572265624, longitude: 20.24397281683219),
                TurfLocationCoordinate2D(latitude: -3.153076171874999, longitude: 19.65842167399262),
                TurfLocationCoordinate2D(latitude: -2.471923828124999, longitude: 19.09894805606463),
                TurfLocationCoordinate2D(latitude: -1.8608093261718746, longitude: 18.675509483772974),
                TurfLocationCoordinate2D(latitude: -1.3197326660156246, longitude: 18.388105957117656),
                TurfLocationCoordinate2D(latitude: -0.8486938476562498, longitude: 18.236737476098675),
                TurfLocationCoordinate2D(latitude: -0.4476928710937499, longitude: 18.22140404071603),
                TurfLocationCoordinate2D(latitude: -0.11672973632812494, longitude: 18.342105650969724),
                TurfLocationCoordinate2D(latitude: 0.144195556640625, longitude: 18.59884230685976),
                TurfLocationCoordinate2D(latitude: 0.3350830078125, longitude: 18.991614008386126),
                TurfLocationCoordinate2D(latitude: 0.4559326171875, longitude: 19.520420755548834),
                TurfLocationCoordinate2D(latitude: 0.61798095703125, longitude: 19.957409438651194),
                TurfLocationCoordinate2D(latitude: 0.82122802734375, longitude: 20.302580057693213),
                TurfLocationCoordinate2D(latitude: 1.065673828125, longitude: 20.555932612674884),
                TurfLocationCoordinate2D(latitude: 1.351318359375, longitude: 20.71746710359621),
                TurfLocationCoordinate2D(latitude: 1.67816162109375, longitude: 20.78718353045719),
                TurfLocationCoordinate2D(latitude: 2.04620361328125, longitude: 20.765081893257825),
                TurfLocationCoordinate2D(latitude: 2.4554443359375, longitude: 20.651162191998118),
                TurfLocationCoordinate2D(latitude: 2.9058837890625, longitude: 20.445424426678063),
                TurfLocationCoordinate2D(latitude: 3.30963134765625, longitude: 20.308954111804166),
                TurfLocationCoordinate2D(latitude: 3.66668701171875, longitude: 20.241751247376424),
                TurfLocationCoordinate2D(latitude: 3.97705078125, longitude: 20.243815833394837),
                TurfLocationCoordinate2D(latitude: 4.24072265625, longitude: 20.31514786985941),
                TurfLocationCoordinate2D(latitude: 4.45770263671875, longitude: 20.455747356770136),
                TurfLocationCoordinate2D(latitude: 4.62799072265625, longitude: 20.66561429412702),
                TurfLocationCoordinate2D(latitude: 4.7515869140625, longitude: 20.94474868193006),
                TurfLocationCoordinate2D(latitude: 4.8284912109375, longitude: 21.29315052017926),
                TurfLocationCoordinate2D(latitude: 4.97955322265625, longitude: 21.63072888151697),
                TurfLocationCoordinate2D(latitude: 5.20477294921875, longitude: 21.957483765943184),
                TurfLocationCoordinate2D(latitude: 5.504150390625, longitude: 22.273415173457913),
                TurfLocationCoordinate2D(latitude: 5.877685546875, longitude: 22.578523104061155),
                TurfLocationCoordinate2D(latitude: 6.32537841796875, longitude: 22.872807557752903),
                TurfLocationCoordinate2D(latitude: 6.84722900390625, longitude: 23.156268534533158),
                TurfLocationCoordinate2D(latitude: 7.4432373046875, longitude: 23.428906034401926),
                TurfLocationCoordinate2D(latitude: 8.1134033203125, longitude: 23.690720057359208),
                TurfLocationCoordinate2D(latitude: 8.584442138671875, longitude: 23.944616820229413),
                TurfLocationCoordinate2D(latitude: 8.856353759765625, longitude: 24.190596323012542),
                TurfLocationCoordinate2D(latitude: 8.92913818359375, longitude: 24.428658565708602),
                TurfLocationCoordinate2D(latitude: 8.80279541015625, longitude: 24.658803548317586),
                TurfLocationCoordinate2D(latitude: 8.477325439453125, longitude: 24.8810312708395),
                TurfLocationCoordinate2D(latitude: 7.952728271484375, longitude: 25.09534173327434),
                TurfLocationCoordinate2D(latitude: 7.22900390625, longitude: 25.301734935622104),
                TurfLocationCoordinate2D(latitude: 6.30615234375, longitude: 25.500210877882797),
                TurfLocationCoordinate2D(latitude: 5.546722412109375, longitude: 25.722481775012973),
                TurfLocationCoordinate2D(latitude: 4.950714111328125, longitude: 25.968547627012633),
                TurfLocationCoordinate2D(latitude: 4.51812744140625, longitude: 26.238408433881773),
                TurfLocationCoordinate2D(latitude: 4.24896240234375, longitude: 26.532064195620396),
                TurfLocationCoordinate2D(latitude: 4.143218994140625, longitude: 26.849514912228507),
                TurfLocationCoordinate2D(latitude: 4.200897216796875, longitude: 27.1907605837061),
                TurfLocationCoordinate2D(latitude: 4.4219970703125, longitude: 27.555801210053176),
                TurfLocationCoordinate2D(latitude: 4.8065185546875, longitude: 27.944636791269737),
                TurfLocationCoordinate2D(latitude: 5.082550048828125, longitude: 28.260739308412003),
                TurfLocationCoordinate2D(latitude: 5.250091552734375, longitude: 28.50410876147997),
                TurfLocationCoordinate2D(latitude: 5.30914306640625, longitude: 28.674745150473644),
                TurfLocationCoordinate2D(latitude: 5.25970458984375, longitude: 28.77264847539302),
                TurfLocationCoordinate2D(latitude: 5.101776123046875, longitude: 28.7978187362381),
                TurfLocationCoordinate2D(latitude: 4.835357666015625, longitude: 28.750255933008884),
                TurfLocationCoordinate2D(latitude: 4.46044921875, longitude: 28.62996006570537),
                TurfLocationCoordinate2D(latitude: 3.97705078125, longitude: 28.436931134327562),
                TurfLocationCoordinate2D(latitude: 3.431854248046875, longitude: 28.172019092219408),
                TurfLocationCoordinate2D(latitude: 2.824859619140625, longitude: 27.835223939380903),
                TurfLocationCoordinate2D(latitude: 2.15606689453125, longitude: 27.426545675812058),
                TurfLocationCoordinate2D(latitude: 1.4254760742187502, longitude: 26.945984301512862),
                TurfLocationCoordinate2D(latitude: 0.6330871582031253, longitude: 26.393539816483322),
                TurfLocationCoordinate2D(latitude: -0.2210998535156246, longitude: 25.76921222072344),
                TurfLocationCoordinate2D(latitude: -1.1370849609374996, longitude: 25.073001514233205)
            ]
        ]

        let polygon = TurfPolygon(original)
        let smoothed = polygon.smooth()

        XCTAssertEqual(smoothed.coordinates, expected)
    }

    func testSmoothWithHole() {
        let original = [
            [
                TurfLocationCoordinate2D(latitude: 100.0, longitude: 0.0),
                TurfLocationCoordinate2D(latitude: 101.0, longitude: 0.0),
                TurfLocationCoordinate2D(latitude: 101.0, longitude: 1.0),
                TurfLocationCoordinate2D(latitude: 100.0, longitude: 1.0),
                TurfLocationCoordinate2D(latitude: 100.0, longitude: 0.0)
            ],
            [
                TurfLocationCoordinate2D(latitude: 100.2, longitude: 0.2),
                TurfLocationCoordinate2D(latitude: 100.8, longitude: 0.2),
                TurfLocationCoordinate2D(latitude: 100.8, longitude: 0.8),
                TurfLocationCoordinate2D(latitude: 100.2, longitude: 0.8),
                TurfLocationCoordinate2D(latitude: 100.2, longitude: 0.2)
            ]
        ]

        let expected = [
            [
                TurfLocationCoordinate2D(latitude: 100.4375, longitude: 0),
                TurfLocationCoordinate2D(latitude: 100.5625, longitude: 0),
                TurfLocationCoordinate2D(latitude: 100.671875, longitude: 0.015625),
                TurfLocationCoordinate2D(latitude: 100.765625, longitude: 0.046875),
                TurfLocationCoordinate2D(latitude: 100.84375, longitude: 0.09375),
                TurfLocationCoordinate2D(latitude: 100.90625, longitude: 0.15625),
                TurfLocationCoordinate2D(latitude: 100.953125, longitude: 0.234375),
                TurfLocationCoordinate2D(latitude: 100.984375, longitude: 0.328125),
                TurfLocationCoordinate2D(latitude: 101, longitude: 0.4375),
                TurfLocationCoordinate2D(latitude: 101, longitude: 0.5625),
                TurfLocationCoordinate2D(latitude: 100.984375, longitude: 0.671875),
                TurfLocationCoordinate2D(latitude: 100.953125, longitude: 0.765625),
                TurfLocationCoordinate2D(latitude: 100.90625, longitude: 0.84375),
                TurfLocationCoordinate2D(latitude: 100.84375, longitude: 0.90625),
                TurfLocationCoordinate2D(latitude: 100.765625, longitude: 0.953125),
                TurfLocationCoordinate2D(latitude: 100.671875, longitude: 0.984375),
                TurfLocationCoordinate2D(latitude: 100.5625, longitude: 1),
                TurfLocationCoordinate2D(latitude: 100.4375, longitude: 1),
                TurfLocationCoordinate2D(latitude: 100.328125, longitude: 0.984375),
                TurfLocationCoordinate2D(latitude: 100.234375, longitude: 0.953125),
                TurfLocationCoordinate2D(latitude: 100.15625, longitude: 0.90625),
                TurfLocationCoordinate2D(latitude: 100.09375, longitude: 0.84375),
                TurfLocationCoordinate2D(latitude: 100.046875, longitude: 0.765625),
                TurfLocationCoordinate2D(latitude: 100.015625, longitude: 0.671875),
                TurfLocationCoordinate2D(latitude: 100, longitude: 0.5625),
                TurfLocationCoordinate2D(latitude: 100, longitude: 0.4375),
                TurfLocationCoordinate2D(latitude: 100.015625, longitude: 0.328125),
                TurfLocationCoordinate2D(latitude: 100.046875, longitude: 0.234375),
                TurfLocationCoordinate2D(latitude: 100.09375, longitude: 0.15625),
                TurfLocationCoordinate2D(latitude: 100.15625, longitude: 0.09375),
                TurfLocationCoordinate2D(latitude: 100.234375, longitude: 0.046875),
                TurfLocationCoordinate2D(latitude: 100.328125, longitude: 0.015625),
                TurfLocationCoordinate2D(latitude: 100.4375, longitude: 0)
            ],
            [
                TurfLocationCoordinate2D(latitude: 100.46249999999999, longitude: 0.2),
                TurfLocationCoordinate2D(latitude: 100.53750000000001, longitude: 0.2),
                TurfLocationCoordinate2D(latitude: 100.603125, longitude: 0.20937500000000003),
                TurfLocationCoordinate2D(latitude: 100.659375, longitude: 0.22812500000000002),
                TurfLocationCoordinate2D(latitude: 100.70625, longitude: 0.25625000000000003),
                TurfLocationCoordinate2D(latitude: 100.74374999999999, longitude: 0.29375),
                TurfLocationCoordinate2D(latitude: 100.771875, longitude: 0.340625),
                TurfLocationCoordinate2D(latitude: 100.79062499999999, longitude: 0.39687500000000003),
                TurfLocationCoordinate2D(latitude: 100.8, longitude: 0.4625),
                TurfLocationCoordinate2D(latitude: 100.8, longitude: 0.5375000000000001),
                TurfLocationCoordinate2D(latitude: 100.79062499999999, longitude: 0.603125),
                TurfLocationCoordinate2D(latitude: 100.771875, longitude: 0.6593750000000002),
                TurfLocationCoordinate2D(latitude: 100.74374999999999, longitude: 0.7062500000000002),
                TurfLocationCoordinate2D(latitude: 100.70625, longitude: 0.7437500000000001),
                TurfLocationCoordinate2D(latitude: 100.659375, longitude: 0.7718750000000001),
                TurfLocationCoordinate2D(latitude: 100.603125, longitude: 0.7906250000000001),
                TurfLocationCoordinate2D(latitude: 100.53750000000001, longitude: 0.8),
                TurfLocationCoordinate2D(latitude: 100.46249999999999, longitude: 0.8),
                TurfLocationCoordinate2D(latitude: 100.396875, longitude: 0.7906250000000001),
                TurfLocationCoordinate2D(latitude: 100.340625, longitude: 0.7718750000000001),
                TurfLocationCoordinate2D(latitude: 100.29375, longitude: 0.7437500000000001),
                TurfLocationCoordinate2D(latitude: 100.25625000000001, longitude: 0.7062500000000002),
                TurfLocationCoordinate2D(latitude: 100.228125, longitude: 0.6593750000000002),
                TurfLocationCoordinate2D(latitude: 100.20937500000001, longitude: 0.603125),
                TurfLocationCoordinate2D(latitude: 100.2, longitude: 0.5375000000000001),
                TurfLocationCoordinate2D(latitude: 100.2, longitude: 0.4625),
                TurfLocationCoordinate2D(latitude: 100.20937500000001, longitude: 0.39687500000000003),
                TurfLocationCoordinate2D(latitude: 100.228125, longitude: 0.340625),
                TurfLocationCoordinate2D(latitude: 100.25625000000001, longitude: 0.29375),
                TurfLocationCoordinate2D(latitude: 100.29375, longitude: 0.25625000000000003),
                TurfLocationCoordinate2D(latitude: 100.340625, longitude: 0.22812500000000002),
                TurfLocationCoordinate2D(latitude: 100.396875, longitude: 0.20937500000000003),
                TurfLocationCoordinate2D(latitude: 100.46249999999999, longitude: 0.2)
            ]
        ]

        let polygon = TurfPolygon(original)
        let smoothed = polygon.smooth()

        XCTAssertEqual(smoothed.coordinates, expected)
    }
}
