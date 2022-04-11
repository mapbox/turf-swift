import Foundation
#if !os(Linux)
import CoreLocation
#endif

/**
 A [MultiLineString geometry](https://datatracker.ietf.org/doc/html/rfc7946#section-3.1.5) is a collection of `LineString` geometries that are disconnected but related.
 */
public struct MultiLineString: Equatable, ForeignMemberContainer {
    /// The positions at which the multi–line string is located. Each nested array corresponds to one line string.
    public var coordinates: [[LocationCoordinate2D]]
    
    public var foreignMembers: JSONObject = [:]
    
    /**
     Initializes a multi–line string defined by the given positions.
     
     - parameter coordinates: The positions at which the multi–line string is located. Each nested array corresponds to one line string.
     */
    public init(_ coordinates: [[LocationCoordinate2D]]) {
        self.coordinates = coordinates
    }
    
    /**
     Initializes a multi–line string coincident to the given polygon’s linear rings.
     
     This initializer is equivalent to the [`polygon-to-line`](https://turfjs.org/docs/#polygonToLine) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-polygon-to-line/)).
     
     - parameter polygon: The polygon whose linear rings are coincident to the multi–line string.
     */
    public init(_ polygon: Polygon) {
        self.coordinates = polygon.coordinates
    }
}

extension MultiLineString: Codable {
    enum CodingKeys: String, CodingKey {
        case kind = "type"
        case coordinates
    }
    
    enum Kind: String, Codable {
        case MultiLineString
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _ = try container.decode(Kind.self, forKey: .kind)
        let coordinates = try container.decode([[LocationCoordinate2DCodable]].self, forKey: .coordinates).decodedCoordinates
        self = .init(coordinates)
        try decodeForeignMembers(notKeyedBy: CodingKeys.self, with: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Kind.MultiLineString, forKey: .kind)
        try container.encode(coordinates.codableCoordinates, forKey: .coordinates)
        try encodeForeignMembers(notKeyedBy: CodingKeys.self, to: encoder)
    }
}
