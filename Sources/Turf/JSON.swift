import Foundation

/**
 A JSON value represents an object, array, or fragment.
 
 This type does not represent the `null` value in JSON. Use `Optional<JSONValue>` wherever `null` is accepted.
 */
public enum JSONValue: Equatable {
    // case null would be redundant to Optional.none
    case string(_ string: String)
    case number(_ number: Double)
    case boolean(_ bool: Bool)
    case array(_ values: JSONArray)
    case object(_ properties: JSONObject)
    
    /**
     The value expressed as a Swift standard library type.
     
     The computed value is consistent with the return value of `JSONSerialization.jsonObject(with:options:)` with `JSONSerialization.ReadingOptions.allowFragments` specified.
     */
    public var rawValue: Any {
        switch self {
        case let .boolean(value):
            return value
        case let .string(value):
            return value
        case let .number(value):
            return value
        case let .object(value):
            return value.mapValues { $0?.rawValue }
        case let .array(value):
            return value.map { $0?.rawValue }
        }
    }
}

/**
 A JSON array of `JSONValue` instances.
 */
public typealias JSONArray = [JSONValue?]

/**
 A JSON object represented in memory by a dictionary with strings as keys and `JSONValue` instances as values.
 */
public typealias JSONObject = [String: JSONValue?]

extension JSONValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

extension JSONValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .number(Double(value))
    }
}

extension JSONValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = .number(value)
    }
}

extension JSONValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .boolean(value)
    }
}

extension JSONValue: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = JSONValue?
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self = .array(elements)
    }
}

extension JSONValue: ExpressibleByDictionaryLiteral {
    public typealias Key = String
    public typealias Value = JSONValue?
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self = .object(.init(uniqueKeysWithValues: elements))
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
