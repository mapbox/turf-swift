import Foundation

/**
 A [feature identifier](https://datatracker.ietf.org/doc/html/rfc7946#section-3.2) identifies a `Feature` object.
 */
public enum FeatureIdentifier: Hashable {
    /// A string.
    case string(_ string: String)
    
    /**
     A floating-point number.
     
     - parameter number: A floating-point number. JSON does not distinguish numeric types of different precisions. If you need integer precision, cast this associated value to an `Int`.
     */
    case number(_ number: Double)
    
    /// Initializes a feature identifier representing the given string.
    public init(_ string: String) {
        self = .string(string)
    }
    
    /**
     Initializes a feature identifier representing the given integer.
     
     - parameter number: An integer. JSON does not distinguish numeric types of different precisions, so the integer is stored as a floating-point number.
     */
    public init<Source>(_ number: Source) where Source: BinaryInteger {
        self = .number(Double(number))
    }
    
    /// Initializes a feature identifier representing the given floating-point number.
    public init<Source>(_ number: Source) where Source: BinaryFloatingPoint {
        self = .number(Double(number))
    }
}

extension FeatureIdentifier: RawRepresentable {
    public typealias RawValue = Any
    
    public init?(rawValue: Any) {
        // Like `JSONSerialization.jsonObject(with:options:)` with `JSONSerialization.ReadingOptions.fragmentsAllowed` specified.
        if let string = rawValue as? String {
            self = .string(string)
        } else if let number = rawValue as? NSNumber {
            self = .number(number.doubleValue)
        } else {
            return nil
        }
    }
    
    public var rawValue: Any {
        switch self {
        case let .string(value):
            return value
        case let .number(value):
            return value
        }
    }
}

extension FeatureIdentifier: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = .init(value)
    }
}

extension FeatureIdentifier: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .init(value)
    }
}

extension FeatureIdentifier: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = .number(value)
    }
}

extension FeatureIdentifier: Codable {
    enum CodingKeys: String, CodingKey {
        case string, number
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            self = .number(try container.decode(Double.self))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        }
    }
}
