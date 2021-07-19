import XCTest
#if !os(Linux)
import CoreLocation
#endif
import GeoJSONKit
@testable import GeoJSONKitTurf

class LineStringTests: XCTestCase {
  
  func testClosestCoordinate() {
    // Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-point-on-line/test/test.js#L117-L118
    
    // turf-point-on-line - first point
    var line = [
      GeoJSON.Position(latitude: 37.72003306385638, longitude: -122.45717525482178),
      GeoJSON.Position(latitude: 37.718242366859215, longitude: -122.45717525482178),
    ]
    let point = GeoJSON.Position(latitude: 37.72003306385638, longitude: -122.45717525482178)
    var snapped = GeoJSON.LineString(positions: line).closestCoordinate(to: point)
    XCTAssertEqual(point, snapped?.coordinate, "point on start should not move")
    
    // turf-point-on-line - points behind first point
    line = [
      GeoJSON.Position(latitude: 37.72003306385638, longitude: -122.45717525482178),
      GeoJSON.Position(latitude: 37.718242366859215, longitude: -122.45717525482178),
    ]
    var points = [
      GeoJSON.Position(latitude: 37.72009306385638, longitude: -122.45717525482178),
      GeoJSON.Position(latitude: 37.82009306385638, longitude: -122.45717525482178),
      GeoJSON.Position(latitude: 37.72009306385638, longitude: -122.45716525482178),
      GeoJSON.Position(latitude: 37.72009306385638, longitude: -122.45516525482178),
    ]
    for point in points {
      snapped = GeoJSON.LineString(positions: line).closestCoordinate(to: point)
      XCTAssertEqual(line.first, snapped?.coordinate, "point behind start should move to first vertex")
    }
    
    // turf-point-on-line - points in front of last point
    line = [
      GeoJSON.Position(latitude: 37.72125936929241, longitude: -122.45616137981413),
      GeoJSON.Position(latitude: 37.72003306385638, longitude: -122.45717525482178),
      GeoJSON.Position(latitude: 37.718242366859215, longitude: -122.45717525482178),
    ]
    points = [
      GeoJSON.Position(latitude: 37.71814052497085, longitude: -122.45696067810057),
      GeoJSON.Position(latitude: 37.71813203814049, longitude: -122.4573630094528),
      GeoJSON.Position(latitude: 37.71797927502795, longitude: -122.45730936527252),
      GeoJSON.Position(latitude: 37.71704571582896, longitude: -122.45718061923981),
    ]
    for point in points {
      snapped = GeoJSON.LineString(positions: line).closestCoordinate(to: point)
      XCTAssertEqual(line.last, snapped?.coordinate, "point behind start should move to last vertex")
    }
    
    // turf-point-on-line - points on joints
    let lines = [
      [
        GeoJSON.Position(latitude: 37.72125936929241, longitude: -122.45616137981413),
        GeoJSON.Position(latitude: 37.72003306385638, longitude: -122.45717525482178),
        GeoJSON.Position(latitude: 37.718242366859215, longitude: -122.45717525482178)
      ],
      [
        GeoJSON.Position(latitude: 31.728167146023935, longitude: 26.279296875),
        GeoJSON.Position(latitude: 32.69486597787505, longitude: 21.796875),
        GeoJSON.Position(latitude: 29.99300228455108, longitude: 18.80859375),
        GeoJSON.Position(latitude: 33.137551192346145, longitude: 12.919921874999998),
        GeoJSON.Position(latitude: 35.60371874069731, longitude: 10.1953125),
        GeoJSON.Position(latitude: 36.527294814546245, longitude: 4.921875),
        GeoJSON.Position(latitude: 36.527294814546245, longitude: -1.669921875),
        GeoJSON.Position(latitude: 34.74161249883172, longitude: -5.44921875),
        GeoJSON.Position(latitude: 32.99023555965106, longitude: -8.7890625)
      ],
      [
        GeoJSON.Position(latitude: 51.52204224896724, longitude: -0.10919809341430663),
        GeoJSON.Position(latitude: 51.521942114455435, longitude: -0.10923027992248535),
        GeoJSON.Position(latitude: 51.52186200668747, longitude: -0.10916590690612793),
        GeoJSON.Position(latitude: 51.52177522311313, longitude: -0.10904788970947266),
        GeoJSON.Position(latitude: 51.521601655468345, longitude: -0.10886549949645996),
        GeoJSON.Position(latitude: 51.52138135712038, longitude: -0.10874748229980469),
        GeoJSON.Position(latitude: 51.5206870765674, longitude: -0.10855436325073242),
        GeoJSON.Position(latitude: 51.52027984939518, longitude: -0.10843634605407713),
        GeoJSON.Position(latitude: 51.519952729849024, longitude: -0.10839343070983887),
        GeoJSON.Position(latitude: 51.51957887606202, longitude: -0.10817885398864746),
        GeoJSON.Position(latitude: 51.51928513164789, longitude: -0.10814666748046874),
        GeoJSON.Position(latitude: 51.518624199789016, longitude: -0.10789990425109863),
        GeoJSON.Position(latitude: 51.51778299991493, longitude: -0.10759949684143065)
      ]
    ];
    for line in lines {
      for point in line {
        snapped = GeoJSON.LineString(positions: line).closestCoordinate(to: point)
        XCTAssertEqual(point, snapped?.coordinate, "point on joint should stay in place")
      }
    }
    
    // turf-point-on-line - points on top of line
    line = [
      GeoJSON.Position(latitude: 51.52204224896724, longitude: -0.10919809341430663),
      GeoJSON.Position(latitude: 51.521942114455435, longitude: -0.10923027992248535),
      GeoJSON.Position(latitude: 51.52186200668747, longitude: -0.10916590690612793),
      GeoJSON.Position(latitude: 51.52177522311313, longitude: -0.10904788970947266),
      GeoJSON.Position(latitude: 51.521601655468345, longitude: -0.10886549949645996),
      GeoJSON.Position(latitude: 51.52138135712038, longitude: -0.10874748229980469),
      GeoJSON.Position(latitude: 51.5206870765674, longitude: -0.10855436325073242),
      GeoJSON.Position(latitude: 51.52027984939518, longitude: -0.10843634605407713),
      GeoJSON.Position(latitude: 51.519952729849024, longitude: -0.10839343070983887),
      GeoJSON.Position(latitude: 51.51957887606202, longitude: -0.10817885398864746),
      GeoJSON.Position(latitude: 51.51928513164789, longitude: -0.10814666748046874),
      GeoJSON.Position(latitude: 51.518624199789016, longitude: -0.10789990425109863),
      GeoJSON.Position(latitude: 51.51778299991493, longitude: -0.10759949684143065),
    ]
    let dist = GeoJSON.LineString(positions: line).distance()!
    let increment = dist / metersPerMile / 10
    for i in 0..<10 {
      let point = GeoJSON.LineString(positions: line).coordinateFromStart(distance: increment * Double(i) * metersPerMile)
      XCTAssertNotNil(point)
      if let point = point {
        let snapped = GeoJSON.LineString(positions: line).closestCoordinate(to: point)
        XCTAssertNotNil(snapped)
        if let snapped = snapped {
          let shift = point.distance(to: snapped.coordinate)
          XCTAssertLessThan(shift / metersPerMile, 0.000001, "point should not shift far")
        }
      }
    }
    
    // turf-point-on-line - point along line
    line = [
      GeoJSON.Position(latitude: 37.72003306385638, longitude: -122.45717525482178),
      GeoJSON.Position(latitude: 37.718242366859215, longitude: -122.45717525482178),
    ]
    let pointAlong = GeoJSON.LineString(positions: line).coordinateFromStart(distance: 0.019 * metersPerMile)
    XCTAssertNotNil(pointAlong)
    if let point = pointAlong {
      let snapped = GeoJSON.LineString(positions: line).closestCoordinate(to: point)
      XCTAssertNotNil(snapped)
      if let snapped = snapped {
        let shift = point.distance(to: snapped.coordinate)
        XCTAssertLessThan(shift / metersPerMile, 0.00001, "point should not shift far")
      }
    }
    
    // turf-point-on-line - points on sides of lines
    line = [
      GeoJSON.Position(latitude: 37.72125936929241, longitude: -122.45616137981413),
      GeoJSON.Position(latitude: 37.718242366859215, longitude: -122.45717525482178),
    ]
    points = [
      GeoJSON.Position(latitude: 37.71881098149625, longitude: -122.45702505111694),
      GeoJSON.Position(latitude: 37.719235317933844, longitude: -122.45733618736267),
      GeoJSON.Position(latitude: 37.72027068864082, longitude: -122.45686411857605),
      GeoJSON.Position(latitude: 37.72063561093274, longitude: -122.45652079582213),
    ]
    for point in points {
      let snapped = GeoJSON.LineString(positions: line).closestCoordinate(to: point)
      XCTAssertNotNil(snapped)
      if let snapped = snapped {
        XCTAssertNotEqual(snapped.coordinate, points.first, "point should not snap to first vertex")
        XCTAssertNotEqual(snapped.coordinate, points.last, "point should not snap to last vertex")
      }
    }
    
    let lineString = GeoJSON.LineString(positions: [
      GeoJSON.Position(latitude: 49.120689999999996, longitude: -122.65401),
      GeoJSON.Position(latitude: 49.120619999999995, longitude: -122.65352),
      GeoJSON.Position(latitude: 49.120189999999994, longitude: -122.65237),
    ])
    
    // https://github.com/mapbox/turf-swift/issues/27
    let short = GeoJSON.Position(latitude: 49.120403526377203, longitude: -122.6529443631224)
    let long = GeoJSON.Position(latitude: 49.120405, longitude: -122.652945)
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
    let indexLineString = GeoJSON.LineString(positions: [
      [0.0, 0.0],
      [1.0, 1.0],
      [2.0, 2.0],
      [3.0, 3.0],
      [4.0, 4.0],
      [5.0, 5.0]
    ].map {
      GeoJSON.Position(latitude: $0.first!, longitude: $0.last!)
    })
    
    let pointToSnap = GeoJSON.Position(latitude: 2.0, longitude: 3.0)
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
    
    let json = Fixture.JSONFromFileNamed(name: "dc-line", extension: "geojson")
    let line = ((json["geometry"] as! [String: Any])["coordinates"] as! [[Double]]).map { GeoJSON.Position(latitude: $0[0], longitude: $0[1]) }
    
    let pointsAlong = [
      GeoJSON.LineString(positions: line).coordinateFromStart(distance: 1 * metersPerMile),
      GeoJSON.LineString(positions: line).coordinateFromStart(distance: 1.2 * metersPerMile),
      GeoJSON.LineString(positions: line).coordinateFromStart(distance: 1.4 * metersPerMile),
      GeoJSON.LineString(positions: line).coordinateFromStart(distance: 1.6 * metersPerMile),
      GeoJSON.LineString(positions: line).coordinateFromStart(distance: 1.8 * metersPerMile),
      GeoJSON.LineString(positions: line).coordinateFromStart(distance: 2 * metersPerMile),
      GeoJSON.LineString(positions: line).coordinateFromStart(distance: 100 * metersPerMile),
      GeoJSON.LineString(positions: line).coordinateFromStart(distance: 0 * metersPerMile)
    ]
    for point in pointsAlong {
      XCTAssertNotNil(point)
    }
    XCTAssertEqual(pointsAlong.count, 8)
    XCTAssertEqual(pointsAlong.last!, line.first!)
  }
  
