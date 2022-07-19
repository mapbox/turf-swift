import Foundation
#if !os(Linux)
import CoreLocation
#endif

/**
 A [LineString geometry](https://datatracker.ietf.org/doc/html/rfc7946#section-3.1.4) is a collection of two or more positions, each position connected to the next position linearly.
 */
public struct LineString: Equatable, ForeignMemberContainer {
    /// The positions at which the line string is located.
    public var coordinates: [LocationCoordinate2D]
    
    public var foreignMembers: JSONObject = [:]
    
    /**
     Initializes a line string defined by given positions.
     
     This initializer is equivalent to the [`lineString`](https://turfjs.org/docs/#lineString) function in the turf-helpers package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers/)).
     
     - parameter coordinates: The positions at which the line string is located.
     */
    public init(_ coordinates: [LocationCoordinate2D]) {
        self.coordinates = coordinates
    }
    
    /**
     Initializes a line string coincident to the given linear ring.
     
     This initializer is roughly equivalent to the [`polygon-to-line`](https://turfjs.org/docs/#polygonToLine) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-polygon-to-line/)), except that it accepts a linear ring instead of a full polygon.
     
     - parameter ring: The linear ring coincident to the line string.
     */
    public init(_ ring: Ring) {
        self.coordinates = ring.coordinates
    }
    
    /**
     Representation of current `LineString` as an array of `LineSegment`s.
     */
    var segments: [LineSegment] {
        return zip(coordinates.dropLast(), coordinates.dropFirst()).map { LineSegment($0.0, $0.1) }
    }
}

extension LineString: Codable {
    enum CodingKeys: String, CodingKey {
        case kind = "type"
        case coordinates
    }
    
    enum Kind: String, Codable {
        case LineString
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _ = try container.decode(Kind.self, forKey: .kind)
        let coordinates = try container.decode([LocationCoordinate2DCodable].self, forKey: .coordinates).decodedCoordinates
        self = .init(coordinates)
        try decodeForeignMembers(notKeyedBy: CodingKeys.self, with: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Kind.LineString, forKey: .kind)
        try container.encode(coordinates.codableCoordinates, forKey: .coordinates)
        try encodeForeignMembers(notKeyedBy: CodingKeys.self, to: encoder)
    }
}

