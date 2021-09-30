import XCTest
import Turf

class JSONTests: XCTestCase {
    func testRawValues() {
        XCTAssertEqual(JSONValue(rawValue: "Jason" as NSString), .string("Jason"))
        XCTAssertEqual(JSONValue(rawValue: 42 as NSNumber), .number(42))
        XCTAssertEqual(JSONValue(rawValue: 3.1415 as NSNumber), .number(3.1415))
        XCTAssertEqual(JSONValue(rawValue: false as NSNumber), .boolean(false))
        XCTAssertEqual(JSONValue(rawValue: true as NSNumber), .boolean(true))
        XCTAssertEqual(JSONValue(rawValue: ["Jason", 42, 3.1415, false, true, nil, [], [:]] as NSArray),
                       .array(["Jason", 42, 3.1415, false, true, nil, [], [:]]))
        XCTAssertEqual(JSONValue(rawValue: [
            "string": "Jason",
            "integer": 42,
            "float": 3.1415,
            "false": false,
            "true": true,
            "nil": nil,
            "array": [],
            "dictionary": [:],
        ] as NSDictionary),
        .object([
            "string": "Jason",
            "integer": 42,
            "float": 3.1415,
            "false": false,
            "true": true,
            "nil": nil,
            "array": [],
            "dictionary": [:],
        ]))
        
        XCTAssertNil(JSONValue(rawValue: NSNull()))
        XCTAssertEqual(JSONValue(rawValue: [NSNull()]), .array([nil]))
        XCTAssertEqual(JSONArray(rawValue: [NSNull()]), [nil])
        XCTAssertEqual(JSONValue(rawValue: ["NSNull": NSNull()]), .object(["NSNull": nil]))
        XCTAssertEqual(JSONObject(rawValue: ["NSNull": NSNull()]), ["NSNull": nil])
        
        XCTAssertNil(JSONValue(rawValue: Set(["Get"])))
        XCTAssertEqual(JSONValue(rawValue: [Set(["Get"])]), .array([nil]))
        XCTAssertEqual(JSONArray(rawValue: [Set(["Get"])]), [nil])
        XCTAssertEqual(JSONValue(rawValue: ["set": Set(["Get"])]), .object(["set": nil]))
        XCTAssertEqual(JSONObject(rawValue: ["set": Set(["Get"])]), ["set": nil])
    }
    
    func testConversion() {
        XCTAssertEqual(JSONValue(String("Jason")), .string("Jason"))
        XCTAssertEqual(JSONValue(Int32.max), .number(Double(Int32.max)))
        XCTAssertEqual(JSONValue(Float(0.0).nextUp), .number(Double(Float(0.0).nextUp)))
        XCTAssertEqual(JSONValue(0.0.nextUp), .number(0.0.nextUp))
        XCTAssertEqual(JSONValue(Bool(true)), .boolean(true))
        XCTAssertEqual(JSONValue(Bool(false)), .boolean(false))
        
        let array = "Jason".map(String.init) + [nil]
        XCTAssertEqual(JSONValue(array), .array(["J", "a", "s", "o", "n", nil]))
        let dictionary = ["string": "Jason", "null": nil]
        XCTAssertEqual(JSONValue(dictionary), .object(["string": "Jason", "null": nil]))
        
        XCTAssertEqual(JSONArray("Jason".map(\.description)), ["J", "a", "s", "o", "n"])
        XCTAssertEqual(JSONArray(array), ["J", "a", "s", "o", "n", nil])
        XCTAssertEqual(JSONObject(dictionary), ["string": "Jason", "null": nil])
    }
    
