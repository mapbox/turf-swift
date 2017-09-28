import CoreLocation

public typealias LocationRadians = Double
public typealias RadianDistance = Double
public typealias RadianDirection = Double

let metersPerRadian = 6_373_000.0

/**
 A `RadianCoordinate2D` is a coordinate represented in radians as opposed to
 `CLLocationCoordinate2D` which is represented in latitude and longitude.
 */
public struct RadianCoordinate2D {
    private(set) var latitude: LocationRadians
    private(set) var longitude: LocationRadians
    
    public init(latitude: LocationRadians, longitude: LocationRadians) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public init(_ degreeCoordinate: CLLocationCoordinate2D) {
        latitude = degreeCoordinate.latitude.toRadians()
        longitude = degreeCoordinate.longitude.toRadians()
    }
    
    /**
     Returns direction given two coordinates.
     */
    public func direction(to coordinate: RadianCoordinate2D) -> RadianDirection {
        let a = sin(coordinate.longitude - longitude) * cos(coordinate.latitude)
        let b = cos(latitude) * sin(coordinate.latitude)
            - sin(latitude) * cos(coordinate.latitude) * cos(coordinate.longitude - longitude)
        return atan2(a, b)
    }
    
    /**
     Returns coordinate at a given distance and direction away from coordinate.
     */
    public func coordinate(at distance: RadianDistance, facing direction: RadianDirection) -> RadianCoordinate2D {
        let distance = distance, direction = direction
        let otherLatitude = asin(sin(latitude) * cos(distance)
            + cos(latitude) * sin(distance) * cos(direction))
        let otherLongitude = longitude + atan2(sin(direction) * sin(distance) * cos(latitude),
                                               cos(distance) - sin(latitude) * sin(otherLatitude))
        return RadianCoordinate2D(latitude: otherLatitude, longitude: otherLongitude)
    }
    
    /**
     Returns the Haversine distance between two coordinates measured in radians.
     */
    public func distance(to coordinate: RadianCoordinate2D) -> RadianDistance {
        let a = pow(sin((coordinate.latitude - self.latitude) / 2), 2)
            + pow(sin((coordinate.longitude - self.longitude) / 2), 2) * cos(self.latitude) * cos(coordinate.latitude)
        return 2 * atan2(sqrt(a), sqrt(1 - a))
    }
}

public typealias LineSegment = (CLLocationCoordinate2D, CLLocationCoordinate2D)


public struct Turf {
    
    /**
     Returns the intersection of two line segments.
     */
    public static func intersection(_ line1: LineSegment, _ line2: LineSegment) -> CLLocationCoordinate2D? {
        // Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-point-on-line/index.js, in turn adapted from http://jsfiddle.net/justin_c_rounds/Gd2S2/light/
        let denominator = ((line2.1.latitude - line2.0.latitude) * (line1.1.longitude - line1.0.longitude))
            - ((line2.1.longitude - line2.0.longitude) * (line1.1.latitude - line1.0.latitude))
        guard denominator != 0 else {
            return nil
        }
        
        let dStartY = line1.0.latitude - line2.0.latitude
        let dStartX = line1.0.longitude - line2.0.longitude
        let numerator1 = (line2.1.longitude - line2.0.longitude) * dStartY - (line2.1.latitude - line2.0.latitude) * dStartX
        let numerator2 = (line1.1.longitude - line1.0.longitude) * dStartY - (line1.1.latitude - line1.0.latitude) * dStartX
        let a = numerator1 / denominator
        let b = numerator2 / denominator
        
        /// Intersection when the lines are cast infinitely in both directions.
        let intersection = CLLocationCoordinate2D(latitude: line1.0.latitude + a * (line1.1.latitude - line1.0.latitude),
                                                  longitude: line1.0.longitude + a * (line1.1.longitude - line1.0.longitude))
        
        /// True if line 1 is finite and line 2 is infinite.
        let intersectsWithLine1 = a > 0 && a < 1
        /// True if line 2 is finite and line 1 is infinite.
        let intersectsWithLine2 = b > 0 && b < 1
        return intersectsWithLine1 && intersectsWithLine2 ? intersection : nil
    }
}

/**
 A `Polyline` struct represents a shape consisting of two or more coordinates,
 specified as `[CLLocationCoordinate2D]`
 */
public struct Polyline {
    
    /**
     `IndexedCoordinate` is a coordinate with additional information such as
     the index from its position in the polyline and distance from the start
     of the polyline.
     */
    public struct IndexedCoordinate {
        /// The coordinate
        public let coordinate: Array<CLLocationCoordinate2D>.Element
        /// The index of the coordinate
        public let index: Array<CLLocationCoordinate2D>.Index
        /// The coordinate’s distance from the start of the polyline
        public let distance: CLLocationDistance
    }
    
