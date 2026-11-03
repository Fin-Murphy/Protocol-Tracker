import XCTest

final class ScatterBrainVVDUITests: XCTestCase {
    let outDir = "/private/tmp/claude-501/-Users-fin-Protocol-Tracker/84132549-9cf4-43e5-bd0e-685d6a7f847f/scratchpad"

    @MainActor
    func testEdges() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-seenWelcome", "YES", "-hideTabLog", "NO", "-hideTabGraphs", "NO", "-hideTabProtocolList", "NO", "-hideTabEvents", "YES"]
        app.launch()
        let allow = XCUIApplication(bundleIdentifier: "com.apple.springboard").buttons["Allow"]
        if allow.waitForExistence(timeout: 4) { allow.tap() }
        sleep(1)
        for (name, i) in [("settings", 0), ("protocols", 5)] {
            app.coordinate(withNormalizedOffset: CGVector(dx: (Double(i) + 0.5) / 6, dy: 0.923)).tap()
            usleep(600_000)
            try! app.screenshot().pngRepresentation.write(to: URL(fileURLWithPath: "\(outDir)/fixed_\(name).png"))
        }
    }
}
