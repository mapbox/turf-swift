import XCTest
#if !os(Linux)
import CoreLocation
#endif
import GeoJSONKit
@testable import GeoJSONKitTurf

class PolygonTests: XCTestCase {
  
  func testPolygonContains() {
    let coordinate = GeoJSON.Position(latitude: 44, longitude: -77)
    let polygon = GeoJSON.Polygon([[
      .init(latitude: 41, longitude: -81),
      .init(latitude: 47, longitude: -81),
      .init(latitude: 47, longitude: -72),
      .init(latitude: 41, longitude: -72),
      .init(latitude: 41, longitude: -81),
    ]])
    XCTAssertTrue(polygon.contains(coordinate))
  }
  
  func testPolygonDoesNotContain() {
    let coordinate = GeoJSON.Position(latitude: 44, longitude: -77)
    let polygon = GeoJSON.Polygon([[
      GeoJSON.Position(latitude: 41, longitude: -51),
      GeoJSON.Position(latitude: 47, longitude: -51),
      GeoJSON.Position(latitude: 47, longitude: -42),
      GeoJSON.Position(latitude: 41, longitude: -42),
      GeoJSON.Position(latitude: 41, longitude: -51),
    ]])
    XCTAssertFalse(polygon.contains(coordinate))
  }
  
  func testPolygonDoesNotContainWithHole() {
    let coordinate = GeoJSON.Position(latitude: 44, longitude: -77)
    let polygon = GeoJSON.Polygon([
      [
        GeoJSON.Position(latitude: 41, longitude: -81),
        GeoJSON.Position(latitude: 47, longitude: -81),
        GeoJSON.Position(latitude: 47, longitude: -72),
        GeoJSON.Position(latitude: 41, longitude: -72),
        GeoJSON.Position(latitude: 41, longitude: -81),
      ],
      [
        GeoJSON.Position(latitude: 43, longitude: -76),
        GeoJSON.Position(latitude: 43, longitude: -78),
        GeoJSON.Position(latitude: 45, longitude: -78),
        GeoJSON.Position(latitude: 45, longitude: -76),
        GeoJSON.Position(latitude: 43, longitude: -76),
      ],
    ])
    XCTAssertFalse(polygon.contains(coordinate))
  }
  
  func testPolygonContainsAtBoundary() {
    let coordinate = GeoJSON.Position(latitude: 1, longitude: 1)
    let polygon = GeoJSON.Polygon([[
      GeoJSON.Position(latitude: 0, longitude: 0),
      GeoJSON.Position(latitude: 1, longitude: 0),
      GeoJSON.Position(latitude: 1, longitude: 1),
      GeoJSON.Position(latitude: 0, longitude: 1),
      GeoJSON.Position(latitude: 0, longitude: 0),
    ]])
    
    XCTAssertFalse(polygon.contains(coordinate, ignoreBoundary: true))
    XCTAssertTrue(polygon.contains(coordinate, ignoreBoundary: false))
    XCTAssertTrue(polygon.contains(coordinate))
  }
  
  func testPolygonWithHoleContainsAtBoundary() {
    let coordinate = GeoJSON.Position(latitude: 43, longitude: -78)
    let polygon = GeoJSON.Polygon([
      [
        GeoJSON.Position(latitude: 41, longitude: -81),
        GeoJSON.Position(latitude: 47, longitude: -81),
        GeoJSON.Position(latitude: 47, longitude: -72),
        GeoJSON.Position(latitude: 41, longitude: -72),
        GeoJSON.Position(latitude: 41, longitude: -81),
      ],
      [
        GeoJSON.Position(latitude: 43, longitude: -76),
        GeoJSON.Position(latitude: 43, longitude: -78),
        GeoJSON.Position(latitude: 45, longitude: -78),
        GeoJSON.Position(latitude: 45, longitude: -76),
        GeoJSON.Position(latitude: 43, longitude: -76),
      ],
    ])
    
    XCTAssertFalse(polygon.contains(coordinate, ignoreBoundary: true))
    XCTAssertTrue(polygon.contains(coordinate, ignoreBoundary: false))
    XCTAssertTrue(polygon.contains(coordinate))
  }
  
