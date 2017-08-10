//
// Copyright © Andrew Dunn, 2017
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
import IPAddress

class IPv6AddressTests: XCTestCase {
    
    /// Test unspecified address detection.
    func testIsUnspecified() {
        var address = IPv6Address(parts: 0, 0, 0, 0, 0, 0, 0, 0)
        XCTAssertTrue(address.isUnspecified)
        address = IPv6Address(parts: 1, 0, 0, 0, 0, 0, 0, 0)
        XCTAssertFalse(address.isUnspecified)
        address = IPv6Address(parts: 0, 0, 0, 0, 0, 0, 0, 1)
        XCTAssertFalse(address.isUnspecified)
        address = IPv6Address(parts: 0x8000, 0, 0, 0, 0, 0, 0, 0)
        XCTAssertFalse(address.isUnspecified)
    }
    
    /// Test the loopback address detection.
    func testIsLoopback() {
        var address = IPv6Address(parts: 0, 0, 0, 0, 0, 0, 0, 0)
        XCTAssertFalse(address.isLoopback)
        address = IPv6Address(parts: 0, 0, 0, 0, 0, 0, 0, 1)
        XCTAssertTrue(address.isLoopback)
        address = IPv6Address(parts: 0, 0, 0, 0, 0, 0, 0, 2)
        XCTAssertFalse(address.isLoopback)
        address = IPv6Address(parts: 1, 0, 0, 0, 0, 0, 0, 1)
        XCTAssertFalse(address.isLoopback)
        address = IPv6Address(parts: 1, 0, 0, 0, 0, 0, 0, 0)
        XCTAssertFalse(address.isLoopback)
        address = IPv6Address(parts: 0, 0, 0, 0, 1, 0, 0, 0)
        XCTAssertFalse(address.isLoopback)
        address = IPv6Address(parts: 0, 0, 0, 1, 0, 0, 0, 0)
        XCTAssertFalse(address.isLoopback)
        address = IPv6Address(parts: 0, 0, 0, 0, 0, 0, 0, 0x100)
        XCTAssertFalse(address.isLoopback)
    }
    
    /// Test for private address detection.
    func testIsUniqueLocal() {
        XCTAssertFalse(IPv6Address(parts: 0, 0, 0, 0, 0, 0xffff, 0xdead, 0xbeef).isUniqueLocal)
        XCTAssertTrue(IPv6Address(parts: 0xfc00, 0, 0, 0, 0, 0, 0, 0).isUniqueLocal)
        XCTAssertTrue(IPv6Address(parts: 0xfd00, 0, 0, 0, 0, 0, 0, 0).isUniqueLocal)
        XCTAssertFalse(IPv6Address(parts: 0xfe00, 0, 0, 0, 0, 0, 0, 0).isUniqueLocal)
        XCTAssertFalse(IPv6Address(parts: 0xff00, 0, 0, 0, 0, 0, 0, 0).isUniqueLocal)
        XCTAssertFalse(IPv6Address(parts: 0x00fc, 0, 0, 0, 0, 0, 0, 0).isUniqueLocal)
        XCTAssertFalse(IPv6Address(parts: 0x00fd, 0, 0, 0, 0, 0, 0, 0).isUniqueLocal)
        XCTAssertTrue(IPv6Address(parts: 0xfcff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff).isUniqueLocal)
        XCTAssertTrue(IPv6Address(parts: 0xfdff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff).isUniqueLocal)
        XCTAssertFalse(IPv6Address(parts: 0x0c, 0, 0, 0, 0, 0, 0, 0).isUniqueLocal)
        XCTAssertFalse(IPv6Address(parts: 0x0d, 0, 0, 0, 0, 0, 0, 0).isUniqueLocal)
    }
    
    /// Test for link-local address detection.
    func testIsLinkLocal() {
    }
    
    /// Test for globally routable address detection.
    func testIsGlobal() {
    }
    
    /// Test for multicast address detection.
    func testIsMulticast() {
    }
    
    /// Test for broadcast address detection.
    func testIsBroadcast() {
    }
    
    /// Test for IP Addresses that are reserved for documentation.
    func testIsDocumentation() {
    }
    
    /// Test that predefined addresses are correct.
    func testStaticValues() {
    }
    
    /// Test that constructors set the value of the address properly.
    func testValue() {
    }
    
    /// Test that the octet array extraction works as expected.
    func testOctets() {
    }
    
