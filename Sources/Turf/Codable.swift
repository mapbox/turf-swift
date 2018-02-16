import Foundation
#if !os(Linux)
import CoreLocation
#endif

public protocol JSONType: Codable {
    var jsonValue: Any { get }
}

extension Int: JSONType {
    public var jsonValue: Any { return self }
}
extension String: JSONType {
    public var jsonValue: Any { return self }
}
extension Double: JSONType {
    public var jsonValue: Any { return self }
}
extension Bool: JSONType {
    public var jsonValue: Any { return self }
}

public struct AnyJSONType: JSONType {
    public let jsonValue: Any
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            jsonValue = intValue
        } else if let stringValue = try? container.decode(String.self) {
            jsonValue = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            jsonValue = boolValue
        } else if let doubleValue = try? container.decode(Double.self) {
            jsonValue = doubleValue
        } else if let doubleValue = try? container.decode([AnyJSONType].self) {
            jsonValue = doubleValue
        } else if let doubleValue = try? container.decode([String:AnyJSONType].self) {
            jsonValue = doubleValue
        } else {
            throw DecodingError.typeMismatch(JSONType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported JSON type"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self)
    }
}

extension Ring: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = Ring(coordinates: try container.decode([CLLocationCoordinate2D].self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(coordinates)
    }
}

extension Polygon: Codable {
    private enum CodingKeys: String, CodingKey {
        case coordinates
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rings = try container.decode([Ring].self, forKey: .coordinates)
        outerRing = rings.first!
        innerRings = Array(rings.suffix(from: 1))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode([outerRing]+innerRings, forKey: .coordinates)
    }
}
