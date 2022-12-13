import Foundation

public protocol WKTCodable {
    var WKTString: String { get }
    init?(fromWKT wkt: String)
}

extension Point: WKTCodable {
    public var WKTString: String {
        return "POINT(\(coordinates.longitude) \(coordinates.latitude))"
    }
    
    public init?(fromWKT wkt: String) {
        guard let data = try? parseWKT(wkt), // catch and log message
              let object = (data as? [Point])?.first else {
            return nil
        }
        self = object
    }
}

extension MultiPoint: WKTCodable {
    public var WKTString: String {
        return "MULTIPOINT\(coordinates.wktCoordinatesString)"
    }
    
    public init?(fromWKT wkt: String) {
        guard let data = try? parseWKT(wkt), // catch and log message
              let object = (data as? [MultiPoint])?.first else {
            return nil
        }
        self = object
    }
}

extension LineString: WKTCodable {
    public var WKTString: String {
        return "LINESTRING\(coordinates.wktCoordinatesString)"
    }
    
    public init?(fromWKT wkt: String) {
        guard let data = try? parseWKT(wkt), // catch and log message
              let object = (data as? [LineString])?.first else {
            return nil
        }
        self = object
    }
}

extension MultiLineString: WKTCodable {
    public var WKTString: String {
        return "MULTILINESTRING\(coordinates.wktCoordinatesString)"
    }
    
    public init?(fromWKT wkt: String) {
        guard let data = try? parseWKT(wkt), // catch and log message
              let object = (data as? [MultiLineString])?.first else {
            return nil
        }
        self = object
    }
}

extension Polygon: WKTCodable {
    public var WKTString: String {
        return "POLYGON\(coordinates.wktCoordinatesString)"
    }
    
    public init?(fromWKT wkt: String) {
        guard let data = try? parseWKT(wkt), // catch and log message
              let object = (data as? [Polygon])?.first else {
            return nil
        }
        self = object
    }
}

extension MultiPolygon: WKTCodable {
    public var WKTString: String {
        return "MULTIPOLYGON\(coordinates.wktCoordinatesString)"
    }
    
    public init?(fromWKT wkt: String) {
        guard let data = try? parseWKT(wkt), // catch and log message
              let object = (data as? [MultiPolygon])?.first else {
            return nil
        }
        self = object
    }
}

extension Geometry: WKTCodable {
    public var WKTString: String {
        switch self {
        case .point(let geometry):
            return geometry.WKTString
        case .lineString(let geometry):
            return geometry.WKTString
        case .polygon(let geometry):
            return geometry.WKTString
        case .multiPoint(let geometry):
            return geometry.WKTString
        case .multiLineString(let geometry):
            return geometry.WKTString
        case .multiPolygon(let geometry):
            return geometry.WKTString
        case .geometryCollection(let geometry):
            return geometry.WKTString
        }
    }
    
    public init?(fromWKT wkt: String) {
        guard let data = try? parseWKT(wkt), // catch and log message
              let object = (data as? [GeometryConvertible])?.first else {
            return nil
        }
        self = object.geometry
    }
}

extension GeometryCollection: WKTCodable {
    public var WKTString: String {
        let geometriesWKT = geometries.map {
            switch $0 {
            case .point(let object):
                return object.WKTString
            case .lineString(let object):
                return object.WKTString
            case .polygon(let object):
                return object.WKTString
            case .multiPoint(let object):
                return object.WKTString
            case .multiLineString(let object):
                return object.WKTString
            case .multiPolygon(let object):
                return object.WKTString
            case .geometryCollection(let object):
                return object.WKTString
            }
        }.joined(separator: ",")
        return "GEOMETRYCOLLECTION(\(geometriesWKT))"
    }
    
    public init?(fromWKT wkt: String) {
        guard let data = try? parseWKT(wkt), // catch and log message
              let object = (data as? [GeometryCollection])?.first else {
            return nil
        }
        self = object
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
