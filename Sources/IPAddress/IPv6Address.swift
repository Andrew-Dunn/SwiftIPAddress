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

/// Represents an IP version 6 address.
///
/// Immutable and space efficient.
///
/// - Author: Andrew Dunn.
///
public struct IPv6Address: LosslessStringConvertible, Equatable {
    fileprivate let high, low: UInt64
    
    public static func ==(lhs: IPv6Address, rhs: IPv6Address) -> Bool {
        return  lhs.high == rhs.high && lhs.low == rhs.low
    }
    
    public init() {
        low = 0;
        high = 0;
    }
    
    /// Initialises a new instance with the given values.
    ///
    /// - Parameters:
    ///   - a: The *first* component of the IP address.
    ///   - b: The *second* component of the IP address.
    ///   - c: The *third* component of the IP address.
    ///   - d: The *fourth & final* component of the IP address.
    public init (parts a: UInt16, _ b: UInt16, _ c: UInt16, _ d: UInt16,
                     _ e: UInt16, _ f: UInt16, _ g: UInt16, _ h: UInt16) {
        high = UInt64(a.bigEndian) | (UInt64(b.bigEndian) << 16)
               | (UInt64(c.bigEndian) << 32) | (UInt64(d.bigEndian) << 48)
        low = UInt64(e.bigEndian) | (UInt64(f.bigEndian) << 16)
              | (UInt64(g.bigEndian) << 32) | (UInt64(h.bigEndian) << 48)
    }
    
    public init?(_ description: String) {
        high = 0
        low = 0
    }
    
    /// Returns `true` if the IP address is an unspecified, if you listen on
    /// this address, your socket will listen on all addresses available.
    ///
    /// - Note: Equivalent to checking if the IP address is equal to
    ///         **::**.
    public var isUnspecified: Bool {
        return high == 0 && low == 0
    }

    /// Returns `true` if the IP address is a loopback address.
    ///
    /// - Note: Equivalent to checking if the IP address is **::1**.
    public var isLoopback: Bool {
        return high == 0 && low == 0x0100_0000_0000_0000
    }
    
    /// Returns `true` if the IP address is a unique local address **(fc00::/7)**.
    public var isUniqueLocal: Bool {
        return (high & 0xFE) == 0xFC
    }
    
    /// Returns `true` if the IP address is a unicast link-local address **(fe80::/10)**.
    public var isUnicastLinkLocal: Bool {
        return (high & 0xC0FF) == 0x80FE
    }
    
    /// Returns `true` if the IP address is a (deprecated) unicast site-local address **(fec0::/10)**.
    public var isUnicastSiteLocal: Bool {
        return (high & 0xC0FF) == 0xC0FE
    }
    
    /// Returns a string representation of the IP address. Will display IPv4 compatible/mapped addresses
    /// correctly, and will truncate zeroes when possible.
    public var description: String {
        var out = ""
        if high == 0 {
            if low == 0 {
                return "::"
            }
            if low == 0x0100_0000_0000_0000 {
                return "::1"
            }
            
            // Check if this is an IPv4-compatible/mapped IPv6 address.
            let ipv4Check = low & 0x0000_0000_FFFF_FFFF
            if (ipv4Check == 0 || ipv4Check == 0xFFFF_0000) {
                // Use dotted quads to represent the IPv4 part.
                let ipv4 = IPv4Address(fromUInt32: UInt32(low >> 32))
                if (ipv4Check == 0) {
                    return "::\(ipv4.description)"
                }
                return "::ffff:\(ipv4.description)"
            }
        }
        
        var segment: UInt64 = 0
        
        while segment < 8 {
            let shift: UInt64 = (segment & 0b11) << 4
            let word: UInt64
            if segment >> 2 == 0 {
                word = (high >> shift) & 0xFFFF
            } else {
                word = (low >> shift) & 0xFFFF
            }
            
            let lo = (word >> 8) & 0xFF
            let hi = word & 0xFF
            
            out += String(lo | (hi << 8), radix: 16, uppercase: false)
            
            segment += 1
            if (segment != 8) {
                out += ":"
            }
        }
        
        return out
    }
}
