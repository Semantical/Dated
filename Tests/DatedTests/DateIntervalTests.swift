//
//  DateIntervalTests.swift
//  Dated
//
//  Created by Jürgen on 02.06.23.
//

import XCTest
import Dated

final class DateIntervalTests: XCTestCase {
    func testIntervalsPerDay() throws {
        let dayTime = CalendarDate.now
        for _ in 1...10 {
            // Test with durations of 4 days max.
            let duration = Int.random(in: 0 ..< 3600*24*4)
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
            XCTAssertEqual(duration, summedDuration)

            // Test start and end.
            XCTAssertEqual(intervalsPerDay.first!.start,
                           interval.start)
            XCTAssertEqual(intervalsPerDay.last!.end,
                           interval.end)
        }
    }

    func testCodable() throws {
        let interval = CalendarDateInterval(start: .now,
                                            duration: .minutes(30))
        let data = try JSONEncoder().encode(interval)
        let decoded = try JSONDecoder().decode(CalendarDateInterval.self,
                                               from: data)
        XCTAssertEqual(decoded, interval)
    }
}
