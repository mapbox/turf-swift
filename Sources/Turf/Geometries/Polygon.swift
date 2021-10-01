import Foundation
#if !os(Linux)
import CoreLocation
#endif

/**
 A [Polygon geometry](https://datatracker.ietf.org/doc/html/rfc7946#section-3.1.6) is conceptually a collection of `Ring`s that form a single connected geometry.
 */
public struct Polygon: Equatable {
    /// The positions at which the polygon is located. Each nested array corresponds to one linear ring.
    public var coordinates: [[LocationCoordinate2D]]
    
    /**
     Initializes a polygon defined by the given positions.
     
     - parameter coordinates: The positions at which the polygon is located. Each nested array corresponds to one linear ring.
     */
    public init(_ coordinates: [[LocationCoordinate2D]]) {
        self.coordinates = coordinates
    }
    
    /**
     Initializes a polygon defined by the given linear rings.
     
     - parameter outerRing: The outer linear ring.
     - parameter innerRings: The inner linear rings that define “holes” in the polygon.
     */
    public init(outerRing: Ring, innerRings: [Ring] = []) {
        self.coordinates = ([outerRing] + innerRings).map { $0.coordinates }
    }

    /**
     Initializes a polygon as a given center coordinate with a given number of
     vertices, as a means to approximate a circle.

     - Parameter center: The center coordinate for the polygon.
     - Parameter radius: The radius of the polygon, measured in meters.
     - Parameter vertices: The number of vertices the polygon will have.
                           The recommended amount is 64.
     - Returns: A polygon shape which approximates a circle.
     */
    public init(center: LocationCoordinate2D, radius: LocationDistance, vertices: Int) {
        // The first and last coordinates in a polygon must be identical,
        // which is why we're using the inclusive range operator in this case.
        // Ported from https://github.com/Turfjs/turf/blob/17002ccd57e04e84ddb38d7e3ac8ede35b019c58/packages/turf-circle/index.ts
        let coordinates = (0...vertices).map { ( step ) -> LocationCoordinate2D in
            let bearing = fabs(LocationDirection(step * -360 / vertices))
            return center.coordinate(at: radius, facing: bearing)
        }

        self.coordinates = [coordinates]
    }
}

extension Polygon: Codable {
    enum CodingKeys: String, CodingKey {
        case kind = "type"
        case coordinates
    }
    
    enum Kind: String, Codable {
        case Polygon
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _ = try container.decode(Kind.self, forKey: .kind)
        let coordinates = try container.decode([[LocationCoordinate2DCodable]].self, forKey: .coordinates).decodedCoordinates
        self = .init(coordinates)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Kind.Polygon, forKey: .kind)
        try container.encode(coordinates.codableCoordinates, forKey: .coordinates)
    }
}

extension Polygon {
    /// Representation of `Polygon`s coordinates of inner rings
    public var innerRings: [Ring] {
        return Array(coordinates.suffix(from: 1)).map { Ring(coordinates: $0) }
    }
    
    /// Representation of `Polygon`s coordinates of outer ring
    public var outerRing: Ring {
        get {
            return Ring(coordinates: coordinates.first! )
        }
    }
    
    /// An area of current `Polygon`
    ///
    /// Ported from https://github.com/Turfjs/turf/blob/a94151418cb969868fdb42955a19a133512da0fd/packages/turf-area/index.js
    public var area: Double {
        return abs(outerRing.area) - innerRings
            .map { abs($0.area) }
            .reduce(0, +)
    }
    
    /// Determines if the given coordinate falls within the polygon and outside of its interior rings.
    /// The optional parameter `ignoreBoundary` will result in the method returning true if the given coordinate
    /// lies on the boundary line of the polygon or its interior rings.
    ///
    ///Ported from: https://github.com/Turfjs/turf/blob/e53677b0931da9e38bb947da448ee7404adc369d/packages/turf-boolean-point-in-polygon/index.ts#L31-L75
    public func contains(_ coordinate: LocationCoordinate2D, ignoreBoundary: Bool = false) -> Bool {
        guard outerRing.contains(coordinate, ignoreBoundary: ignoreBoundary) else {
            return false
        }
        for ring in innerRings {
            if ring.contains(coordinate, ignoreBoundary: !ignoreBoundary) {
                return false
            }
        }
        return true
    }