  func testDistance() {
    let point1 = GeoJSON.Position(latitude: 39.984, longitude: -75.343)
    let point2 = GeoJSON.Position(latitude: 39.123, longitude: -75.534)
    let line = [point1, point2]
    
    // https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-distance/test.js
    let a = GeoJSON.LineString(positions: line).distance()!
    XCTAssertEqual(a, 97_159.57803131901, accuracy: 1)
    
    let point3 = GeoJSON.Position(latitude: 20, longitude: 20)
    let point4 = GeoJSON.Position(latitude: 40, longitude: 40)
    let line2 = [point3, point4]
    
    let c = GeoJSON.LineString(positions: line2).distance()!
    XCTAssertEqual(c, 2_928_304, accuracy: 1)
    
    // Adapted from: https://gist.github.com/bsudekum/2604b72ae42b6f88aa55398b2ff0dc22
    let d = GeoJSON.LineString(positions: line2).distance(from: GeoJSON.Position(latitude: 30, longitude: 30), to: GeoJSON.Position(latitude: 40, longitude: 40))!
    XCTAssertEqual(d, 1_546_971, accuracy: 1)
    
    // https://github.com/mapbox/turf-swift/issues/27
    let short = GeoJSON.Position(latitude: 49.120403526377203, longitude: -122.6529443631224)
    let long = GeoJSON.Position(latitude: 49.120405, longitude: -122.652945)
    XCTAssertLessThan(short.distance(to: long), 1)
    
    XCTAssertEqual(0, GeoJSON.LineString(positions: [
      GeoJSON.Position(latitude: 49.120689999999996, longitude: -122.65401),
      GeoJSON.Position(latitude: 49.120619999999995, longitude: -122.65352),
    ]).distance(from: short, to: long), "Distance between two coordinates past the end of the line string should be 0")
    XCTAssertEqual(short.distance(to: long), GeoJSON.LineString(positions: [
      GeoJSON.Position(latitude: 49.120689999999996, longitude: -122.65401),
      GeoJSON.Position(latitude: 49.120619999999995, longitude: -122.65352),
      GeoJSON.Position(latitude: 49.120189999999994, longitude: -122.65237),
    ]).distance(from: short, to: long)!, accuracy: 0.1, "Distance between two coordinates between the same vertices should be roughly the same as the distance between those two coordinates")
  }
  
