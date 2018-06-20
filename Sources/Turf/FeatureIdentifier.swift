import Foundation

public enum Number: Equatable {
    case int(Int)
    case double(Double)
    
    public var value: Any? {
        switch self {
        case .int(let value):
            return value
        case .double(let value):
            return value
        }
    }
}

extension Number: Codable {
    enum CodingKeys: String, CodingKey {
        case int, double
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else {
            self = .double(try container.decode(Double.self))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        }
    }
}

public enum FeatureIdentifier {
    case string(String)
    case number(Number)
    
    public var value: Any? {
        switch self {
        case .number(let value):
            return value
        case .string(let value):
            return value
        }
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
            self = .number(try container.decode(Number.self))
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
