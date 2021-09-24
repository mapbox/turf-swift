import Foundation

enum Simplifier {
    
    static func simplify(_ coordinates: [LocationCoordinate2D], tolerance: Double, highestQuality: Bool) -> [LocationCoordinate2D] {
        guard coordinates.count > 2 else { return coordinates }

        let squareTolerance = tolerance * tolerance

        let input = highestQuality ? coordinates : Simplifier.simplifyRadial(coordinates, squareTolerance: squareTolerance)

        return Simplifier.simplifyDouglasPeucker(input, tolerance: squareTolerance)
    }
    
    // MARK: - Douglas-Peucker
    
    private static func squareSegmentDistance(_ coordinate: LocationCoordinate2D, segmentStart: LocationCoordinate2D, segmentEnd: LocationCoordinate2D) -> LocationDistance {

        var x = segmentStart.latitude
        var y = segmentStart.longitude
        var dx = segmentEnd.latitude - x
        var dy = segmentEnd.longitude - y

        if dx != 0 || dy != 0 {
            let t = ((coordinate.latitude - x) * dx + (coordinate.longitude - y) * dy) / (dx * dx + dy * dy)
            if t > 1 {
                x = segmentEnd.latitude
                y = segmentEnd.longitude
            } else if t > 0 {
                x += dx * t
                y += dy * t
            }
        }

        dx = coordinate.latitude - x
        dy = coordinate.longitude - y

        return dx * dx + dy * dy
    }

    private static func simplifyDouglasPeuckerStep(_ coordinates: [LocationCoordinate2D], first: Int, last: Int, tolerance: Double, simplified: inout [LocationCoordinate2D]) {

        var maxSquareDistance = tolerance
        var index = 0

        for i in first + 1 ..< last {
            let squareDistance = squareSegmentDistance(coordinates[i], segmentStart: coordinates[first], segmentEnd: coordinates[last])

            if squareDistance > maxSquareDistance {
                index = i
                maxSquareDistance = squareDistance
            }
        }

        if maxSquareDistance > tolerance {
            if index - first > 1 {
                simplifyDouglasPeuckerStep(coordinates, first: first, last: index, tolerance: tolerance, simplified: &simplified)
            }
            simplified.append(coordinates[index])
            if last - index > 1 {
                simplifyDouglasPeuckerStep(coordinates, first: index, last: last, tolerance: tolerance, simplified: &simplified)
            }
        }
    }

    private static func simplifyDouglasPeucker(_ coordinates: [LocationCoordinate2D], tolerance: Double) -> [LocationCoordinate2D] {
        if coordinates.count <= 2 {
            return coordinates
        }

        let lastPoint = coordinates.count - 1
        var result = [coordinates[0]]
        simplifyDouglasPeuckerStep(coordinates, first: 0, last: lastPoint, tolerance: tolerance, simplified: &result)
        result.append(coordinates[lastPoint])
        return result
    }
    
    //MARK: - Radial simplification
    
    private static func squareDistance(from origin: LocationCoordinate2D, to destination: LocationCoordinate2D) -> Double {
        let dx = origin.longitude - destination.longitude
        let dy = origin.latitude - destination.latitude
        return dx * dx + dy * dy
    }
    
    private static func simplifyRadial(_ coordinates: [LocationCoordinate2D], squareTolerance: Double) -> [LocationCoordinate2D] {
        guard coordinates.count > 2 else { return coordinates }

        var prevCoordinate = coordinates[0]
        var newCoordinates = [prevCoordinate]
        var coordinate = coordinates[1]

        for index in 1 ..< coordinates.count {
            coordinate = coordinates[index]

            if squareDistance(from: coordinate, to: prevCoordinate) > squareTolerance {
                newCoordinates.append(coordinate)
                prevCoordinate = coordinate
            }
        }

        if prevCoordinate != coordinate {
            newCoordinates.append(coordinate)
        }

        return newCoordinates
    }
    
}
