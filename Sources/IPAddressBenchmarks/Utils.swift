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

import IPAddress
#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

class Utils {
    static func randomByte() -> UInt8 {
        #if os(Linux)
            return UInt8(rand() & 0xFF)
        #else
            return UInt8(arc4random_uniform(255))
        #endif
    }
    
    static func randomIPAddressString() -> String {
        let a = randomByte()
        let b = randomByte()
        let c = randomByte()
        let d = randomByte()
        return "\(a).\(b).\(c).\(d)"
    }
    
    static func randomIPv4() -> IPv4Address {
        #if os(Linux)
            return IPv4Address(fromUInt32: rand())
        #else
            return IPv4Address(fromUInt32: arc4random_uniform(UInt32.max))
        #endif
    }
    
    static func randomIPAddressStrings(count: Int) -> [String] {
        var addressStrings: [String] = []
        for _ in 0..<count {
            addressStrings.append(randomIPAddressString())
        }
        return addressStrings
    }
    
    static func randomIPv4s(count: Int) -> [IPv4Address] {
        var addresses: [IPv4Address] = []
        for _ in 0..<count {
            addresses.append(randomIPv4())
        }
        return addresses
    }
    
    static func atonDecodeIPAddress(ipString: String) -> in_addr? {
        var addr: in_addr = in_addr()
        let result = inet_aton(ipString, &addr)
        if result == 0 {
            return nil
        }
        return addr
    }
    
    static func ptonDecodeIPAddress(ipString: String) -> in_addr? {
        var addr: in_addr = in_addr()
        let result = inet_pton(AF_INET, ipString, &addr)
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
    
    static func ntoaEncodeIPAddress(ip: IPv4Address) -> String {
        let addr: in_addr = in_addr(
            s_addr: in_addr_t(
                integerLiteral: UInt32(fromIPv4Address: ip)))
        let result = inet_ntoa(addr)
        if result == nil {
            return ""
        }
        return String(cString: result!)
    }
    
    static func ntopEncodeIPAddress(ip: IPv4Address) -> String {
        var cString: [Int8] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        let addr: [in_addr] = [in_addr(
            s_addr: in_addr_t(
                integerLiteral: UInt32(fromIPv4Address: ip)))]
        let result = inet_ntop(AF_INET, addr, &cString, 16)
        if result == nil {
            return ""
        }
        return String(cString: result!)
    }
}