  func testLineCentroid() {
    // Adopted from https://github.com/Turfjs/turf/blob/3b20c568e5638f680cde39c26b56fbcf034133f2/packages/turf-centroid/test.js
    let coordinate = GeoJSON.Position(latitude: 45.759199, longitude: 4.860076)
    let line = GeoJSON.Geometry.lineString(GeoJSON.LineString(positions: [
      GeoJSON.Position(latitude: 45.749558, longitude: 4.859948),
      GeoJSON.Position(latitude: 45.768840, longitude: 4.860204),
    ]))
    XCTAssertLessThan(line.centroid()!.distance(to: coordinate), 1)
  }

  func testLineCentreOfMass() {
    // Adopted from https://github.com/Turfjs/turf/blob/3b20c568e5638f680cde39c26b56fbcf034133f2/packages/turf-center-of-mass/test.js
    let coordinate = GeoJSON.Position(latitude: 45.759199, longitude: 4.860076)
    let line = GeoJSON.Geometry.lineString(GeoJSON.LineString(positions: [
      GeoJSON.Position(latitude: 45.749558, longitude: 4.859948),
      GeoJSON.Position(latitude: 45.768840, longitude: 4.860204),
    ]))
    XCTAssertLessThan(line.centerOfMass()!.distance(to: coordinate), 1)
  }
  func testSliced() {
    // https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-line-slice/test.js
    
    // turf-line-slice -- line1
    let line1 = [
      GeoJSON.Position(latitude: 22.466878364528448, longitude: -97.88131713867188),
      GeoJSON.Position(latitude: 22.175960091218524, longitude: -97.82089233398438),
      GeoJSON.Position(latitude: 21.8704201873689, longitude: -97.6190185546875),
    ]
    var start = GeoJSON.Position(latitude: 22.254624939561698, longitude: -97.79617309570312)
    var stop = GeoJSON.Position(latitude: 22.057641623615734, longitude: -97.72750854492188)
    var sliced = GeoJSON.LineString(positions: line1).sliced(from: start, to: stop)
    var slicedCoordinates = sliced?.coordinates
    let line1Out = [
      GeoJSON.Position(latitude: 22.247393614241204, longitude: -97.83572934173804),
      GeoJSON.Position(latitude: 22.175960091218524, longitude: -97.82089233398438),
      GeoJSON.Position(latitude: 22.051208078134735, longitude: -97.7384672234217),
    ]
    XCTAssertEqual(line1Out.first!.latitude, 22.247393614241204, accuracy: 0.001)
    XCTAssertEqual(line1Out.first!.longitude, -97.83572934173804, accuracy: 0.001)
    
    XCTAssertEqual(line1Out[1], line1[1])
    
    XCTAssertEqual(line1Out.last!.latitude, 22.051208078134735, accuracy: 0.001)
    XCTAssertEqual(line1Out.last!.longitude, -97.7384672234217, accuracy: 0.001)
    XCTAssertEqual(slicedCoordinates?.count, 3)
    
    // turf-line-slice -- vertical
    let vertical = [
      GeoJSON.Position(latitude: 38.70582415504791, longitude: -121.25447809696198),
      GeoJSON.Position(latitude: 38.709767459877554, longitude: -121.25449419021606),
    ]
    start = GeoJSON.Position(latitude: 38.70582415504791, longitude: -121.25447809696198)
    stop = GeoJSON.Position(latitude: 38.70634324369764, longitude: -121.25447809696198)
    sliced = GeoJSON.LineString(positions: vertical).sliced(from: start, to: stop)
    slicedCoordinates = sliced?.coordinates
    XCTAssertEqual(slicedCoordinates?.count, 2, "no duplicated coords")
    XCTAssertNotEqual(slicedCoordinates?.first, slicedCoordinates?.last, "vertical slice should not collapse to first coordinate")
    
    sliced = GeoJSON.LineString(positions: vertical).sliced(from: vertical[0], to: vertical[1])
    slicedCoordinates = sliced?.coordinates
    XCTAssertEqual(slicedCoordinates?.count, 2, "no duplicated coords")
    XCTAssertNotEqual(slicedCoordinates?.first, slicedCoordinates?.last, "vertical slice should not collapse to first coordinate")
    
    sliced = GeoJSON.LineString(positions: vertical).sliced()
    slicedCoordinates = sliced?.coordinates
    XCTAssertEqual(slicedCoordinates?.count, 2, "no duplicated coords")
    XCTAssertNotEqual(slicedCoordinates?.first, slicedCoordinates?.last, "vertical slice should not collapse to first coordinate")
  }
  
