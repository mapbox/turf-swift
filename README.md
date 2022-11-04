# Turf for Swift

📱[![iOS](https://app.bitrise.io/app/49f5bcca71bf6c8d/status.svg?token=SzGBTkEtxsbuAnbcF9MTog&branch=main)](https://www.bitrise.io/app/49f5bcca71bf6c8d) &nbsp;&nbsp;&nbsp;
🖥💻[![macOS](https://app.bitrise.io/app/b72273651db53613/status.svg?token=ODv2UnyAHoOxV8APATEBFw&branch=main)](https://www.bitrise.io/app/b72273651db53613) &nbsp;&nbsp;&nbsp;
📺[![tvOS](https://app.bitrise.io/app/0b037542c2395ffb/status.svg?token=yOtMqbu-5bj8grB1Jmoefg)](https://www.bitrise.io/app/0b037542c2395ffb) &nbsp;&nbsp;&nbsp;
⌚️[![watchOS](https://app.bitrise.io/app/0d4d611f02295183/status.svg?token=NiLB_E_0IvYYqV4Mj973TQ)](https://www.bitrise.io/app/0d4d611f02295183) &nbsp;&nbsp;&nbsp;
<img src="https://upload.wikimedia.org/wikipedia/commons/3/3c/TuxFlat.svg" width="20" alt="Linux">[![](https://api.travis-ci.com/mapbox/turf-swift.svg?branch=main)](https://travis-ci.com/mapbox/turf-swift) &nbsp;&nbsp;&nbsp;
[![Documentation](https://mapbox.github.io/turf-swift/2.6.1/badge.svg)](https://mapbox.github.io/turf-swift/) &nbsp;&nbsp;&nbsp;
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) &nbsp;&nbsp;&nbsp;
[![CocoaPods](https://img.shields.io/cocoapods/v/Turf.svg)](https://cocoapods.org/pods/Turf/) &nbsp;&nbsp;&nbsp;
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/) &nbsp;&nbsp;&nbsp;

A [spatial analysis](http://en.wikipedia.org/wiki/Spatial_analysis) library written in Swift for native iOS, macOS, tvOS, watchOS, and Linux applications, ported from [Turf.js](https://github.com/Turfjs/turf/).

## Requirements

Turf requires Xcode 12.0 or above and supports the following minimum deployment targets:

* iOS 11.0 and above
* macOS 10.13 (High Sierra) and above
* tvOS 11.0 and above
* watchOS 4.0 and above

Alternatively, you can incorporate Turf into a command line tool without Xcode on any platform that [Swift](https://swift.org/download/) supports, including Linux.

If your project is written in Objective-C, you’ll need to write a compatibility layer between turf-swift and your Objective-C code. If your project is written in Objective-C++, you may be able to use [spatial-algorithms](https://github.com/mapbox/spatial-algorithms/) as an alternative to Turf.

## Installation

Although a stable release of this library is not yet available, prereleases are available for installation using any of the popular Swift dependency managers.

### CocoaPods

To install Turf using [CocoaPods](https://cocoapods.org/):

1. Specify the following dependency in your Podfile:
   ```rb
   pod 'Turf', '~> 2.6'
   ```
1. Run `pod repo update` if you haven’t lately.
1. Run `pod install` and open the resulting Xcode workspace.
1. Add `import Turf` to any Swift file in your application target.

### Carthage

To install Turf using [Carthage](https://github.com/Carthage/Carthage/):

1. Add the following dependency to your Cartfile:
   ```
   github "mapbox/turf-swift" ~> 2.6
   ```
1. Run `carthage bootstrap`.
1. Follow the rest of [Carthage’s integration instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application). Your application target’s Embedded Frameworks should include Turf.framework.
1. Add `import Turf` to any Swift file in your application target.

### Swift Package Manager

To install Turf using the [Swift Package Manager](https://swift.org/package-manager/), add the following package to the `dependencies` in your Package.swift file:

```swift
.package(url: "https://github.com/mapbox/turf-swift.git", from: "2.6.0")
```

Then `import Turf` in any Swift file in your module.


## Available functionality

This work-in-progress port of [Turf.js](https://github.com/Turfjs/turf/) contains the following functionality:

Turf.js | Turf for Swift
----|----
[turf-along#along](https://turfjs.org/docs/#along) | `LineString.coordinateFromStart(distance:)`
[turf-area#area](https://turfjs.org/docs/#area) | `Polygon.area`
[turf-bearing#bearing](https://turfjs.org/docs/#bearing) | `CLLocationCoordinate2D.direction(to:)`<br>`LocationCoordinate2D.direction(to:)` on Linux<br>`RadianCoordinate2D.direction(to:)`
[turf-bezier-spline#bezierSpline](https://turfjs.org/docs/#bezierSpline) | `LineString.bezier(resolution:sharpness:)`
[turf-boolean-point-in-polygon#booleanPointInPolygon](https://turfjs.org/docs/#booleanPointInPolygon) | `Polygon.contains(_:ignoreBoundary:)`
[turf-center#center](https://turfjs.org/docs/#center) | `Polygon.center`
[turf-center-of-mass#centerOfMass](https://turfjs.org/docs/#centerOfMass) | `Polygon.centerOfMass`
[turf-centroid#centroid](https://turfjs.org/docs/#centroid) | `Polygon.centroid`
[turf-circle#circle](https://turfjs.org/docs/#circle) | `Polygon(center:radius:vertices:)` |
[turf-destination#destination](https://turfjs.org/docs/#destination) | `CLLocationCoordinate2D.coordinate(at:facing:)`<br>`LocationCoordinate2D.coordinate(at:facing:)` on Linux<br>`RadianCoordinate2D.coordinate(at:facing:)`
[turf-distance#distance](https://turfjs.org/docs/#distance) | `CLLocationCoordinate2D.distance(to:)`<br>`LocationCoordinate2D.distance(to:)` on Linux<br>`RadianCoordinate2D.distance(to:)`
[turf-helpers#polygon](https://turfjs.org/docs/#polygon) | `Polygon(_:)`
[turf-helpers#lineString](https://turfjs.org/docs/#lineString) | `LineString(_:)`
[turf-helpers#degreesToRadians](https://turfjs.org/docs/#degreesToRadians) | `CLLocationDegrees.toRadians()`<br>`LocationDegrees.toRadians()` on Linux
[turf-helpers#radiansToDegrees](https://turfjs.org/docs/#radiansToDegrees) | `CLLocationDegrees.toDegrees()`<br>`LocationDegrees.toDegrees()` on Linux
[turf-helpers#convertLength](https://turfjs.org/docs/#convertLength)<br>[turf-helpers#convertArea](https://turfjs.org/docs/#convertArea) | `Measurement.converted(to:)`
[turf-length#length](https://turfjs.org/docs/#length) | `LineString.distance(from:to:)`
[turf-line-intersect#lineIntersect](https://turfjs.org/docs/#lineIntersect) | `LineString.intersections(with:)`
[turf-line-slice#lineSlice](https://turfjs.org/docs/#lineSlice) | `LineString.sliced(from:to:)`
[turf-line-slice-along#lineSliceAlong](https://turfjs.org/docs/#lineSliceAlong) | `LineString.trimmed(from:to:)`
[turf-midpoint#midpoint](https://turfjs.org/docs/#midpoint) | `mid(_:_:)`
[turf-nearest-point-on-line#nearestPointOnLine](https://turfjs.org/docs/#nearestPointOnLine) | `LineString.closestCoordinate(to:)`
[turf-polygon-to-line#polygonToLine](https://turfjs.org/docs/#polygonToLine) | `LineString(_:)`<br>`MultiLineString(_:)`
[turf-simplify#simplify](https://turfjs.org/docs/#simplify) | `LineString.simplify(tolerance:highestQuality:)`<br>`LineString.simplified(tolerance:highestQuality:)`
[turf-polygon-smooth#polygonSmooth](https://turfjs.org/docs/#polygonSmooth) | `Polygon.smooth(iterations:)`
— | `CLLocationDirection.difference(from:)`<br>`LocationDirection.difference(from:)` on Linux
— | `CLLocationDirection.wrap(min:max:)`<br>`LocationDirection.wrap(min:max:)` on Linux

## GeoJSON

turf-swift also contains a GeoJSON encoder/decoder with support for Codable.

```swift
// Decode an unknown GeoJSON object.
let geojson = try JSONDecoder().decode(GeoJSONObject.self, from: data)
guard case let .feature(feature) = geojson,
      case let .point(point) = feature.geometry else {
    return
}

// Decode a known GeoJSON object.
let featureCollection = try JSONDecoder().decode(FeatureCollection.self, from: data)

// Initialize a Point feature and encode it as GeoJSON.
let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 1)
let point = Point(coordinate)
let pointFeature = Feature(geometry: .point(point))
let data = try JSONEncoder().encode(pointFeature)
let json = String(data: data, encoding: .utf8)
print(json)

/*
{
  "type": "Feature",
  "geometry": {
    "type": "Point",
    "coordinates": [
      1,
      0
    ]
  }
}
*/

```
