# TURF_DEMO

A SwiftUI MVVM app that explores four spatial strategies for recommending a meeting place between two users. 

## Strategies

### 1. Naive Midpoint

Geometric center between two users on a sphere. A bounding box shows the full search space.

### 2. Weighted Midpoint

Shifts the meeting point toward the less mobile user. Each user sets a max travel radius via slider; the algorithm weights inversely so a tighter radius exerts more pull. Circle overlays visualize each user's reachable area.

### 3. Venue Filter

Surfaces all cafes that fall inside both users' travel circles. Venues are validated with point-in-polygon testing. 

### 4. Voronoi Selection

Each venue owns a Voronoi cell (the region of space closer to it than to any other venue). Whichever cell the weighted centroid lands in determines the recommendation. 
(Note: Cells were precomputed via `scipy.spatial.Voronoi`, as there is currently no native Turf-Swift voronoi implementation.)

## Turf.swift Functions Used

| Function | Strategy |
|---|---|
| `mid()` | 1 |
| `distance(to:)` | 1, 2, 3, 4 |
| `direction(to:)` | 2, 3, 4 |
| `coordinate(at:facing:)` | 2, 3, 4 |
| `Polygon(center:radius:vertices:)` | 2, 3 |
| `Polygon.area` | 2 |
| `Polygon.contains(_:)` | 3, 4 |
| `outerRing.coordinates` | 2, 3 |
| `BoundingBox(from:)` | 1 |
| `Polygon(outerRing: Ring(coordinates:))` | 4 |

## Setup

1. Open in Xcode 15+ (iOS 17 target)
2. Turf.swift is included as a Swift Package dependency (`https://github.com/mapbox/turf-swift.git`, version 4.0.0)
3. Build and run — no API keys required, all venue data is hardcoded

## Project Structure

```
Turf_DEMO/
├── DataModels.swift        # MockUser, Venue, VoronoiCell, MeetStrategy, sample data
├── ViewModel.swift         # All state + Turf computation (MVVM)
├── ContentView.swift       # Map + bottom sheet with controls and Turf annotations
└── Turf_DEMOApp.swift      # @main entry point
```

## Sample Data

Two users placed across Chicago (Hyde Park and Logan Square) with five real cafes in the midpoint zone. Voronoi cells were precomputed with scipy and clipped to `BoundingBox(from: [user1, user2])`.

## Recommendation for Future Turf-Swift Features

This demo exposed two gaps in the current API:

- **Weighted midpoint** — `mid()` returns the geometric center, but there's no built-in way to bias toward one coordinate. This demo implements it by combining `distance(to:)`, `direction(to:)`, and `coordinate(at:facing:)`, but a native `mid(_:_:weight:)` would be a natural addition.

- **Voronoi tessellation** — Turf.js supports `turf-voronoi` but there is no Swift port. A native implementation would enable spatial partitioning use cases (nearest-venue selection, service area mapping) without relying on precomputed data.