  func testSimplify() {
    let coordinates = [
      GeoJSON.Position(latitude: -80.51399230957031, longitude: 28.069556808283608),
      GeoJSON.Position(latitude: -80.51193237304688, longitude: 28.057438520876673),
      GeoJSON.Position(latitude: -80.49819946289062, longitude: 28.05622661698537),
      GeoJSON.Position(latitude: -80.5023193359375, longitude: 28.04471284867091),
      GeoJSON.Position(latitude: -80.48583984375, longitude: 28.042288740362853),
      GeoJSON.Position(latitude: -80.50575256347656, longitude: 28.028349057505775),
      GeoJSON.Position(latitude: -80.50163269042969, longitude: 28.02168161433489),
      GeoJSON.Position(latitude: -80.49476623535156, longitude: 28.021075462659883),
      GeoJSON.Position(latitude: -80.48652648925781, longitude: 28.021075462659883),
      GeoJSON.Position(latitude: -80.47691345214844, longitude: 28.021075462659883),
      GeoJSON.Position(latitude: -80.46936035156249, longitude: 28.015619944017807),
      GeoJSON.Position(latitude: -80.47760009765624, longitude: 28.007133032319448),
      GeoJSON.Position(latitude: -80.49201965332031, longitude: 27.998039170620494),
      GeoJSON.Position(latitude: -80.46730041503906, longitude: 27.962262536875905),
      GeoJSON.Position(latitude: -80.46524047851562, longitude: 27.91980029694533),
      GeoJSON.Position(latitude: -80.40550231933594, longitude: 27.930114089618602),
      GeoJSON.Position(latitude: -80.39657592773438, longitude: 27.980455528671527),
      GeoJSON.Position(latitude: -80.41305541992188, longitude: 27.982274659104082),
      GeoJSON.Position(latitude: -80.42953491210938, longitude: 27.990763528690582),
      GeoJSON.Position(latitude: -80.4144287109375, longitude: 28.00955793247135),
      GeoJSON.Position(latitude: -80.3594970703125, longitude: 27.972572275562527),
      GeoJSON.Position(latitude: -80.36224365234375, longitude: 27.948919060105453),
      GeoJSON.Position(latitude: -80.38215637207031, longitude: 27.913732900444284),
      GeoJSON.Position(latitude: -80.41786193847656, longitude: 27.881570017022806),
      GeoJSON.Position(latitude: -80.40550231933594, longitude: 27.860932192608534),
      GeoJSON.Position(latitude: -80.39382934570312, longitude: 27.85425440786446),
      GeoJSON.Position(latitude: -80.37803649902344, longitude: 27.86336037597851),
      GeoJSON.Position(latitude: -80.38215637207031, longitude: 27.880963078302393),
      GeoJSON.Position(latitude: -80.36842346191405, longitude: 27.888246118437756),
      GeoJSON.Position(latitude: -80.35743713378906, longitude: 27.882176952341734),
      GeoJSON.Position(latitude: -80.35469055175781, longitude: 27.86882358965466),
      GeoJSON.Position(latitude: -80.3594970703125, longitude: 27.8421119273228),
      GeoJSON.Position(latitude: -80.37940979003906, longitude: 27.83300417483936),
      GeoJSON.Position(latitude: -80.39932250976561, longitude: 27.82511017099003),
      GeoJSON.Position(latitude: -80.40069580078125, longitude: 27.79352841586229),
      GeoJSON.Position(latitude: -80.36155700683594, longitude: 27.786846483587688),
      GeoJSON.Position(latitude: -80.35537719726562, longitude: 27.794743268514615),
      GeoJSON.Position(latitude: -80.36705017089844, longitude: 27.800209937418252),
      GeoJSON.Position(latitude: -80.36889553070068, longitude: 27.801918215058347),
      GeoJSON.Position(latitude: -80.3690242767334, longitude: 27.803930152059845),
      GeoJSON.Position(latitude: -80.36713600158691, longitude: 27.805942051806845),
      GeoJSON.Position(latitude: -80.36584854125977, longitude: 27.805524490772143),
      GeoJSON.Position(latitude: -80.36563396453857, longitude: 27.80465140342285),
      GeoJSON.Position(latitude: -80.36619186401367, longitude: 27.803095012921272),
      GeoJSON.Position(latitude: -80.36623477935791, longitude: 27.801842292177923),
      GeoJSON.Position(latitude: -80.36524772644043, longitude: 27.80127286888392),
      GeoJSON.Position(latitude: -80.36224365234375, longitude: 27.801158983867033),
      GeoJSON.Position(latitude: -80.36065578460693, longitude: 27.802639479776524),
      GeoJSON.Position(latitude: -80.36138534545898, longitude: 27.803740348273823),
      GeoJSON.Position(latitude: -80.36220073699951, longitude: 27.804803245204976),
      GeoJSON.Position(latitude: -80.36190032958984, longitude: 27.806625330038287),
      GeoJSON.Position(latitude: -80.3609561920166, longitude: 27.80742248254359),
      GeoJSON.Position(latitude: -80.35932540893555, longitude: 27.806853088493792),
      GeoJSON.Position(latitude: -80.35889625549315, longitude: 27.806321651354835),
      GeoJSON.Position(latitude: -80.35902500152588, longitude: 27.805448570411585),
      GeoJSON.Position(latitude: -80.35863876342773, longitude: 27.804461600896783),
      GeoJSON.Position(latitude: -80.35739421844482, longitude: 27.804461600896783),
      GeoJSON.Position(latitude: -80.35700798034668, longitude: 27.805334689771293),
      GeoJSON.Position(latitude: -80.35696506500244, longitude: 27.80673920932572),
      GeoJSON.Position(latitude: -80.35726547241211, longitude: 27.80772615814989),
      GeoJSON.Position(latitude: -80.35808086395264, longitude: 27.808295547623707),
      GeoJSON.Position(latitude: -80.3585958480835, longitude: 27.80928248230861),
      GeoJSON.Position(latitude: -80.35653591156006, longitude: 27.80943431761813),
      GeoJSON.Position(latitude: -80.35572052001953, longitude: 27.808637179875486),
      GeoJSON.Position(latitude: -80.3555917739868, longitude: 27.80772615814989),
      GeoJSON.Position(latitude: -80.3555917739868, longitude: 27.806055931810487),
      GeoJSON.Position(latitude: -80.35572052001953, longitude: 27.803778309057556),
      GeoJSON.Position(latitude: -80.35537719726562, longitude: 27.801804330717825),
      GeoJSON.Position(latitude: -80.3554630279541, longitude: 27.799564581098746),
      GeoJSON.Position(latitude: -80.35670757293701, longitude: 27.799564581098746),
      GeoJSON.Position(latitude: -80.35499095916748, longitude: 27.796831264786892),
      GeoJSON.Position(latitude: -80.34610748291016, longitude: 27.79478123244122),
      GeoJSON.Position(latitude: -80.34404754638672, longitude: 27.802070060660014),
      GeoJSON.Position(latitude: -80.34748077392578, longitude: 27.804955086774896),
      GeoJSON.Position(latitude: -80.3433609008789, longitude: 27.805790211616266),
      GeoJSON.Position(latitude: -80.34353256225586, longitude: 27.8101555324401),
      GeoJSON.Position(latitude: -80.33499240875244, longitude: 27.810079615315917),
      GeoJSON.Position(latitude: -80.33383369445801, longitude: 27.805676331334084),
      GeoJSON.Position(latitude: -80.33022880554199, longitude: 27.801652484744796),
      GeoJSON.Position(latitude: -80.32872676849365, longitude: 27.80848534345178),
    ]
    
    let simplifiedCoordinates = [
      GeoJSON.Position(latitude : -80.51399230957031, longitude : 28.069556808283608),
      GeoJSON.Position(latitude : -80.49819946289062, longitude : 28.05622661698537),
      GeoJSON.Position(latitude : -80.5023193359375, longitude : 28.04471284867091),
      GeoJSON.Position(latitude : -80.48583984375, longitude : 28.042288740362853),
      GeoJSON.Position(latitude : -80.50575256347656, longitude : 28.028349057505775),
      GeoJSON.Position(latitude : -80.49476623535156, longitude : 28.021075462659883),
      GeoJSON.Position(latitude : -80.47691345214844, longitude : 28.021075462659883),
      GeoJSON.Position(latitude : -80.49201965332031, longitude : 27.998039170620494),
      GeoJSON.Position(latitude : -80.46730041503906, longitude : 27.962262536875905),
      GeoJSON.Position(latitude : -80.46524047851562, longitude : 27.91980029694533),
      GeoJSON.Position(latitude : -80.40550231933594, longitude : 27.930114089618602),
      GeoJSON.Position(latitude : -80.39657592773438, longitude : 27.980455528671527),
      GeoJSON.Position(latitude : -80.41305541992188, longitude : 27.982274659104082),
      GeoJSON.Position(latitude : -80.42953491210938, longitude : 27.990763528690582),
      GeoJSON.Position(latitude : -80.4144287109375, longitude : 28.00955793247135),
      GeoJSON.Position(latitude : -80.3594970703125, longitude : 27.972572275562527),
      GeoJSON.Position(latitude : -80.38215637207031, longitude : 27.913732900444284),
      GeoJSON.Position(latitude : -80.41786193847656, longitude : 27.881570017022806),
      GeoJSON.Position(latitude : -80.39382934570312, longitude : 27.85425440786446),
      GeoJSON.Position(latitude : -80.37803649902344, longitude : 27.86336037597851),
      GeoJSON.Position(latitude : -80.38215637207031, longitude : 27.880963078302393),
      GeoJSON.Position(latitude : -80.36842346191405, longitude : 27.888246118437756),
      GeoJSON.Position(latitude : -80.35743713378906, longitude : 27.882176952341734),
      GeoJSON.Position(latitude : -80.3594970703125, longitude : 27.8421119273228),
      GeoJSON.Position(latitude : -80.37940979003906, longitude : 27.83300417483936),
      GeoJSON.Position(latitude : -80.39932250976561, longitude : 27.82511017099003),
      GeoJSON.Position(latitude : -80.40069580078125, longitude : 27.79352841586229),
      GeoJSON.Position(latitude : -80.36155700683594, longitude : 27.786846483587688),
      GeoJSON.Position(latitude : -80.35537719726562, longitude : 27.794743268514615),
      GeoJSON.Position(latitude : -80.36705017089844, longitude : 27.800209937418252),
      GeoJSON.Position(latitude : -80.35932540893555, longitude : 27.806853088493792),
      GeoJSON.Position(latitude : -80.35499095916748, longitude : 27.796831264786892),
      GeoJSON.Position(latitude : -80.34404754638672, longitude : 27.802070060660014),
      GeoJSON.Position(latitude : -80.33499240875244, longitude : 27.810079615315917),
      GeoJSON.Position(latitude : -80.32872676849365, longitude : 27.80848534345178),
    ]
    let original = GeoJSON.LineString(positions: coordinates)
    let simplified = original.simplify(tolerance: 0.01, highestQuality: false).coordinates
    XCTAssertEqual(simplified, simplifiedCoordinates)
    XCTAssertEqual(simplified.first, coordinates.first)
    XCTAssertEqual(simplified.last, coordinates.last)
  }
}
