// Copyright (c) 2024 Semantical GmbH & Co. KG
// Licensed under the MIT License. See LICENSE file.

import Testing
import Foundation
import Dated

@Test
func intervalsPerDay() throws {
    let dayTime = CalendarDate.now
    for _ in 1...10 {
        // Test with durations of 4 days max.
        let duration = Int.random(in: 0..<3600 * 24 * 4)
        let interval = CalendarDateInterval(
            start: dayTime,
            duration: .seconds(duration)
        )
        let intervalsPerDay = interval.intervalsPerDay()
        
        // Test duration sum.
        var summedDuration = 0
        for interval in intervalsPerDay {
            summedDuration += interval.duration.seconds
        }
        #expect(duration == summedDuration)
        
        // Test start and end.
        #expect(intervalsPerDay.first!.start == interval.start)
        #expect(intervalsPerDay.last!.end == interval.end)
    }
}

@Test
func dateIntervalCodable() throws {
    let interval = CalendarDateInterval(
        start: .now,
        duration: .minutes(30)
    )
    let data = try JSONEncoder().encode(interval)
    let decoded = try JSONDecoder().decode(
        CalendarDateInterval.self,
        from: data
    )
    #expect(decoded == interval)
}
