# GeoJSONKit+Turf

[![Swift](https://github.com/maparoni/GeoJSONKit-Turf/actions/workflows/swift.yml/badge.svg)](https://github.com/maparoni/GeoJSONKit-Turf/actions/workflows/swift.yml)

This package provides various geospatial extensions for [GeoJSONKit](https://github.com/maparoni/geojsonkit). It is a fork of [turf-swift](https://github.com/mapbox/turf-swift.git), which is ported from [Turf.js](https://github.com/Turfjs/turf/).

## Requirements

GeoJSONKitTurf requires Xcode 12.x and supports the following minimum deployment targets:

* iOS 10.0 and above
* macOS 10.12 (Sierra) and above
* tvOS 10.0 and above
* watchOS 3.0 and above

It's also compatible with Linux (and possibly other platforms), as long as you have [Swift](https://swift.org/download/) 5.3 (or above) installed.

## Installation

### Swift Package Manager

To install GeoJSONKitTurf using the [Swift Package Manager](https://swift.org/package-manager/), add the following package to the `dependencies` in your Package.swift file:

```swift
.package(name: "GeoJSONKitTurf", url: "https://github.com/maparoni/geojsonkit-turf", from: "0.1.0")
```

Then usen: 

```swift
import GeoJSONKitTurf
```


## Available functionality

This is a partial port of [Turf.js](https://github.com/Turfjs/turf/), which adds the following functionality to [GeoJSONKit](https://github.com/maparoni/geojsonkit)'s `GeoJSON`:

Turf.js | Turf-swift
----|----
[turf-along](https://github.com/Turfjs/turf/tree/master/packages/turf-along/) | `GeoJSON.LineString.coordinateFromStart(distance:)`
[turf-area](https://github.com/Turfjs/turf/blob/master/packages/turf-area/) | `GeoJSON.Polygon.area`
[turf-bearing](https://turfjs.org/docs/#bearing) | `GeoJSON.Position.direction(to:)`<br/> `RadianCoordinate2D.direction(to:)`
[turf-bezier-spline](https://github.com/Turfjs/turf/tree/master/packages/turf-bezier-spline/) | `GeoJSON.LineString.bezier(resolution:sharpness:)`
[turf-boolean-point-in-polygon](https://github.com/Turfjs/turf/tree/master/packages/turf-boolean-point-in-polygon) | `GeoJSON.Polygon.contains(_:ignoreBoundary:)`
[turf-center](http://turfjs.org/docs/#center) | `GeoJSON.Geometry.center()` |
[turf-center-of-mass](http://turfjs.org/docs/#centerOfMass) | `GeoJSON.Geometry.centerOfMass()` |
[turf-centroid](http://turfjs.org/docs/#centroid) | `GeoJSON.Geometry.centroid()` |
[turf-circle](https://turfjs.org/docs/#circle) | `GeoJSON.Polygon(center:radius:vertices:)` |
[turf-destination](https://github.com/Turfjs/turf/tree/master/packages/turf-destination/) | `GeoJSON.Position.coordinate(at:facing:)`<br/> `RadianCoordinate2D.coordinate(at:facing:)`
[turf-distance](https://github.com/Turfjs/turf/tree/master/packages/turf-distance/) | `GeoJSON.Position.distance(to:)`<br>`RadianCoordinate2D.distance(to:)`
[turf-helpers#degreesToRadians](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers/#degreesToRadians) | `GeoJSON.Degrees.toRadians()`
[turf-helpers#radiansToDegrees](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers/#radiansToDegrees) | `GeoJSON.DegreesRadians.toDegrees()`
[turf-helpers#convertLength](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers#convertlength)<br>[turf-helpers#convertArea](https://github.com/Turfjs/turf/tree/master/packages/turf-helpers#convertarea) | `Measurement.converted(to:)`
[turf-length](https://github.com/Turfjs/turf/tree/master/packages/turf-length/) | `GeoJSON.LineString.distance(from:to:)`
[turf-line-intersect](https://github.com/Turfjs/turf/tree/master/packages/turf-line-intersect/) | `GeoJSON.LineString.intersection(with:)`
[turf-line-slice](https://github.com/Turfjs/turf/tree/master/packages/turf-line-slice/) | `GeoJSON.LineString.sliced(from:to:)`
[turf-line-slice-along](https://github.com/Turfjs/turf/tree/master/packages/turf-line-slice-along/) | `GeoJSON.LineString.trimmed(from:distance:)`, `GeoJSON.LineString.trimmed(from:to:)` 
[turf-midpoint](https://github.com/Turfjs/turf/blob/master/packages/turf-midpoint/index.js) | `mid(_:_:)`
[turf-nearest-point-on-line](https://github.com/Turfjs/turf/tree/master/packages/turf-nearest-point-on-line/) | `GeoJSON.LineString.closestCoordinate(to:)`
[turf-polygon-smooth](https://github.com/Turfjs/turf/tree/master/packages/turf-polygon-smooth) | `GeoJSON.Polygon.smooth(iterations:)`
[turf-union](https://github.com/Turfjs/turf/tree/master/packages/turf-union) | Not provided, but see [ASPolygonKit](https://github.com/nighthawk/ASPolygonKit) 
[turf-simplify](https://github.com/Turfjs/turf/tree/master/packages/turf-simplify) | `GeoJSON.simplify(options:)`
— | `GeoJSON.Direction.difference(from:)`
— | `GeoJSON.Direction.wrap(min:max:)`

## CLI

Comes with a mini-CLI `geokitten` with these commands:

- `geokitten simplify $input` to simplify a GeoJSON

### Installation

<details>
<summary>Via SPM</summary>

First clone or download the repository, then run this:

```bash
swift build -c release
sudo cp .build/release/geokitten /usr/local/bin/geokitten
```
</details>

<details>
<summary>Via <a href="https://github.com/yonaskolb/Mint">Mint</a></summary>

```bash
mint install maparoni/GeoJSONKit-Turf@main
```

If you get a permissions error, check [this Mint issue](https://github.com/yonaskolb/Mint/issues/188).
</details>
