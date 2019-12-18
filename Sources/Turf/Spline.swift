import Foundation
#if !os(Linux)
import CoreLocation
#endif


struct SplinePoint {
    let x: CLLocationDegrees
    let y: CLLocationDegrees
    let z: CLLocationDegrees
    
    init(coordinate: CLLocationCoordinate2D) {
        x = coordinate.longitude
        y = coordinate.latitude
        z = 0
    }
    
    init(x: CLLocationDegrees, y: CLLocationDegrees, z: CLLocationDegrees) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: y, longitude: x)
    }
}

struct Spline {
    private let points: [SplinePoint]
    private let duration: Int
    private let sharpness: Double
    private let stepLength: Double
    private let length: Int
    private let delay: Int = 0
    private var centers = [SplinePoint]()
    private var controls = [(SplinePoint, SplinePoint)]()
    private var steps = [Int]()
    
    init?(points: [SplinePoint], duration: Int, sharpness: Double, stepLength: Double = 60) {
        guard points.count >= 2 else { return nil }
        self.points = points
        self.duration = duration
        self.sharpness = sharpness
        self.stepLength = stepLength
        
        length = points.count
        
        centers = (0..<(points.count - 1)).map { (index) in
            let point = points[index]
            let nextPoint = points[index + 1]
            let center = SplinePoint(x: (point.x + nextPoint.x) / 2, y: (point.y + nextPoint.y) / 2, z: (point.z + nextPoint.z) / 2)
            return center
        }
        
        controls = (0..<(centers.count - 1)).map { (index) in
            let center = centers[index]
            let nextCenter = centers[index + 1]
            let nextPoint = points[index + 1]
            let dx = nextPoint.x - (center.x + nextCenter.x) / 2
            let dy = nextPoint.y - (center.y + nextCenter.y) / 2
            let dz = nextPoint.z - (center.z + nextCenter.z) / 2
            let control1 = SplinePoint(x: (1 - sharpness) * nextPoint.x + sharpness * (center.x + dx),
                                       y: (1 - sharpness) * nextPoint.y + sharpness * (center.y + dy),
                                       z: (1 - sharpness) * nextPoint.z + sharpness * (center.z + dz))
            let control2 = SplinePoint(x: (1 - sharpness) * nextPoint.x + sharpness * (nextCenter.x + dx),
                                       y: (1 - sharpness) * nextPoint.y + sharpness * (nextCenter.y + dy),
                                       z: (1 - sharpness) * nextPoint.z + sharpness * (nextCenter.z + dz))
            return (control1, control2)
        }
        let firstPoint = points.first!
        controls.insert((firstPoint, firstPoint), at: 0)
        let lastPoint = points.last!
        controls.append((lastPoint, lastPoint))
        
        var lastStep = position(at: 0)
        steps.append(0)
        for t in stride(from: 0, to: duration, by: 10) {
            let step = position(at: t)
            let dist = sqrt((step.x - lastStep.x) * (step.x - lastStep.x) +
                (step.y - lastStep.y) * (step.y - lastStep.y) +
                (step.z - lastStep.z) * (step.z - lastStep.z))
            if dist > stepLength {
                steps.append(t)
                lastStep = step
            }
        }
    }
    
    func position(at time: Int) -> SplinePoint {
        var t = max(0, time - delay)
        if t > duration {
            t = duration - 1
        }
        let t2: Double = Double(t) / Double(duration)
        if t2 >= 1 {
            return points.last!
        }
        let n = floor(Double(points.count - 1) * t2)
        let t1 = Double(points.count - 1) * t2 - n
        let index = Int(n)
        return bezier(t: t1, p1: points[index], c1: controls[index].1, c2: controls[index + 1].0, p2: points[index + 1])
    }
    
    //MARK: - Private
    
    private func bezier(t: Double, p1: SplinePoint, c1: SplinePoint, c2: SplinePoint, p2: SplinePoint) -> SplinePoint {
        let b = B(t)
        let pos = SplinePoint(x: p2.x * b.0 + c2.x * b.1 + c1.x * b.2 + p1.x * b.3,
                              y: p2.y * b.0 + c2.y * b.1 + c1.y * b.2 + p1.y * b.3,
                              z: p2.z * b.0 + c2.z * b.1 + c1.z * b.2 + p1.z * b.3)
        return pos
    }
    
    private func B(_ t: Double) -> (Double, Double, Double, Double) {
        let t2 = t * t
        let t3 = t * t2
        return (t3, (3 * t2 * (1 - t)), (3 * t * (1 - t) * (1 - t)), ((1 - t) * (1 - t) * (1 - t)))
    }
}

public extension LineString {
	
    /**
     Returns a new LineString based on bezier transformation of the input line
     */
    func bezier(resolution: Int = 10000, sharpness: Double = 0.85) -> LineString? {
        // ported from https://github.com/Turfjs/turf/blob/1ea264853e1be7469c8b7d2795651c9114a069aa/packages/turf-bezier-spline/index.ts
        let points = coordinates.map {
            SplinePoint(coordinate: $0)
        }
        guard let spline = Spline(points: points, duration: resolution, sharpness: sharpness) else { return nil }
        let coords = stride(from: 0, to: resolution, by: 10)
            .filter { Int(floor(Double($0) / 100)) % 2 == 0 }
            .map { spline.position(at: $0).coordinate }
        let result = LineString(coords)
        return result
    }
}
