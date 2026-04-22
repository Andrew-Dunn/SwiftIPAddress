# SwiftIPAddress

A small Swift library for parsing and formatting IPv4 and IPv6 addresses. It
aims to offer a familiar, idiomatic API with good performance on both Apple
and Linux Swift toolchains.

## Design goals

### Pure Swift

The core types are implemented in pure Swift rather than wrapping
`inet_ntop` / `inet_pton`. This gives the compiler more room to inline hot
paths and keeps the library portable across every platform Swift supports.

### Compact representation

Address values are stored in their minimum natural width: `IPv4Address`
holds four bytes and `IPv6Address` holds sixteen. Both are `struct` value
types with no heap allocation, which keeps per-address overhead predictable
in memory-sensitive environments.

### Good performance

Parsing and formatting are designed to avoid per-call allocation and to
lean on simple bit-twiddling rather than format-string plumbing. In our
benchmarks the pure-Swift implementation is competitive with — and often
faster than — the libc helpers called from Swift, largely because it
skips the Swift/C marshalling that wrapping `inet_ntop` / `inet_pton`
would require. Your mileage will vary; the benchmark target
(`IPAddressBenchmarks`) is included if you want to measure for yourself.

## Installation

Add the package as a Swift Package Manager dependency:

```swift
dependencies: [
    .package(url: "https://github.com/Andrew-Dunn/SwiftIPAddress.git",
             from: "1.0.1"),
]
```

Then `import IPAddress` wherever you need it:

```swift
import IPAddress

let ip = IPv6Address("2b88:b6::14")
```

## API

### `IPv4Address`

An immutable, four-byte value representing an IPv4 address. Supports
parsing from a dotted-quad string, construction from octets or a
`UInt32`, and predicates for the common classifications (`isLoopback`,
`isPrivate`, `isLinkLocal`, `isMulticast`, `isBroadcast`,
`isDocumentation`, `isGlobal`).

### `IPv6Address`

An immutable, sixteen-byte value representing an IPv6 address. Supports
the full RFC 5952 textual forms (including `::` compression and the
IPv4-mapped `::ffff:X.X.X.X` shorthand) and the corresponding
classification predicates.

### CIDR membership

`IPv4CIDR` and `IPv6CIDR` represent a network/prefix pair. Construction
pre-computes the masked network and mask, so `address.isIncluded(in:)`
is a single bitwise compare with no string work on the hot path:

```swift
let cidr = IPv4CIDR("10.0.0.0/8")!
IPv4Address("10.1.2.3")!.isIncluded(in: cidr)  // true
```

There is also a convenience overload that takes a CIDR string directly,
which is handy for one-shot checks but does the parse on every call.

## License

Copyright © Andrew Dunn, 2017

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at:
http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
