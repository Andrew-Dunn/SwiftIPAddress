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
let ipAddressStrings = Utils.randomIPAddressStrings(count: ipCount)
let ipAddresses = Utils.randomIPv4s(count: ipCount)
var timer = HighResolutionTimer()

print("=====================================")
print("SwiftIPAddress Performance Benchmarks")
print("=====================================\n")
print("IPv4 Dotted Quad Parsing")
print("Method,IPv4 addresses per second")

timer.mark()
for ipString in ipAddressStrings {
    let result = Utils.swiftDecodeIPAddress(ipString: ipString)
    if result == nil {
        print("SwiftIPAddress,ERROR")
        exit(1)
    }
}
var elapsedSeconds = timer.check()
print("SwiftIPAddress,\( doubleCount / elapsedSeconds)")

timer.mark()
for ipString in ipAddressStrings {
    let result = Utils.atonDecodeIPAddress(ipString: ipString)
    if result == nil {
        print("inet_aton (Swift),ERROR")
        exit(1)
    }
}
elapsedSeconds = timer.check()
print("inet_aton (Swift),\( doubleCount / elapsedSeconds)")

timer.mark()
for ipString in ipAddressStrings {
    let result = Utils.ptonDecodeIPAddress(ipString: ipString)
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
for ip in ipAddresses {
    let result = ip.description
    if result.isEmpty {
        print("SwiftIPAddress,ERROR")
        exit(1)
    }
}
elapsedSeconds = timer.check()
print("SwiftIPAddress,\( doubleCount / elapsedSeconds)")

timer.mark()
for ip in ipAddresses {
    let result = Utils.ntoaEncodeIPAddress(ip: ip)
    if result.isEmpty {
        print("inet_ntoa (Swift),ERROR")
        exit(1)
    }
}
elapsedSeconds = timer.check()
print("inet_ntoa (Swift),\( doubleCount / elapsedSeconds)")

timer.mark()
for ip in ipAddresses {
    let result = Utils.ntopEncodeIPAddress(ip: ip)
    if result.isEmpty {
        print("inet_ntop (Swift),ERROR")
        exit(1)
    }
}
elapsedSeconds = timer.check()
print("inet_ntop (Swift),\( doubleCount / elapsedSeconds)")
