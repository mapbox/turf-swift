# GeoJSONKit+Turf

A fork of [turf-swift](https://github.com/mapbox/turf-swift.git) which relies on [GeoJSONKit](https://github.com/maparoni/geojsonkit). turf-swift itself is proted from [Turf.js](https://github.com/Turfjs/turf/). For an alternative see [spatial-algorithms](https://github.com/mapbox/spatial-algorithms/).

## Requirements

GeoJSONKitTurf requires Xcode 9.x and supports the following minimum deployment targets:

* iOS 10.0 and above
* macOS 10.12 (Sierra) and above
* tvOS 10.0 and above
* watchOS 3.0 and above

Alternatively, you can incorporate GeoJSONKitTurf into a command line tool without Xcode on any platform that [Swift](https://swift.org/download/) supports, including Linux.

## Installation

Just as turf-swift, a stable release of this library is not yet available.

### Swift Package Manager

To install GeoJSONKitTurf using the [Swift Package Manager](https://swift.org/package-manager/), add the following package to the `dependencies` in your Package.swift file:

```swift
.package(url: "https://github.com/maparoni/geojsonkit-turf", .branch("main")
```

Then `import GeoJSONKitTurf` in any Swift file in your module.


## Available functionality

This work-in-progress port of [Turf.js](https://github.com/Turfjs/turf/) contains the following functionality:

Turf.js | Turf-swift
----|----
[turf-along](https://github.com/Turfjs/turf/tree/master/packages/turf-along/) | `GeoJSON.LineString.coordinateFromStart(distance:)`
[turf-area](https://github.com/Turfjs/turf/blob/master/packages/turf-area/) | `GeoJSON.Polygon.area`
[turf-bearing](https://turfjs.org/docs/#bearing) | `GeoJSON.Position.direction(to:)`<br>`RadianCoordinate2D.direction(to:)`
[turf-bezier-spline](https://github.com/Turfjs/turf/tree/master/packages/turf-bezier-spline/) | `GeoJSON.LineString.bezier(resolution:sharpness:)`
[turf-boolean-point-in-polygon](https://github.com/Turfjs/turf/tree/master/packages/turf-boolean-point-in-polygon) | `GeoJSON.Polygon.contains(_:ignoreBoundary:)`
[turf-center](http://turfjs.org/docs/#center) | `GeoJSON.Geometry.center()` |
[turf-center-of-mass](http://turfjs.org/docs/#centerOfMass) | `GeoJSON.Geometry.centerOfMass()` |
[turf-centroid](http://turfjs.org/docs/#centroid) | `GeoJSON.Geometry.centroid()` |
[turf-circle](https://turfjs.org/docs/#circle) | `GeoJSON.Polygon(center:radius:vertices:)` |
[turf-destination](https://github.com/Turfjs/turf/tree/master/packages/turf-destination/) | `GeoJSON.Position.coordinate(at:facing:)<br>`RadianCoordinate2D.coordinate(at:facing:)`
[turf-distance](https://github.com/Turfjs/turf/tree/master/packages/turf-distance/) | `GeoJSON.Position.distance(to:)`<br>`RadianCoordinate2D.distance(to:)`
[turf-helpers#degreesToRadians](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers/#degreesToRadians) | `CLLocationDegrees.toRadians()`<br>`LocationDegrees.toRadians()` on Linux
[turf-helpers#radiansToDegrees](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers/#radiansToDegrees) | `CLLocationDegrees.toDegrees()`<br>`LocationDegrees.toDegrees()` on Linux
[turf-helpers#convertLength](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers#convertlength)<br>[turf-helpers#convertArea](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers#convertarea) | `Measurement.converted(to:)`
[turf-length](https://github.com/Turfjs/turf/tree/master/packages/turf-length/) | `GeoJSON.LineString.distance(from:to:)`
[turf-line-intersect](https://github.com/Turfjs/turf/tree/master/packages/turf-line-intersect/) | `intersection(_:_:)`
[turf-line-slice](https://github.com/Turfjs/turf/tree/master/packages/turf-line-slice/) | `GeoJSON.LineString.sliced(from:to:)`
[turf-line-slice-along](https://github.com/Turfjs/turf/tree/master/packages/turf-line-slice-along/) | `GeoJSON.LineString.trimmed(from:distance:)`
[turf-midpoint](https://github.com/Turfjs/turf/blob/master/packages/turf-midpoint/index.js) | `mid(_:_:)`
[turf-nearest-point-on-line](https://github.com/Turfjs/turf/tree/master/packages/turf-nearest-point-on-line/) | `GeoJSON.LineString.closestCoordinate(to:)`
[turf-polygon-smooth](https://github.com/Turfjs/turf/tree/master/packages/turf-polygon-smooth) | `GeoJSON.Polygon.smooth(iterations:)`
[turf-simplify](https://github.com/Turfjs/turf/tree/master/packages/turf-simplify) | `GeoJSON.simplify(options:)`
— | `CLLocationDirection.difference(from:)`<br>`LocationDirection.difference(from:)` on Linux
— | `CLLocationDirection.wrap(min:max:)`<br>`LocationDirection.wrap(min:max:)` on Linux

## GeoJSON

In contrast to [turf-swift](https://github.com/mapbox/turf-swift.git), this fork does not have any GeoJSON code itself, and instead relies on [GeoJSONKit](https://github.com/maparoni/geojsonkit).
