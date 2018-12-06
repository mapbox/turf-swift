import Foundation
#if !os(Linux)
import CoreLocation
#endif


/**
 
 */

struct SplinePoint {
    let x: CLLocationDegrees
    let y: CLLocationDegrees
    let z: CLLocationDegrees
    
    init(coordinate: CLLocationCoordinate2D) {
        self.x = coordinate.longitude
        self.y = coordinate.latitude
        self.z = 0
    }
    
    init(x: CLLocationDegrees, y: CLLocationDegrees, z: CLLocationDegrees) {
        self.x = x
        self.y = y
        self.z = z
    }
}

struct Spline {
    private let points: [SplinePoint]
    private let duration: Int
    private let sharpness: Double
    private let stepLength: Int
    private let length: Int
    private let delay: Int = 0
    private var centers = [SplinePoint]()
    private var controls = [(SplinePoint, SplinePoint)]()
    
    init?(points: [SplinePoint], duration: Int = 10000, sharpness: Double = 0.85, stepLength: Int = 60) {
        guard points.count >= 2 else { return nil }
        self.points = points
        self.duration = duration
        self.sharpness = sharpness
        self.stepLength = stepLength
        
        self.length = points.count
        
        for (index, point) in points.enumerated() {
            guard index < points.count - 1 else { continue }
            let nextPoint = points[index + 1]
            let center = SplinePoint(x: (point.x + nextPoint.x)/2, y: (point.y + nextPoint.y)/2, z: (point.z + nextPoint.z)/2)
            self.centers.append(center)
        }
        
        self.controls.append((points[0], points[0]))
        
        for (index, center) in self.centers.enumerated() {
            guard index < points.count - 1 else { continue }
            let nextCenter = self.centers[index + 1]
            let nextPoint = self.points[index + 1]
            let dx = nextPoint.x - (center.x + nextCenter.x)/2
            let dy = nextPoint.y - (center.y + nextCenter.y)/2
            let dz = nextPoint.z - (center.z + nextCenter.z)/2
            let control1 = SplinePoint(x: (1 - sharpness) * nextPoint.x + sharpness * (center.x + dx),
                                       y: (1 - sharpness) * nextPoint.y + sharpness * (center.y + dy),
                                       z: (1 - sharpness) * nextPoint.z + sharpness * (center.z + dz))
            let control2 = SplinePoint(x: (1 - sharpness) * nextPoint.x + sharpness * (nextCenter.x + dx),
                                       y: (1 - sharpness) * nextPoint.y + sharpness * (nextCenter.y + dy),
                                       z: (1 - sharpness) * nextPoint.z + sharpness * (nextCenter.z + dz))
            self.controls.append((control1, control2))
        }
        let lastPoint = points.last!
        self.controls.append((lastPoint, lastPoint))
        self.test()
    }
    
    
    func test() {
        
    }
    
    //MARK: - Private
    
    private func B<T>(t: T) {
        
    }
}
