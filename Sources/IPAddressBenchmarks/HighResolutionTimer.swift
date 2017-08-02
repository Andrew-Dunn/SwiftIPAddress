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

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

fileprivate let NANOSECONDS_IN_A_SECOND = 1_000_000_000.0

class HighResolutionTimer {
    #if os(Linux)
        typealias EpochType = timespec
    #else
        typealias EpochType = UInt64
        var timeBaseInfo = mach_timebase_info_data_t()
        let ticksPerNs: Double
    #endif
    
    var epoch: EpochType
    
    init() {
        #if os(Linux)
            epoch = timespec()
            clock_gettime(CLOCK_MONOTONIC, &epoch)
        #else
            epoch = mach_absolute_time()
            mach_timebase_info(&timeBaseInfo)
            ticksPerNs = Double(timeBaseInfo.numer) / Double(timeBaseInfo.denom)
        #endif
    }
    
    func mark() {
        #if os(Linux)
            clock_gettime(CLOCK_MONOTONIC, &epoch)
        #else
            epoch = mach_absolute_time()
        #endif
    }
    
    func check() -> Double {
        #if os(Linux)
            var now = timespec()
            clock_gettime(CLOCK_MONOTONIC, &now)
            let delta = Double(now.tv_sec - epoch.tv_sec)
                        + (Double(now.tv_nsec - epoch.tv_nsec) / NANOSECONDS_IN_A_SECOND)
        #else
            let now = mach_absolute_time()
            let delta = (Double(now - epoch) * ticksPerNs) / NANOSECONDS_IN_A_SECOND
        #endif
        return delta;
    }
}
