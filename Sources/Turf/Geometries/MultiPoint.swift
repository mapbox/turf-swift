import Foundation
#if !os(Linux)
import CoreLocation
#endif

/**
 A [MultiPoint geometry](https://datatracker.ietf.org/doc/html/rfc7946#section-3.1.3) represents a collection of disconnected but related positions.
 */
public struct MultiPoint: Equatable, ForeignMemberContainer {
    /// The positions at which the multipoint is located.
    public var coordinates: [LocationCoordinate2D]
    
    public var foreignMembers: JSONObject = [:]
    
    /**
     Initializes a multipoint defined by the given positions.
     
     - parameter coordinates: The positions at which the multipoint is located.
     */
    public init(_ coordinates: [LocationCoordinate2D]) {
        self.coordinates = coordinates
    }
}

extension MultiPoint: Codable {
    enum CodingKeys: String, CodingKey {
        case kind = "type"
        case coordinates
    }
    
    enum Kind: String, Codable {
        case MultiPoint
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _ = try container.decode(Kind.self, forKey: .kind)
        let coordinates = try container.decode([LocationCoordinate2DCodable].self, forKey: .coordinates).decodedCoordinates
        self = .init(coordinates)
        try decodeForeignMembers(notKeyedBy: CodingKeys.self, with: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Kind.MultiPoint, forKey: .kind)
        try container.encode(coordinates.codableCoordinates, forKey: .coordinates)
        try encodeForeignMembers(notKeyedBy: CodingKeys.self, to: encoder)
    }
}
