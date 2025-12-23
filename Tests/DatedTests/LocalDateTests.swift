// Copyright (c) 2024 Semantical GmbH & Co. KG
// Licensed under the MIT License. See LICENSE file.

import Testing
import Foundation
import Dated

@Test
func timeZones() throws {
    TimeZone.withRandom(20) { timeZone in
        let testDate = Date.random()
        
        // Get local time in time zone.
        let local = LocalDate(date: testDate, timeZone: timeZone)
        
        // Convert to Time value.
        let date = CalendarDate(local)
        
        #expect(
            date.hourOfDay == CalendarDate.calendar.dateComponents(
                in: timeZone,
                from: testDate
            ).hour!
        )
    }
}

@Test
func calendarDatePreservesSeconds() throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .gmt
    CalendarDate.$calendar.withValue(calendar) {
        let date = calendar.date(from: DateComponents(
            year: 2024,
            month: 6,
            day: 1,
            hour: 12,
            minute: 34,
            second: 56
        ))!
        let local = LocalDate(date: date, timeZone: .gmt)
        #expect(local.calendarDate.secondOfHour == 56)
    }
}

@Test
func localDateCodable() throws {
    try Date.withRandom(20) { date in
        let local = LocalDate(date: date, timeZone: .current)
        let data = try JSONEncoder().encode(local)
        let decodedDate = try JSONDecoder().decode(LocalDate.self, from: data)
        // Weirdly enough, Date cannot accurately represent itself
        // using `timeIntervalSince1970`.
        #expect(abs(decodedDate.date.timeIntervalSince(local.date)) < 0.001)
        #expect(decodedDate.timeZone == local.timeZone)
        
    }
}

@Test
func comparable() throws {
    let earlierButSeemsLater = LocalDate(
        date: Date(timeIntervalSinceReferenceDate: 0),
        timeZone: .init(secondsFromGMT: 7200)!
    )
    let laterButSeemsEarlier = LocalDate(
        date: Date(timeIntervalSinceReferenceDate: 3600),
        timeZone: .init(secondsFromGMT: 0)!
    )
    #expect(laterButSeemsEarlier < earlierButSeemsLater)
}
