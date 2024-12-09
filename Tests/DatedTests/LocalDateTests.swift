// Copyright (c) 2024 Semantical GmbH & Co. KG
// Licensed under the MIT License. See LICENSE file.

import XCTest
@testable import Dated

final class LocalDateTests: XCTestCase {
    func testTimeZones() throws {
        TimeZone.withRandom(20) { timeZone in
            let testDate = Date.random()
            
            // Get local time in time zone.
            let local = LocalDate(date: testDate, timeZone: timeZone)
            
            // Convert to Time value.
            let date = CalendarDate(local)
            
            XCTAssertEqual(
                date.hourOfDay,
                CalendarDate.calendar.dateComponents(
                    in: timeZone,
                    from: testDate
                ).hour!
            )
        }
    }
    
    func testCodable() throws {
        try Date.withRandom(20) { date in
            let local = LocalDate(date: date, timeZone: .current)
            let data = try JSONEncoder().encode(local)
            let decodedDate = try JSONDecoder().decode(LocalDate.self, from: data)
            // Weirdly enough, Date cannot accurately represent itself
            // using `timeIntervalSince1970`.
            XCTAssertLessThan(abs(decodedDate.date.timeIntervalSince(local.date)), 0.001)
            XCTAssertEqual(decodedDate.timeZone, local.timeZone)
            
        }
    }
    
    func testComparable() throws {
        let earlierButSeemsLater = LocalDate(
            date: Date(timeIntervalSinceReferenceDate: 0),
            timeZone: .init(secondsFromGMT: 7200)!
        )
        let laterButSeemsEarlier = LocalDate(
            date: Date(timeIntervalSinceReferenceDate: 3600),
            timeZone: .init(secondsFromGMT: 0)!
        )
        XCTAssertLessThan(laterButSeemsEarlier, earlierButSeemsLater)
    }
}
