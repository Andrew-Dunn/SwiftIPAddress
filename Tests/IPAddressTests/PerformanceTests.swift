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

class PerformanceTests: XCTestCase {
    class Utils {
        static func randomIPAddressString() -> String {
            let a = arc4random_uniform(256)
            let b = arc4random_uniform(256)
            let c = arc4random_uniform(256)
            let d = arc4random_uniform(256)
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
        
        static func cDecodeIPAddress(ipString: String) -> IPv4Address? {
            var addr: in_addr = in_addr()
            let result = ipString.withCString { (cString: UnsafePointer<Int8>) -> Int32 in
                return inet_aton(cString, &addr)
            }
            if result == 0 {
                return nil
            }
            return IPv4Address(fromUInt32: addr.s_addr)
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
            XCTAssertNotNil(IPv4Address(ipString))
        }
        for ipString in PerformanceTests.ipAddressStrings {
            XCTAssertNotNil(IPv4Address(ipString))
        }
        for ipString in PerformanceTests.ipAddressStrings {
            XCTAssertNotNil(IPv4Address(ipString))
        }
        measure {
            for ipString in PerformanceTests.ipAddressStrings {
                XCTAssertNotNil(IPv4Address(ipString))
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
