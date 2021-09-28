import Foundation
#if !os(Linux)
import CoreLocation
#endif


public struct GeometryCollection: Equatable {
    public var geometries: [Geometry]
    
    public init(geometries: [Geometry]) {
        self.geometries = geometries
    }
    
    public init(_ multiPolygon: MultiPolygon) {
        self.geometries = multiPolygon.coordinates.map {
            $0.count > 1 ?
                .multiLineString(.init($0)) :
                .lineString(.init($0[0]))
        }
    }
}

extension GeometryCollection: Codable {
    enum CodingKeys: String, CodingKey {
        case kind = "type"
        case geometries
    }
    
    enum Kind: String, Codable {
        case GeometryCollection
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _ = try container.decode(Kind.self, forKey: .kind)
        let geometries = try container.decode([Geometry].self, forKey: .geometries)
        self = .init(geometries: geometries)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Kind.GeometryCollection, forKey: .kind)
        try container.encode(geometries, forKey: .geometries)
    }
}
