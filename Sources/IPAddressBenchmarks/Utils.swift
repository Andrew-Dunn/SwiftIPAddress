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
    
    static func randomIPv4String() -> String {
        let a = randomByte()
        let b = randomByte()
        let c = randomByte()
        let d = randomByte()
        return "\(a).\(b).\(c).\(d)"
    }
    
    static func randomIPv4() -> IPv4Address {
        #if os(Linux)
            return IPv4Address(fromUInt32: UInt32(rand()))
        #else
            return IPv4Address(fromUInt32: arc4random_uniform(UInt32.max))
        #endif
    }
    
    static func randomIPv6() -> IPv6Address {
        #if os(Linux)
            let a: UInt32 = rand()
            let b: UInt32 = rand()
            let c: UInt32 = rand()
            let d: UInt32 = rand()
            return IPv6Address(parts: UInt16((a & 0xFFFF) >> 16), UInt16(a & 0xFFFF),
                                      UInt16((b & 0xFFFF) >> 16), UInt16(b & 0xFFFF),
                                      UInt16((c & 0xFFFF) >> 16), UInt16(c & 0xFFFF),
                                      UInt16((d & 0xFFFF) >> 16), UInt16(d & 0xFFFF))
        #else
            return IPv6Address(parts: UInt16(arc4random_uniform(UInt32(UInt16.max))),
                                      UInt16(arc4random_uniform(UInt32(UInt16.max))),
                                      UInt16(arc4random_uniform(UInt32(UInt16.max))),
                                      UInt16(arc4random_uniform(UInt32(UInt16.max))),
                                      UInt16(arc4random_uniform(UInt32(UInt16.max))),
                                      UInt16(arc4random_uniform(UInt32(UInt16.max))),
                                      UInt16(arc4random_uniform(UInt32(UInt16.max))),
                                      UInt16(arc4random_uniform(UInt32(UInt16.max))))
        #endif
    }
    
    static func randomIPv4Strings(count: Int) -> [String] {
        var addressStrings: [String] = []
        for _ in 0..<count {
            addressStrings.append(randomIPv4String())
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
    
    static func randomIPv6Strings(count: Int) -> [String] {
        var addressStrings: [String] = []
        for _ in 0..<count {
            addressStrings.append(randomIPv6().description)
        }
        return addressStrings
    }
    
    static func randomIPv6s(count: Int) -> [IPv6Address] {
        var addresses: [IPv6Address] = []
        for _ in 0..<count {
            addresses.append(randomIPv6())
        }
        return addresses
    }

    static func atonDecodeIPv4Address(ipString: String) -> in_addr? {
        var addr: in_addr = in_addr()
        let result = inet_aton(ipString, &addr)
        if result == 0 {
            return nil
        }
        return addr
    }
    
    static func ptonDecodeIPv4Address(ipString: String) -> in_addr? {
        var addr: in_addr = in_addr()
        let result = inet_pton(AF_INET, ipString, &addr)
        if result == 0 {
            return nil
        }
        return addr
    }
    
    static func swiftDecodeIPv4Address(ipString: String) -> in_addr? {
        let result = IPv4Address(ipString)
        if (result == nil) {
            return nil
        }
        return in_addr(
            s_addr: in_addr_t(
                integerLiteral: UInt32(fromIPv4Address: result!)))
    }
    
    static func ntoaEncodeIPv4Address(ip: IPv4Address) -> String {
        let addr: in_addr = in_addr(
            s_addr: in_addr_t(
                integerLiteral: UInt32(fromIPv4Address: ip)))
        let result = inet_ntoa(addr)
        if result == nil {
            return ""
        }
        return String(cString: result!)
    }
    
    static func ntopEncodeIPv4Address(ip: IPv4Address) -> String {
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
    
    static func ptonDecodeIPv6Address(ipString: String) -> in6_addr? {
        var addr: in6_addr = in6_addr()
        let result = inet_pton(AF_INET6, ipString, &addr)
        if result == 0 {
            return nil
        }
        return addr
    }
    
    static func swiftDecodeIPv6Address(ipString: String) -> in6_addr? {
        let result = IPv6Address(ipString)
        if (result == nil) {
            return nil
        }
        #if os(Linux)
            return in6_addr(__in6_u: in6_addr.__Unnamed_union___in6_u(__u6_addr32: result!.words))
        #else
            return in6_addr(__u6_addr: in6_addr.__Unnamed_union___u6_addr(__u6_addr32: result!.words))
        #endif
    }
    
    static func ntopEncodeIPv6Address(ip: IPv6Address) -> String {
        var cString: [Int8] = []
        cString.reserveCapacity(Int(INET6_ADDRSTRLEN))
        #if os(Linux)
            let addr: [in6_addr] = [
                in6_addr(__in6_u: in6_addr.__Unnamed_union___in6_u(__u6_addr32: ip.words))
            ]
        #else
            let addr: [in6_addr] = [
                in6_addr(__u6_addr: in6_addr.__Unnamed_union___u6_addr(__u6_addr32: ip.words))
            ]
        #endif
        let result = inet_ntop(AF_INET, addr, &cString, 16)
        if result == nil {
            return ""
        }
        return String(cString: result!)
    }
}
