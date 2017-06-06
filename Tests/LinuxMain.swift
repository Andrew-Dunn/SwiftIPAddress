import XCTest
@testable import IPAddressTests

XCTMain([
    testCase(IPv4AddressTests.allTests),
    testCase(PerformanceTests.allTests),
])
