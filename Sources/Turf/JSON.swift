import Foundation

/**
 A JSON value represents an object, array, or fragment.
 
 This type does not represent the `null` value in JSON. Use `Optional<JSONValue>` wherever `null` is accepted.
 */
public enum JSONValue: Equatable, RawRepresentable {
    public typealias RawValue = Any
    
    // case null would be redundant to Optional.none
    case string(_ string: String)
    case number(_ number: Double)
    case boolean(_ bool: Bool)
    case array(_ values: JSONArray)
    case object(_ properties: JSONObject)
    
    public init(_ string: String) {
        self = .string(string)
    }
    
    public init<Source>(_ number: Source) where Source: BinaryInteger {
        self = .number(Double(number))
    }
    
    public init<Source>(_ number: Source) where Source: BinaryFloatingPoint {
        self = .number(Double(number))
    }
    
    public init(_ bool: Bool) {
        self = .boolean(bool)
    }
    
    public init(_ values: JSONArray) {
        self = .array(values)
    }
    
    public init(_ properties: JSONObject) {
        self = .object(properties)
    }
    
    public init?(rawValue: Any) {
        // Like `JSONSerialization.jsonObject(with:options:)` with `JSONSerialization.ReadingOptions.fragmentsAllowed` specified.
        if let bool = rawValue as? Bool {
            self = .boolean(bool)
        } else if let string = rawValue as? String {
            self = .string(string)
        } else if let number = rawValue as? NSNumber {
            self = .number(number.doubleValue)
        } else if let array = rawValue as? JSONArray.RawValue {
            self = .array(.init(rawValue: array))
        } else if let object = rawValue as? JSONObject.RawValue {
            self = .object(.init(rawValue: object))
        } else {
            return nil
        }
    }
    
    public var rawValue: Any {
        switch self {
        case let .boolean(value):
            return value
        case let .string(value):
            return value
        case let .number(value):
            return value
        case let .object(value):
            return value.rawValue
        case let .array(value):
            return value.rawValue
        }
    }
}

/**
 A JSON array of `JSONValue` instances.
 */
public typealias JSONArray = [JSONValue?]

extension JSONArray: RawRepresentable {
    public typealias RawValue = [Any?]
    
    public init(rawValue values: RawValue) {
        self = values.map(JSONValue.init(rawValue:))
    }
    
    public var rawValue: RawValue {
        return map { $0?.rawValue }
    }
}

/**
 A JSON object represented in memory by a dictionary with strings as keys and `JSONValue` instances as values.
 */
public typealias JSONObject = [String: JSONValue?]

extension JSONObject: RawRepresentable {
    public typealias RawValue = [String: Any?]
    
    public init(rawValue: RawValue) {
        self = rawValue.mapValues { $0.flatMap(JSONValue.init(rawValue:)) }
    }
    
    public var rawValue: RawValue {
        return mapValues { $0?.rawValue }
    }
}

extension JSONValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = .init(value)
    }
}

extension JSONValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .init(value)
    }
}

extension JSONValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = .init(value)
    }
}

extension JSONValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .init(value)
    }
}

extension JSONValue: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = JSONValue?
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self = .init(elements)
    }
}

extension JSONValue: ExpressibleByDictionaryLiteral {
    public typealias Key = String
    public typealias Value = JSONValue?
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self = .init(.init(uniqueKeysWithValues: elements))
    }
}

extension JSONValue: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let boolean = try? container.decode(Bool.self) {
            self = .boolean(boolean)
        } else if let number = try? container.decode(Double.self) {
            self = .number(number)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let object = try? container.decode(JSONObject.self) {
            self = .object(object)
        } else if let array = try? container.decode(JSONArray.self) {
            self = .array(array)
        } else {
            throw DecodingError.typeMismatch(JSONValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unable to decode as a JSONValue."))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .boolean(value):
            try container.encode(value)
        case let .string(value):
            try container.encode(value)
        case let .number(value):
            try container.encode(value)
        case let .object(value):
            try container.encode(value)
        case let .array(value):
            try container.encode(value)
        }
    }
}
