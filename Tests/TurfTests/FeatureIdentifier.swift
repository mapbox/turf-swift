import Turf
import XCTest

final class FeatureIdentifierTests: XCTestCase {
    func testConvenienceAccessors() {
        XCTAssertEqual(TurfFeatureIdentifier("foo").string, "foo")
        XCTAssertEqual(TurfFeatureIdentifier("foo").number, nil)

        XCTAssertEqual(TurfFeatureIdentifier(3.14).string, nil)
        XCTAssertEqual(TurfFeatureIdentifier(3.14).number, 3.14)
    }
}
