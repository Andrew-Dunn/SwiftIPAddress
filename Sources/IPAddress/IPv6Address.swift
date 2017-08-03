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
    public init?(_ description: String) {
        high = 0
        low = 0
    }
    
    public static func ==(lhs: IPv6Address, rhs: IPv6Address) -> Bool {
        return  lhs.high == rhs.high && lhs.low == rhs.low
    }
    
    public var description: String = "::0"
    
    fileprivate let low, high: UInt64
    
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
}

