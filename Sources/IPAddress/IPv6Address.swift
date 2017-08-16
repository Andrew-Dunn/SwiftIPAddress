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
    ///   - d: The *fourth* component of the IP address.
    ///   - e: The *fifth* component of the IP address.
    ///   - f: The *sixth* component of the IP address.
    ///   - g: The *seventh* component of the IP address.
    ///   - h: The *eighth* component of the IP address.
    public init (parts a: UInt16, _ b: UInt16, _ c: UInt16, _ d: UInt16,
                     _ e: UInt16, _ f: UInt16, _ g: UInt16, _ h: UInt16) {
        high = UInt64(a.bigEndian) | (UInt64(b.bigEndian) << 16)
               | (UInt64(c.bigEndian) << 32) | (UInt64(d.bigEndian) << 48)
        low = UInt64(e.bigEndian) | (UInt64(f.bigEndian) << 16)
              | (UInt64(g.bigEndian) << 32) | (UInt64(h.bigEndian) << 48)
    }
    
    public init?(_ str: String) {
        var segments: [UInt16] = []
        var zeroRunIndex: Int = -1
        var currentValue: UInt32 = 0
        var currentLength = 0
        var hasHex = false
        var wasColon = false
        var parsingQuad = false
        var segment: UInt64 = 0
        var hi: UInt64 = 0
        var lo: UInt64 = 0
        var power: UInt32 = 16
        var ipv4: UInt32 = 0
        var ipv4Shift: UInt32 = 0
        
        for c in str.unicodeScalars {
            let val: UInt32
            if c >= "0" && c <= "9" {
                val = c.value - UnicodeScalar("0")!.value
                currentLength += 1
                wasColon = false
                currentValue *= power
                currentValue += val
            }
            else if c >= "A" && c <= "F" {
                val = c.value - UnicodeScalar("A")!.value + 10
                currentLength += 1
                hasHex = true
                wasColon = false
                currentValue *= power
                currentValue += val
            }
            else if c >= "a" && c <= "f" {
                val = c.value - UnicodeScalar("a")!.value + 10
                currentLength += 1
                hasHex = true
                wasColon = false
                currentValue *= power
                currentValue += val
            }
            else if c == "." {
                wasColon = false
                if hasHex {
                    return nil
                }
                if (currentLength == 0) {
                    // Part had no digits.
                    return nil
                }
                if !parsingQuad {
                    var newV: UInt32 = 0
                    // Convert hex to dec
                    if currentValue > 0x100 {
                        newV += ((currentValue & 0xF00) >> 8) * 100
                    }
                    if currentValue > 0x10 {
                        newV += ((currentValue & 0xF0) >> 4) * 10
                    }
                    newV += currentValue & 0xF
                    currentValue = newV
                    power = 10
                }
                if (currentValue > 255) {
                    // Part was too long.
                    return nil
                }
                parsingQuad = true
                hasHex = false
                
                ipv4 |= currentValue << ipv4Shift
                currentValue = 0
                ipv4Shift += 8
                if (ipv4Shift > 24) {
                    // Encountered too many points.
                    return nil
                }
                currentLength = 0
            }
            else if c == ":" {
                if wasColon == true {
                    if zeroRunIndex >= 0 {
                        return nil
                    }
                    zeroRunIndex = Int(segment)
                    continue
                }
                if parsingQuad {
                    return nil
                }
                wasColon = true
                hasHex = false
                
                if (zeroRunIndex == -1) {
                    let shift: UInt64 = (segment & 0b11) << 4
                    // Same as dividing by 4.
                    if segment >> 2 == 0 {
                        hi |= UInt64(UInt16(currentValue).bigEndian) << shift
                    } else {
                        lo |= UInt64(UInt16(currentValue).bigEndian) << shift
                    }
                    segment += 1
                } else {
                    segments.append(UInt16(currentValue).bigEndian)
                }
                currentValue = 0
                currentLength = 0
            } else {
                break
            }
        }
        if (parsingQuad) {
            if (ipv4Shift != 24) {
                // Not enough parts.
                return nil
            }
            if (currentLength == 0) {
                // No final part.
                return nil
            }
            if (currentValue > 255) {
                // Part was too long.
                return nil
            }
            ipv4 |= currentValue << 24
            
            if (zeroRunIndex == -1) {
                segment += 2
                lo |= UInt64(ipv4 & 0xFFFF_FFFF) << 32
            } else {
                segments.append(UInt16(ipv4 & 0xFFFF))
                segments.append(UInt16((ipv4 & 0xFFFF_0000) >> 16))
            }
            currentValue = 0
            currentLength = 0
        }

        if (!parsingQuad && zeroRunIndex == -1) {
            let shift: UInt64 = (segment & 0b11) << 4
            // Same as dividing by 4.
            if segment >> 2 == 0 {
                hi |= UInt64(UInt16(currentValue).bigEndian) << shift
            } else {
                lo |= UInt64(UInt16(currentValue).bigEndian) << shift
            }
            segment += 1
        } else if currentLength > 0 || segments.count > 0 {
            if currentLength > 0 {
                segments.append(UInt16(currentValue).bigEndian)
            }
            if Int(segment) + segments.count > 8 {
                return nil
            }
            while (Int(segment) < 8 - segments.count) {
                segment += 1
            }
            for val in segments {
                let shift: UInt64 = (segment & 0b11) << 4
                // Same as dividing by 4.
                if segment >> 2 == 0 {
                    hi |= UInt64(val) << shift
                } else {
                    lo |= UInt64(val) << shift
                }
                segment += 1
            }
        } else if Int(segment) == zeroRunIndex {
            segment = 8
        }
        
        
        if segment > 8 {
            return nil
        } else if segment < 8 {
            return nil
        }
        
        high = hi
        low = lo
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
    
    /// Returns `true` if the IP address is a global unicast address **(2000::/3)**.
    public var isUnicastGlobal: Bool {
        return (high & 0xE0) == 0x20
    }
    
    /// Returns `true` if the IP address is a unique local address **(fc00::/7)**.
    public var isUnicastUniqueLocal: Bool {
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
    
    /// Returns `true` if the IP address is a multicast address **(ff00::/8)**.
    public var isMulticast: Bool {
        return (high & 0xFF) == 0xFF
    }
    
    /// Returns `true` if the IP address is in the range reserved for use in documentation.
    public var isDocumentation: Bool {
        return (high & 0xFFFF_FFFF) == 0xb80d_0120
    }
    
    /// Returns a string representation of the IP address. Will display IPv4 compatible/mapped addresses
    /// correctly, and will truncate zeroes when possible.
    public var description: String {
        var segment: UInt64 = 0
        var outputSegs: [String] = [""]
        
        var isZeroRun = false
        var zeroRunLength = 0
        var longestZeroRun = -1
        var currentOutputSeg = 0
        var longestZeroRunLength = 0
        
        // First 64 bits are 0.
        if high == 0 {
            // These cases need special handlers to prevent them from being presented as IPv4 compatible.
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
            
            // Skip the first 4 segments.
            isZeroRun = true
            zeroRunLength = 4
            longestZeroRun = 0
            longestZeroRunLength = 4
            segment = 4
        }
        
        while segment < 8 {
            // Calculate which 16-bit word we should be handling. (x & 0b11) << 4, is equivalent to
            // (x % 4) * 16.
            let shift: UInt64 = (segment & 0b11) << 4
            let word: UInt64
            // Same as dividing by 4.
            if segment >> 2 == 0 {
                word = (high >> shift) & 0xFFFF
            } else {
                word = (low >> shift) & 0xFFFF
            }
            
            let isZero = (word == 0)
            
            if segment == 0 && isZero {
                // isZeroRun will be misconfigured if the first segment is a zero, so let's fix that.
                isZeroRun = true
            } else if segment != 0 && isZero != isZeroRun {
                // Add logic for when a run of zeroes ends/begins.
                currentOutputSeg += 1
                outputSegs.append("")
                zeroRunLength = 0
                isZeroRun = isZero
            }
            
            if (isZero) {
                zeroRunLength += 1
                if zeroRunLength > longestZeroRunLength {
                    longestZeroRunLength = zeroRunLength
                    longestZeroRun = currentOutputSeg
                }
                outputSegs[currentOutputSeg] += "0"
            } else {
                let lo = (word >> 8) & 0xFF
                let hi = word & 0xFF
                outputSegs[currentOutputSeg] += String(lo | (hi << 8), radix: 16, uppercase: false)
            }
            
            segment += 1
            // The ':' character should only be used in-between segments, not at the end of the entire
            // address.
            if (segment != 8) {
                outputSegs[currentOutputSeg] += ":"
            }
        }
        
        var out = ""
        // Special handling for when the first output segment is the longest zero run.
        if (longestZeroRun == 0) && (longestZeroRunLength > 1) {
            out = ":"
        }
        for i in 0..<outputSegs.count {
            if (longestZeroRun == i) && (longestZeroRunLength > 1) {
                out += ":"
            } else {
                out += outputSegs[i]
            }
        }
        return out
    }
    
    /// Returns a quad of 32-bit unsigned ints representing the IP address.
    public var words: (UInt32, UInt32, UInt32, UInt32) {
        return (UInt32(high & 0xFFFFFFFF), UInt32((high & 0xFFFFFFFF_00000000) >> 32),
                UInt32(low & 0xFFFFFFFF), UInt32((low & 0xFFFFFFFF_00000000) >> 32))
    }
    
    /// Returns an array of octets representing the parts of the IP address.
    public var octets: [UInt8] {
        return [UInt8(high & 0xFF), UInt8((high >> 8) & 0xFF),
                UInt8((high >> 16) & 0xFF), UInt8((high >> 24) & 0xFF),
                UInt8((high >> 32) & 0xFF), UInt8((high >> 40) & 0xFF),
                UInt8((high >> 48) & 0xFF), UInt8(high >> 56),
                UInt8(low & 0xFF), UInt8((low >> 8) & 0xFF),
                UInt8((low >> 16) & 0xFF), UInt8((low >> 24) & 0xFF),
                UInt8((low >> 32) & 0xFF), UInt8((low >> 40) & 0xFF),
                UInt8((low >> 48) & 0xFF), UInt8(low >> 56)]
    }
    
    /// Returns an unspecified IP address.
    public static var any: IPv6Address {
        struct Static {
            static let anyAddress = IPv6Address.init()
        }
        return Static.anyAddress
    }
    
    /// Returns a representation of the IPv6 loopback address **::1**.
    public static var loopback: IPv6Address {
        struct Static {
            static let loopbackAddress = IPv6Address.init(parts: 0, 0, 0, 0, 0, 0, 0, 1)
        }
        return Static.loopbackAddress
    }
}
