import Turf
import XCTest

final class FeatureIdentifierTests: XCTestCase {
    func testConvenienceAccessors() {
        XCTAssertEqual(FeatureIdentifier("foo").string, "foo")
        XCTAssertEqual(FeatureIdentifier("foo").number, nil)

        XCTAssertEqual(FeatureIdentifier(3.14).string, nil)
        XCTAssertEqual(FeatureIdentifier(3.14).number, 3.14)
    }
}
