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

import Foundation

let ipCount = 1_000_000
let doubleCount = Double(ipCount)
let ipv4AddressStrings = Utils.randomIPv4Strings(count: ipCount)
let ipv4Addresses = Utils.randomIPv4s(count: ipCount)
let ipv6AddressStrings = Utils.randomIPv6Strings(count: ipCount)
let ipv6Addresses = Utils.randomIPv6s(count: ipCount)
var timer = HighResolutionTimer()

print("=====================================")
print("SwiftIPAddress Performance Benchmarks")
print("=====================================\n")
print("IPv4 Dotted Quad Parsing")
print("Method,IPv4 addresses per second")

timer.mark()
for ipString in ipv4AddressStrings {
    let result = Utils.swiftDecodeIPv4Address(ipString: ipString)
    if result == nil {
        print("SwiftIPAddress,ERROR")
        exit(1)
    }
}
var elapsedSeconds = timer.check()
print("SwiftIPAddress,\( doubleCount / elapsedSeconds)")

timer.mark()
for ipString in ipv4AddressStrings {
    let result = Utils.atonDecodeIPv4Address(ipString: ipString)
    if result == nil {
        print("inet_aton (Swift),ERROR")
        exit(1)
    }
}
elapsedSeconds = timer.check()
print("inet_aton (Swift),\( doubleCount / elapsedSeconds)")

timer.mark()
for ipString in ipv4AddressStrings {
    let result = Utils.ptonDecodeIPv4Address(ipString: ipString)
    if result == nil {
        print("inet_pton (Swift),ERROR")
        exit(1)
    }
}
elapsedSeconds = timer.check()
print("inet_pton (Swift),\( doubleCount / elapsedSeconds)")


print("\nIPv4 Dotted Quad Presentation")
print("Method,IPv4 addresses per second")

timer.mark()
for ip in ipv4Addresses {
    let result = ip.description
    if result.isEmpty {
        print("SwiftIPAddress,ERROR")
        exit(1)
    }
}
elapsedSeconds = timer.check()
print("SwiftIPAddress,\( doubleCount / elapsedSeconds)")

timer.mark()
for ip in ipv4Addresses {
    let result = Utils.ntoaEncodeIPv4Address(ip: ip)
    if result.isEmpty {
        print("inet_ntoa (Swift),ERROR")
        exit(1)
    }
}
elapsedSeconds = timer.check()
print("inet_ntoa (Swift),\( doubleCount / elapsedSeconds)")

timer.mark()
for ip in ipv4Addresses {
    let result = Utils.ntopEncodeIPv4Address(ip: ip)
    if result.isEmpty {
        print("inet_ntop (Swift),ERROR")
        exit(1)
    }
}
elapsedSeconds = timer.check()
print("inet_ntop (Swift),\( doubleCount / elapsedSeconds)")

print("\nIPv6 Address Parsing")
print("Method,IPv6 addresses per second")

timer.mark()
for ipString in ipv6AddressStrings {
    let result = Utils.swiftDecodeIPv6Address(ipString: ipString)
    if result == nil {
        print("SwiftIPAddress,ERROR")
        exit(1)
    }
}
elapsedSeconds = timer.check()
print("SwiftIPAddress,\( doubleCount / elapsedSeconds)")

timer.mark()
for ipString in ipv6AddressStrings {
    let result = Utils.ptonDecodeIPv6Address(ipString: ipString)
    if result == nil {
        print("inet_pton (Swift),ERROR")
        exit(1)
    }
}
elapsedSeconds = timer.check()
print("inet_pton (Swift),\( doubleCount / elapsedSeconds)")


print("\nIPv6 Address Presentation")
print("Method,IPv6 addresses per second")

timer.mark()
for ip in ipv6Addresses {
    let result = ip.description
    if result.isEmpty {
        print("SwiftIPAddress,ERROR")
        exit(1)
    }
}
elapsedSeconds = timer.check()
print("SwiftIPAddress,\( doubleCount / elapsedSeconds)")

timer.mark()
for ip in ipv6Addresses {
    let result = Utils.ntopEncodeIPv6Address(ip: ip)
    if result.isEmpty {
        print("inet_ntop (Swift),ERROR")
        exit(1)
    }
}
elapsedSeconds = timer.check()
print("inet_ntop (Swift),\( doubleCount / elapsedSeconds)")
