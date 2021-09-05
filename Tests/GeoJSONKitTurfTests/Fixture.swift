import XCTest
import Foundation
import GeoJSONKit

class Fixture {
  static func loadData(folder: String? = nil, filename: String, extension fileExtension: String) throws -> Data {
    // TODO: In Swift 5.3, we can use proper resources
    // See
    // - https://stackoverflow.com/questions/47177036/use-resources-in-unit-tests-with-swift-package-manager
    // - https://stackoverflow.com/questions/39815054/how-to-include-assets-resources-in-a-swift-package-manager-library
    
    let thisSourceFile = URL(fileURLWithPath: #file)
    let thisDirectory = thisSourceFile.deletingLastPathComponent()
    
    var path = thisDirectory.appendingPathComponent("Fixtures", isDirectory: true)
    if let folder = folder {
      path = path.appendingPathComponent(folder, isDirectory: true)
    }
    path = path
      .appendingPathComponent(filename)
      .appendingPathExtension(fileExtension)
    return try Data(contentsOf: path)
  }
  
  class func stringFromFileNamed(name: String) -> String {
    do {
      let data = try loadData(filename: name, extension: "json")
      return String(decoding: data, as: UTF8.self)
    } catch {
      XCTAssert(false, "Unable to decode fixture at \(name): \(error).")
      return ""
    }
  }
  
  class func geojsonData(from name: String) throws -> Data? {
    return try loadData(filename: name, extension: "geojson")
  }
  
  class func JSONFromFileNamed(name: String, extension fileExtension: String = "json") -> [String: Any] {
    do {
      let data = try loadData(filename: name, extension: fileExtension)
      return try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
    } catch {
      XCTAssert(false, "Unable to decode JSON fixture at \(name): \(error).")
      return [:]
    }
  }
  
  static func fixtures(folder: String, pair: (String, GeoJSON, GeoJSON) -> Void) throws {
    let thisSourceFile = URL(fileURLWithPath: #file)
    let thisDirectory = thisSourceFile.deletingLastPathComponent()
    
    let path = thisDirectory
      .appendingPathComponent("Fixtures", isDirectory: true)
      .appendingPathComponent(folder, isDirectory: true)
    let inDir = path.appendingPathComponent("in", isDirectory: true)
    let outDir = path.appendingPathComponent("out", isDirectory: true)
    
    let inputs = try FileManager.default.contentsOfDirectory(at: inDir, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)
    
    for inPath in inputs {
      let outPath = outDir.appendingPathComponent(inPath.lastPathComponent)
      let inputData = try Data(contentsOf: inPath)
      let outputData = try Data(contentsOf: outPath)
      pair(
        inPath.lastPathComponent,
        try GeoJSON(data: inputData),
        try GeoJSON(data: outputData)
      )
    }

  }

}

