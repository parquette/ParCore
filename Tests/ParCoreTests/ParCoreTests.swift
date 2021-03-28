import XCTest
@testable import ParCore

final class ParCoreTests: XCTestCase {
    func testParCoreModule() {
        XCTAssertEqual(ParCoreModule().internalParCoreData, "Hi ParCore!")
    }
}
