import Foundation
#if !os(Linux)
import CoreLocation
#endif


public struct LineString: Equatable {
    public var coordinates: [CLLocationCoordinate2D]
    
    public init(_ coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = coordinates
    }
    
    public init(_ ring: Ring) {
        self.coordinates = ring.coordinates
    }
}

extension LineString {
    /// Returns a new `.LineString` based on bezier transformation of the input line.
    ///
    /// ported from https://github.com/Turfjs/turf/blob/1ea264853e1be7469c8b7d2795651c9114a069aa/packages/turf-bezier-spline/index.ts
    func bezier(resolution: Int = 10000, sharpness: Double = 0.85) -> LineString? {
        let points = coordinates.map {
            SplinePoint(coordinate: $0)
        }
        guard let spline = Spline(points: points, duration: resolution, sharpness: sharpness) else {
            return nil
        }
        let coords = stride(from: 0, to: resolution, by: 10)
            .filter { Int(floor(Double($0) / 100)) % 2 == 0 }
            .map { spline.position(at: $0).coordinate }
        return LineString(coords)
    }
    
    /// Returns a `.LineString` along a `.LineString` within a distance from a coordinate.
    public func trimmed(from coordinate: CLLocationCoordinate2D, distance: CLLocationDistance) -> LineString? {
        let startVertex = closestCoordinate(to: coordinate)
        guard startVertex != nil && distance != 0 else {
            return nil
        }
        
        var vertices: [CLLocationCoordinate2D] = [startVertex!.coordinate]
        var cumulativeDistance: CLLocationDistance = 0
        let addVertex = { (vertex: CLLocationCoordinate2D) -> Bool in
            let lastVertex = vertices.last!
            let incrementalDistance = lastVertex.distance(to: vertex)
            if cumulativeDistance + incrementalDistance <= abs(distance) {
                vertices.append(vertex)
                cumulativeDistance += incrementalDistance
                return true
            } else {
                let remainingDistance = abs(distance) - cumulativeDistance
                let direction = lastVertex.direction(to: vertex)
                let endpoint = lastVertex.coordinate(at: remainingDistance, facing: direction)
                vertices.append(endpoint)
                cumulativeDistance += remainingDistance
                return false
            }
        }
        
        if distance > 0 {
            for vertex in coordinates.suffix(from: startVertex!.index) {
                if !addVertex(vertex) {
                    break
                }
            }
        } else {
            for vertex in coordinates.prefix(through: startVertex!.index).reversed() {
                if !addVertex(vertex) {
                    break
                }
            }
        }
        assert(round(cumulativeDistance) <= round(abs(distance)))
        return LineString(vertices)
    }
    
    /// `IndexedCoordinate` is a coordinate with additional information such as
    /// the index from its position in the polyline and distance from the start
    /// of the polyline.
    public struct IndexedCoordinate {
        /// The coordinate
        public let coordinate: Array<CLLocationCoordinate2D>.Element
        /// The index of the coordinate
        public let index: Array<CLLocationCoordinate2D>.Index
        /// The coordinate’s distance from the start of the polyline
        public let distance: CLLocationDistance
    }
    
    /// Returns a coordinate along a `.LineString` at a certain distance from the start of the polyline.
    public func coordinateFromStart(distance: CLLocationDistance) -> CLLocationCoordinate2D? {
        return indexedCoordinateFromStart(distance: distance)?.coordinate
    }
    
    /// Returns an indexed coordinate along a `.LineString` at a certain distance from the start of the polyline.
    ///
    /// Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-along/index.js
    public func indexedCoordinateFromStart(distance: CLLocationDistance) -> IndexedCoordinate? {
        var traveled: CLLocationDistance = 0
        
        guard let firstCoordinate = coordinates.first else {
            return nil
        }
        guard distance >= 0  else {
            return IndexedCoordinate(coordinate: firstCoordinate, index: 0, distance: 0)
        }
        
        for i in 0..<coordinates.count {
            guard distance < traveled || i < coordinates.count - 1 else {
                break
            }
            
            if traveled >= distance {
                let overshoot = distance - traveled
                if overshoot == 0 {
                    return IndexedCoordinate(coordinate: coordinates[i], index: i, distance: traveled)
                }
                
                let direction = coordinates[i].direction(to: coordinates[i - 1]) - 180
                let coordinate = coordinates[i].coordinate(at: overshoot, facing: direction)
                return IndexedCoordinate(coordinate: coordinate, index: i - 1, distance: distance)
            }
            
            traveled += coordinates[i].distance(to: coordinates[i + 1])
        }
        
        return IndexedCoordinate(coordinate: coordinates.last!, index: coordinates.endIndex - 1, distance: traveled)
    }
    
    
    /// Returns the distance along a slice of a `.LineString` with the given endpoints.
    ///
    /// Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-line-slice/index.js
    public func distance(from start: CLLocationCoordinate2D? = nil, to end: CLLocationCoordinate2D? = nil) -> CLLocationDistance? {
        guard !coordinates.isEmpty else { return nil }
        
        guard let slicedCoordinates = sliced(from: start, to: end)?.coordinates else {
            return nil
        }
        
        let zippedCoordinates = zip(slicedCoordinates.prefix(upTo: slicedCoordinates.count - 1), slicedCoordinates.suffix(from: 1))
        return zippedCoordinates.map { $0.distance(to: $1) }.reduce(0, +)
    }
    
