import Foundation
#if !os(Linux)
import CoreLocation
#endif


public struct MultiPoint: Equatable {
    public var coordinates: [CLLocationCoordinate2D]
    
    public init(_ coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = coordinates
    }
}
