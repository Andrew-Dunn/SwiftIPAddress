# SwiftIPAddress

SwiftIPAddress is a library for parsing and presenting IP addresses using Apple's Swift
programming language. Not only does it present an idiomatic API that would feel familiar 
to developers, it is blazing fast, outperforming the Operating System standard libraries,
and it is also extremely well tested.

## Design Goals

There goals that guide this package's development are as follows:

### The main types must be implemented in pure Swift code.

This project is implemented in pure Swift both as an academic exercise, as well as a
constraint. It would be very easy to wrap the `inet_ntop` and `inet_pton` methods, however
that would have both limited the compiler's ability to inline code, as well as prevented
interoperability with future targets available to Swift.

### The main types must use no more memory than required to represent their values.

In an age where memory is the most constricting resource in cloud deployments, it was
extremely important to me to use no more memory than absolutely necessary for the
internal representations. `IPv4Address` is represented internally with 4 bytes, and
`IPv6Address` uses 16-bytes. They are also both value types, avoiding the need for any
memory management.

### The library must be goddamn fast.

This library currently exceeds the performance of the Operating System libraries quite
handily when called from Swift. This is owing to the pure Swift implementation,
eliminating the need to convert to and from C-friendly data structures, as well as the
possibility for more aggressive inlining. This library proves that Swift code can be very
performant, even outperforming the native C functions.

## Installation

SwiftIPAddress is installed using the Swift Package Manager. It is compatible with
projects using Swift 3.0 and later. To use it in your project, simply add the following
line to your package's dependencies:

```swift
dependencies: [
    .Package(url: "https://github.com/Andrew-Dunn/SwiftIPAddress.git",
                  "1.0.1"),
]
```

It may then be used directly by importing the `IPAddress` package at the start of your
sources files.

```swift
import IPAddress

let ip = IPv6Address("2b88:b6::14")
```

## API

### `IPv4Address`

The `IPv4Address` type is an immutable data structure that represents an IPv4 address.

### `IPv6Address`

The `IPv6Address` type is an immutable data structure that represents an IPv6 address.

## License

Copyright © Andrew Dunn, 2017

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at: http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
