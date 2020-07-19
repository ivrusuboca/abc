import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(abcTests.allTests),
        testCase(binanceTests.allTests),
    ]
}
#endif
