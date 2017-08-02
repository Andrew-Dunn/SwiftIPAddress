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

import Darwin
import Foundation

let ipCount = 1_000_000
let ipAddressStrings = Utils.randomIPAddressStrings(count: ipCount)
let ipAddresses = Utils.randomIPv4s(count: ipCount)
var timeBaseInfo = mach_timebase_info_data_t()
mach_timebase_info(&timeBaseInfo)

print("=====================================")
print("SwiftIPAddress Performance Benchmarks")
print("=====================================")
print("+---------------------------------+")
print("| IPv4 Dotted Quad Parsing        |")
print("+-------------------+-------------+")

var t1 = mach_absolute_time()
for ipString in ipAddressStrings {
    let result = Utils.swiftDecodeIPAddress(ipString: ipString)
    if result == nil {
        print("| SwiftIPAddress    |       ERROR |")
        print("+-------------------+-------------+")
        exit(1)
    }
}
var t2 = mach_absolute_time()

var elapsed = t2 - t1
var elapsedNano = Double(elapsed) * Double(timeBaseInfo.numer) / Double(timeBaseInfo.denom);
let nanosInASecond = 1_000_000_000.0
var elapsedSeconds = elapsedNano / nanosInASecond
print(String(format: "| SwiftIPAddress    | %9f s |", elapsedNano / nanosInASecond))
print("+-------------------+-------------+")

t1 = mach_absolute_time()
for ipString in ipAddressStrings {
    let result = Utils.atonDecodeIPAddress(ipString: ipString)
    if result == nil {
        print("| inet_aton (Swift) |       ERROR |")
        print("+-------------------+-------------+")
        exit(1)
    }
}
t2 = mach_absolute_time()

elapsed = t2 - t1
elapsedNano = Double(elapsed) * Double(timeBaseInfo.numer) / Double(timeBaseInfo.denom);
elapsedSeconds = elapsedNano / nanosInASecond
print(String(format: "| inet_aton (Swift) | %9f s |", elapsedNano / nanosInASecond))
print("+-------------------+-------------+")

t1 = mach_absolute_time()
for ipString in ipAddressStrings {
    let result = Utils.ptonDecodeIPAddress(ipString: ipString)
    if result == nil {
        print("| inet_pton (Swift) |       ERROR |")
        print("+-------------------+-------------+")
        exit(1)
    }
}
t2 = mach_absolute_time()
elapsed = t2 - t1
elapsedNano = Double(elapsed) * Double(timeBaseInfo.numer) / Double(timeBaseInfo.denom);
elapsedSeconds = elapsedNano / nanosInASecond
print(String(format: "| inet_pton (Swift) | %9f s |", elapsedNano / nanosInASecond))

print("+-------------------+-------------+\n")


print("+---------------------------------+")
print("| IPv4 Dotted Quad Presentation   |")
print("+-------------------+-------------+")

t1 = mach_absolute_time()
for ip in ipAddresses {
    let result = ip.description
    if result.isEmpty {
        print("| SwiftIPAddress    |       ERROR |")
        print("+-------------------+-------------+")
        exit(1)
    }
}
t2 = mach_absolute_time()
elapsed = t2 - t1
elapsedNano = Double(elapsed) * Double(timeBaseInfo.numer) / Double(timeBaseInfo.denom);
elapsedSeconds = elapsedNano / nanosInASecond
print(String(format: "| SwiftIPAddress    | %9f s |", elapsedNano / nanosInASecond))
print("+-------------------+-------------+")

t1 = mach_absolute_time()
for ip in ipAddresses {
    let result = Utils.ntoaEncodeIPAddress(ip: ip)
    if result.isEmpty {
        print("| inet_ntoa (Swift) |       ERROR |")
        print("+-------------------+-------------+")
        exit(1)
    }
}
t2 = mach_absolute_time()
elapsed = t2 - t1
elapsedNano = Double(elapsed) * Double(timeBaseInfo.numer) / Double(timeBaseInfo.denom);
elapsedSeconds = elapsedNano / nanosInASecond
print(String(format: "| inet_ntoa (Swift) | %9f s |", elapsedNano / nanosInASecond))
print("+-------------------+-------------+")

t1 = mach_absolute_time()
for ip in ipAddresses {
    let result = Utils.ntopEncodeIPAddress(ip: ip)
    if result.isEmpty {
        print("| inet_ntop (Swift) |       ERROR |")
        print("+-------------------+-------------+")
        exit(1)
    }
}
t2 = mach_absolute_time()
elapsed = t2 - t1
elapsedNano = Double(elapsed) * Double(timeBaseInfo.numer) / Double(timeBaseInfo.denom);
elapsedSeconds = elapsedNano / nanosInASecond
print(String(format: "| inet_ntop (Swift) | %9f s |", elapsedNano / nanosInASecond))
print("+-------------------+-------------+")
