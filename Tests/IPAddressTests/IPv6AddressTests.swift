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
    func testIsUnicastUniqueLocal() {
        XCTAssertFalse(IPv6Address(parts: 0, 0, 0, 0, 0, 0xffff, 0xdead, 0xbeef).isUnicastUniqueLocal)
        XCTAssertTrue(IPv6Address(parts: 0xfc00, 0, 0, 0, 0, 0, 0, 0).isUnicastUniqueLocal)
        XCTAssertTrue(IPv6Address(parts: 0xfd00, 0, 0, 0, 0, 0, 0, 0).isUnicastUniqueLocal)
        XCTAssertFalse(IPv6Address(parts: 0xfe00, 0, 0, 0, 0, 0, 0, 0).isUnicastUniqueLocal)
        XCTAssertFalse(IPv6Address(parts: 0xff00, 0, 0, 0, 0, 0, 0, 0).isUnicastUniqueLocal)
        XCTAssertFalse(IPv6Address(parts: 0x00fc, 0, 0, 0, 0, 0, 0, 0).isUnicastUniqueLocal)
        XCTAssertFalse(IPv6Address(parts: 0x00fd, 0, 0, 0, 0, 0, 0, 0).isUnicastUniqueLocal)
        XCTAssertTrue(IPv6Address(parts: 0xfcff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff).isUnicastUniqueLocal)
        XCTAssertTrue(IPv6Address(parts: 0xfdff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff).isUnicastUniqueLocal)
        XCTAssertFalse(IPv6Address(parts: 0x0c, 0, 0, 0, 0, 0, 0, 0).isUnicastUniqueLocal)
        XCTAssertFalse(IPv6Address(parts: 0x0d, 0, 0, 0, 0, 0, 0, 0).isUnicastUniqueLocal)
    }
    
    /// Test for link-local address detection.
    func testIsUnicastLinkLocal() {
        XCTAssertTrue(IPv6Address("fe80::")!.isUnicastLinkLocal)
        XCTAssertTrue(IPv6Address("febf::")!.isUnicastLinkLocal)
        XCTAssertFalse(IPv6Address("fec0::")!.isUnicastLinkLocal)
        XCTAssertFalse(IPv6Address("ff80::")!.isUnicastLinkLocal)
        XCTAssertFalse(IPv6Address("fe00::")!.isUnicastLinkLocal)
        XCTAssertTrue(IPv6Address("fe80:ffff:ffff:ffff:ffff:ffff:ffff:ffff")!.isUnicastLinkLocal)
        XCTAssertTrue(IPv6Address("febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff")!.isUnicastLinkLocal)
        XCTAssertFalse(IPv6Address("fec0:ffff:ffff:ffff:ffff:ffff:ffff:ffff")!.isUnicastLinkLocal)
        XCTAssertFalse(IPv6Address("ff80:ffff:ffff:ffff:ffff:ffff:ffff:ffff")!.isUnicastLinkLocal)
        XCTAssertFalse(IPv6Address("fe00:ffff:ffff:ffff:ffff:ffff:ffff:ffff")!.isUnicastLinkLocal)

    }
    
    /// Test for globally routable address detection.
    func testIsUnicastGlobal() {
        XCTAssertTrue(IPv6Address("2000::")!.isUnicastGlobal)
        XCTAssertTrue(IPv6Address("3000::")!.isUnicastGlobal)
        XCTAssertTrue(IPv6Address("3fff::")!.isUnicastGlobal)
        XCTAssertFalse(IPv6Address("a000::")!.isUnicastGlobal)
        XCTAssertFalse(IPv6Address("e000::")!.isUnicastGlobal)
        XCTAssertFalse(IPv6Address("bfff::")!.isUnicastGlobal)
        XCTAssertFalse(IPv6Address("ffff::")!.isUnicastGlobal)
        XCTAssertTrue(IPv6Address("2000:ffff:ffff:ffff:ffff:ffff:ffff:ffff")!.isUnicastGlobal)
        XCTAssertTrue(IPv6Address("3000:ffff:ffff:ffff:ffff:ffff:ffff:ffff")!.isUnicastGlobal)
        XCTAssertTrue(IPv6Address("3fff:ffff:ffff:ffff:ffff:ffff:ffff:ffff")!.isUnicastGlobal)
        XCTAssertFalse(IPv6Address("a000:ffff:ffff:ffff:ffff:ffff:ffff:ffff")!.isUnicastGlobal)
        XCTAssertFalse(IPv6Address("e000:ffff:ffff:ffff:ffff:ffff:ffff:ffff")!.isUnicastGlobal)
        XCTAssertFalse(IPv6Address("bfff:ffff:ffff:ffff:ffff:ffff:ffff:ffff")!.isUnicastGlobal)
        XCTAssertFalse(IPv6Address("ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff")!.isUnicastGlobal)
    }
    
    /// Test for multicast address detection.
    func testIsMulticast() {
        XCTAssertTrue(IPv6Address("ff00::")!.isMulticast)
        XCTAssertTrue(IPv6Address("ffff::")!.isMulticast)
        XCTAssertFalse(IPv6Address("fe00::")!.isMulticast)
        XCTAssertFalse(IPv6Address("feff::")!.isMulticast)
        XCTAssertFalse(IPv6Address("7f00::")!.isMulticast)
        XCTAssertFalse(IPv6Address("7fff::")!.isMulticast)
        XCTAssertFalse(IPv6Address("ef00::")!.isMulticast)
        XCTAssertFalse(IPv6Address("efff::")!.isMulticast)
        XCTAssertTrue(IPv6Address("ff00:ffff:ffff:ffff:ffff:ffff:ffff:ffff")!.isMulticast)
        XCTAssertTrue(IPv6Address("ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff")!.isMulticast)
        XCTAssertFalse(IPv6Address("fe00:ffff:ffff:ffff:ffff:ffff:ffff:ffff")!.isMulticast)
        XCTAssertFalse(IPv6Address("feff:ffff:ffff:ffff:ffff:ffff:ffff:ffff")!.isMulticast)
        XCTAssertFalse(IPv6Address("7f00:ffff:ffff:ffff:ffff:ffff:ffff:ffff")!.isMulticast)
        XCTAssertFalse(IPv6Address("7fff:ffff:ffff:ffff:ffff:ffff:ffff:ffff")!.isMulticast)
        XCTAssertFalse(IPv6Address("ef00:ffff:ffff:ffff:ffff:ffff:ffff:ffff")!.isMulticast)
        XCTAssertFalse(IPv6Address("efff:ffff:ffff:ffff:ffff:ffff:ffff:ffff")!.isMulticast)
    }
    
    /// Test for IP Addresses that are reserved for documentation.
    func testIsDocumentation() {
        XCTAssertTrue(IPv6Address(parts: 0x2001, 0xdb8, 0, 0, 0, 0, 0, 0).isDocumentation)
        XCTAssertFalse(IPv6Address(parts: 0x2002, 0xdb8, 0, 0, 0, 0, 0, 0).isDocumentation)
        XCTAssertFalse(IPv6Address(parts: 0x2001, 0xdb9, 0, 0, 0, 0, 0, 0).isDocumentation)
        XCTAssertFalse(IPv6Address(parts: 0x2002, 0x1db8, 0, 0, 0, 0, 0, 0).isDocumentation)
        XCTAssertTrue(IPv6Address(parts: 0x2001, 0x0db8, 0xffff, 0xffff,
                                         0xffff, 0xffff, 0xffff, 0xffff).isDocumentation)
    }
    
    /// Test that predefined addresses are correct.
    func testStaticValues() {
        XCTAssertTrue(IPv6Address.any.isUnspecified)
        XCTAssertEqual(IPv6Address.any, IPv6Address())
        XCTAssertTrue(IPv6Address.loopback.isLoopback)
        XCTAssertEqual(IPv6Address.loopback, IPv6Address("::1"))
    }
    
    /// Test that constructors set the value of the address properly.
    func testValue() {
        let address = IPv6Address(parts: 0x0123, 0x4567, 0x89ab, 0xcdef, 0x8091, 0xa2b3, 0xc4d5, 0xe6f7)
        let words = address.words
        XCTAssertEqual(words.0, 0x67452301)
        XCTAssertEqual(words.1, 0xefcdab89)
        XCTAssertEqual(words.2, 0xb3a29180)
        XCTAssertEqual(words.3, 0xf7e6d5c4)
    }
    
    /// Test that the octet array extraction works as expected.
    func testOctets() {
        let address = IPv6Address(parts: 0x0123, 0x4567, 0x89ab, 0xcdef, 0x8091, 0xa2b3, 0xc4d5, 0xe6f7)
        XCTAssertEqual(address.octets, [0x01,0x23, 0x45,0x67, 0x89,0xab, 0xcd,0xef,
                                        0x80,0x91, 0xa2,0xb3, 0xc4,0xd5, 0xe6,0xf7])
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
        var address1 = IPv6Address()
        var address2 = IPv6Address(parts: 0,0,0,0,0,0,0,0)
        XCTAssertTrue(address1 == address2)
        XCTAssertFalse(address1 != address2)
        XCTAssertEqual(address1, address2)
        address2 = IPv6Address(parts: 0,0,0,0,0,0,0,1)
        XCTAssertFalse(address1 == address2)
        XCTAssertTrue(address1 != address2)
        XCTAssertNotEqual(address1, address2)
        address2 = IPv6Address(parts: 0,0,0,0,0,0,1,0)
        XCTAssertFalse(address1 == address2)
        XCTAssertTrue(address1 != address2)
        XCTAssertNotEqual(address1, address2)
        address2 = IPv6Address(parts: 0,0,0,0,0,1,0,0)
        XCTAssertFalse(address1 == address2)
        XCTAssertTrue(address1 != address2)
        XCTAssertNotEqual(address1, address2)
        address2 = IPv6Address(parts: 0,0,0,0,1,0,0,0)
        XCTAssertFalse(address1 == address2)
        XCTAssertTrue(address1 != address2)
        XCTAssertNotEqual(address1, address2)
        address2 = IPv6Address(parts: 0,0,0,1,0,0,0,0)
        XCTAssertFalse(address1 == address2)
        XCTAssertTrue(address1 != address2)
        XCTAssertNotEqual(address1, address2)
        address2 = IPv6Address(parts: 0,0,1,0,0,0,0,0)
        XCTAssertFalse(address1 == address2)
        XCTAssertTrue(address1 != address2)
        XCTAssertNotEqual(address1, address2)
        address2 = IPv6Address(parts: 0,1,0,0,0,0,0,0)
        XCTAssertFalse(address1 == address2)
        XCTAssertTrue(address1 != address2)
        XCTAssertNotEqual(address1, address2)
        address2 = IPv6Address(parts: 1,0,0,0,0,0,0,0)
        XCTAssertFalse(address1 == address2)
        XCTAssertTrue(address1 != address2)
        XCTAssertNotEqual(address1, address2)
        address1 = IPv6Address(parts: 0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff)
        XCTAssertFalse(address1 == address2)
        XCTAssertTrue(address1 != address2)
        XCTAssertNotEqual(address1, address2)
        address2 = IPv6Address(parts: 0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff)
        XCTAssertTrue(address1 == address2)
        XCTAssertFalse(address1 != address2)
        XCTAssertEqual(address1, address2)
        address2 = IPv6Address(parts: 0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xfffe)
        XCTAssertFalse(address1 == address2)
        XCTAssertTrue(address1 != address2)
        XCTAssertNotEqual(address1, address2)
        address2 = IPv6Address(parts: 0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xfffe,0xffff)
        XCTAssertFalse(address1 == address2)
        XCTAssertTrue(address1 != address2)
        XCTAssertNotEqual(address1, address2)
        address2 = IPv6Address(parts: 0xffff,0xffff,0xffff,0xffff,0xffff,0xfffe,0xffff,0xffff)
        XCTAssertFalse(address1 == address2)
        XCTAssertTrue(address1 != address2)
        XCTAssertNotEqual(address1, address2)
        address2 = IPv6Address(parts: 0xffff,0xffff,0xffff,0xffff,0xfffe,0xffff,0xffff,0xffff)
        XCTAssertFalse(address1 == address2)
        XCTAssertTrue(address1 != address2)
        XCTAssertNotEqual(address1, address2)
        address2 = IPv6Address(parts: 0xffff,0xffff,0xffff,0xfffe,0xffff,0xffff,0xffff,0xffff)
        XCTAssertFalse(address1 == address2)
        XCTAssertTrue(address1 != address2)
        XCTAssertNotEqual(address1, address2)
        address2 = IPv6Address(parts: 0xffff,0xffff,0xfffe,0xffff,0xffff,0xffff,0xffff,0xffff)
        XCTAssertFalse(address1 == address2)
        XCTAssertTrue(address1 != address2)
        XCTAssertNotEqual(address1, address2)
        address2 = IPv6Address(parts: 0xffff,0xfffe,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff)
        XCTAssertFalse(address1 == address2)
        XCTAssertTrue(address1 != address2)
        XCTAssertNotEqual(address1, address2)
        address2 = IPv6Address(parts: 0xfffe,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff)
        XCTAssertFalse(address1 == address2)
        XCTAssertTrue(address1 != address2)
        XCTAssertNotEqual(address1, address2)
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
        parsed = IPv6Address("123:4567:89ab:cdef::8091:a2b3:c4d5:e6f7")
        actual = IPv6Address(parts: 0x0123, 0x4567, 0x89ab, 0xcdef, 0x8091, 0xa2b3, 0xc4d5, 0xe6f7)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed, actual)
        parsed = IPv6Address("::127.0.0.1")
        actual = IPv6Address(parts: 0, 0, 0, 0, 0, 0, 0x7f00, 0x0001)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed, actual)
        parsed = IPv6Address("0:0:0:0:0:0:127.0.0.1")
        actual = IPv6Address(parts: 0, 0, 0, 0, 0, 0, 0x7f00, 0x0001)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed, actual)
        parsed = IPv6Address("0:0:0:0:0:0::127.0.0.1")
        actual = IPv6Address(parts: 0, 0, 0, 0, 0, 0, 0x7f00, 0x0001)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed, actual)
        parsed = IPv6Address("0:0:0:0:0:0::255.255.255.255")
        actual = IPv6Address(parts: 0, 0, 0, 0, 0, 0, 0xffff, 0xffff)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed, actual)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed, actual)
        parsed = IPv6Address("123:4567:89AB:cDeF:8091:a2B3:C4D5:E6F7")
        actual = IPv6Address(parts: 0x0123, 0x4567, 0x89ab, 0xcdef, 0x8091, 0xa2b3, 0xc4d5, 0xe6f7)
        
        parsed = IPv6Address("123:4567:89ab:cdef:8091:a2b3:c4d5")
        XCTAssertNil(parsed)
        parsed = IPv6Address("123:4567:89ab:cdef:8091:a2b3:c4d5:e6f7:1")
        XCTAssertNil(parsed)
        parsed = IPv6Address("123:4567:89ab:cdef::8091:a2b3:c4d5:e6f7:1")
        XCTAssertNil(parsed)
        parsed = IPv6Address("0:0:0:0:0:0:0:127.0.0.1")
        XCTAssertNil(parsed)
        parsed = IPv6Address("0:0:0:0:0:0:0::127.0.0.1")
        XCTAssertNil(parsed)
        parsed = IPv6Address("0:0:0:0:0:0:256.0.0.1")
        XCTAssertNil(parsed)
        parsed = IPv6Address("123:4567:89ab:cgef:8091:a2b3:c4d5:e6f7")
        XCTAssertNil(parsed)
        parsed = IPv6Address("0:0:0:0:0:0:253.0.0")
        XCTAssertNil(parsed)
    }
    
    /// Test that the swift version creates the same IP address as the C version.
    func testEqualToPton() {
        func cDecodeIPAddress(ipString: String) -> in6_addr? {
            var addr: in6_addr = in6_addr()
            let result = ipString.withCString { (cString: UnsafePointer<Int8>) -> Int32 in
                return inet_pton(AF_INET6, cString, &addr)
            }
            if result == 0 {
                return nil
            }
            return addr
        }
        
        func swiftDecodeIPAddress(ipString: String) -> in6_addr? {
            let result = IPv6Address(ipString)
            if (result == nil) {
                return nil
            }
            let words = result!.words
            #if os(Linux)
                return in6_addr(__in6_u: in6_addr.__Unnamed_union___in6_u(__u6_addr32: words))
            #else
                return in6_addr(__u6_addr: in6_addr.__Unnamed_union___u6_addr(__u6_addr32: words))
            #endif

        }
        
        var ipAddressString = "123:4567:89ab:cdef:8091:a2b3:c4d5:e6f7"
        XCTAssertNotNil(cDecodeIPAddress(ipString: ipAddressString))
        XCTAssertNotNil(swiftDecodeIPAddress(ipString: ipAddressString))
        XCTAssertTrue(cDecodeIPAddress(ipString: ipAddressString)!.__u6_addr.__u6_addr32 ==
                      swiftDecodeIPAddress(ipString: ipAddressString)!.__u6_addr.__u6_addr32)
        
        ipAddressString = "::"
        XCTAssertNotNil(cDecodeIPAddress(ipString: ipAddressString))
        XCTAssertNotNil(swiftDecodeIPAddress(ipString: ipAddressString))
        XCTAssertTrue(cDecodeIPAddress(ipString: ipAddressString)!.__u6_addr.__u6_addr32 ==
                      swiftDecodeIPAddress(ipString: ipAddressString)!.__u6_addr.__u6_addr32)
        
        ipAddressString = "::255.255.255.255"
        XCTAssertNotNil(cDecodeIPAddress(ipString: ipAddressString))
        XCTAssertNotNil(swiftDecodeIPAddress(ipString: ipAddressString))
        XCTAssertTrue(cDecodeIPAddress(ipString: ipAddressString)!.__u6_addr.__u6_addr32 ==
                      swiftDecodeIPAddress(ipString: ipAddressString)!.__u6_addr.__u6_addr32)
    }

    static var allTests = [
        ("testIsUnspecified",        testIsUnspecified),
        ("testIsLoopback",           testIsLoopback),
        ("testIsUnicastUniqueLocal", testIsUnicastUniqueLocal),
        ("testIsUnicastLinkLocal",   testIsUnicastLinkLocal),
        ("testIsUnicastGlobal",      testIsUnicastGlobal),
        ("testIsMulticast",          testIsMulticast),
        ("testIsDocumentation",      testIsDocumentation),
        ("testStaticValues",         testStaticValues),
        ("testValue",                testValue),
        ("testOctets",               testOctets),
        ("testStringConversion",     testStringConversion),
        ("testEqualityOperators",    testEqualityOperators),
        ("testStringConstructor",    testStringConstructor),
        ("testEqualToPton",          testEqualToPton)
    ]
}
