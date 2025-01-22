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
