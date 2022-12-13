import Foundation
import CoreLocation

private typealias WKTConsumer = Consumer<WKTLabel>

enum WKTError: Error {
    case invalidNumber(String)
    case invalidCodePoint(String)
}

func parseWKT(_ input: String) throws -> Any {
    let match = try wktConsumer.match(input.uppercased())
    return try match.transform(wktTransform)!
}


private enum WKTLabel: String {
    case number
    case coordinate
    case coordinatesArray
    case coordinatesArray2D
    case coordinatesArray3D
    case object
    
    case point
    case multiPoint
    case lineString
    case multiLineString
    case polygon
    case multiPolygon
    case geometryCollection
}

// Consumers
private let spaceCharacters = " \t\n\r"
private let space: Consumer<WKTLabel> = .discard(.zeroOrMore(.character(in: spaceCharacters)))
private let digit: Consumer<WKTLabel> = .character(in: "0" ... "9")
private let number: Consumer<WKTLabel> = .label(.number, .flatten([
    .optional("-"),
    .any(["0", [.character(in: "1" ... "9"), .zeroOrMore(digit)]]),
    .optional([".", .oneOrMore(digit)]),
    .optional([
        .character(in: "eE"),
        .optional(.character(in: "+-")),
        .oneOrMore(digit),
    ]),
]))
private let coordinate: Consumer<WKTLabel> = .label(.coordinate,[
    .reference(.number),
    space,
    .reference(.number)
])

private let coordinatesArray: Consumer<WKTLabel> = .label(.coordinatesArray,
                                                          .interleaved(
                                                            .spaced(.reference(.coordinate)),
                                                            .discard(",")
                                                          )
)

private let coordinatesArray2D: Consumer<WKTLabel> = .label(.coordinatesArray2D,
                                                            .interleaved(
                                                                .bracketed(
                                                                    .reference(.coordinatesArray)
                                                                ),
                                                                .discard(",")
                                                            )
)

private let coordinatesArray3D: Consumer<WKTLabel> = .label(.coordinatesArray3D,
                                                            .interleaved(
                                                                .bracketed(
                                                                    .reference(.coordinatesArray2D)
                                                                ),
                                                                .discard(",")
                                                            )
)

extension Point {
    fileprivate var wktConsumer: WKTConsumer {
        .label(.point, [
            .spaced(.string("POINT")),
            .any([
                .string("EMPTY"),
                .bracketed(.reference(.coordinate))
            ])
        ])
    }
}
/*
 POINT (30 10)
 */
private let point: WKTConsumer = .label(.point, [
    .spaced(.string("POINT")),
    .any([
        .string("EMPTY"),
        .bracketed(.reference(.coordinate))
    ])
])

/*
 MULTIPOINT ((10 40), (40 30), (20 20), (30 10))
 MULTIPOINT (10 40, 40 30, 20 20, 30 10)
 */
private let multiPoint: Consumer<WKTLabel> = .label(.multiPoint, [
    .spaced(.string("MULTIPOINT")),
    .any([
        .string("EMPTY"),
        [
            .bracketed(
                .any([
                    .interleaved([
                        .bracketed(
                            .reference(.coordinate)
                        )
                    ], .discard(",")
                    ),
                    .interleaved(
                        .spaced(.reference(.coordinate)),
                        .discard(",")
                    )
                ])
            )
        ]
    ])
])

/*
 LINESTRING (30 10, 10 30, 40 40)
 */
private let lineString: Consumer<WKTLabel> = .label(.lineString, [
    .spaced(.string("LINESTRING")),
    .any([
        .string("EMPTY"),
        .bracketed(
            .reference(.coordinatesArray)
        )
    ])
])

/*
 MULTILINESTRING ((10 10, 20 20, 10 40),
 (40 40, 30 30, 40 20, 30 10))
 */
private let multiLineString: Consumer<WKTLabel> = .label(.multiLineString, [
    .spaced(.string("MULTILINESTRING")),
    .any([
        .string("EMPTY"),
        .bracketed(
            .reference(.coordinatesArray2D)
        )
    ])
])

