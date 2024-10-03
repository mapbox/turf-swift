import Foundation

/**
 Entity which can be converted to and from 'Well Known Text'.
 */
public protocol WKTConvertible {
    var wkt: String { get }
    init(wkt: String) throws
}

extension TurfPoint: WKTConvertible {
    public var wkt: String {
        return "POINT(\(coordinates.longitude) \(coordinates.latitude))"
    }
    
    public init(wkt: String) throws {
        self = try WKTParser.parse(wkt)
    }
}

extension TurfMultiPoint: WKTConvertible {
    public var wkt: String {
        return "MULTIPOINT\(coordinates.wktCoordinatesString)"
    }
    
    public init(wkt: String) throws {
        self = try WKTParser.parse(wkt)
    }
}

extension TurfLineString: WKTConvertible {
    public var wkt: String {
        return "LINESTRING\(coordinates.wktCoordinatesString)"
    }
    
    public init(wkt: String) throws {
        self = try WKTParser.parse(wkt)
    }
}

extension TurfMultiLineString: WKTConvertible {
    public var wkt: String {
        return "MULTILINESTRING\(coordinates.wktCoordinatesString)"
    }
    
    public init(wkt: String) throws {
        self = try WKTParser.parse(wkt)
    }
}

extension TurfPolygon: WKTConvertible {
    public var wkt: String {
        return "POLYGON\(coordinates.wktCoordinatesString)"
    }
    
    public init(wkt: String) throws {
        self = try WKTParser.parse(wkt)
    }
}

extension TurfMultiPolygon: WKTConvertible {
    public var wkt: String {
        return "MULTIPOLYGON\(coordinates.wktCoordinatesString)"
    }
    
    public init(wkt: String) throws {
        self = try WKTParser.parse(wkt)
    }
}

extension TurfGeometry: WKTConvertible {
    public var wkt: String {
        switch self {
        case .point(let geometry):
            return geometry.wkt
        case .lineString(let geometry):
            return geometry.wkt
        case .polygon(let geometry):
            return geometry.wkt
        case .multiPoint(let geometry):
            return geometry.wkt
        case .multiLineString(let geometry):
            return geometry.wkt
        case .multiPolygon(let geometry):
            return geometry.wkt
        case .geometryCollection(let geometry):
            return geometry.wkt
        }
    }
    
    public init(wkt: String) throws {
        let object: GeometryConvertible = try WKTParser.parse(wkt)
        self = object.geometry
    }
}

extension TurfGeometryCollection: WKTConvertible {
    public var wkt: String {
        let geometriesWKT = geometries.map {
            switch $0 {
            case .point(let object):
                return object.wkt
            case .lineString(let object):
                return object.wkt
            case .polygon(let object):
                return object.wkt
            case .multiPoint(let object):
                return object.wkt
            case .multiLineString(let object):
                return object.wkt
            case .multiPolygon(let object):
                return object.wkt
            case .geometryCollection(let object):
                return object.wkt
            }
        }.joined(separator: ",")
        return "GEOMETRYCOLLECTION(\(geometriesWKT))"
    }
    
    public init(wkt: String) throws {
        self = try WKTParser.parse(wkt)
    }
}


extension Array where Element == TurfLocationCoordinate2D {
    fileprivate var wktCoordinatesString: String {
        let string = map {
            return "\($0.longitude) \($0.latitude)"
        }.joined(separator:",")
        return "(\(string))"
    }
}

extension Array where Element == [TurfLocationCoordinate2D] {
    fileprivate var wktCoordinatesString: String {
        let string =  map {
            return $0.wktCoordinatesString
        }.joined(separator:",")
        return "(\(string))"
    }
}

extension Array where Element == [[TurfLocationCoordinate2D]] {
    fileprivate var wktCoordinatesString: String {
        let string =  map {
            return $0.wktCoordinatesString
        }.joined(separator:",")
        return "(\(string))"
    }
}
