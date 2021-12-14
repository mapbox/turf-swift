import Foundation

/**
 A coding key as an extensible enumeration.
 */
struct AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

extension KeyedDecodingContainer {
    /**
     All the keys the decoder has for this container, except for the well-known keys in the given type.
     */
    func foreignKeys<WellKnownCodingKeys>(excludingKeysIn _: WellKnownCodingKeys.Type) -> [Key] where WellKnownCodingKeys: CodingKey {
        return allKeys.filter {
            WellKnownCodingKeys(stringValue: $0.stringValue) == nil
        }
    }
}
