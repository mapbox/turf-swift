import Foundation

public enum FeatureIdentifier: Equatable {
    case string(String)
    case number(Double)
    
    public init(_ string: String) {
        self = .string(string)
    }
    
    public init<Source>(_ number: Source) where Source: BinaryInteger {
        self = .number(Double(number))
    }
    
    public init<Source>(_ number: Source) where Source: BinaryFloatingPoint {
        self = .number(Double(number))
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
