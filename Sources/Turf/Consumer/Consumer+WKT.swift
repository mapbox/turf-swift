import Foundation
#if !os(Linux)
import CoreLocation
#endif


struct WKTParser {
    init() {}
    
    mutating func parse<T>(_ input: String) throws -> T {
        let match = try wktConsumer.match(input.uppercased())
        guard let output = try match.transform(wktTransform) else {
            throw WKTError.emptyOutput
        }
        guard let castOutput = output as? [T] else {
            throw WKTError.castFailed(T.self)
        }
        guard let object = castOutput.first else {
            throw WKTError.emptyOutput
        }
        return object
    }
    
    static func parse<T>(_ input: String) throws -> T {
        var parser = WKTParser()
        return try parser.parse(input)
    }
    
    enum WKTError: Error, CustomStringConvertible {
        case emptyOutput
        case numberParsingFailed(Any)
        case coordinatesParsingFailed(Any)
        case geometriesParsingFailed(Any)
        case castFailed(Any.Type)
        
        public var description: String {
            switch self {
            case .emptyOutput:
                return "Parsing result did not yield any object."
            case .numberParsingFailed(let values):
                return "Could not convert input into a valid numbers array: \(values)."
            case .coordinatesParsingFailed(let values):
                return "Could not convert input into a valid coordinates array: \(values)."
            case .geometriesParsingFailed(let values):
                return "Could not convert input into a geometries: \(values)."
            case .castFailed(let type):
                return "Could not cast resulting object into suggested type '\(type)'."
            }
        }
    }
    
    fileprivate enum WKTLabel: String {
        case empty
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
    fileprivate lazy var space: Consumer<WKTLabel> = .discard(.zeroOrMore(.character(in: CharacterSet.whitespacesAndNewlines)))
    private let empty: Consumer<WKTLabel> = .label(.empty, .string("EMPTY"))
    private let digit: Consumer<WKTLabel> = .character(in: "0" ... "9")
    private lazy var number: Consumer<WKTLabel> = .label(.number, .flatten([
        .optional("-"),
        .any(["0", [.character(in: "1" ... "9"), .zeroOrMore(digit)]]),
        .optional([".", .oneOrMore(digit)]),
        .optional([
            .character(in: "eE"),
            .optional(.character(in: "+-")),
            .oneOrMore(digit),
        ]),
    ]))
    private lazy var coordinate: Consumer<WKTLabel> = .label(.coordinate,[
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
    
    /*
     POINT (30 10)
     */
    private let point: Consumer<WKTLabel> = .label(.point, [
        .spaced(.string("POINT")),
        .any([
            .reference(.empty),
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
            .reference(.empty),
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
            .reference(.empty),
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
            .reference(.empty),
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
            .reference(.empty),
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
            .reference(.empty),
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
            .reference(.empty),
            .bracketed(
                .interleaved(
                    .spaced(.reference(.object)),
                    .discard(",")
                )
            )
        ])
    ])
    
    private lazy var object: Consumer<WKTLabel> = {
        let primitives = empty | number | coordinate | coordinatesArray | coordinatesArray2D | coordinatesArray3D | space
        let geometries = geometryCollection | point | multiPoint | lineString | multiLineString | polygon | multiPolygon
        return .label(.object, [
            primitives | geometries
        ])
    } ()
    
    private lazy var wktConsumer: Consumer<WKTLabel> = .interleaved([
        .spaced(object)
    ], .discard(","))
    
    // Transform
    private let wktTransform: Consumer<WKTLabel>.Transform = { label, values in
        switch label {
        case .empty:
            return nil
        case .number:
            guard let numbers = (values as? [String])?.compactMap({ Double($0) }),
                  numbers.count == values.count,
                  let number = numbers.first else {
                throw WKTError.numberParsingFailed(values)
            }
            return number
        case .coordinate:
            guard let coords = values as? [Double],
                  coords.count == 2 else {
                throw WKTError.coordinatesParsingFailed(values)
            }
            return LocationCoordinate2D(latitude: coords[1],
                                        longitude: coords[0])
        case .coordinatesArray:
            guard let coords = values as? [LocationCoordinate2D] else {
                throw WKTError.coordinatesParsingFailed(values)
            }
            return coords
        case .coordinatesArray2D:
            guard let coords = values as? [[LocationCoordinate2D]] else {
                throw WKTError.coordinatesParsingFailed(values)
            }
            return coords
        case .coordinatesArray3D:
            guard let coords = values as? [[[LocationCoordinate2D]]] else {
                throw WKTError.coordinatesParsingFailed(values)
            }
            return coords
        case .point:
            guard values.count > 1 else { return nil }
            guard let coords = values[1] as? LocationCoordinate2D else {
                throw WKTError.coordinatesParsingFailed(values)
            }
            return Point(coords)
        case .multiPoint:
            guard values.count > 1 else { return nil }
            let coords = values.suffix(from: 1).compactMap { $0 as? LocationCoordinate2D }
            guard coords.count == values.count - 1 else {
                throw WKTError.coordinatesParsingFailed(values)
            }
            return MultiPoint(coords)
        case .lineString:
            guard values.count > 1 else { return nil }
            guard let coords = values[1] as? [LocationCoordinate2D] else {
                throw WKTError.coordinatesParsingFailed(values)
            }
            return LineString(coords)
        case .multiLineString:
            guard values.count > 1 else { return nil }
            guard let coords = values[1] as? [[LocationCoordinate2D]] else {
                throw WKTError.coordinatesParsingFailed(values)
            }
            return MultiLineString(coords)
        case .polygon:
            guard values.count > 1 else { return nil }
            guard let coords = values[1] as? [[LocationCoordinate2D]] else {
                throw WKTError.coordinatesParsingFailed(values)
            }
            return Polygon(coords)
        case .multiPolygon:
            guard values.count > 1 else { return nil }
            guard let coords = values[1] as? [[[LocationCoordinate2D]]] else {
                throw WKTError.coordinatesParsingFailed(values)
            }
            return MultiPolygon(coords)
        case .geometryCollection:
            guard values.count > 1 else { return nil }
            let geometries = values.suffix(from: 1).compactMap { ($0 as? GeometryConvertible)?.geometry }
            guard geometries.count == values.count - 1 else {
                throw WKTError.geometriesParsingFailed(values)
            }
            return GeometryCollection(geometries: geometries)
        case .object:
            return values.first
        }
    }
}


extension Consumer where Label == WKTParser.WKTLabel {
    private static var space: Consumer<WKTParser.WKTLabel> {
        return .discard(.zeroOrMore(.character(in: " \t\n\r")))
    }
    
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
