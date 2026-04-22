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

fileprivate let zero = UnicodeScalar("0")
fileprivate let nine = UnicodeScalar("9")
fileprivate let dot = UnicodeScalar(".")

// Use lookup tables to massively improve the performance of converting IP addresses to strings.
fileprivate let firstQuad = [  "0",  "1",  "2",  "3",  "4",  "5",  "6",  "7",  "8",  "9",
                              "10", "11", "12", "13", "14", "15", "16", "17", "18", "19",
                              "20", "21", "22", "23", "24", "25", "26", "27", "28", "29",
                              "30", "31", "32", "33", "34", "35", "36", "37", "38", "39",
                              "40", "41", "42", "43", "44", "45", "46", "47", "48", "49",
                              "50", "51", "52", "53", "54", "55", "56", "57", "58", "59",
                              "60", "61", "62", "63", "64", "65", "66", "67", "68", "69",
                              "70", "71", "72", "73", "74", "75", "76", "77", "78", "79",
                              "80", "81", "82", "83", "84", "85", "86", "87", "88", "89",
                              "90", "91", "92", "93", "94", "95", "96", "97", "98", "99",
                             "100","101","102","103","104","105","106","107","108","109",
                             "110","111","112","113","114","115","116","117","118","119",
                             "120","121","122","123","124","125","126","127","128","129",
                             "130","131","132","133","134","135","136","137","138","139",
                             "140","141","142","143","144","145","146","147","148","149",
                             "150","151","152","153","154","155","156","157","158","159",
                             "160","161","162","163","164","165","166","167","168","169",
                             "170","171","172","173","174","175","176","177","178","179",
                             "180","181","182","183","184","185","186","187","188","189",
                             "190","191","192","193","194","195","196","197","198","199",
                             "200","201","202","203","204","205","206","207","208","209",
                             "210","211","212","213","214","215","216","217","218","219",
                             "220","221","222","223","224","225","226","227","228","229",
                             "230","231","232","233","234","235","236","237","238","239",
                             "240","241","242","243","244","245","246","247","248","249",
                             "250","251","252","253","254","255"]
fileprivate let latterQuads = [  ".0",  ".1",  ".2",  ".3",  ".4",  ".5",  ".6",  ".7",  ".8",  ".9",
                                ".10", ".11", ".12", ".13", ".14", ".15", ".16", ".17", ".18", ".19",
                                ".20", ".21", ".22", ".23", ".24", ".25", ".26", ".27", ".28", ".29",
                                ".30", ".31", ".32", ".33", ".34", ".35", ".36", ".37", ".38", ".39",
                                ".40", ".41", ".42", ".43", ".44", ".45", ".46", ".47", ".48", ".49",
                                ".50", ".51", ".52", ".53", ".54", ".55", ".56", ".57", ".58", ".59",
                                ".60", ".61", ".62", ".63", ".64", ".65", ".66", ".67", ".68", ".69",
                                ".70", ".71", ".72", ".73", ".74", ".75", ".76", ".77", ".78", ".79",
                                ".80", ".81", ".82", ".83", ".84", ".85", ".86", ".87", ".88", ".89",
                                ".90", ".91", ".92", ".93", ".94", ".95", ".96", ".97", ".98", ".99",
                               ".100",".101",".102",".103",".104",".105",".106",".107",".108",".109",
                               ".110",".111",".112",".113",".114",".115",".116",".117",".118",".119",
                               ".120",".121",".122",".123",".124",".125",".126",".127",".128",".129",
                               ".130",".131",".132",".133",".134",".135",".136",".137",".138",".139",
                               ".140",".141",".142",".143",".144",".145",".146",".147",".148",".149",
                               ".150",".151",".152",".153",".154",".155",".156",".157",".158",".159",
                               ".160",".161",".162",".163",".164",".165",".166",".167",".168",".169",
                               ".170",".171",".172",".173",".174",".175",".176",".177",".178",".179",
                               ".180",".181",".182",".183",".184",".185",".186",".187",".188",".189",
                               ".190",".191",".192",".193",".194",".195",".196",".197",".198",".199",
                               ".200",".201",".202",".203",".204",".205",".206",".207",".208",".209",
                               ".210",".211",".212",".213",".214",".215",".216",".217",".218",".219",
                               ".220",".221",".222",".223",".224",".225",".226",".227",".228",".229",
                               ".230",".231",".232",".233",".234",".235",".236",".237",".238",".239",
                               ".240",".241",".242",".243",".244",".245",".246",".247",".248",".249",
                               ".250",".251",".252",".253",".254",".255"
                              ]

