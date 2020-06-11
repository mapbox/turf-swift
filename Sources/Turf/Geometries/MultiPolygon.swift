import Foundation
#if !os(Linux)
import CoreLocation
#endif


public struct MultiPolygon: Equatable {
    public var coordinates: [[[CLLocationCoordinate2D]]]
    
    public init(_ coordinates: [[[CLLocationCoordinate2D]]]) {
        self.coordinates = coordinates
    }
    
    public init(_ polygons: [Polygon]) {
        self.coordinates = polygons.map { (polygon) -> [[CLLocationCoordinate2D]] in
            return polygon.coordinates
        }
    }
}

extension MultiPolygon {
    
    public var polygons: [Polygon] {
        return coordinates.map { (coordinates) -> Polygon in
            return Polygon(coordinates)
        }
    }
    
    /**
     * Determines if the given coordinate falls within any of the polygons.
     * The optional parameter `ignoreBoundary` will result in the method returning true if the given coordinate
     * lies on the boundary line of the polygon or its interior rings.
     *
     * Calls contains function for each contained polygon
     */
    public func contains(_ coordinate: CLLocationCoordinate2D, ignoreBoundary: Bool = false) -> Bool {
        return polygons.contains {
            $0.contains(coordinate, ignoreBoundary: ignoreBoundary)
        }
    }
}