  func testCirclePolygon()
  {
    let coord = GeoJSON.Position(latitude: 10.0, longitude: 5.0)
    let radius = 500
    let circleShape = GeoJSON.Polygon(center: coord, radius: LocationDistance(radius), vertices: 64)
    
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
  
  func testSmoothClose() {
    let original = [
      [
        GeoJSON.Position(latitude: 18.28125, longitude: 39.095962936305476),
        GeoJSON.Position(latitude: 32.34375, longitude: 31.653381399664),
        GeoJSON.Position(latitude: 19.6875, longitude: 17.97873309555617),
        GeoJSON.Position(latitude: 35.15625, longitude: 10.833305983642491),
        GeoJSON.Position(latitude: 19.6875, longitude: 0),
        GeoJSON.Position(latitude: 32.6953125, longitude: -2.811371193331128),
        GeoJSON.Position(latitude: 40.78125, longitude: 13.923403897723347),
        GeoJSON.Position(latitude: 24.2578125, longitude: 17.97873309555617),
        GeoJSON.Position(latitude: 33.75, longitude: 31.952162238024975),
        GeoJSON.Position(latitude: 29.53125, longitude: 40.713955826286046),
        GeoJSON.Position(latitude: 22.8515625, longitude: 40.713955826286046),
        GeoJSON.Position(latitude: 18.28125, longitude: 39.095962936305476),
      ]
    ]
    let expected = [
      [
        GeoJSON.Position(latitude: 24.43359375, longitude: 35.83983351402483),
        GeoJSON.Position(latitude: 26.19140625, longitude: 34.90951082194465),
        GeoJSON.Position(latitude: 27.53173828125, longitude: 33.8818120866228),
        GeoJSON.Position(latitude: 28.45458984375, longitude: 32.7567373080593),
        GeoJSON.Position(latitude: 28.9599609375, longitude: 31.534286486254125),
        GeoJSON.Position(latitude: 29.0478515625, longitude: 30.21445962120729),
        GeoJSON.Position(latitude: 28.71826171875, longitude: 28.797256712918795),
        GeoJSON.Position(latitude: 27.97119140625, longitude: 27.28267776138864),
        GeoJSON.Position(latitude: 26.806640625, longitude: 25.670722766616823),
        GeoJSON.Position(latitude: 25.224609375, longitude: 23.961391728603346),
        GeoJSON.Position(latitude: 24.08203125, longitude: 22.3540797717179),
        GeoJSON.Position(latitude: 23.37890625, longitude: 20.84878689596049),
        GeoJSON.Position(latitude: 23.115234375, longitude: 19.445513101331112),
        GeoJSON.Position(latitude: 23.291015625, longitude: 18.144258387829765),
        GeoJSON.Position(latitude: 23.90625, longitude: 16.945022755456456),
        GeoJSON.Position(latitude: 24.9609375, longitude: 15.847806204211178),
        GeoJSON.Position(latitude: 26.455078125, longitude: 14.852608734093936),
        GeoJSON.Position(latitude: 28.388671875, longitude: 13.959430345104726),
        GeoJSON.Position(latitude: 29.8388671875, longitude: 13.008628848744754),
        GeoJSON.Position(latitude: 30.8056640625, longitude: 12.000204245014018),
        GeoJSON.Position(latitude: 31.2890625, longitude: 10.934156533912521),
        GeoJSON.Position(latitude: 31.2890625, longitude: 9.81048571544026),
        GeoJSON.Position(latitude: 30.8056640625, longitude: 8.629191789597236),
        GeoJSON.Position(latitude: 29.8388671875, longitude: 7.39027475638345),
        GeoJSON.Position(latitude: 28.388671875, longitude: 6.093734615798901),
        GeoJSON.Position(latitude: 26.455078125, longitude: 4.73957136784359),
        GeoJSON.Position(latitude: 24.9664306640625, longitude: 3.5107508509868937),
        GeoJSON.Position(latitude: 23.9227294921875, longitude: 2.4072730652288126),
        GeoJSON.Position(latitude: 23.323974609375, longitude: 1.429138010569346),
        GeoJSON.Position(latitude: 23.170166015625, longitude: 0.5763456870084949),
        GeoJSON.Position(latitude: 23.4613037109375, longitude: -0.15110390545374128),
        GeoJSON.Position(latitude: 24.1973876953125, longitude: -0.7532107668173623),
        GeoJSON.Position(latitude: 25.37841796875, longitude: -1.2299748970823683),
        GeoJSON.Position(latitude: 27.00439453125, longitude: -1.581396296248759),
        GeoJSON.Position(latitude: 28.553466796875, longitude: -1.6274091597216251),
        GeoJSON.Position(latitude: 30.025634765625, longitude: -1.3680134875009662),
        GeoJSON.Position(latitude: 31.4208984375, longitude: -0.803209279586782),
        GeoJSON.Position(latitude: 32.7392578125, longitude: 0.06700346402092716),
        GeoJSON.Position(latitude: 33.980712890625, longitude: 1.2426247433221613),
        GeoJSON.Position(latitude: 35.145263671875, longitude: 2.7236545583169205),
        GeoJSON.Position(latitude: 36.23291015625, longitude: 4.510092909005205),
        GeoJSON.Position(latitude: 37.24365234375, longitude: 6.601939795387015),
        GeoJSON.Position(latitude: 37.869873046875, longitude: 8.495670339687235),
        GeoJSON.Position(latitude: 38.111572265625, longitude: 10.191284541905867),
        GeoJSON.Position(latitude: 37.96875, longitude: 11.68878240204291),
        GeoJSON.Position(latitude: 37.44140625, longitude: 12.98816392009837),
        GeoJSON.Position(latitude: 36.529541015625, longitude: 14.089429096072237),
        GeoJSON.Position(latitude: 35.233154296875, longitude: 14.992577929964515),
        GeoJSON.Position(latitude: 33.55224609375, longitude: 15.697610421775206),
        GeoJSON.Position(latitude: 31.48681640625, longitude: 16.20452657150431),
        GeoJSON.Position(latitude: 29.827880859375, longitude: 16.86641303286835),
        GeoJSON.Position(latitude: 28.575439453125, longitude: 17.683269805867326),
        GeoJSON.Position(latitude: 27.7294921875, longitude: 18.65509689050124),
        GeoJSON.Position(latitude: 27.2900390625, longitude: 19.781894286770097),
        GeoJSON.Position(latitude: 27.257080078125, longitude: 21.063661994673886),
        GeoJSON.Position(latitude: 27.630615234375, longitude: 22.50040001421261),
        GeoJSON.Position(latitude: 28.41064453125, longitude: 24.092108345386272),
        GeoJSON.Position(latitude: 29.59716796875, longitude: 25.838786988194872),
        GeoJSON.Position(latitude: 30.5694580078125, longitude: 27.504033825468973),
        GeoJSON.Position(latitude: 31.3275146484375, longitude: 29.087848857208584),
        GeoJSON.Position(latitude: 31.871337890625, longitude: 30.590232083413696),
        GeoJSON.Position(latitude: 32.200927734375, longitude: 32.011183504084315),
        GeoJSON.Position(latitude: 32.3162841796875, longitude: 33.35070311922044),
        GeoJSON.Position(latitude: 32.2174072265625, longitude: 34.60879092882206),
        GeoJSON.Position(latitude: 31.904296875, longitude: 35.785446932889194),
        GeoJSON.Position(latitude: 31.376953125, longitude: 36.88067113142183),
        GeoJSON.Position(latitude: 30.8111572265625, longitude: 37.83899230513788),
        GeoJSON.Position(latitude: 30.2069091796875, longitude: 38.66041045403736),
        GeoJSON.Position(latitude: 29.564208984375, longitude: 39.344925578120254),
        GeoJSON.Position(latitude: 28.883056640625, longitude: 39.89253767738657),
        GeoJSON.Position(latitude: 28.1634521484375, longitude: 40.30324675183631),
        GeoJSON.Position(latitude: 27.4053955078125, longitude: 40.57705280146946),
        GeoJSON.Position(latitude: 26.60888671875, longitude: 40.713955826286046),
        GeoJSON.Position(latitude: 25.77392578125, longitude: 40.713955826286046),
        GeoJSON.Position(latitude: 24.971923828125, longitude: 40.6886746873801),
        GeoJSON.Position(latitude: 24.202880859375, longitude: 40.6381124095682),
        GeoJSON.Position(latitude: 23.466796875, longitude: 40.56226899285036),
        GeoJSON.Position(latitude: 22.763671875, longitude: 40.46114443722658),
        GeoJSON.Position(latitude: 22.093505859375, longitude: 40.33473874269685),
        GeoJSON.Position(latitude: 21.456298828125, longitude: 40.183051909261174),
        GeoJSON.Position(latitude: 20.85205078125, longitude: 40.00608393691955),
        GeoJSON.Position(latitude: 20.28076171875, longitude: 39.80383482567197),
        GeoJSON.Position(latitude: 20.0006103515625, longitude: 39.51057651682032),
        GeoJSON.Position(latitude: 20.0115966796875, longitude: 39.12630901036461),
        GeoJSON.Position(latitude: 20.313720703125, longitude: 38.6510323063048),
        GeoJSON.Position(latitude: 20.906982421875, longitude: 38.084746404640924),
        GeoJSON.Position(latitude: 21.7913818359375, longitude: 37.42745130537297),
        GeoJSON.Position(latitude: 22.9669189453125, longitude: 36.679147008500934),
        GeoJSON.Position(latitude: 24.43359375, longitude: 35.83983351402483),
      ]
    ]
    
    let polygon = GeoJSON.Polygon(original)
    let smoothed = polygon.smooth()
    
    XCTAssertEqual(smoothed.coordinates, expected)
  }
  
  func testSmoothGeometry() {
    let original = [
      [
        GeoJSON.Position(latitude: 2.28515625, longitude: 27.761329874505233),
        GeoJSON.Position(latitude: -5.537109374999999, longitude: 21.616579336740603),
        GeoJSON.Position(latitude: -0.087890625, longitude: 17.14079039331665),
        GeoJSON.Position(latitude: 0.87890625, longitude: 21.37124437061831),
        GeoJSON.Position(latitude: 4.482421875, longitude: 19.72534224805787),
        GeoJSON.Position(latitude: 5.09765625, longitude: 22.51255695405145),
        GeoJSON.Position(latitude: 10.458984375, longitude: 24.607069137709683),
        GeoJSON.Position(latitude: 3.076171875, longitude: 26.194876675795218),
        GeoJSON.Position(latitude: 6.15234375, longitude: 29.305561325527698),
        GeoJSON.Position(latitude: 2.28515625, longitude: 27.761329874505233),
      ]
    ]
    
    let expected = [
      [
        GeoJSON.Position(latitude: -1.1370849609374996, longitude: 25.073001514233205),
        GeoJSON.Position(latitude: -2.114868164062499, longitude: 24.30490769701263),
        GeoJSON.Position(latitude: -2.885284423828124, longitude: 23.562891404703624),
        GeoJSON.Position(latitude: -3.448333740234374, longitude: 22.84695263730619),
        GeoJSON.Position(latitude: -3.804016113281249, longitude: 22.157091394820334),
        GeoJSON.Position(latitude: -3.952331542968749, longitude: 21.493307677246044),
        GeoJSON.Position(latitude: -3.893280029296874, longitude: 20.85560148458333),
        GeoJSON.Position(latitude: -3.626861572265624, longitude: 20.24397281683219),
        GeoJSON.Position(latitude: -3.153076171874999, longitude: 19.65842167399262),
        GeoJSON.Position(latitude: -2.471923828124999, longitude: 19.09894805606463),
        GeoJSON.Position(latitude: -1.8608093261718746, longitude: 18.675509483772974),
        GeoJSON.Position(latitude: -1.3197326660156246, longitude: 18.388105957117656),
        GeoJSON.Position(latitude: -0.8486938476562498, longitude: 18.236737476098675),
        GeoJSON.Position(latitude: -0.4476928710937499, longitude: 18.22140404071603),
        GeoJSON.Position(latitude: -0.11672973632812494, longitude: 18.342105650969724),
        GeoJSON.Position(latitude: 0.144195556640625, longitude: 18.59884230685976),
        GeoJSON.Position(latitude: 0.3350830078125, longitude: 18.991614008386126),
        GeoJSON.Position(latitude: 0.4559326171875, longitude: 19.520420755548834),
        GeoJSON.Position(latitude: 0.61798095703125, longitude: 19.957409438651194),
        GeoJSON.Position(latitude: 0.82122802734375, longitude: 20.302580057693213),
        GeoJSON.Position(latitude: 1.065673828125, longitude: 20.555932612674884),
        GeoJSON.Position(latitude: 1.351318359375, longitude: 20.71746710359621),
        GeoJSON.Position(latitude: 1.67816162109375, longitude: 20.78718353045719),
        GeoJSON.Position(latitude: 2.04620361328125, longitude: 20.765081893257825),
        GeoJSON.Position(latitude: 2.4554443359375, longitude: 20.651162191998118),
        GeoJSON.Position(latitude: 2.9058837890625, longitude: 20.445424426678063),
        GeoJSON.Position(latitude: 3.30963134765625, longitude: 20.308954111804166),
        GeoJSON.Position(latitude: 3.66668701171875, longitude: 20.241751247376424),
        GeoJSON.Position(latitude: 3.97705078125, longitude: 20.243815833394837),
        GeoJSON.Position(latitude: 4.24072265625, longitude: 20.31514786985941),
        GeoJSON.Position(latitude: 4.45770263671875, longitude: 20.455747356770136),
        GeoJSON.Position(latitude: 4.62799072265625, longitude: 20.66561429412702),
        GeoJSON.Position(latitude: 4.7515869140625, longitude: 20.94474868193006),
        GeoJSON.Position(latitude: 4.8284912109375, longitude: 21.29315052017926),
        GeoJSON.Position(latitude: 4.97955322265625, longitude: 21.63072888151697),
        GeoJSON.Position(latitude: 5.20477294921875, longitude: 21.957483765943184),
        GeoJSON.Position(latitude: 5.504150390625, longitude: 22.273415173457913),
        GeoJSON.Position(latitude: 5.877685546875, longitude: 22.578523104061155),
        GeoJSON.Position(latitude: 6.32537841796875, longitude: 22.872807557752903),
        GeoJSON.Position(latitude: 6.84722900390625, longitude: 23.156268534533158),
        GeoJSON.Position(latitude: 7.4432373046875, longitude: 23.428906034401926),
        GeoJSON.Position(latitude: 8.1134033203125, longitude: 23.690720057359208),
        GeoJSON.Position(latitude: 8.584442138671875, longitude: 23.944616820229413),
        GeoJSON.Position(latitude: 8.856353759765625, longitude: 24.190596323012542),
        GeoJSON.Position(latitude: 8.92913818359375, longitude: 24.428658565708602),
        GeoJSON.Position(latitude: 8.80279541015625, longitude: 24.658803548317586),
        GeoJSON.Position(latitude: 8.477325439453125, longitude: 24.8810312708395),
        GeoJSON.Position(latitude: 7.952728271484375, longitude: 25.09534173327434),
        GeoJSON.Position(latitude: 7.22900390625, longitude: 25.301734935622104),
        GeoJSON.Position(latitude: 6.30615234375, longitude: 25.500210877882797),
        GeoJSON.Position(latitude: 5.546722412109375, longitude: 25.722481775012973),
        GeoJSON.Position(latitude: 4.950714111328125, longitude: 25.968547627012633),
        GeoJSON.Position(latitude: 4.51812744140625, longitude: 26.238408433881773),
        GeoJSON.Position(latitude: 4.24896240234375, longitude: 26.532064195620396),
        GeoJSON.Position(latitude: 4.143218994140625, longitude: 26.849514912228507),
        GeoJSON.Position(latitude: 4.200897216796875, longitude: 27.1907605837061),
        GeoJSON.Position(latitude: 4.4219970703125, longitude: 27.555801210053176),
        GeoJSON.Position(latitude: 4.8065185546875, longitude: 27.944636791269737),
        GeoJSON.Position(latitude: 5.082550048828125, longitude: 28.260739308412003),
        GeoJSON.Position(latitude: 5.250091552734375, longitude: 28.50410876147997),
        GeoJSON.Position(latitude: 5.30914306640625, longitude: 28.674745150473644),
        GeoJSON.Position(latitude: 5.25970458984375, longitude: 28.77264847539302),
        GeoJSON.Position(latitude: 5.101776123046875, longitude: 28.7978187362381),
        GeoJSON.Position(latitude: 4.835357666015625, longitude: 28.750255933008884),
        GeoJSON.Position(latitude: 4.46044921875, longitude: 28.62996006570537),
        GeoJSON.Position(latitude: 3.97705078125, longitude: 28.436931134327562),
        GeoJSON.Position(latitude: 3.431854248046875, longitude: 28.172019092219408),
        GeoJSON.Position(latitude: 2.824859619140625, longitude: 27.835223939380903),
        GeoJSON.Position(latitude: 2.15606689453125, longitude: 27.426545675812058),
        GeoJSON.Position(latitude: 1.4254760742187502, longitude: 26.945984301512862),
        GeoJSON.Position(latitude: 0.6330871582031253, longitude: 26.393539816483322),
        GeoJSON.Position(latitude: -0.2210998535156246, longitude: 25.76921222072344),
        GeoJSON.Position(latitude: -1.1370849609374996, longitude: 25.073001514233205)
      ]
    ]
    
    let polygon = GeoJSON.Polygon(original)
    let smoothed = polygon.smooth()
    
    XCTAssertEqual(smoothed.coordinates, expected)
  }
  
  func testSmoothWithHole() {
    let original = [
      [
        GeoJSON.Position(latitude: 100.0, longitude: 0.0),
        GeoJSON.Position(latitude: 101.0, longitude: 0.0),
        GeoJSON.Position(latitude: 101.0, longitude: 1.0),
        GeoJSON.Position(latitude: 100.0, longitude: 1.0),
        GeoJSON.Position(latitude: 100.0, longitude: 0.0)
      ],
      [
        GeoJSON.Position(latitude: 100.2, longitude: 0.2),
        GeoJSON.Position(latitude: 100.8, longitude: 0.2),
        GeoJSON.Position(latitude: 100.8, longitude: 0.8),
        GeoJSON.Position(latitude: 100.2, longitude: 0.8),
        GeoJSON.Position(latitude: 100.2, longitude: 0.2)
      ]
    ]
    
    let expected = [
      [
        GeoJSON.Position(latitude: 100.4375, longitude: 0),
        GeoJSON.Position(latitude: 100.5625, longitude: 0),
        GeoJSON.Position(latitude: 100.671875, longitude: 0.015625),
        GeoJSON.Position(latitude: 100.765625, longitude: 0.046875),
        GeoJSON.Position(latitude: 100.84375, longitude: 0.09375),
        GeoJSON.Position(latitude: 100.90625, longitude: 0.15625),
        GeoJSON.Position(latitude: 100.953125, longitude: 0.234375),
        GeoJSON.Position(latitude: 100.984375, longitude: 0.328125),
        GeoJSON.Position(latitude: 101, longitude: 0.4375),
        GeoJSON.Position(latitude: 101, longitude: 0.5625),
        GeoJSON.Position(latitude: 100.984375, longitude: 0.671875),
        GeoJSON.Position(latitude: 100.953125, longitude: 0.765625),
        GeoJSON.Position(latitude: 100.90625, longitude: 0.84375),
        GeoJSON.Position(latitude: 100.84375, longitude: 0.90625),
        GeoJSON.Position(latitude: 100.765625, longitude: 0.953125),
        GeoJSON.Position(latitude: 100.671875, longitude: 0.984375),
        GeoJSON.Position(latitude: 100.5625, longitude: 1),
        GeoJSON.Position(latitude: 100.4375, longitude: 1),
        GeoJSON.Position(latitude: 100.328125, longitude: 0.984375),
        GeoJSON.Position(latitude: 100.234375, longitude: 0.953125),
        GeoJSON.Position(latitude: 100.15625, longitude: 0.90625),
        GeoJSON.Position(latitude: 100.09375, longitude: 0.84375),
        GeoJSON.Position(latitude: 100.046875, longitude: 0.765625),
        GeoJSON.Position(latitude: 100.015625, longitude: 0.671875),
        GeoJSON.Position(latitude: 100, longitude: 0.5625),
        GeoJSON.Position(latitude: 100, longitude: 0.4375),
        GeoJSON.Position(latitude: 100.015625, longitude: 0.328125),
        GeoJSON.Position(latitude: 100.046875, longitude: 0.234375),
        GeoJSON.Position(latitude: 100.09375, longitude: 0.15625),
        GeoJSON.Position(latitude: 100.15625, longitude: 0.09375),
        GeoJSON.Position(latitude: 100.234375, longitude: 0.046875),
        GeoJSON.Position(latitude: 100.328125, longitude: 0.015625),
        GeoJSON.Position(latitude: 100.4375, longitude: 0)
      ],
      [
        GeoJSON.Position(latitude: 100.46249999999999, longitude: 0.2),
        GeoJSON.Position(latitude: 100.53750000000001, longitude: 0.2),
        GeoJSON.Position(latitude: 100.603125, longitude: 0.20937500000000003),
        GeoJSON.Position(latitude: 100.659375, longitude: 0.22812500000000002),
        GeoJSON.Position(latitude: 100.70625, longitude: 0.25625000000000003),
        GeoJSON.Position(latitude: 100.74374999999999, longitude: 0.29375),
        GeoJSON.Position(latitude: 100.771875, longitude: 0.340625),
        GeoJSON.Position(latitude: 100.79062499999999, longitude: 0.39687500000000003),
        GeoJSON.Position(latitude: 100.8, longitude: 0.4625),
        GeoJSON.Position(latitude: 100.8, longitude: 0.5375000000000001),
        GeoJSON.Position(latitude: 100.79062499999999, longitude: 0.603125),
        GeoJSON.Position(latitude: 100.771875, longitude: 0.6593750000000002),
        GeoJSON.Position(latitude: 100.74374999999999, longitude: 0.7062500000000002),
        GeoJSON.Position(latitude: 100.70625, longitude: 0.7437500000000001),
        GeoJSON.Position(latitude: 100.659375, longitude: 0.7718750000000001),
        GeoJSON.Position(latitude: 100.603125, longitude: 0.7906250000000001),
        GeoJSON.Position(latitude: 100.53750000000001, longitude: 0.8),
        GeoJSON.Position(latitude: 100.46249999999999, longitude: 0.8),
        GeoJSON.Position(latitude: 100.396875, longitude: 0.7906250000000001),
        GeoJSON.Position(latitude: 100.340625, longitude: 0.7718750000000001),
        GeoJSON.Position(latitude: 100.29375, longitude: 0.7437500000000001),
        GeoJSON.Position(latitude: 100.25625000000001, longitude: 0.7062500000000002),
        GeoJSON.Position(latitude: 100.228125, longitude: 0.6593750000000002),
        GeoJSON.Position(latitude: 100.20937500000001, longitude: 0.603125),
        GeoJSON.Position(latitude: 100.2, longitude: 0.5375000000000001),
        GeoJSON.Position(latitude: 100.2, longitude: 0.4625),
        GeoJSON.Position(latitude: 100.20937500000001, longitude: 0.39687500000000003),
        GeoJSON.Position(latitude: 100.228125, longitude: 0.340625),
        GeoJSON.Position(latitude: 100.25625000000001, longitude: 0.29375),
        GeoJSON.Position(latitude: 100.29375, longitude: 0.25625000000000003),
        GeoJSON.Position(latitude: 100.340625, longitude: 0.22812500000000002),
        GeoJSON.Position(latitude: 100.396875, longitude: 0.20937500000000003),
        GeoJSON.Position(latitude: 100.46249999999999, longitude: 0.2)
      ]
    ]
    
    let polygon = GeoJSON.Polygon(original)
    let smoothed = polygon.smooth()
    
    XCTAssertEqual(smoothed.coordinates, expected)
  }
  
  func testSimplifySimplePolygon() {
    let original = [
      [
        GeoJSON.Position(latitude: 26.148429528000065, longitude: -28.29755210099995),
        GeoJSON.Position(latitude: 26.148582685000065, longitude: -28.29778390599995),
        GeoJSON.Position(latitude: 26.149207731000047, longitude: -28.29773837299996),
        GeoJSON.Position(latitude: 26.14925541100007, longitude: -28.297771688999944),
        GeoJSON.Position(latitude: 26.149255844000038, longitude: -28.297773261999964),
        GeoJSON.Position(latitude: 26.149276505000046, longitude: -28.29784835099997),
        GeoJSON.Position(latitude: 26.14928482700003, longitude: -28.29787859399994),
        GeoJSON.Position(latitude: 26.14928916200006, longitude: -28.29800647199994),
        GeoJSON.Position(latitude: 26.14931069800008, longitude: -28.298641791999955),
        GeoJSON.Position(latitude: 26.149339971000074, longitude: -28.298641232999955),
        GeoJSON.Position(latitude: 26.151298488000066, longitude: -28.29860385099994),
        GeoJSON.Position(latitude: 26.151290002000053, longitude: -28.298628995999934),
        GeoJSON.Position(latitude: 26.151417002000073, longitude: -28.299308003999954),
        GeoJSON.Position(latitude: 26.15159000400007, longitude: -28.299739003999946),
        GeoJSON.Position(latitude: 26.151951998000072, longitude: -28.30051100299994),
        GeoJSON.Position(latitude: 26.15206407200003, longitude: -28.30076885099993),
        GeoJSON.Position(latitude: 26.152066543000046, longitude: -28.30077453499996),
        GeoJSON.Position(latitude: 26.151987021000025, longitude: -28.300799009999935),
        GeoJSON.Position(latitude: 26.149896693000073, longitude: -28.301442350999935),
        GeoJSON.Position(latitude: 26.150354333000053, longitude: -28.30260575099993),
        GeoJSON.Position(latitude: 26.14914131000006, longitude: -28.302975170999957),
        GeoJSON.Position(latitude: 26.14836387300005, longitude: -28.302853868999932),
        GeoJSON.Position(latitude: 26.147575408000023, longitude: -28.30269948399996),
        GeoJSON.Position(latitude: 26.146257624000043, longitude: -28.302462392999928),
        GeoJSON.Position(latitude: 26.14557943400007, longitude: -28.302181192999967),
        GeoJSON.Position(latitude: 26.145492669000078, longitude: -28.302154609999945),
        GeoJSON.Position(latitude: 26.144921243000056, longitude: -28.303395982999973),
        GeoJSON.Position(latitude: 26.14482272200007, longitude: -28.30455853999996),
        GeoJSON.Position(latitude: 26.14431040900007, longitude: -28.30451913099995),
        GeoJSON.Position(latitude: 26.14429070400007, longitude: -28.304144747999942),
        GeoJSON.Position(latitude: 26.143837504000032, longitude: -28.304144747999942),
        GeoJSON.Position(latitude: 26.143613499000026, longitude: -28.304592757999956),
        GeoJSON.Position(latitude: 26.14346312200007, longitude: -28.304893512999968),
        GeoJSON.Position(latitude: 26.143260178000048, longitude: -28.304893512999968),
        GeoJSON.Position(latitude: 26.143246374000057, longitude: -28.304893512999968),
        GeoJSON.Position(latitude: 26.143147852000027, longitude: -28.304893512999968),
        GeoJSON.Position(latitude: 26.14295080900007, longitude: -28.304834399999947),
        GeoJSON.Position(latitude: 26.14200500000004, longitude: -28.30449942699994),
        GeoJSON.Position(latitude: 26.14198529600003, longitude: -28.304420608999976),
        GeoJSON.Position(latitude: 26.141525339000054, longitude: -28.304298579999966),
        GeoJSON.Position(latitude: 26.141019783000047, longitude: -28.30416445299994),
        GeoJSON.Position(latitude: 26.141118305000077, longitude: -28.304637356999933),
        GeoJSON.Position(latitude: 26.140940966000073, longitude: -28.30512996599998),
        GeoJSON.Position(latitude: 26.140376789000072, longitude: -28.306172836999963),
        GeoJSON.Position(latitude: 26.140476282000066, longitude: -28.30621363399996),
        GeoJSON.Position(latitude: 26.14041675800007, longitude: -28.306326533999936),
        GeoJSON.Position(latitude: 26.140146555000058, longitude: -28.30640398099996),
        GeoJSON.Position(latitude: 26.140073975000064, longitude: -28.306410747999962),
        GeoJSON.Position(latitude: 26.137315367000042, longitude: -28.305189078999945),
        GeoJSON.Position(latitude: 26.136645419000047, longitude: -28.304854104999947),
        GeoJSON.Position(latitude: 26.135719315000074, longitude: -28.30451913099995),
        GeoJSON.Position(latitude: 26.135515376000058, longitude: -28.304330879999952),
        GeoJSON.Position(latitude: 26.13546315800005, longitude: -28.304282678999982),
        GeoJSON.Position(latitude: 26.13558800000004, longitude: -28.30419999999998),
        GeoJSON.Position(latitude: 26.137463000000025, longitude: -28.30242899999996),
        GeoJSON.Position(latitude: 26.13794500000006, longitude: -28.30202799999995),
        GeoJSON.Position(latitude: 26.13796479100006, longitude: -28.30201049699997),
        GeoJSON.Position(latitude: 26.13798299700005, longitude: -28.302025000999947),
        GeoJSON.Position(latitude: 26.139450004000025, longitude: -28.30074499999995),
        GeoJSON.Position(latitude: 26.141302000000053, longitude: -28.29914199999996),
        GeoJSON.Position(latitude: 26.141913997000074, longitude: -28.29862600399997),
        GeoJSON.Position(latitude: 26.14212216900006, longitude: -28.29845037299998),
        GeoJSON.Position(latitude: 26.144304360000035, longitude: -28.296499429999983),
        GeoJSON.Position(latitude: 26.144799071000023, longitude: -28.29614006399993),
        GeoJSON.Position(latitude: 26.145209090000037, longitude: -28.295759748999956),
        GeoJSON.Position(latitude: 26.145465732000048, longitude: -28.295507246999932),
        GeoJSON.Position(latitude: 26.14575028200005, longitude: -28.295352539999953),
        GeoJSON.Position(latitude: 26.14589208800004, longitude: -28.295275441999934),
        GeoJSON.Position(latitude: 26.146584820000044, longitude: -28.295135245999973),
        GeoJSON.Position(latitude: 26.146587504000024, longitude: -28.295134702999974),
        GeoJSON.Position(latitude: 26.146827588000065, longitude: -28.295606591999956),
        GeoJSON.Position(latitude: 26.14685742000006, longitude: -28.29565372899998),
        GeoJSON.Position(latitude: 26.14691261200005, longitude: -28.29574093599996),
        GeoJSON.Position(latitude: 26.147077344000024, longitude: -28.296001226999977),
        GeoJSON.Position(latitude: 26.147117344000037, longitude: -28.296041226999932),
        GeoJSON.Position(latitude: 26.147907966000048, longitude: -28.29696016899993),
        GeoJSON.Position(latitude: 26.147913396000035, longitude: -28.296966331999954),
        GeoJSON.Position(latitude: 26.148429528000065, longitude: -28.29755210099995)
      ]
    ]
    
    let expected = [
      [
        GeoJSON.Position(latitude: 26.148429528000065, longitude: -28.29755210099995),
        GeoJSON.Position(latitude: 26.135515376000058, longitude: -28.304330879999952),
        GeoJSON.Position(latitude: 26.13546315800005, longitude: -28.304282678999982),
        GeoJSON.Position(latitude: 26.148429528000065, longitude: -28.29755210099995)
      ]
    ]
    
    let polygon = GeoJSON.Polygon(original)
    let simplified = polygon.simplify(tolerance: 100, highestQuality: false);
    
    XCTAssertEqual(simplified.coordinates, expected)
  }
}
