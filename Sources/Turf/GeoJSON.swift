import Foundation
#if !os(Linux)
import CoreLocation
#endif

#if !MAPBOX_COMMON_WITH_TURF_SWIFT_LIBRARY
public typealias GeoJSONObject = TurfGeoJSONObject
#endif

/**
 A [GeoJSON object](https://datatracker.ietf.org/doc/html/rfc7946#section-3) represents a TurfGeometry, TurfFeature, or collection of Features.
 
 - Note: [Foreign members](https://datatracker.ietf.org/doc/html/rfc7946#section-6.1) which may be present inside are coded only if used `JSONEncoder` or `JSONDecoder` has `userInfo[.includesForeignMembers] = true`.
 */
public enum TurfGeoJSONObject: Equatable, Sendable {
    /**
     A [TurfGeometry object](https://datatracker.ietf.org/doc/html/rfc7946#section-3.1) represents points, curves, and surfaces in coordinate space.
     
     - parameter geometry: The GeoJSON object as a TurfGeometry object.
     */
    case geometry(_ geometry: TurfGeometry)
    
    /**
     A [TurfFeature object](https://datatracker.ietf.org/doc/html/rfc7946#section-3.2) represents a spatially bounded thing.
     
     - parameter feature: The GeoJSON object as a TurfFeature object.
     */
    case feature(_ feature: TurfFeature)

    /**
     A [TurfFeatureCollection object](https://datatracker.ietf.org/doc/html/rfc7946#section-3.3) is a collection of TurfFeature objects.
     
     - parameter TurfFeatureCollection: The GeoJSON object as a TurfFeatureCollection object.
     */
    case featureCollection(_ featureCollection: TurfFeatureCollection)

    /// Initializes a GeoJSON object representing the given GeoJSON object–convertible instance.
    public init(_ object: GeoJSONObjectConvertible) {
        self = object.geoJSONObject
    }
}

extension TurfGeoJSONObject {
    /// A geometry object.
    public var geometry: TurfGeometry? {
        if case let .geometry(geometry) = self {
            return geometry
        }
        return nil
    }
    
    /// A feature object.
    public var feature: TurfFeature? {
        if case let .feature(feature) = self {
            return feature
        }
        return nil
    }
    
    /// A feature collection object.
    public var featureCollection: TurfFeatureCollection? {
        if case let .featureCollection(featureCollection) = self {
            return featureCollection
        }
        return nil
    }
}

extension TurfGeoJSONObject: Codable {
    private enum CodingKeys: String, CodingKey {
        case kind = "type"
    }
    
    public init(from decoder: Decoder) throws {
        let kindContainer = try decoder.container(keyedBy: CodingKeys.self)
        let container = try decoder.singleValueContainer()
        switch try kindContainer.decode(String.self, forKey: .kind) {
        case TurfFeature.Kind.Feature.rawValue:
            self = .feature(try container.decode(TurfFeature.self))
        case TurfFeatureCollection.Kind.FeatureCollection.rawValue:
            self = .featureCollection(try container.decode(TurfFeatureCollection.self))
        default:
            self = .geometry(try container.decode(TurfGeometry.self))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .geometry(let geometry):
            try container.encode(geometry)
        case .feature(let feature):
            try container.encode(feature)
        case .featureCollection(let featureCollection):
            try container.encode(featureCollection)
        }
    }
}

/**
 A type that can be represented as a `TurfGeoJSONObject` instance.
 */
public protocol GeoJSONObjectConvertible {
    /// The instance wrapped in a `TurfGeoJSONObject` instance.
    var geoJSONObject: TurfGeoJSONObject { get }
}

extension TurfGeoJSONObject: GeoJSONObjectConvertible {
    public var geoJSONObject: TurfGeoJSONObject { return self }
}

extension TurfGeometry: GeoJSONObjectConvertible {
    public var geoJSONObject: TurfGeoJSONObject { return .geometry(self) }
}

extension TurfFeature: GeoJSONObjectConvertible {
    public var geoJSONObject: TurfGeoJSONObject { return .feature(self) }
}

extension TurfFeatureCollection: GeoJSONObjectConvertible {
    public var geoJSONObject: TurfGeoJSONObject { return .featureCollection(self) }
}

/**
 A GeoJSON object that can contain [foreign members](https://datatracker.ietf.org/doc/html/rfc7946#section-6.1) in arbitrary keys.
 */
public protocol ForeignMemberContainer: Sendable {
    /// [Foreign members](https://datatracker.ietf.org/doc/html/rfc7946#section-6.1) to round-trip to JSON.
    ///
    /// Members are coded only if used `JSONEncoder` or `JSONDecoder` has `userInfo[.includesForeignMembers] = true`.
    var foreignMembers: JSONObject { get set }
}

/**
 Key to pass to populate a `userInfo` dictionary, which is passed to the `JSONDecoder` or `JSONEncoder` to enable processing foreign members.
*/
public extension CodingUserInfoKey {
    /**
     Indicates if coding of foreign members is enabled.
     
     Boolean flag to enable coding. Default (or missing) value is to ignore foreign members.
     */
    static let includesForeignMembers = CodingUserInfoKey(rawValue: "com.mapbox.turf.coding.includesForeignMembers")!
}

extension ForeignMemberContainer {
    /**
     Decodes any foreign members using the given decoder.
     */
    mutating func decodeForeignMembers<WellKnownCodingKeys>(notKeyedBy _: WellKnownCodingKeys.Type, with decoder: Decoder) throws where WellKnownCodingKeys: CodingKey {
        guard let allowCoding = decoder.userInfo[.includesForeignMembers] as? Bool,
              allowCoding else { return }
        
        let foreignMemberContainer = try decoder.container(keyedBy: AnyCodingKey.self)
        for key in foreignMemberContainer.allKeys {
            if WellKnownCodingKeys(stringValue: key.stringValue) == nil {
                foreignMembers[key.stringValue] = try foreignMemberContainer.decode(TurfJSONValue?.self, forKey: key)
            }
        }
    }
    
    /**
     Encodes any foreign members using the given encoder.
     */
    func encodeForeignMembers<WellKnownCodingKeys>(notKeyedBy _: WellKnownCodingKeys.Type, to encoder: Encoder) throws where WellKnownCodingKeys: CodingKey {
        guard let allowCoding = encoder.userInfo[.includesForeignMembers] as? Bool,
              allowCoding else { return }
        
        var foreignMemberContainer = encoder.container(keyedBy: AnyCodingKey.self)
        for (key, value) in foreignMembers {
            if let key = AnyCodingKey(stringValue: key),
               WellKnownCodingKeys(stringValue: key.stringValue) == nil {
                try foreignMemberContainer.encode(value, forKey: key)
            }
        }
    }
}