    /// Smooths a `Polygon`. Based on [Chaikin's algorithm](http://graphics.cs.ucdavis.edu/education/CAGDNotes/Chaikins-Algorithm/Chaikins-Algorithm.html).
    /// Warning: may create degenerate polygons.
    ///
    /// Ported from https://github.com/Turfjs/turf/blob/402716a29f6ae16bf3d0220e213e5380cc5a50c4/packages/turf-polygon-smooth/index.js
    public func smooth(iterations: Int = 3) -> Polygon {
        var poly = self
        var tempOutput: [[LocationCoordinate2D]] = [[]];
        var outCoords: [[LocationCoordinate2D]] = [[]];

        (0..<iterations).forEach({ i in
            tempOutput = [[]]
            
            if (i > 0) {
                poly = Polygon(outCoords);
            }

            processPolygon(poly, &tempOutput);
            outCoords = tempOutput
        })

        return Polygon(outCoords);
    }

    private func processPolygon(_ poly: Polygon, _ tempOutput: inout [[LocationCoordinate2D]]) {
        var coordIndex = 0
        var prevGeomIndex = 0;
        var geometryIndex = 0;
        var subtractCoordIndex = 0;

        (0..<poly.coordinates.count).forEach { j in
            (0..<poly.coordinates[j].count - 1).forEach { k in
                if (geometryIndex > prevGeomIndex) {
                    prevGeomIndex = geometryIndex;
                    subtractCoordIndex = coordIndex;
                    tempOutput.append([]);
                }

                let currentCoord = poly.coordinates[j][k]
                let realCoordIndex = coordIndex - subtractCoordIndex;
                let p1 = poly.coordinates[geometryIndex][realCoordIndex + 1];
                let p0x = currentCoord.latitude;
                let p0y = currentCoord.longitude;
                let p1x = p1.latitude;
                let p1y = p1.longitude;
                tempOutput[geometryIndex].append(LocationCoordinate2D(
                    latitude: 0.75 * p0x + 0.25 * p1x,
                    longitude: 0.75 * p0y + 0.25 * p1y
                ));
                tempOutput[geometryIndex].append(LocationCoordinate2D(
                    latitude: 0.25 * p0x + 0.75 * p1x,
                    longitude: 0.25 * p0y + 0.75 * p1y
                ));

                coordIndex += 1
            }

            geometryIndex += 1
        }

        tempOutput.enumerated().forEach({ i, ring in
            tempOutput[i] = ring + [ring[0]]
        })
    }

    /// Returns a copy of the Polygon with the Ramer–Douglas–Peucker algorithm applied to it.
    ///
    /// tolerance:  Controls the level of simplification by specifying the maximum allowed distance between the original line point
    /// and the simplified point. Higher tolerance values results in higher simplification.
    ///
    /// highestQuality: Excludes distance-based preprocessing step which leads to highest quality simplification. High quality simplification runs considerably slower so consider how much precision is needed in your application.
    ///
    /// Ported from https://github.com/Turfjs/turf/blob/master/packages/turf-simplify/lib/simplify.js
    public func simplified(tolerance: Double = 1.0, highestQuality: Bool = false) -> Polygon {
        var copy = Polygon(coordinates)
        copy.simplify(tolerance: tolerance, highestQuality: highestQuality)
        return copy
    }

    /// Mutates the Polygon into a simplified version using the Ramer–Douglas–Peucker algorithm.
    ///
    /// tolerance:  Controls the level of simplification by specifying the maximum allowed distance between the original line point
    /// and the simplified point. Higher tolerance values results in higher simplification.
    ///
    /// highestQuality: Excludes distance-based preprocessing step which leads to highest quality simplification. High quality simplification runs considerably slower so consider how much precision is needed in your application.
    ///
    /// Ported from https://github.com/Turfjs/turf/blob/master/packages/turf-simplify/lib/simplify.js
    public mutating func simplify(tolerance: Double = 1.0, highestQuality: Bool = false) {
        coordinates = coordinates.map { ring in
            guard ring.count > 3 else { return ring }
            
            var tolerance = tolerance
            var simpleRing: [LocationCoordinate2D]
            repeat {
                simpleRing = Simplifier.simplify(ring, tolerance: tolerance, highestQuality: highestQuality)
                
                //remove 1 percent of tolerance until enough points to make a triangle
                tolerance -= tolerance * 0.01

            } while !checkValidity(ring: simpleRing)

            if (
                simpleRing[simpleRing.count - 1].latitude != simpleRing[0].latitude ||
                simpleRing[simpleRing.count - 1].longitude != simpleRing[0].longitude
            ) {
                simpleRing.append(simpleRing[0])
            }

            return simpleRing
        }
    }

