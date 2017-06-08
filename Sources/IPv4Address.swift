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

/// Represents an IP version 4 address.
///
/// Immutable and space efficient.
///
/// - Author: Andrew Dunn.
///
public struct IPv4Address: LosslessStringConvertible, Equatable {
    // Store the value in an array to enable simple typecasting to an array of
    // [UInt8] values.
    fileprivate let value: UInt32;
    
    /// Initialises a new instance with all zeroes.
    public init () {
        value = 0
    }
    
    /// Initialises a new instance with the given values.
    ///
    /// - Parameters:
    ///   - a: The *first* component of the IP address.
    ///   - b: The *second* component of the IP address.
    ///   - c: The *third* component of the IP address.
    ///   - d: The *fourth & final* component of the IP address.
    public init (parts a: UInt8, _ b: UInt8, _ c: UInt8, _ d: UInt8) {
        value = UInt32(a) | UInt32(b) << 8 | UInt32(c) << 16 | UInt32(d) << 24
    }
    
    /// Initialises a new instance with an array of octets.
    ///
    /// - Parameter array: An array of octets that make up the parts of an IP
    ///                    address.
    ///
    /// - Note: If the number of elements in the array is not equal to *4*,
    ///         the behaviour is undefined.
    public init (fromOctets array: [UInt8]) {
        assert(array.count == 4)
        value = array.withUnsafeBytes({ (p) -> UInt32 in
            return p.load(as: UInt32.self)
        })
    }
    
    /// Intialises a new instance with an integer representation of an IP
    /// address in network-byte order.
    ///
    /// - Parameter uint: An integer representation of an IP address in
    ///                   network-byte order.
    public init (fromUInt32 uint: UInt32) {
        value = uint
    }
    
