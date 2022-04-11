import Foundation
#if !os(Linux)
import CoreLocation
#endif

/**
 A [GeometryCollection geometry](https://datatracker.ietf.org/doc/html/rfc7946#section-3.1.8) is a heterogeneous collection of `Geometry` objects that are related.
 */
public struct GeometryCollection: Equatable, ForeignMemberContainer {
    /// The geometries contained by the geometry collection.
    public var geometries: [Geometry]
    
    public var foreignMembers: JSONObject = [:]
    
    /**
     Initializes a geometry collection defined by the given geometries.
     
     - parameter geometries: The geometries contained by the geometry collection.
     */
    public init(geometries: [Geometry]) {
        self.geometries = geometries
    }
    
    /**
     Initializes a geometry collection coincident to the given multipolygon.
     
     You should only use this initializer if you intend to add geometries other than multipolygons to the geometry collection after initializing it.
     
     - parameter multiPolygon: The multipolygon that is coincident to the geometry collection.
     */
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
        try decodeForeignMembers(notKeyedBy: CodingKeys.self, with: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Kind.GeometryCollection, forKey: .kind)
        try container.encode(geometries, forKey: .geometries)
        try encodeForeignMembers(notKeyedBy: CodingKeys.self, to: encoder)
    }
}
