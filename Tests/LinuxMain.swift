import XCTest

import expressionTests

var tests = [XCTestCaseEntry]()
tests += expressionTests.allTests()
XCTMain(tests)