    /// Checks if a ring has at least 3 coordinates. Will return false for a 3 coordinate ring
    /// where the first and last coordinates are the same
    ///
    /// - Parameter ring: Array of coordinates to be checked
    /// - Returns: true if valid
    private func checkValidity(ring: [LocationCoordinate2D]) -> Bool {
        guard ring.count >= 3 else { return false }
        // if the last point is the same as the first, it's not a triangle
        return !(
            ring.count == 3 &&
            ring[2].latitude == ring[0].latitude &&
            ring[2].longitude == ring[0].longitude
        )
    }

    /// Calculates the absolute centre (of the bounding box).
    public var center: LocationCoordinate2D? {
        // This implementation is a port of: https://github.com/Turfjs/turf/blob/master/packages/turf-center/index.ts
        return BoundingBox(from: outerRing.coordinates)
            .map { .init(
                latitude: ($0.southWest.latitude + $0.northEast.latitude) / 2,
                longitude: ($0.southWest.longitude + $0.northEast.longitude) / 2
            ) }
    }

    /// Calculates the centroid using the mean of all vertices.
    /// This lessens the effect of small islands and artifacts when calculating the centroid of a set of polygons.
    public var centroid: LocationCoordinate2D? {
        // This implementation is a port of: https://github.com/Turfjs/turf/blob/master/packages/turf-centroid/index.ts
        
        let coordinates = outerRing.coordinates.dropLast()
        guard coordinates.count > 0 else { return nil }
        
        let summed = coordinates
            .reduce(into: LocationCoordinate2D(latitude: 0, longitude: 0)) { acc, next in
                acc.latitude += next.latitude
                acc.longitude += next.longitude
            }
        return LocationCoordinate2D(
            latitude: summed.latitude / Double(coordinates.count),
            longitude: summed.longitude / Double(coordinates.count)
        ).normalized
    }
    
    /// Calculates the [center of mass](https://en.wikipedia.org/wiki/Center_of_mass) using this formula: [Centroid of Polygon](https://en.wikipedia.org/wiki/Centroid#Centroid_of_polygon).
    public var centerOfMass: LocationCoordinate2D? {
        // This implementation is a port of: https://github.com/Turfjs/turf/blob/master/packages/turf-center-of-mass/index.ts
        
        // First, we neutralize the feature (set it around coordinates [0,0]) to prevent rounding errors
        // We take any point to translate all the points around 0
        guard let center = centroid else { return nil }
        let coordinates = outerRing.coordinates
        let neutralized = coordinates.map {
            LocationCoordinate2D(latitude: $0.latitude - center.latitude, longitude: $0.longitude - center.longitude)
        }
        
        var signedArea: Double = 0
        var sum = LocationCoordinate2D(latitude: 0, longitude: 0)
        let zipped = zip(neutralized.prefix(upTo: neutralized.count - 1), neutralized.suffix(from: 1))
        for (pi, pj) in zipped {
            let (xi, yi) = (pi.longitude, pi.latitude)
            let (xj, yj) = (pj.longitude, pj.latitude)
            
            // common factor to compute the signed area and the final coordinates
            let a = xi * yj - xj * yi
            signedArea += a
            sum.longitude += (xi + xj) * a
            sum.latitude += (yi + yj) * a
        }
        guard signedArea != 0 else { return center }
        
        // compute signed area, and factorise 1/6A
        let area = signedArea / 2
        let areaFactor = 1 / (6 * area)
        
        // final coordinates, adding back values that have been neutralized
        return LocationCoordinate2D(
            latitude: center.latitude + areaFactor * sum.latitude,
            longitude: center.longitude + areaFactor * sum.longitude
        ).normalized
    }}
