//
//  ContentView.swift
//  Turf_DEMO
//
//  Created by Juniper Rodriguez on 4/27/26.
//
import SwiftUI
import MapKit

struct ContentView: View {
    
    @State private var vm = ViewModel()
    @State private var sheetDetent: PresentationDetent = .fraction(0.25)
    
    var body: some View {
        ZStack(alignment: .top) {
            Map {
                // Users
                Marker(vm.users.mary.name, coordinate: vm.users.mary.coordinate)
                    .tint(.blue)
                Marker(vm.users.selena.name, coordinate: vm.users.selena.coordinate)
                    .tint(.red)
                
                // Result
                Marker(vm.strategyLabel, systemImage: "mappin", coordinate: vm.resultPoint)
                    .tint(.purple)
                
                // Strategy-specific overlays
                switch vm.selectedStrategy {
                    
                // Strategy 1: Naive midpoint via Turf mid() + BoundingBox(from:) displays full search space between users
                case .midpoint:
                    if !vm.boundingBoxCoords.isEmpty {
                        MapPolygon(coordinates: vm.boundingBoxCoords)
                            .foregroundStyle(.clear)
                            .stroke(.red.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                    }
                
                // Strategy 2: Weighted centroid via Turf distance(to:), direction(to:), coordinate(at:facing:). Circles generated via Polygon(center:radius:vertices:).
                case .weighted:
                    MapPolygon(coordinates: vm.maryCircleCoords)
                        .foregroundStyle(.blue.opacity(0.08))
                        .stroke(.blue.opacity(0.3), lineWidth: 1)
                    MapPolygon(coordinates: vm.selenaCircleCoords)
                        .foregroundStyle(.indigo.opacity(0.08))
                        .stroke(.red.opacity(0.3), lineWidth: 1)
                
                // Strategy 3: Venues filtered by Polygon.contains(), only shows cafes inside both users' travel circles (intersection of two polygons).
                case .venueFilter:
                    MapPolygon(coordinates: vm.maryCircleCoords)
                        .foregroundStyle(.blue.opacity(0.08))
                        .stroke(.blue.opacity(0.3), lineWidth: 1)
                    MapPolygon(coordinates: vm.selenaCircleCoords)
                        .foregroundStyle(.indigo.opacity(0.08))
                        .stroke(.red.opacity(0.3), lineWidth: 1)
                    ForEach(vm.reachableVenues) { venue in
                        Marker(venue.name, systemImage: "cup.and.saucer.fill", coordinate: venue.coordinate)
                            .tint(.green)
                    }
                    
                // Strategy 4: Precomputed Voronoi tessellation: each venue owns the region of space closer to it than any other.
                // Weighted centroid tested against cells via Polygon(outerRing:) + Polygon.contains(), and shows one recommended venue with cell containing centroid.
                case .voronoi:
                    let activeName = vm.activeVoronoiCell?.venueName
                    ForEach(vm.voronoiCells) { cell in
                        if cell.venueName == activeName {
                            MapPolygon(coordinates: cell.vertices)
                                .foregroundStyle(.green.opacity(0.50))
                                .stroke(.green, lineWidth: 3)
                        } else {
                            MapPolygon(coordinates: cell.vertices)
                                .foregroundStyle(.green.opacity(0.20))
                                .stroke(.green.opacity(0.5), lineWidth: 1)
                        }
                    }
                    ForEach(vm.venues) { venue in
                        Marker(venue.name, systemImage: "cup.and.saucer.fill", coordinate: venue.coordinate)
                            .tint(.green)
                    }
                    if let selected = vm.voronoiSelectedVenue {
                        Marker(selected.name, systemImage: "star.fill", coordinate: selected.coordinate)
                            .tint(.yellow)
                    }
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            
            switch vm.selectedStrategy {
            case .midpoint, .weighted:
                let pt = vm.resultPoint
                HStack(spacing: 6) {
                    Image(systemName: "mappin")
                        .foregroundStyle(.purple)
                    Text(String(format: "%.4f, %.4f", pt.latitude, pt.longitude))
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.top, 8)
                
            case .venueFilter:
                VStack(spacing: 4) {
                    ForEach(vm.reachableVenues) { venue in
                        HStack(spacing: 6) {
                            Image(systemName: "cup.and.saucer.fill")
                                .foregroundStyle(.green)
                            Text(venue.name)
                                .fontWeight(.semibold)
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                    if vm.reachableVenues.isEmpty {
                        Text("No venues in overlap")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                }
                .padding(.top, 8)
                
            case .voronoi:
                if let selected = vm.voronoiSelectedVenue {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text(selected.name)
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.top, 8)
                }
            }
        }
        .sheet(isPresented: .constant(true)) {
            SheetContent(vm: vm)
                .presentationDetents(
                    [.fraction(0.10), .fraction(0.25), .medium, .large],
                    selection: $sheetDetent
                )
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled)
                .interactiveDismissDisabled()
        }
    }
}

// MARK: - Sheet Content

private struct SheetContent: View {
    @Bindable var vm: ViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Picker("Strategy", selection: $vm.selectedStrategy) {
                    ForEach(MeetStrategy.allCases) { s in
                        Text(s.rawValue).tag(s)
                    }
                }
                .pickerStyle(.segmented)
                
                if vm.selectedStrategy != .midpoint {
                    Divider()
                    Text("Travel Radius:")
                            .font(.title3)
                            .padding(5)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(vm.users.mary.name) — \(String(format: "%.1f", vm.maryTravel / 1000)) km")
                            .font(.caption)
                            .foregroundStyle(.blue)
                        Slider(value: $vm.maryTravel, in: 1000...15000, step: 250)
                            .tint(.blue)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(vm.users.selena.name) — \(String(format: "%.1f", vm.selenaTravel / 1000)) km")
                            .font(.caption)
                            .foregroundStyle(.red)
                        Slider(value: $vm.selenaTravel, in: 1000...15000, step: 250)
                            .tint(.red)
                    }
                }
                
                Divider()
                Text("Turf Functions Used:")
                        .font(.title3)

                // Info section per strategy
                switch vm.selectedStrategy {
                case .midpoint:
                    turfAnnotation("mid()", desc: "Naive geographic midpoint between two coordinates")
                    turfAnnotation("distance(to:)", desc: String(format: "Separation: %.1f km", vm.userSeparationMeters / 1000))
                    turfAnnotation("BoundingBox(from:)", desc: "Dashed rectangle enclosing both users")
                    
                case .weighted:
                    turfAnnotation("distance(to:)", desc: String(format: "Separation: %.1f km", vm.userSeparationMeters / 1000))
                    turfAnnotation("direction(to:)", desc: "Bearing from Mary to Selena")
                    turfAnnotation("coordinate(at:facing:)", desc: "Weighted destination along bearing")
                    turfAnnotation("Polygon(center:radius:vertices:)", desc: "Circle generation (64 vertices)")
                    turfAnnotation("Polygon.area", desc: String(format: "Mary: %.1f km²  Selena: %.1f km²", vm.maryAreaKm2, vm.selenaAreaKm2))
                    
                case .venueFilter:
                    turfAnnotation("Polygon.contains()", desc: "Point-in-polygon test for each venue")
                    turfAnnotation("outerRing.coordinates", desc: "Vertex extraction for map overlay")
                    
                case .voronoi:
                    turfAnnotation("Polygon(outerRing:)", desc: "Construct polygon from Voronoi vertices")
                    turfAnnotation("Polygon.contains()", desc: "Test which cell the result point falls in")
                }
            }
            .padding()
        }
    }
    
    private func turfAnnotation(_ name: String, desc: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(.caption2)
                .bold()
                .fontDesign(.monospaced)
            Text(desc)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
