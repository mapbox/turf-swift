import Foundation
#if !os(Linux)
import CoreLocation
#endif


public struct GeometryCollection {
    public let geometries: [Geometry]
    
    public init(_ geometries: [Geometry]) {
        self.geometries = geometries
    }
    
    public init(_ multiPolygon: MultiPolygon) {
        self.geometries = multiPolygon.coordinates.map {
            $0.count > 1 ?
                .MultiLineString(coordinates: .init($0)) :
                .LineString(coordinates:  .init($0[0]))
        }
    }
}
