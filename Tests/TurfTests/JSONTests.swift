import XCTest
import Turf

class JSONTests: XCTestCase {
    func testRawValues() {
        XCTAssertEqual(TurfJSONValue(rawValue: "Jason" as NSString), .string("Jason"))
        XCTAssertEqual(TurfJSONValue(rawValue: 42 as NSNumber), .number(42))
        XCTAssertEqual(TurfJSONValue(rawValue: 3.1415 as NSNumber), .number(3.1415))
        XCTAssertEqual(TurfJSONValue(rawValue: false as NSNumber), .boolean(false))
        XCTAssertEqual(TurfJSONValue(rawValue: true as NSNumber), .boolean(true))
        XCTAssertEqual(TurfJSONValue(rawValue: false), .boolean(false))
        XCTAssertEqual(TurfJSONValue(rawValue: true), .boolean(true))
        XCTAssertEqual(TurfJSONValue(rawValue: 0 as NSNumber), .number(0))
        XCTAssertEqual(TurfJSONValue(rawValue: 1 as NSNumber), .number(1))
        XCTAssertEqual(TurfJSONValue(rawValue: ["Jason", 42, 3.1415, false, true, nil, [], [:]] as NSArray),
                       .array(["Jason", 42, 3.1415, false, true, nil, [], [:]]))
        XCTAssertEqual(TurfJSONValue(rawValue: [
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
        
        XCTAssertNil(TurfJSONValue(rawValue: NSNull()))
        XCTAssertEqual(TurfJSONValue(rawValue: [NSNull()]), .array([nil]))
        XCTAssertEqual(JSONArray(turfRawValue: [NSNull()]), [nil])
        XCTAssertEqual(TurfJSONValue(rawValue: ["NSNull": NSNull()]), .object(["NSNull": nil]))
        XCTAssertEqual(JSONObject(turfRawValue: ["NSNull": NSNull()]), ["NSNull": nil])
        
        XCTAssertNil(TurfJSONValue(rawValue: Set(["Get"])))
        XCTAssertEqual(TurfJSONValue(rawValue: [Set(["Get"])]), .array([nil]))
        XCTAssertEqual(JSONArray(turfRawValue: [Set(["Get"])]), [nil])
        XCTAssertEqual(TurfJSONValue(rawValue: ["set": Set(["Get"])]), .object(["set": nil]))
        XCTAssertEqual(JSONObject(turfRawValue: ["set": Set(["Get"])]), ["set": nil])
    }
    
    func testLiterals() throws {
        if case let TurfJSONValue.string(string) = "Jason" {
            XCTAssertEqual(string, "Jason")
        } else {
            XCTFail()
        }
        
        if case let TurfJSONValue.number(number) = 42 {
            XCTAssertEqual(number, 42)
        } else {
            XCTFail()
        }
        
        if case let TurfJSONValue.number(number) = 3.1415 {
            XCTAssertEqual(number, 3.1415)
        } else {
            XCTFail()
        }
        
        if case let TurfJSONValue.boolean(boolean) = false {
            XCTAssertFalse(boolean)
        } else {
            XCTFail()
        }
        
        if case let TurfJSONValue.boolean(boolean) = true {
            XCTAssertTrue(boolean)
        } else {
            XCTFail()
        }
        
        if case TurfJSONValue.boolean = 0 {
            XCTFail()
        }
        
        if case TurfJSONValue.boolean = 1 {
            XCTFail()
        }
        
        if case TurfJSONValue.number = false {
            XCTFail()
        }
        
        if case TurfJSONValue.number = true {
            XCTFail()
        }
        
        if case let TurfJSONValue.array(array) = ["Jason", 42, 3.1415, false, true, nil, [], [:]],
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
        
        if case let TurfJSONValue.object(object) = [
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
        var decodedValue: TurfJSONValue?
        XCTAssertNoThrow(decodedValue = try JSONDecoder().decode(TurfJSONValue.self, from: serializedArray))
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
        XCTAssertNoThrow(decodedValue = try JSONDecoder().decode(TurfJSONValue.self, from: serializedObject))
        XCTAssertNotNil(decodedValue)
        
        if case let .object(object) = decodedValue,
           case let .string(string) = object["string"] {
            XCTAssertEqual(string, rawObject["string"] as? String)
        } else {
            XCTFail()
        }
        
        XCTAssertEqual(decodedValue?.rawValue as? NSDictionary, rawObject as NSDictionary)
        
        XCTAssertNoThrow(try JSONEncoder().encode(decodedValue))

        // check decoding of 0/1 true/false to ensure unwanted conversions are avoided
        let rawString = "[0, 1, true, false]"
        // force-unwrap is safe since we control the input
        let serializedArrayFromString = rawString.data(using: .utf8)!
        XCTAssertNoThrow(decodedValue = try JSONDecoder().decode(TurfJSONValue.self, from: serializedArrayFromString))
        XCTAssertNotNil(decodedValue)
        XCTAssertEqual(.array([.number(0), .number(1), .boolean(true), .boolean(false)]), decodedValue)
    }
    
    func testConvenienceAccessors() {
        XCTAssertEqual(TurfJSONValue.string("Jason").string, "Jason")
        XCTAssertEqual(TurfJSONValue.string("Jason").number, nil)

        XCTAssertEqual(TurfJSONValue.number(42).number, 42)
        XCTAssertEqual(TurfJSONValue.number(42).string, nil)

        XCTAssertEqual(TurfJSONValue.boolean(true).boolean, true)
        XCTAssertEqual(TurfJSONValue.boolean(true).string, nil)

        XCTAssertEqual(TurfJSONValue.array(["Jason", 42, 3.1415, false, true, nil, [], [:]]).array, ["Jason", 42, 3.1415, false, true, nil, [], [:]])
        XCTAssertEqual(TurfJSONValue.array(["Jason", 42, 3.1415, false, true, nil, [], [:]]).string, nil)

        XCTAssertEqual(TurfJSONValue.object([
            "string": "Jason",
            "integer": 42,
            "float": 3.1415,
            "false": false,
            "true": true,
            "nil": nil,
            "array": [],
            "dictionary": [:],
        ]).object, [
            "string": "Jason",
            "integer": 42,
            "float": 3.1415,
            "false": false,
            "true": true,
            "nil": nil,
            "array": [],
            "dictionary": [:],
        ])
        XCTAssertEqual(TurfJSONValue.object([
            "string": "Jason",
            "integer": 42,
            "float": 3.1415,
            "false": false,
            "true": true,
            "nil": nil,
            "array": [],
            "dictionary": [:],
        ]).string, nil)
    }
}
