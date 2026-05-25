import XCTest
@testable import PROJEKT_PACKAGE

/// Smoke-Tests — die Mindest-Pflicht: das Package compiliert und das öffentliche
/// API existiert. Erweitere diese Datei nach Phase 0 mit echten Tests.
final class PROJEKT_PACKAGETests: XCTestCase {
    func testVersionIsSet() {
        XCTAssertFalse(PROJEKT_PACKAGE.version.isEmpty, "version darf nicht leer sein")
    }

    func testHelloContainsVersion() {
        let greeting = PROJEKT_PACKAGE.hello()
        XCTAssertTrue(
            greeting.contains(PROJEKT_PACKAGE.version),
            "hello() soll die Version enthalten"
        )
    }
}
