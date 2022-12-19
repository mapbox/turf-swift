import Foundation

/**
 Entity which can be converted to and from 'Well Known Text'.
 */
public protocol WKTConvertible {
    var wktString: String { get }
    init(fromWKT wkt: String) throws
}

extension Point: WKTConvertible {
    public var wktString: String {
        return "POINT(\(coordinates.longitude) \(coordinates.latitude))"
    }
    
    public init(fromWKT wkt: String) throws {
        self = try WKTParser.parse(wkt)
    }
}

extension MultiPoint: WKTConvertible {
    public var wktString: String {
        return "MULTIPOINT\(coordinates.wktCoordinatesString)"
    }
    
    public init(fromWKT wkt: String) throws {
        self = try WKTParser.parse(wkt)
    }
}

extension LineString: WKTConvertible {
    public var wktString: String {
        return "LINESTRING\(coordinates.wktCoordinatesString)"
    }
    
    public init(fromWKT wkt: String) throws {
        self = try WKTParser.parse(wkt)
    }
}

extension MultiLineString: WKTConvertible {
    public var wktString: String {
        return "MULTILINESTRING\(coordinates.wktCoordinatesString)"
    }
    
    public init(fromWKT wkt: String) throws {
        self = try WKTParser.parse(wkt)
    }
}

extension Polygon: WKTConvertible {
    public var wktString: String {
        return "POLYGON\(coordinates.wktCoordinatesString)"
    }
    
    public init(fromWKT wkt: String) throws {
        self = try WKTParser.parse(wkt)
    }
}

extension MultiPolygon: WKTConvertible {
    public var wktString: String {
        return "MULTIPOLYGON\(coordinates.wktCoordinatesString)"
    }
    
    public init(fromWKT wkt: String) throws {
        self = try WKTParser.parse(wkt)
    }
}

extension Geometry: WKTConvertible {
    public var wktString: String {
        switch self {
        case .point(let geometry):
            return geometry.wktString
        case .lineString(let geometry):
            return geometry.wktString
        case .polygon(let geometry):
            return geometry.wktString
        case .multiPoint(let geometry):
            return geometry.wktString
        case .multiLineString(let geometry):
            return geometry.wktString
        case .multiPolygon(let geometry):
            return geometry.wktString
        case .geometryCollection(let geometry):
            return geometry.wktString
        }
    }
    
    public init(fromWKT wkt: String) throws {
        let object: GeometryConvertible = try WKTParser.parse(wkt)
        self = object.geometry
    }
}

extension GeometryCollection: WKTConvertible {
    public var wktString: String {
        let geometriesWKT = geometries.map {
            switch $0 {
            case .point(let object):
                return object.wktString
            case .lineString(let object):
                return object.wktString
            case .polygon(let object):
                return object.wktString
            case .multiPoint(let object):
                return object.wktString
            case .multiLineString(let object):
                return object.wktString
            case .multiPolygon(let object):
                return object.wktString
            case .geometryCollection(let object):
                return object.wktString
            }
        }.joined(separator: ",")
        return "GEOMETRYCOLLECTION(\(geometriesWKT))"
    }
    
    public init(fromWKT wkt: String) throws {
        self = try WKTParser.parse(wkt)
    }
}


extension Array where Element == LocationCoordinate2D {
    fileprivate var wktCoordinatesString: String {
        let string = map {
            return "\($0.longitude) \($0.latitude)"
        }.joined(separator:",")
        return "(\(string))"
    }
}

extension Array where Element == [LocationCoordinate2D] {
    fileprivate var wktCoordinatesString: String {
        let string =  map {
            return $0.wktCoordinatesString
        }.joined(separator:",")
        return "(\(string))"
    }
}

extension Array where Element == [[LocationCoordinate2D]] {
    fileprivate var wktCoordinatesString: String {
        let string =  map {
            return $0.wktCoordinatesString
        }.joined(separator:",")
        return "(\(string))"
    }
}