/*
 POLYGON ((35 10, 45 45, 15 40, 10 20, 35 10),
 (20 30, 35 35, 30 20, 20 30))
 */
private let polygon: Consumer<WKTLabel> = .label(.polygon, [
    .spaced(.string("POLYGON")),
    .any([
        .string("EMPTY"),
        .bracketed(
            .reference(.coordinatesArray2D)
        )
    ])
])

/*
 MULTIPOLYGON (((40 40, 20 45, 45 30, 40 40)),
 ((20 35, 10 30, 10 10, 30 5, 45 20, 20 35),
 (30 20, 20 15, 20 25, 30 20)))
 */
private let multiPolygon: Consumer<WKTLabel> = .label(.multiPolygon, [
    .spaced(.string("MULTIPOLYGON")),
    .any([
        .string("EMPTY"),
        .bracketed(
            .reference(.coordinatesArray3D)
        ),
    ])
])

/*
 GEOMETRYCOLLECTION (POINT (40 10),
 LINESTRING (10 10, 20 20, 10 40),
 POLYGON ((40 40, 20 45, 45 30, 40 40)))
 */
private let geometryCollection: Consumer<WKTLabel> = .label(.geometryCollection, [
    .spaced(.string("GEOMETRYCOLLECTION")),
    .any([
        .string("EMPTY"),
        .bracketed(
            .interleaved(
                .spaced(.reference(.object)),
                .discard(",")
            )
        )
    ])
])

private let object: Consumer<WKTLabel> = .label(.object, [
    geometryCollection | number | coordinate | coordinatesArray | coordinatesArray2D | coordinatesArray3D | space | point | multiPoint | lineString | multiLineString | polygon | multiPolygon
    ])

private let wktConsumer: Consumer<WKTLabel> = .interleaved([
    .spaced(object)
], .discard(","))

// Transform
private let wktTransform: Consumer<WKTLabel>.Transform = { label, values in
    switch label { // test empty
    case .number:
        return (values as! [String]).compactMap { Double($0) }.first
    case .coordinate:
        print("coordinate: \(values)")
        let coords = values as! [Double]
        return CLLocationCoordinate2D(latitude: coords[1],
                                      longitude: coords[0])
    case .coordinatesArray:
        print("coordinatesArray: \(values)")
        return values as! [CLLocationCoordinate2D]
    case .coordinatesArray2D:
        print("coordinatesArray2D: \(values)")
        return values as! [[CLLocationCoordinate2D]]
    case .coordinatesArray3D:
        print("coordinatesArray3D: \(values)")
        return values as! [[[CLLocationCoordinate2D]]]
    case .point:
        print("point: \(values)")
        return Point(values[1] as! CLLocationCoordinate2D)
    case .multiPoint:
        print("multiPoint: \(values)")
        return MultiPoint(values[1..<values.endIndex].map { $0 as! CLLocationCoordinate2D })
    case .lineString:
        print("lineString: \(values)")
        return LineString(values[1] as! [CLLocationCoordinate2D])
    case .multiLineString:
        print("multiLineString: \(values)")
        return MultiLineString(values[1] as! [[CLLocationCoordinate2D]])
    case .polygon:
        print("polygon: \(values)")
        return Polygon(values[1] as! [[CLLocationCoordinate2D]])
    case .multiPolygon:
        print("multiPolygon: \(values)")
        return MultiPolygon(values[1] as! [[[CLLocationCoordinate2D]]])
    case .geometryCollection:
        print("geometryCollection: \(values)")
        return GeometryCollection(geometries: values[1..<values.endIndex].map { ($0 as! GeometryConvertible).geometry })
    case .object:
        print("object: \(values)")
        return values.first
    }
}


extension Consumer where Label == WKTLabel {
    static func spaced(_ consumer: Consumer) -> Consumer {
        return .sequence([
            space,
            consumer,
            space
        ])
    }
    
    static func bracketed(_ consumer: Consumer) -> Consumer {
        return .sequence([
            space,
            .discard("("),
            space,
            consumer,
            space,
            .discard(")"),
            space
        ])
    }
}
