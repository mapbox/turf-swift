import Foundation
#if !os(Linux)
import CoreLocation
#endif


public struct MultiPoint: Equatable {
    public var coordinates: [LocationCoordinate2D]
    
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
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Kind.MultiPoint, forKey: .kind)
        try container.encode(coordinates.codableCoordinates, forKey: .coordinates)
    }
}