    /// Returns a subset of the `.LineString` between given coordinates.
    ///
    /// Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-line-slice/index.js
    public func sliced(from start: CLLocationCoordinate2D? = nil, to end: CLLocationCoordinate2D? = nil) -> LineString? {
        guard !coordinates.isEmpty else { return nil }
                
        let startVertex = (start != nil ? closestCoordinate(to: start!) : nil) ?? IndexedCoordinate(coordinate: coordinates.first!, index: 0, distance: 0)
        let endVertex = (end != nil ? closestCoordinate(to: end!) : nil) ?? IndexedCoordinate(coordinate: coordinates.last!, index: coordinates.indices.last!, distance: 0)
        let ends: (IndexedCoordinate, IndexedCoordinate)
        if startVertex.index <= endVertex.index {
            ends = (startVertex, endVertex)
        } else {
            ends = (endVertex, startVertex)
        }
        
        var coords = ends.0.index == ends.1.index ? [] : Array(coordinates[ends.0.index + 1...ends.1.index])
        coords.insert(ends.0.coordinate, at: 0)
        if coords.last != ends.1.coordinate {
            coords.append(ends.1.coordinate)
        }
        
        return LineString(coords)
    }
    
    /// Returns the geographic coordinate along the `.LineString` that is closest to the given coordinate as the crow flies.
    /// The returned coordinate may not correspond to one of the polyline’s vertices, but it always lies along the polyline.
    ///
    /// Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-point-on-line/index.js
    
    public func closestCoordinate(to coordinate: CLLocationCoordinate2D) -> IndexedCoordinate? {
        guard let startCoordinate = coordinates.first else { return nil }
        
        guard coordinates.count > 1 else {
            return IndexedCoordinate(coordinate: startCoordinate, index: 0, distance: coordinate.distance(to: startCoordinate))
        }
        
        var closestCoordinate: IndexedCoordinate?
        var closestDistance: CLLocationDistance?
        
        for index in 0..<coordinates.count - 1 {
            let segment = (coordinates[index], coordinates[index + 1])
            let distances = (coordinate.distance(to: segment.0), coordinate.distance(to: segment.1))
            
            let maxDistance = max(distances.0, distances.1)
            let direction = segment.0.direction(to: segment.1)
            let perpendicularPoint1 = coordinate.coordinate(at: maxDistance, facing: direction + 90)
            let perpendicularPoint2 = coordinate.coordinate(at: maxDistance, facing: direction - 90)
            let intersectionPoint = intersection((perpendicularPoint1, perpendicularPoint2), segment)
            let intersectionDistance: CLLocationDistance? = intersectionPoint != nil ? coordinate.distance(to: intersectionPoint!) : nil
            
            if distances.0 < closestDistance ?? .greatestFiniteMagnitude {
                closestCoordinate = IndexedCoordinate(coordinate: segment.0,
                                                      index: index,
                                                      distance: startCoordinate.distance(to: segment.0))
                closestDistance = distances.0
            }
            if distances.1 < closestDistance ?? .greatestFiniteMagnitude {
                closestCoordinate = IndexedCoordinate(coordinate: segment.1,
                                                      index: index+1,
                                                      distance: startCoordinate.distance(to: segment.1))
                closestDistance = distances.1
            }
            if intersectionDistance != nil && intersectionDistance! < closestDistance ?? .greatestFiniteMagnitude {
                closestCoordinate = IndexedCoordinate(coordinate: intersectionPoint!,
                                                      index: index,
                                                      distance: startCoordinate.distance(to: intersectionPoint!))
                closestDistance = intersectionDistance!
            }
        }
        
        return closestCoordinate
    }
}
