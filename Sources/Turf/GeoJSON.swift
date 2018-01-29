import Foundation
#if !os(Linux)
import CoreLocation
#endif

public struct GeoJSON: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case geoJSONType = "type"
        case properties
        case geometry
    }
    
    public enum GeoJSONType: String, Codable {
        case Feature
    }
    
    public var geoJSONType: GeoJSONType?
    public var properties: [String: AnyJSONType]?
    public var geometry: Geometry
    
    public struct Geometry: Codable {
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            geometryType = try container.decode(GeometryType.self, forKey: .geometryType)
            switch geometryType {
            case .Point:
                coordinates = [try container.decode(CLLocationCoordinate2D.self, forKey: .coordinates)]
            default:
                coordinates = try container.decode([CLLocationCoordinate2D].self, forKey: .coordinates)
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case geometryType = "type"
            case coordinates
        }
        
        public enum GeometryType: String, Codable {
            case Point
            case LineString
            case Polygon
            case MultiPoint
            case MultiLineString
            case MultiPolygon
        }
        
        public var geometryType: GeometryType
        public var coordinates: [CLLocationCoordinate2D]
    }
}
