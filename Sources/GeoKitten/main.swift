//
//  main.swift
//  GeoKitten
//
//  Created by Adrian Schönig on 5/9/21.
//

import Foundation

#if os(macOS)

import ArgumentParser

import GeoJSONKit
import GeoJSONKitTurf

struct GeoKitten: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "geokitten",
    abstract: "CLI for GeoJSONKit-Turf",
    subcommands: [Simplify.self]
  )
}

struct Simplify: ParsableCommand {
  @Argument(help: "GeoJSON file to simplify", completion: .file(extensions: ["geojson", "json"])) var input: String
  
  @Option(name: .shortAndLong, help: "Douglas-Peucker tolerance")
  var tolerance: Double = 0.01

  @Option(name: .shortAndLong, help: "Enable high quality, skipping radial simplification")
  var highQuality: Bool = false

  func run() throws {
    let inputPath = URL(fileURLWithPath: input)
    let inputData = try Data(contentsOf: inputPath)
    let input = try GeoJSON(data: inputData)
    let simplified = input.simplified(options: .init(algorithm: .RamerDouglasPeucker(tolerance: tolerance), highestQuality: highQuality))
    let output = try simplified.toData(options: [])
    print(String(decoding: output, as: UTF8.self))
  }
}

GeoKitten.main()

#endif
