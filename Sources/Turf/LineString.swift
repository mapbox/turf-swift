import Foundation
#if !os(Linux)
import CoreLocation
#endif


// `Polyline` has been renamed to `LineString`. This alias is for backwards compatibility.
public typealias Polyline = LineString


/**
 `LineString` geometry represents a shape consisting of two or more coordinates.
 */
public struct LineString: Codable, Equatable {
    var type: String = GeometryType.LineString.rawValue
    public var coordinates: [CLLocationCoordinate2D]
}

public struct LineStringFeature: GeoJSONObject {
    public var type: FeatureType = .feature
    public var identifier: FeatureIdentifier?
    public var geometry: LineString!
    public var properties: [String : AnyJSONType]?
    
    public init(_ geometry: LineString) {
        self.geometry = geometry
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GeoJSONCodingKeys.self)
        geometry = try container.decode(LineString.self, forKey: .geometry)
        properties = try container.decode([String: AnyJSONType]?.self, forKey: .properties)
        identifier = try container.decodeIfPresent(FeatureIdentifier.self, forKey: .identifier)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: GeoJSONCodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(geometry, forKey: .geometry)
        try container.encode(properties, forKey: .properties)
        try container.encodeIfPresent(identifier, forKey: .identifier)
    }
}

extension LineString {
    
    /**
     Returns a polyline along a polyline within a distance from a coordinate.
     */
    public func trimmed(from coordinate: CLLocationCoordinate2D, distance: CLLocationDistance) -> LineString {
        let startVertex = closestCoordinate(to: coordinate)
        guard startVertex != nil && distance != 0 else {
            return LineString([])
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
     Initializes a Polyline from the given coordinates.
     */
    public init(_ coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = coordinates
    }
    
    /**
     Returns a coordinate along a LineString at a certain distance from the start of the polyline.
     */
    public func coordinateFromStart(distance: CLLocationDistance) -> CLLocationCoordinate2D? {
        return indexedCoordinateFromStart(distance: distance)?.coordinate
    }
    
    /**
     Returns an indexed coordinate along a LineString at a certain distance from the start of the polyline.
     */
    public func indexedCoordinateFromStart(distance: CLLocationDistance) -> IndexedCoordinate? {
        // Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-along/index.js
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
    
    
    /**
     Returns the distance along a slice of a LineString with the given endpoints.
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
     Returns a subset of the LineString between given coordinates.
     */
    public func sliced(from start: CLLocationCoordinate2D? = nil, to end: CLLocationCoordinate2D? = nil) -> LineString {
        // Ported from https://github.com/Turfjs/turf/blob/142e137ce0c758e2825a260ab32b24db0aa19439/packages/turf-line-slice/index.js
        guard !coordinates.isEmpty else {
            return LineString([])
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
        
        return LineString(coords)
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
            
            if distances.0 < closestCoordinate?.distance ?? .greatestFiniteMagnitude {
                closestCoordinate = IndexedCoordinate(coordinate: segment.0, index: index, distance: distances.0)
            }
            if distances.1 < closestCoordinate?.distance ?? .greatestFiniteMagnitude {
                closestCoordinate = IndexedCoordinate(coordinate: segment.1, index: index+1, distance: distances.1)
            }
            if intersectionDistance != nil && intersectionDistance! < closestCoordinate?.distance ?? .greatestFiniteMagnitude {
                closestCoordinate = IndexedCoordinate(coordinate: intersectionPoint!, index: (distances.0 < distances.1 ? index : index+1), distance: intersectionDistance!)
            }
        }
        
        return closestCoordinate
    }
}