    func testLiterals() throws {
        if case let JSONValue.string(string) = "Jason" {
            XCTAssertEqual(string, "Jason")
        } else {
            XCTFail()
        }
        
        if case let JSONValue.number(number) = 42 {
            XCTAssertEqual(number, 42)
        } else {
            XCTFail()
        }
        
        if case let JSONValue.number(number) = 3.1415 {
            XCTAssertEqual(number, 3.1415)
        } else {
            XCTFail()
        }
        
        if case let JSONValue.boolean(boolean) = false {
            XCTAssertFalse(boolean)
        } else {
            XCTFail()
        }
        
        if case let JSONValue.boolean(boolean) = true {
            XCTAssertTrue(boolean)
        } else {
            XCTFail()
        }
        
        if case let JSONValue.array(array) = ["Jason", 42, 3.1415, false, true, nil, [], [:]],
           array.count == 8 {
            if case let .string(string) = array[0] {
                XCTAssertEqual(string, "Jason")
            } else {
                XCTFail()
            }
            
            if case let .number(number) = array[1] {
                XCTAssertEqual(number, 42)
            } else {
                XCTFail()
            }
            
            if case let .number(number) = array[2] {
                XCTAssertEqual(number, 3.1415)
            } else {
                XCTFail()
            }
            
            if case let .boolean(boolean) = array[3] {
                XCTAssertFalse(boolean)
            } else {
                XCTFail()
            }
            
            if case let .boolean(boolean) = array[4] {
                XCTAssertTrue(boolean)
            } else {
                XCTFail()
            }
            
            if case .none = array[5] {} else {
                XCTFail()
            }
            
            if case let .array(array) = array[6] {
                XCTAssertEqual(array, [])
            } else {
                XCTFail()
            }
            
            if case let .object(object) = array[7] {
                XCTAssertEqual(object, [:])
            } else {
                XCTFail()
            }
        } else {
            XCTFail()
        }
        
        if case let JSONValue.object(object) = [
            "string": "Jason",
            "integer": 42,
            "float": 3.1415,
            "false": false,
            "true": true,
            "nil": nil,
            "array": [],
            "dictionary": [:],
        ], object.count == 8 {
            if case let .string(string) = object["string"] {
                XCTAssertEqual(string, "Jason")
            } else {
                XCTFail()
            }
            
            if case let .number(number) = object["integer"] {
                XCTAssertEqual(number, 42)
            } else {
                XCTFail()
            }
            
            if case let .number(number) = object["float"] {
                XCTAssertEqual(number, 3.1415)
            } else {
                XCTFail()
            }
            
            if case let .boolean(boolean) = object["false"] {
                XCTAssertFalse(boolean)
            } else {
                XCTFail()
            }
            
            if case let .boolean(boolean) = object["true"] {
                XCTAssertTrue(boolean)
            } else {
                XCTFail()
            }
            
            // The optional from dictionary subscripting isn’t unwrapped automatically if matching Optional.none.
            if case .some(.none) = object["nil"] {} else {
                XCTFail()
            }
            
            if case let .array(array) = object["array"] {
                XCTAssertEqual(array, [])
            } else {
                XCTFail()
            }
            
            if case let .object(object) = object["dictionary"] {
                XCTAssertEqual(object, [:])
            } else {
                XCTFail()
            }
        } else {
            XCTFail()
        }
    }
    
    func testCoding() {
        let rawArray = ["Jason", 42, 3.1415, false, true, nil, [], [:]] as [Any?]
        let serializedArray = try! JSONSerialization.data(withJSONObject: rawArray, options: [])
        var decodedValue: JSONValue?
        XCTAssertNoThrow(decodedValue = try JSONDecoder().decode(JSONValue.self, from: serializedArray))
        XCTAssertNotNil(decodedValue)
        
        if case let .array(array) = decodedValue,
           case let .string(string) = array[0] {
            XCTAssertEqual(string, rawArray[0] as? String)
        } else {
            XCTFail()
        }
        
        XCTAssertEqual(decodedValue?.rawValue as? NSArray, rawArray as NSArray)
        
        XCTAssertNoThrow(try JSONEncoder().encode(decodedValue))
        
        let rawObject = [
            "string": "Jason",
            "integer": 42,
            "float": 3.1415,
            "false": false,
            "true": true,
            "nil": nil,
            "array": [],
            "dictionary": [:],
        ] as [String: Any?]
        let serializedObject = try! JSONSerialization.data(withJSONObject: rawObject, options: [])
        XCTAssertNoThrow(decodedValue = try JSONDecoder().decode(JSONValue.self, from: serializedObject))
        XCTAssertNotNil(decodedValue)
        
        if case let .object(object) = decodedValue,
           case let .string(string) = object["string"] {
            XCTAssertEqual(string, rawObject["string"] as? String)
        } else {
            XCTFail()
        }
        
        XCTAssertEqual(decodedValue?.rawValue as? NSDictionary, rawObject as NSDictionary)
        
        XCTAssertNoThrow(try JSONEncoder().encode(decodedValue))
    }
}
