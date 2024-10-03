import Foundation
#if !os(Linux)
import CoreLocation
#endif

#if !MAPBOX_COMMON_WITH_TURF_SWIFT_LIBRARY
public typealias Point = TurfPoint
#endif

/**
 A [TurfPoint geometry](https://datatracker.ietf.org/doc/html/rfc7946#section-3.1.2) represents a single position.
 */
public struct TurfPoint: Equatable, ForeignMemberContainer, Sendable {
    /**
     The position at which the point is located.
     
     This property has a plural name for consistency with [RFC 7946](https://datatracker.ietf.org/doc/html/rfc7946#section-3.1.2). For convenience, it is represented by a `TurfLocationCoordinate2D` instead of a dedicated `Position` type.
     */
    public var coordinates: TurfLocationCoordinate2D
    
    public var foreignMembers: JSONObject = [:]
    
    /**
     Initializes a point defined by the given position.
     
     - parameter coordinates: The position at which the point is located.
     */
    public init(_ coordinates: TurfLocationCoordinate2D) {
        self.coordinates = coordinates
    }
}

extension TurfPoint: Codable {
    enum CodingKeys: String, CodingKey {
        case kind = "type"
        case coordinates
    }
    
    enum Kind: String, Codable {
        case Point
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _ = try container.decode(Kind.self, forKey: .kind)
        let coordinates = try container.decode(LocationCoordinate2DCodable.self, forKey: .coordinates).decodedCoordinates
        self = .init(coordinates)
        try decodeForeignMembers(notKeyedBy: CodingKeys.self, with: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Kind.Point, forKey: .kind)
        try container.encode(coordinates.codableCoordinates, forKey: .coordinates)
        try encodeForeignMembers(notKeyedBy: CodingKeys.self, to: encoder)
    }
}