extension LineString {
    /**
     Returns the line string transformed into an approximation of a curve by applying a Bézier spline algorithm.
     
     This method is equivalent to the [turf-bezier-spline](https://turfjs.org/docs/#bezierSpline) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-bezier-spline/)).
     */
    public func bezier(resolution: Int = 10000, sharpness: Double = 0.85) -> LineString? {
        // Ported from https://github.com/Turfjs/turf/blob/1ea264853e1be7469c8b7d2795651c9114a069aa/packages/turf-bezier-spline/index.ts
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
    
    /**
     Returns the portion of the line string that begins at the given start distance and extends the given stop distance along the line string.
     
     This method is equivalent to the [turf-line-slice-along](https://turfjs.org/docs/#lineSliceAlong) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-line-slice-along/)).
     */
    public func trimmed(from startDistance: LocationDistance, to stopDistance: LocationDistance) -> LineString? {
        // The method is porting from https://github.com/Turfjs/turf/blob/5375941072b90d489389db22b43bfe809d5e451e/packages/turf-line-slice-along/index.js
        guard startDistance >= 0.0 && stopDistance >= startDistance else { return nil }
        let coordinates = self.coordinates
        var traveled: LocationDistance = 0
        var slice = [LocationCoordinate2D]()
        
        for i in 0..<coordinates.endIndex {
            if startDistance >= traveled && i == coordinates.endIndex - 1 {
                break
            } else if traveled > startDistance && slice.isEmpty {
                let overshoot = startDistance - traveled
                if overshoot == 0.0 {
                    slice.append(coordinates[i])
                    return LineString(slice)
                }
                let direction = coordinates[i].direction(to: coordinates[i - 1]) - 180
                let interpolated = coordinates[i].coordinate(at: overshoot, facing: direction)
                slice.append(interpolated)
            }
            
            if traveled >= stopDistance {
                let overshoot = stopDistance - traveled
                if overshoot == 0.0 {
                    slice.append(coordinates[i])
                    return LineString(slice)
                }
                let direction = coordinates[i].direction(to: coordinates[i - 1]) - 180
                let interpolated = coordinates[i].coordinate(at: overshoot, facing: direction)
                slice.append(interpolated)
                return LineString(slice)
            }
            
            if traveled >= startDistance {
                slice.append(coordinates[i])
            }
            
            if i == coordinates.count - 1 {
                return LineString(slice)
            }
            
            traveled += coordinates[i].distance(to: coordinates[i + 1])
        }
        
        if traveled < startDistance { return nil }
        
        if let last = coordinates.last {
            return LineString([last, last])
        }
        
        return nil
    }
    
    /**
     Returns the portion of the line string that begins at the given coordinate and extends the given distance along the line string.
     */
    public func trimmed(from coordinate: LocationCoordinate2D, distance: LocationDistance) -> LineString? {
        let startVertex = closestCoordinate(to: coordinate)
        guard startVertex != nil && distance != 0 else {
            return nil
        }
        
        var vertices: [LocationCoordinate2D] = [startVertex!.coordinate]
        var cumulativeDistance: LocationDistance = 0
        let addVertex = { (vertex: LocationCoordinate2D) -> Bool in
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
    
    /**
     `IndexedCoordinate` is a coordinate with additional information such as the index from its position in the polyline and distance from the start of the polyline.
     */
    public struct IndexedCoordinate {
        /// The coordinate
        public let coordinate: Array<LocationCoordinate2D>.Element
        /// The index of the coordinate
        public let index: Array<LocationCoordinate2D>.Index
        /// The coordinate’s distance from the start of the polyline
        public let distance: LocationDistance
    }
    
    /**
     Returns a coordinate along a line string at a certain distance from the start of the polyline.
     
     This method is equivalent to the [turf-along](https://turfjs.org/docs/#along) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-along/)).
     */
    public func coordinateFromStart(distance: LocationDistance) -> LocationCoordinate2D? {
        return indexedCoordinateFromStart(distance: distance)?.coordinate
    }
    
    /**
     Returns an indexed coordinate along a line string at a certain distance from the start of the polyline.
     */
    public func indexedCoordinateFromStart(distance: LocationDistance) -> IndexedCoordinate? {
        // Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-along/index.js
        var traveled: LocationDistance = 0
        
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
    
    
    /**
     Returns the distance along a slice of the line string with the given endpoints.
     
     If the `start` and `end` arguments are unspecified, this method is equivalent to the [turf-length](https://turfjs.org/docs/#length) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-length/)).
     */
    public func distance(from start: LocationCoordinate2D? = nil, to end: LocationCoordinate2D? = nil) -> LocationDistance? {
        // Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-line-slice/index.js
        guard !coordinates.isEmpty else { return nil }
        
        guard let slicedCoordinates = sliced(from: start, to: end)?.coordinates else {
            return nil
        }
        
        let zippedCoordinates = zip(slicedCoordinates.prefix(upTo: slicedCoordinates.count - 1), slicedCoordinates.suffix(from: 1))
        return zippedCoordinates.map { $0.distance(to: $1) }.reduce(0, +)
    }
    
    /**
     Returns a subset of the line string between two given coordinates.
     
     This method is equivalent to the [turf-line-slice](https://turfjs.org/docs/#lineSlice) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-line-slice/)).
     */
    public func sliced(from start: LocationCoordinate2D? = nil, to end: LocationCoordinate2D? = nil) -> LineString? {
        // Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-line-slice/index.js
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
    
    /**
     Returns the geographic coordinate along the line string that is closest to the given coordinate as the crow flies.
     
     The returned coordinate may not correspond to one of the polyline’s vertices, but it always lies along the polyline.
     
     This method is equivalent to the [turf-nearest-point-on-line](https://turfjs.org/docs/#nearestPointOnLine) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-nearest-point-on-line/)).
     */
    public func closestCoordinate(to coordinate: LocationCoordinate2D) -> IndexedCoordinate? {
        // Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-point-on-line/index.js
        guard let startCoordinate = coordinates.first else { return nil }
        
        guard coordinates.count > 1 else {
            return IndexedCoordinate(coordinate: startCoordinate, index: 0, distance: coordinate.distance(to: startCoordinate))
        }
        
        var closestCoordinate: IndexedCoordinate?
        var closestDistance: LocationDistance?
        
        for index in 0..<coordinates.count - 1 {
            let segment = (coordinates[index], coordinates[index + 1])
            let distances = (coordinate.distance(to: segment.0), coordinate.distance(to: segment.1))
            
            let maxDistance = max(distances.0, distances.1)
            let direction = segment.0.direction(to: segment.1)
            let perpendicularPoint1 = coordinate.coordinate(at: maxDistance, facing: direction + 90)
            let perpendicularPoint2 = coordinate.coordinate(at: maxDistance, facing: direction - 90)
            let intersectionPoint = Turf.intersection((perpendicularPoint1, perpendicularPoint2), segment)
            let intersectionDistance: LocationDistance? = intersectionPoint != nil ? coordinate.distance(to: intersectionPoint!) : nil
            
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

    /**
     Returns a copy of the line string simplified using the Ramer–Douglas–Peucker algorithm.
     
     This method is equivalent to the [turf-simplify](https://turfjs.org/docs/#simplify) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-simplify/)).
     
     - parameter tolerance: Controls the level of simplification by specifying the maximum allowed distance between the original line point and the simplified point. A higher tolerance value results in higher simplification.
     - parameter highestQuality: Excludes the distance-based preprocessing step that leads to highest-quality simplification. High-quality simplification runs considerably slower, so consider how much precision is needed in your application.
     - returns: A simplified line string.
     */
    public func simplified(tolerance: Double = 1.0, highestQuality: Bool = false) -> LineString {
        // Ported from https://github.com/Turfjs/turf/blob/4e8342acb1dbd099f5e91c8ee27f05fb2647ee1b/packages/turf-simplify/lib/simplify.js
        guard coordinates.count > 2 else { return LineString(coordinates) }

        var copy = LineString(coordinates)
        copy.simplify(tolerance: tolerance, highestQuality: highestQuality)
        return copy
    }

    /**
     Simplifies the line string in place using the Ramer–Douglas–Peucker algorithm.
     
     This method is nearly equivalent to the [turf-simplify](https://turfjs.org/docs/#simplify) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-simplify/)), except that it mutates the line string it is called on.
     
     - parameter tolerance: Controls the level of simplification by specifying the maximum allowed distance between the original line point and the simplified point. A higher tolerance value results in higher simplification.
     - parameter highestQuality: Excludes the distance-based preprocessing step that leads to highest-quality simplification. High-quality simplification runs considerably slower, so consider how much precision is needed in your application.
     */
    public mutating func simplify(tolerance: Double = 1.0, highestQuality: Bool = false) {
        // Ported from https://github.com/Turfjs/turf/blob/4e8342acb1dbd099f5e91c8ee27f05fb2647ee1b/packages/turf-simplify/lib/simplify.js
        coordinates = Simplifier.simplify(coordinates, tolerance: tolerance, highestQuality: highestQuality)
    }
    
    /**
     Returns all intersections with another `LineString`.
     
     This function is roughly equivalent to the [turf-line-intersect](https://turfjs.org/docs/#lineIntersect) package of Turf.js ([source code](https://github.com/Turfjs/turf/tree/master/packages/turf-line-intersect/)). Order of found intersections is not determined.
     
     You can also use `Turf.intersection(_:, _:)` if you need to find intersection of individual `LineSegment`s.
     
     - seealso: `Turf.intersection(_:, _:)`
     */
    public func intersections(with line: LineString) -> [LocationCoordinate2D] {
        var intersections = Set<HashableCoordinate>()
        for segment1 in segments {
            for segment2 in line.segments {
                if let intersection = Turf.intersection(LineSegment(segment1.0, segment1.1),
                                                        LineSegment(segment2.0, segment2.1)) {
                    intersections.insert(.init(intersection))
                }
            }
        }
        return intersections.map { $0.locationCoordinate }
    }
    
    private struct HashableCoordinate: Hashable {
        let latitude: Double
        let longitude: Double
        
        var locationCoordinate: LocationCoordinate2D {
            return LocationCoordinate2D(latitude: latitude,
                                        longitude: longitude)
        }
        
        init(_ coordinate: LocationCoordinate2D) {
            self.latitude = coordinate.latitude
            self.longitude = coordinate.longitude
        }
    }
}
