//
//  XCTest+Save.swift
//  
//
//  Created by Adrian Schönig on 14/6/2022.
//

import XCTest


extension XCTest {
  static func save(_ data: Data, filename: String, extension fileExtension: String) throws {
    let thisSourceFile = URL(fileURLWithPath: #file)
    let thisDirectory = thisSourceFile.deletingLastPathComponent()
    let path = thisDirectory
      .appendingPathComponent(filename)
      .appendingPathExtension(fileExtension)
    return try data.write(to: path)
  }
}
