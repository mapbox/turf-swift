# Turf-swift 

📱[![](https://www.bitrise.io/app/49f5bcca71bf6c8d/status.svg?token=SzGBTkEtxsbuAnbcF9MTog&branch=master)](https://www.bitrise.io/app/49f5bcca71bf6c8d)
🖥💻[![](https://www.bitrise.io/app/b72273651db53613/status.svg?token=ODv2UnyAHoOxV8APATEBFw&branch=master)](https://www.bitrise.io/app/b72273651db53613)

A [spatial analysis](http://en.wikipedia.org/wiki/Spatial_analysis) library written in Swift for native iOS, macOS, and tvOS applications, ported from [Turf.js](https://github.com/Turfjs/turf/).

The Turf-swift API is **experimental** and is subject to change. Please use with caution and open issues for any problems you see or missing features that should be added.

### Installation

Although there has not yet been a beta release of this library yet, you can still experiment with it in your application by using CocoaPods to install it. Edit your Podfile to include:

```
pod 'Turf-swift', '~> 0.0.4'
```

Alternatively, you can clone this repo and drag and drop Turf.swift and CoreLocation.swift into your project in Xcode.

### Available functionality

This work-in-progress port of [Turf.js](https://github.com/Turfjs/turf/) contains the following functionality:

Turf.js | Turf-swift
----|----
[turf-along](https://github.com/Turfjs/turf/tree/master/packages/turf-along/) | `Polyline.coordinateFromStart(distance:)`
[turf-area](https://github.com/Turfjs/turf/blob/master/packages/turf-area/) | `Polygon.area`
[turf-destination](https://github.com/Turfjs/turf/tree/master/packages/turf-destination/) | `CLLocationCoordinate2D.coordinate(at:facing:)`<br>`RadianCoordinate2D.coordinate(at:facing:)`
[turf-distance](https://github.com/Turfjs/turf/tree/master/packages/turf-distance/) | `CLLocationCoordinate2D.distance(to:)`<br>`RadianCoordinate2D.distance(to:)`
[turf-helpers#polygon](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers/#polygon) | `Polygon(outerRing:innerRings:)`
[turf-helpers#lineString](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers/#linestring) | `Polyline(_:)`
[turf-helpers#degreesToRadians](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers/#degreesToRadians) | `CLLocationDegrees.toRadians()`
[turf-helpers#radiansToDegrees](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers/#radiansToDegrees) | `CLLocationDegrees.toDegrees()`
[turf-helpers#convertLength](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers#convertlength)<br>[turf-helpers#convertArea](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers#convertarea) | `Measurement.converted(to:)`
[turf-length](https://github.com/Turfjs/turf/tree/master/packages/turf-length/) | `Polyline.distance(from:to:)`
[turf-line-intersect](https://github.com/Turfjs/turf/tree/master/packages/turf-line-intersect/) | `Turf.intersection(_:_:)`
[turf-line-slice](https://github.com/Turfjs/turf/tree/master/packages/turf-line-slice/) | `Polyline.sliced(from:to:)`
[turf-line-slice-along](https://github.com/Turfjs/turf/tree/master/packages/turf-line-slice-along/) | `Polyline.trimmed(from:distance:)`
[turf-point-on-line](https://github.com/Turfjs/turf/tree/master/packages/turf-point-on-line/) | `Polyline.closestCoordinate(to:)`
— | `CLLocationCoordinate2D.direction(to:)`<br>`RadianCoordinate2D.direction(to:)`
— | `CLLocationDirection.differenceBetween(_:)`
— | `CLLocationDirection.wrap(min:max:)`