/// Represents an IP version 4 address.
///
/// Immutable and space efficient.
///
/// - Author: Andrew Dunn.
///
public struct IPv4Address: LosslessStringConvertible, Hashable {
    // Store the value in an array to enable simple typecasting to an array of
    // [UInt8] values.
    fileprivate let value: UInt32
    
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
    /// - Parameter octets: An array of octets that make up the parts of an IP
    ///                     address.
    ///
    /// - Note: If the number of elements in the array is not equal to *4*,
    ///         the behaviour is undefined.
    public init(_ octets: [UInt8]) {
        assert(octets.count == 4)
        value = octets.withUnsafeBytes({ (p) -> UInt32 in
            return p.load(as: UInt32.self)
        })
    }

    /// Initialises a new instance with an integer representation of an IP
    /// address in network-byte order.
    ///
    /// - Parameter uint: An integer representation of an IP address in
    ///                   network-byte order.
    public init(_ uint: UInt32) {
        value = uint
    }

    /// Initialises a new instance from a string representation of an IPv4
    /// address.
    ///
    /// - Parameter str: A string representation of an IPv4 address. If the
    ///                  string is anything other than an IPv4 address, `nil`
    ///                  will be returned instead.
    public init?(_ str: String) {
        var shiftedDistance = UInt32(0)
        var currentValue = UInt32(0)
        var currentLength = 0
        var rawValue = UInt32(0)
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
        return [UInt8(value & 0xFF),
                UInt8((value >> 8) & 0xFF),
                UInt8((value >> 16) & 0xFF),
                UInt8(value >> 24)]
    }
    
    /// Returns `true` if the IP address is an unspecified, if you listen on
    /// this address, your socket will listen on all addresses available.
    ///
    /// - Note: Equivalent to checking if the IP address is equal to
    ///         **0.0.0.0**.
    public var isUnspecified: Bool {
        return value == 0
    }
    
    /// Returns `true` if the IP address is a loopback address.
    ///
    /// - Note: Equivalent to checking if the IP address is in the subnet
    ///         **127.0.0.0/8**.
    public var isLoopback: Bool {
        return (value & 0x000000FF) == 0x0000007F
    }
    
    /// Returns `true` if the IP address is in one of the ranges reserved for
    /// private use. These addresses are not globally routable.
    ///
    /// - Note: The address ranges reserved for private use are as follows:
    ///     - **192.168.0.0/16** (65,536 IP addresses)
    ///     - **172.16.0.0/12** (1,048,576 IP addresses)
    ///     - **10.0.0.0/8** (16,777,216 IP addresses)
    public var isPrivate: Bool {
        return (value & 0x000000FF) == 0x0000000A ||
            (value & 0x0000F0FF) == 0x000010AC ||
            (value & 0x0000FFFF) == 0x0000A8C0
    }
    
    /// Returns `true` if the IP address is a link-local address.
    ///
    /// - Note: The address block reserved for link-local addresses is
    ///         **169.254.0.0/16**.
    public var isLinkLocal: Bool {
        return (value & 0x0000FFFF) == 0x0000FEA9
    }
    
    /// Returns `true` if the IP address is globally-routable.
    public var isGlobal: Bool {
        return !(
            // Unspecified Address
            value == 0x00000000 ||
            // Private Addresses
            (value & 0x000000FF) == 0x0000000A ||
            (value & 0x0000F0FF) == 0x000010AC ||
            (value & 0x0000FFFF) == 0x0000A8C0 ||
            // Loopback Address
            (value & 0x000000FF) == 0x0000007F ||
            // Link-Local Address
            (value & 0x0000FFFF) == 0x0000FEA9 ||
            // Broadcast Address
            value == 0xFFFFFFFF ||
            // Documentation Addresses
            (value & 0x00FFFFFF) == 0x000200C0 ||
            (value & 0x00FFFFFF) == 0x006433C6 ||
            (value & 0x00FFFFFF) == 0x007100CB
        )
    }
    
    /// Returns true if IP address is a multicast address.
    public var isMulticast: Bool {
        return value & 0x000000F0 == 0x000000E0
    }
    