    /**
     The coordinates that the `Polyline` was initialized with.
     */
    public var coordinates: [CLLocationCoordinate2D]
    
    /**
     Initializes a Polyline from the given coordinates.
     */
    public init(_ coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = coordinates
    }
    
    
    /**
     Returns a coordinate along a polyline at a certain distance from the start of the polyline.
     */
    public func coordinateFromStart(distance: CLLocationDistance) -> CLLocationCoordinate2D? {
        // Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-along/index.js
        var traveled: CLLocationDistance = 0
        
        guard distance >= 0  else {
            return coordinates.first
        }
        
        for i in 0..<coordinates.count {
            guard distance < traveled || i < coordinates.count - 1 else {
                break
            }
            
            if traveled >= distance {
                let overshoot = distance - traveled
                if overshoot == 0 {
                    return coordinates[i]
                }
                
                let direction = coordinates[i].direction(to: coordinates[i - 1]) - 180
                return coordinates[i].coordinate(at: overshoot, facing: direction)
            }
            
            traveled += coordinates[i].distance(to: coordinates[i + 1])
        }
        
        return coordinates.last
    }
    
    
    /**
     Returns the distance along a slice of a polyline with the given endpoints.
     */
    public func distance(from start: CLLocationCoordinate2D? = nil, to end: CLLocationCoordinate2D? = nil) -> CLLocationDistance {
        // Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-line-slice/index.js
        guard !coordinates.isEmpty else {
            return 0
        }
        
        let slicedCoordinates = sliced(from: start, to: end).coordinates
        let zippedCoordinates = zip(slicedCoordinates.prefix(upTo: slicedCoordinates.count - 1), slicedCoordinates.suffix(from: 1))
        return zippedCoordinates.map { $0.distance(to: $1) }.reduce(0, +)
    }
    
    
    /**
     Returns a subset of the polyline between given coordinates.
     */
    public func sliced(from start: CLLocationCoordinate2D? = nil, to end: CLLocationCoordinate2D? = nil) -> Polyline {
        // Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-line-slice/index.js
        guard !coordinates.isEmpty else {
            return Polyline([])
        }
        
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
        coords.append(ends.1.coordinate)
        
        return Polyline(coords)
    }
    
    
    /**
     Returns a polyline along a polyline within a distance from a coordinate.
     */
    public func trimmed(from coordinate: CLLocationCoordinate2D, distance: CLLocationDistance) -> Polyline {
        let startVertex = closestCoordinate(to: coordinate)
        guard startVertex != nil && distance != 0 else {
            return Polyline([])
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
        return Polyline(vertices)
    }
    
    /**
     Returns the geographic coordinate along the polyline that is closest to the given coordinate as the crow flies.
     
     The returned coordinate may not correspond to one of the polyline’s vertices, but it always lies along the polyline.
     */
    public func closestCoordinate(to coordinate: CLLocationCoordinate2D) -> IndexedCoordinate? {
        // Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-point-on-line/index.js
        
        guard !coordinates.isEmpty else {
            return nil
        }
        guard coordinates.count > 1 else {
            return IndexedCoordinate(coordinate: coordinates.first!, index: 0, distance: coordinate.distance(to: coordinates.first!))
        }
        
        var closestCoordinate: IndexedCoordinate?
        
        for index in 0..<coordinates.count - 1 {
            let segment = (coordinates[index], coordinates[index + 1])
            let distances = (coordinate.distance(to: segment.0), coordinate.distance(to: segment.1))
            
            let maxDistance = max(distances.0, distances.1)
            let direction = segment.0.direction(to: segment.1)
            let perpendicularPoint1 = coordinate.coordinate(at: maxDistance, facing: direction + 90)
            let perpendicularPoint2 = coordinate.coordinate(at: maxDistance, facing: direction - 90)
            let intersectionPoint = Turf.intersection((perpendicularPoint1, perpendicularPoint2), segment)
            let intersectionDistance: CLLocationDistance? = intersectionPoint != nil ? coordinate.distance(to: intersectionPoint!) : nil
            
            if distances.0 < closestCoordinate?.distance ?? CLLocationDistanceMax {
                closestCoordinate = IndexedCoordinate(coordinate: segment.0, index: index, distance: distances.0)
            }
            if distances.1 < closestCoordinate?.distance ?? CLLocationDistanceMax {
                closestCoordinate = IndexedCoordinate(coordinate: segment.1, index: index+1, distance: distances.1)
            }
            if intersectionDistance != nil && intersectionDistance! < closestCoordinate?.distance ?? CLLocationDistanceMax {
                closestCoordinate = IndexedCoordinate(coordinate: intersectionPoint!, index: (distances.0 < distances.1 ? index : index+1), distance: intersectionDistance!)
            }
        }
        
        return closestCoordinate
    }
}
