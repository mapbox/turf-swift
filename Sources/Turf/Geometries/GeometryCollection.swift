import Foundation
#if !os(Linux)
import CoreLocation
#endif


public struct GeometryCollection {
    public let geometries: [Geometry]
    
    public init(_ geometries: [Geometry]) {
        self.geometries = geometries
    }
}
