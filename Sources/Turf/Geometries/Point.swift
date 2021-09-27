import Foundation
#if !os(Linux)
import CoreLocation
#endif


public struct Point: Equatable {
    /** Note: The pluralization of `coordinates` is defined
     in the GeoJSON RFC, so we've kept it for consistency.
     https://tools.ietf.org/html/rfc7946#section-1.5 */
    public var coordinates: LocationCoordinate2D
    
    public init(_ coordinates: LocationCoordinate2D) {
        self.coordinates = coordinates
    }
}

extension Point: Codable {
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
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Kind.Point, forKey: .kind)
        try container.encode(coordinates.codableCoordinates, forKey: .coordinates)
    }
}
