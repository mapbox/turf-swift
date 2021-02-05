import Foundation
#if !os(Linux)
import CoreLocation
#endif


public struct MultiLineString: Equatable {
    public var coordinates: [[LocationCoordinate2D]]
    
    public init(_ coordinates: [[LocationCoordinate2D]]) {
        self.coordinates = coordinates
    }
    
    public init(_ polygon: Polygon) {
        self.coordinates = polygon.coordinates
    }
}
