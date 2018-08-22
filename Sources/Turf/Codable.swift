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
    
    public init(_ value: Any) {
        self.jsonValue = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            jsonValue = NSNull()
        } else if let intValue = try? container.decode(Int.self) {
            jsonValue = intValue
        } else if let stringValue = try? container.decode(String.self) {
            jsonValue = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            jsonValue = boolValue
        } else if let doubleValue = try? container.decode(Double.self) {
            jsonValue = doubleValue
        } else if let doubleValue = try? container.decode([AnyJSONType].self) {
            jsonValue = doubleValue
        } else if let doubleValue = try? container.decode([String: AnyJSONType].self) {
            jsonValue = doubleValue
        } else {
            throw DecodingError.typeMismatch(JSONType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported JSON type"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if jsonValue is NSNull {
            try container.encodeNil()
        } else if let intValue = jsonValue as? Int {
            try container.encode(intValue)
        } else if let stringValue = jsonValue as? String {
            try container.encode(stringValue)
        } else if let boolValue = jsonValue as? Bool {
            try container.encode(boolValue)
        } else if let doubleValue = jsonValue as? Double {
            try container.encode(doubleValue)
        } else if let arrayValue = jsonValue as? [AnyJSONType] {
            try container.encode(arrayValue)
        } else if let dictionaryValue = jsonValue as? [String: AnyJSONType] {
            try container.encode(dictionaryValue)
        }
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

