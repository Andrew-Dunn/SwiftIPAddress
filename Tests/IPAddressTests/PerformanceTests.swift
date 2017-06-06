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
#if os(Linux)
    import Glibc
#endif

class PerformanceTests: XCTestCase {
    class Utils {
        static func randomByte() -> UInt8 {
            #if os(Linux)
                return UInt8(rand() & 0xFF)
            #else
                return UInt8(arc4random_uniform(256))
            #endif
        }
        
        static func randomIPAddressString() -> String {
            let a = randomByte()
            let b = randomByte()
            let c = randomByte()
            let d = randomByte()
            return "\(a).\(b).\(c).\(d)"
        }
        
        static func randomIPAddressStrings(count: Int) -> [String] {
            var addressStrings: [String] = []
            for _ in 0..<count {
                addressStrings.append(randomIPAddressString())
            }
            print("\(count) IP Addresses Generated.")
            return addressStrings
        }
        
        static func cDecodeIPAddress(ipString: String) -> in_addr? {
            var addr: in_addr = in_addr()
            let result = ipString.withCString { (cString: UnsafePointer<Int8>) -> Int32 in
                return inet_aton(cString, &addr)
            }
            if result == 0 {
                return nil
            }
            return addr
        }
        
        static func swiftDecodeIPAddress(ipString: String) -> in_addr? {
            let result = IPv4Address(ipString)
            if (result == nil) {
                return nil
            }
            return in_addr(
                s_addr: in_addr_t(
                    integerLiteral: UInt32(fromIPv4Address: result!)))
        }
    }
    
    // The number of IPv4 addresses to generate.
    static var ipAddressStrings: [String] = []
    
    override static func setUp() {
        ipAddressStrings = Utils.randomIPAddressStrings(count: 1000000)
    }
    
    func testPerformance() {
        print("Profiling IPv4Address String Constructor.")
        // Warm up the cache.
        for ipString in PerformanceTests.ipAddressStrings {
            XCTAssertNotNil(Utils.swiftDecodeIPAddress(ipString: ipString))
        }
        for ipString in PerformanceTests.ipAddressStrings {
            XCTAssertNotNil(Utils.swiftDecodeIPAddress(ipString: ipString))
        }
        for ipString in PerformanceTests.ipAddressStrings {
            XCTAssertNotNil(Utils.swiftDecodeIPAddress(ipString: ipString))
        }
        measure {
            for ipString in PerformanceTests.ipAddressStrings {
                XCTAssertNotNil(Utils.swiftDecodeIPAddress(ipString: ipString))
            }
        }
    }
    
    func testInetAtonPerformance() {
        print("Profiling inet_aton")
        // Warm up the cache.
        for ipString in PerformanceTests.ipAddressStrings {
            XCTAssertNotNil(Utils.cDecodeIPAddress(ipString: ipString))
        }
        for ipString in PerformanceTests.ipAddressStrings {
            XCTAssertNotNil(Utils.cDecodeIPAddress(ipString: ipString))
        }
        for ipString in PerformanceTests.ipAddressStrings {
            XCTAssertNotNil(Utils.cDecodeIPAddress(ipString: ipString))
        }
        measure {
            for ipString in PerformanceTests.ipAddressStrings {
                XCTAssertNotNil(Utils.cDecodeIPAddress(ipString: ipString))
            }
        }
    }
    
    static var allTests = [
        ("testPerformance",         testPerformance),
        ("testInetAtonPerformance", testInetAtonPerformance)
    ]
}
