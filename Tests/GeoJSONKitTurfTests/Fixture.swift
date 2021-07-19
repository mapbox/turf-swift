import XCTest
import Foundation

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

}

