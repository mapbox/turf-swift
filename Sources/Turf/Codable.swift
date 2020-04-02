import Foundation
#if !os(Linux)
import CoreLocation
#endif


struct JSONCodingKeys: CodingKey {
    var stringValue: String

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    var intValue: Int?

    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}

extension KeyedDecodingContainer {

    public func decode(_ type: [String: Any?].Type, forKey key: K) throws -> [String: Any?] {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decode(type)
    }

    public func decodeIfPresent(_ type: [String: Any?].Type, forKey key: K) throws -> [String: Any?]? {
        guard contains(key) else {
            return nil
        }
        return try decode(type, forKey: key)
    }

    public func decode(_ type: [Any?].Type, forKey key: K) throws -> [Any?] {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }

    public func decodeIfPresent(_ type: [Any?].Type, forKey key: K) throws -> [Any?]? {
        guard contains(key) else {
            return nil
        }
        return try decode(type, forKey: key)
    }

    public func decode(_ type: [String: Any?].Type) throws -> [String: Any?] {
        var dictionary = [String: Any?]()

        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode([String:  Any?].self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode([Any?].self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            } else if (try? decodeNil(forKey: key)) ?? false {
                dictionary[key.stringValue] = .none
            }
        }
        return dictionary
    }
}

extension UnkeyedDecodingContainer {

    public mutating func decode(_ type: [Any?].Type) throws -> [Any?] {
        var array: [Any?] = []
        while isAtEnd == false {
            if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(Int.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode([String: Any?].self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode([Any?].self) {
                array.append(nestedArray)
            } else if (try? decodeNil()) ?? false {
                array.append(.none)
            }
        }
        return array
    }

    public mutating func decode(_ type: [String: Any?].Type) throws -> [String: Any?] {

        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        return try nestedContainer.decode(type)
    }
}

extension KeyedEncodingContainerProtocol {
    
    public mutating func encodeIfPresent(_ value: [String: Any?]?, forKey key: Self.Key) throws {
        guard let value = value else { return }
        return try encode(value, forKey: key)
    }
    
    public mutating func encode(_ value: [String: Any?], forKey key: Key) throws {
        var container = self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        try container.encode(value)
    }
    
    public mutating func encodeIfPresent(_ value: [Any?]?, forKey key: Self.Key) throws {
        guard let value = value else { return }
        return try encode(value, forKey: key)
    }
    
    public mutating func encode(_ value: [Any?], forKey key: Key) throws {
        var container = self.nestedUnkeyedContainer(forKey: key)
        try container.encode(value)
    }
    
    public mutating func encode(_ value: [String: Any?]) throws {
        try value.forEach({ (key, value) in
            guard let key = Key(stringValue: key) else { return }
            switch value {
            case let value as Bool:
                try encode(value, forKey: key)
            case let value as Int:
                try encode(value, forKey: key)
            case let value as String:
                try encode(value, forKey: key)
            case let value as Double:
                try encode(value, forKey: key)
            case let value as [String: Any?]:
                try encode(value, forKey: key)
            case let value as Array<Any>:
                try encode(value, forKey: key)
            case Optional<Any>.none:
                try encodeNil(forKey: key)
            default:
                return
            }
        })
    }
}

extension UnkeyedEncodingContainer {
    public mutating func encode(_ value: [String: Any?]) throws {
        var nestedContainer = self.nestedContainer(keyedBy: JSONCodingKeys.self)
        try nestedContainer.encode(value)
    }
    
    public mutating func encode(_ value: [Any?]) throws {
        try value.enumerated().forEach({ (index, value) in
            switch value {
            case let value as Bool:
                try encode(value)
            case let value as Int:
                try encode(value)
            case let value as String:
                try encode(value)
            case let value as Double:
                try encode(value)
            case let value as [String: Any?]:
                try encode(value)
            case let value as Array<Any>:
                try encode(value)
            case Optional<Any>.none:
                try encodeNil()
            default:
                return
            }
        })
    }
}

extension Ring: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = Ring(coordinates: try container.decode([CLLocationCoordinate2DCodable].self).decodedCoordinates)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(coordinates.codableCoordinates)
    }
}