    /// Intialises a new instance from a string representaion of an IPv4
    /// address.
    ///
    /// - Parameter str: A string representation of an IPv4 address. If the
    ///                  string is anything other than an IPv4 address, `nil`
    ///                  will be returned instead.
    public init? (_ str: String) {
        var shiftedDistance = UInt32(0)
        var currentValue = UInt32(0)
        var currentLength = 0
        var rawValue = UInt32(0)
        let zero = UnicodeScalar("0")!
        let nine = UnicodeScalar("9")!
        let dot = UnicodeScalar(".")!
        for c in str.unicodeScalars {
            // Handle digits.
            if c >= zero && c <= nine {
                currentValue *= 10
                currentLength += 1
                if (currentLength > 3) {
                    // Part was too long.
                    return nil
                }
                currentValue += c.value - zero.value
            } else if c == dot {
                if (currentLength == 0) {
                    // Part had no digits.
                    return nil
                }
                currentLength = 0
                if (currentValue > 255) {
                    // Part was too long.
                    return nil
                }
                rawValue |= currentValue << shiftedDistance
                currentValue = 0
                shiftedDistance += 8
                if (shiftedDistance > 24) {
                    // Encountered too many points.
                    return nil
                }
            } else {
                // Unexpected character.
                return nil
            }
        }
        if (shiftedDistance != 24) {
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
        rawValue |= currentValue << 24
        value = rawValue
    }
    
    /// Returns an array of octets representing the parts of the IP address.
    public var octets: [UInt8] {
        return [UInt8(value & 0x000000FF),
                UInt8((value & 0x0000FF00) >> 8),
                UInt8((value & 0x00FF0000) >> 16),
                UInt8((value & 0xFF000000) >> 24)]
    }
    
    /// Returns `true` if the IP address is an unspecified, if you listen on
    /// this address, your socket will listen on all addresses available.
    ///
    /// - Note: Equivalent to checking if the IP address is equal to
    ///         **0.0.0.0**.
    public var isUnspecified: Bool {
        return UInt32(fromIPv4Address: self) == 0
    }
    
    /// Returns `true` if the IP address is a loopback address.
    ///
    /// - Note: Equivalent to checking if the IP address is in the subnet
    ///         **127.0.0.0/8**.
    public var isLoopback: Bool {
        return (UInt32(fromIPv4Address: self) & 0x000000FF) == 0x0000007F
    }
    
    /// Returns `true` if the IP address is in one of the ranges reserved for
    /// private use. These addresses are not globally routable.
    ///
    /// - Note: The address ranges reserved for private use are as follows:
    ///     - **192.168.0.0/16** (65,536 IP addresses)
    ///     - **172.16.0.0/12** (1,048,576 IP addresses)
    ///     - **10.0.0.0/8** (16,777,216 IP addresses)
    public var isPrivate: Bool {
        let uint = UInt32(fromIPv4Address: self)
        return (uint & 0x000000FF) == 0x0000000A ||
            (uint & 0x0000F0FF) == 0x000010AC ||
            (uint & 0x0000FFFF) == 0x0000A8C0
    }
    
    /// Returns `true` if the IP address is a link-local address.
    ///
    /// - Note: The address block reserved for link-local addresses is
    ///         **169.254.0.0/16**.
    public var isLinkLocal: Bool {
        return (UInt32(fromIPv4Address: self) & 0x0000FFFF) == 0x0000FEA9
    }
    
    /// Returns `true` if the IP address is globally-routable.
    public var isGlobal: Bool {
        let uint = UInt32(fromIPv4Address: self)
        // Private Addresses
        return !((uint & 0x000000FF) == 0x0000000A ||
            (uint & 0x0000F0FF) == 0x000010AC ||
            (uint & 0x0000FFFF) == 0x0000A8C0 ||
            // Loopback Address
            (uint & 0x000000FF) == 0x0000007F ||
            // Link-Local Address
            (uint & 0x0000FFFF) == 0x0000FEA9 ||
            // Broadcast Address
            uint == 0xFFFFFFFF ||
            // Documentation Addresses
            (uint & 0x00FFFFFF) == 0x000200C0 ||
            (uint & 0x00FFFFFF) == 0x006433C6 ||
            (uint & 0x00FFFFFF) == 0x007100CB)
    }
    
    /// Returns true if IP address is a multicast address.
    public var isMulticast: Bool {
        return value & 0x000000F0 == 0x000000E0
    }
    
    /// Returns true if the IP address is a broadcast address.
    public var isBroadcast: Bool {
        return UInt32(fromIPv4Address: self) == 0xFFFFFFFF
    }
    
    /// Returns true if the IP address is in a block reserved for the purposes
    /// of having example IP addresses in written documentation.
    public var isDocumentation: Bool {
        let uint = UInt32(fromIPv4Address: self)
        return (uint & 0x00FFFFFF) == 0x000200C0 ||
            (uint & 0x00FFFFFF) == 0x006433C6 ||
            (uint & 0x00FFFFFF) == 0x007100CB
    }
    
    /// Returns a string representation of the IP address.
    public var description: String {
        let o = octets
        return "\(o[0]).\(o[1]).\(o[2]).\(o[3])"
    }
    
    /// Returns an unspecified IP address.
    public static var any: IPv4Address {
        struct Static {
            static let anyAddress = IPv4Address.init()
        }
        return Static.anyAddress
    }
    
    /// Returns a representation of the IPv4 loopback address **127.0.0.1**.
    public static var loopback: IPv4Address {
        struct Static {
            static let loopbackAddress =
                IPv4Address.init(fromUInt32: 0x0100007F)
        }
        return Static.loopbackAddress
    }
    
    /// Returns a representation of the IPv4 broadcast address
    /// **255.255.255.255**.
    public static var broadcast: IPv4Address {
        struct Static {
            static let broadcastAddress =
                IPv4Address.init(fromUInt32: 0xFFFFFFFF)
        }
        return Static.broadcastAddress
    }
    
    /// Returns a Boolean value indicating whether IP addresses are equal.
    public static func == (lhs: IPv4Address, rhs: IPv4Address) -> Bool {
        return lhs.value == rhs.value
    }
}

/// Extracts an integer representation of the given IPv4 address in network-byte
/// order.
public extension UInt32 {
    public init (fromIPv4Address ip: IPv4Address) {
        self = ip.value
    }
}
