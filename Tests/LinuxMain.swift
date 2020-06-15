import XCTest

import abcTests

var tests = [XCTestCaseEntry]()
tests += abcTests.allTests()
XCTMain(tests)