    /// Returns true if the IP address is a broadcast address.
    public var isBroadcast: Bool {
        return value == 0xFFFFFFFF
    }

    /// Returns true if the IP address is in a block reserved for the purposes
    /// of having example IP addresses in written documentation.
    public var isDocumentation: Bool {
        return (value & 0x00FFFFFF) == 0x000200C0 ||
            (value & 0x00FFFFFF) == 0x006433C6 ||
            (value & 0x00FFFFFF) == 0x007100CB
    }

    /// Returns true if the IP address is included in the given CIDR range.
    ///
    /// - Parameter cidr: The CIDR range to test membership in.
    /// - Returns: True if the IP address is within the range, false otherwise.
    public func isIncluded(in cidr: IPv4CIDR) -> Bool {
        return (value & cidr.mask) == cidr.maskedNetwork
    }

    /// Returns true if the IP address is included in the given CIDR range.
    ///
    /// - Parameter range: A string representation of a CIDR range (e.g., "192.168.0.0/16").
    /// - Returns: True if the IP address is within the range, false otherwise.
    public func isIncluded(in range: String) -> Bool {
        guard let cidr = IPv4CIDR(range) else { return false }
        return isIncluded(in: cidr)
    }
    
    // MARK: - Deprecated API

    @available(*, deprecated, renamed: "init(_:)")
    public init(fromOctets octets: [UInt8]) { self.init(octets) }

    @available(*, deprecated, renamed: "init(_:)")
    public init(fromUInt32 uint: UInt32) { self.init(uint) }

    // MARK: -

    /// Returns a string representation of the IP address.
    public var description: String {
        let o0 = Int(value & 0xFF)
        let o1 = Int((value >> 8) & 0xFF)
        let o2 = Int((value >> 16) & 0xFF)
        let o3 = Int(value >> 24)
        var out = firstQuad[o0]
        out.append(latterQuads[o1])
        out.append(latterQuads[o2])
        out.append(latterQuads[o3])
        return out
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
                IPv4Address(0x0100007F)
        }
        return Static.loopbackAddress
    }
    
    /// Returns a representation of the IPv4 broadcast address
    /// **255.255.255.255**.
    public static var broadcast: IPv4Address {
        struct Static {
            static let broadcastAddress =
                IPv4Address(0xFFFFFFFF)
        }
        return Static.broadcastAddress
    }
    
    /// Returns a Boolean value indicating whether IP addresses are equal.
    public static func == (lhs: IPv4Address, rhs: IPv4Address) -> Bool {
        return lhs.value == rhs.value
    }
}

/// Represents an IPv4 CIDR range.
///
/// Pre-computes the mask and masked network address at construction time so
/// membership tests (`IPv4Address.isIncluded(in:)`) are a single bitmask-and-compare
/// with no parsing or allocation.
public struct IPv4CIDR: Hashable {
    // Stored in the same little-endian layout as IPv4Address.value.
    fileprivate let maskedNetwork: UInt32
    fileprivate let mask: UInt32

    /// Initialises a new instance from a network address and prefix length.
    ///
    /// - Parameters:
    ///   - network: The network address (host bits are ignored).
    ///   - prefix: The prefix length (0–32). Returns `nil` if out of range.
    public init?(network: IPv4Address, prefix: UInt32) {
        guard prefix <= 32 else { return nil }
        // Build the mask in network byte order then byte-swap to match the
        // little-endian internal representation.
        let mask: UInt32 = prefix == 0 ? 0 : (UInt32.max << (32 - prefix)).byteSwapped
        self.mask = mask
        self.maskedNetwork = network.value & mask
    }

    /// Initialises a new instance from a CIDR string (e.g. "192.168.0.0/16").
    /// Returns `nil` if the string is not a valid CIDR range.
    public init?(_ description: String) {
        let components = description.split(separator: "/")
        guard components.count == 2,
              let network = IPv4Address(String(components[0])),
              let prefix = UInt32(components[1]) else { return nil }
        self.init(network: network, prefix: prefix)
    }
}

/// Extracts an integer representation of the given IPv4 address in network-byte
/// order.
public extension UInt32 {
    init(_ ip: IPv4Address) {
        self = ip.value
    }

    @available(*, deprecated, renamed: "init(_:)")
    init(fromIPv4Address ip: IPv4Address) { self.init(ip) }
}
