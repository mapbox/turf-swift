import Foundation
#if !os(Linux)
import CoreLocation
#endif

extension Ring: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = Ring(coordinates: try container.decode([LocationCoordinate2DCodable].self).decodedCoordinates)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(coordinates.codableCoordinates)
    }
}

