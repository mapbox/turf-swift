import Foundation
#if !os(Linux)
import CoreLocation
#endif


public struct MultiLineString: Equatable {
    public var coordinates: [[CLLocationCoordinate2D]]
    
    public init(_ coordinates: [[CLLocationCoordinate2D]]) {
        self.coordinates = coordinates
    }
    
    public init(_ polygon: Polygon) {
        self.coordinates = polygon.coordinates
    }
}
