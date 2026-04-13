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

        for (lhs, rhs) in zip(intervalsPerDay, intervalsPerDay.dropFirst()) {
            #expect(lhs.end == rhs.start)
            #expect(!lhs.contains(rhs.start))
        }
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

@Test
func containsExcludesSharedEndBoundary() throws {
    let start = CalendarDate.now
    let boundary = start + .hours(1)
    let nextBoundary = boundary + .hours(1)

    let first = CalendarDateInterval(start: start, end: boundary)
    let second = CalendarDateInterval(start: boundary, end: nextBoundary)

    #expect(first.contains(start))
    #expect(!first.contains(boundary))
    #expect(second.contains(boundary))
}