    /// Test that IP Addresses can be converted to a string correctly.
    func testStringConversion() {
        var address = IPv6Address(parts: 0x0123, 0x4567, 0x89ab, 0xcdef, 0x8091, 0xa2b3, 0xc4d5, 0xe6f7)
        XCTAssertEqual(address.description, "123:4567:89ab:cdef:8091:a2b3:c4d5:e6f7")
        address = IPv6Address(parts: 1, 2, 3, 4, 5, 6, 7, 8)
        XCTAssertEqual(address.description, "1:2:3:4:5:6:7:8")
        address = IPv6Address(parts: 0, 0, 0, 0, 0x8091, 0xa2b3, 0xc4d5, 0xe6f7)
        XCTAssertEqual(address.description, "::8091:a2b3:c4d5:e6f7")
        address = IPv6Address(parts: 0, 0, 0, 0, 0, 0xffff, 0xc4d5, 0xe6f7)
        XCTAssertEqual(address.description, "::ffff:196.213.230.247")
        address = IPv6Address(parts: 0, 0, 0, 0, 0, 0, 0xc4d5, 0xe6f7)
        XCTAssertEqual(address.description, "::196.213.230.247")
        address = IPv6Address(parts: 0, 0, 0, 0, 0, 0, 0, 0)
        XCTAssertEqual(address.description, "::")
        address = IPv6Address(parts: 0, 0, 0, 0, 0, 0, 0, 1)
        XCTAssertEqual(address.description, "::1")
        address = IPv6Address(parts: 0, 0, 0, 0, 0, 0, 0, 2)
        XCTAssertEqual(address.description, "::0.0.0.2")
        address = IPv6Address(parts: 0, 0, 0, 0xcdef, 0x8091, 0xa2b3, 0xc4d5, 0xe6f7)
        XCTAssertEqual(address.description, "::cdef:8091:a2b3:c4d5:e6f7")
        address = IPv6Address(parts: 0x0123, 0, 0, 0, 0x8091, 0xa2b3, 0xc4d5, 0xe6f7)
        XCTAssertEqual(address.description, "123::8091:a2b3:c4d5:e6f7")
        address = IPv6Address(parts: 0x0123, 0, 0, 0, 0x8091, 0, 0, 0)
        XCTAssertEqual(address.description, "123::8091:0:0:0")
        address = IPv6Address(parts: 0, 0, 0xaa57, 0xcdef, 0, 0, 0, 0x3b7a)
        XCTAssertEqual(address.description, "0:0:aa57:cdef::3b7a")
        address = IPv6Address(parts: 0x0123, 0x4567, 0x89ab, 0xcdef, 0x8091, 0xa2b3, 0, 0)
        XCTAssertEqual(address.description, "123:4567:89ab:cdef:8091:a2b3::")
        address = IPv6Address(parts: 0, 0, 0, 0, 0, 0xa2b3, 0xc4d5, 0xe6f7)
        XCTAssertEqual(address.description, "::a2b3:c4d5:e6f7")
        
        // Don't truncate a single zero.
        address = IPv6Address(parts: 0, 2, 3, 4, 5, 6, 7, 8)
        XCTAssertEqual(address.description, "0:2:3:4:5:6:7:8")
        address = IPv6Address(parts: 1, 2, 3, 4, 0, 6, 7, 8)
        XCTAssertEqual(address.description, "1:2:3:4:0:6:7:8")
        address = IPv6Address(parts: 1, 2, 3, 4, 5, 6, 7, 0)
        XCTAssertEqual(address.description, "1:2:3:4:5:6:7:0")
    }
    
    /// Test that the equality/inequality operators work as expected.
    func testEqualityOperators() {
    }
    
    /// Test that string representations of IP addresses are parsed correctly.
    func testStringConstructor() {
        var parsed = IPv6Address("1:2:3:4:5:6:7:8")
        var actual = IPv6Address(parts: 1, 2, 3, 4, 5, 6, 7, 8)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed, actual)
        parsed = IPv6Address("123:4567:89ab:cdef:8091:a2b3:c4d5:e6f7")
        actual = IPv6Address(parts: 0x0123, 0x4567, 0x89ab, 0xcdef, 0x8091, 0xa2b3, 0xc4d5, 0xe6f7)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed, actual)
        parsed = IPv6Address("::")
        actual = IPv6Address()
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed, actual)
        parsed = IPv6Address("::1")
        actual = IPv6Address(parts: 0, 0, 0, 0, 0, 0, 0, 1)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed, actual)
        parsed = IPv6Address("123:4567:89ab:cdef:8091:a2b3::")
        actual = IPv6Address(parts: 0x0123, 0x4567, 0x89ab, 0xcdef, 0x8091, 0xa2b3, 0, 0)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed, actual)
        parsed = IPv6Address("123:4567:89ab::a2b3:c4d5:e6f7")
        actual = IPv6Address(parts: 0x0123, 0x4567, 0x89ab, 0, 0, 0xa2b3, 0xc4d5, 0xe6f7)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed, actual)
        parsed = IPv6Address("::cdef:8091:a2b3:c4d5:e6f7")
        actual = IPv6Address(parts: 0, 0, 0, 0xcdef, 0x8091, 0xa2b3, 0xc4d5, 0xe6f7)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed, actual)
        parsed = IPv6Address("::ffff:192.168.0.1")
        actual = IPv6Address(parts: 0, 0, 0, 0, 0, 0xffff, 0xc0a8, 0x0001)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed, actual)
    }
    
    /// Test that the swift version creates the same IP address as the C version.
    func testEqualToPton() {
    }

    static var allTests = [
        ("testIsUnspecified",     testIsUnspecified),
        ("testIsLoopback",        testIsLoopback),
        ("testIsUniqueLocal",     testIsUniqueLocal),
        ("testIsLinkLocal",       testIsLinkLocal),
        ("testIsGlobal",          testIsGlobal),
        ("testIsMulticast",       testIsMulticast),
        ("testIsBroadcast",       testIsBroadcast),
        ("testIsDocumentation",   testIsDocumentation),
        ("testStaticValues",      testStaticValues),
        ("testValue",             testValue),
        ("testOctets",            testOctets),
        ("testStringConversion",  testStringConversion),
        ("testEqualityOperators", testEqualityOperators),
        ("testStringConstructor", testStringConstructor),
        ("testEqualToPton",       testEqualToPton)
    ]
}
