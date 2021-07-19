# GeoJSONKit+Turf

A fork of [turf-swift](https://github.com/mapbox/turf-swift.git) which relies on [GeoJSONKit](https://gitlab.com/maparoni/geojsonkit). turf-swift itself is proted from [Turf.js](https://github.com/Turfjs/turf/). For an alternative see [spatial-algorithms](https://github.com/mapbox/spatial-algorithms/).

## Requirements

Turf requires Xcode 9.x and supports the following minimum deployment targets:

* iOS 10.0 and above
* macOS 10.12 (Sierra) and above
* tvOS 10.0 and above
* watchOS 3.0 and above

Alternatively, you can incorporate Turf into a command line tool without Xcode on any platform that [Swift](https://swift.org/download/) supports, including Linux.

If your project is written in Objective-C, you’ll need to write a compatibility layer between turf-swift and your Objective-C code. If your project is written in Objective-C++, you may be able to use [spatial-algorithms](https://github.com/mapbox/spatial-algorithms/) as an alternative to Turf.

## Installation

Just as turf-swift, a stable release of this library is not yet available.

### Swift Package Manager

To install Turf using the [Swift Package Manager](https://swift.org/package-manager/), add the following package to the `dependencies` in your Package.swift file:

```swift
.package(url: "https://gitlab.com/maparoni/geojsonkit-turf", from: "1.2.0")
```

Then `import GeoJSONKitTurf` in any Swift file in your module.


## Available functionality

This work-in-progress port of [Turf.js](https://github.com/Turfjs/turf/) contains the following functionality:

Turf.js | Turf-swift
----|----
[turf-along](https://github.com/Turfjs/turf/tree/master/packages/turf-along/) | `LineString.coordinateFromStart(distance:)`
[turf-area](https://github.com/Turfjs/turf/blob/master/packages/turf-area/) | `Polygon.area`
[turf-bearing](https://turfjs.org/docs/#bearing) | `CLLocationCoordinate2D.direction(to:)`<br>`LocationCoordinate2D.direction(to:)` on Linux<br>`RadianCoordinate2D.direction(to:)`
[turf-bezier-spline](https://github.com/Turfjs/turf/tree/master/packages/turf-bezier-spline/) | `LineString.bezier(resolution:sharpness:)`
[turf-boolean-point-in-polygon](https://github.com/Turfjs/turf/tree/master/packages/turf-boolean-point-in-polygon) | `Polygon.contains(_:ignoreBoundary:)`
[turf-circle](https://turfjs.org/docs/#circle) | `Polygon(center:radius:vertices:)` |
[turf-destination](https://github.com/Turfjs/turf/tree/master/packages/turf-destination/) | `CLLocationCoordinate2D.coordinate(at:facing:)`<br>`LocationCoordinate2D.coordinate(at:facing:)` on Linux<br>`RadianCoordinate2D.coordinate(at:facing:)`
[turf-distance](https://github.com/Turfjs/turf/tree/master/packages/turf-distance/) | `CLLocationCoordinate2D.distance(to:)`<br>`LocationCoordinate2D.distance(to:)` on Linux<br>`RadianCoordinate2D.distance(to:)`
[turf-helpers#polygon](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers/#polygon) | `Polygon(_:)`
[turf-helpers#lineString](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers/#linestring) | `LineString(_:)`
[turf-helpers#degreesToRadians](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers/#degreesToRadians) | `CLLocationDegrees.toRadians()`<br>`LocationDegrees.toRadians()` on Linux
[turf-helpers#radiansToDegrees](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers/#radiansToDegrees) | `CLLocationDegrees.toDegrees()`<br>`LocationDegrees.toDegrees()` on Linux
[turf-helpers#convertLength](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers#convertlength)<br>[turf-helpers#convertArea](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers#convertarea) | `Measurement.converted(to:)`
[turf-length](https://github.com/Turfjs/turf/tree/master/packages/turf-length/) | `LineString.distance(from:to:)`
[turf-line-intersect](https://github.com/Turfjs/turf/tree/master/packages/turf-line-intersect/) | `intersection(_:_:)`
[turf-line-slice](https://github.com/Turfjs/turf/tree/master/packages/turf-line-slice/) | `LineString.sliced(from:to:)`
[turf-line-slice-along](https://github.com/Turfjs/turf/tree/master/packages/turf-line-slice-along/) | `LineString.trimmed(from:distance:)`
[turf-midpoint](https://github.com/Turfjs/turf/blob/master/packages/turf-midpoint/index.js) | `mid(_:_:)`
[turf-nearest-point-on-line](https://github.com/Turfjs/turf/tree/master/packages/turf-nearest-point-on-line/) | `LineString.closestCoordinate(to:)`
[turf-polygon-to-line](https://github.com/Turfjs/turf/tree/master/packages/turf-polygon-to-line/) | `LineString(_:)`<br>`MultiLineString(_:)`<br>`FeatureCollection(_:)`
[turf-simplify](https://github.com/Turfjs/turf/tree/master/packages/turf-simplify) | `LineString.simplified(tolerance:highestQuality:)`
[turf-polygon-smooth](https://github.com/Turfjs/turf/tree/master/packages/turf-polygon-smooth) | `Polygon.smooth(iterations:)`
[turf-simplify](https://github.com/Turfjs/turf/tree/master/packages/turf-simplify) | `Polygon.simplified(tolerance:highestQuality:)`
— | `CLLocationDirection.difference(from:)`<br>`LocationDirection.difference(from:)` on Linux
— | `CLLocationDirection.wrap(min:max:)`<br>`LocationDirection.wrap(min:max:)` on Linux

## GeoJSON

This fork relies on [GeoJSONKit](https://gitlab.com/maparoni/geojsonkit).
