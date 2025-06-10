// Copyright (c) 2024 Semantical GmbH & Co. KG
// Licensed under the MIT License. See LICENSE file.

import Testing
import Foundation
import Dated

@Test(arguments: Calendar.testCalendars)
func weekdays(with calendar: Calendar) throws {
    CalendarDate.$calendar.withValue(calendar) {
        #expect(Week.current.days.map(\.dayOfWeek) == [1, 2, 3, 4, 5, 6, 7])
    }
}

@Test
func firstWeekday() throws {
    // We look at the US and DE calendar as they have different first
    // weekdays. The first of June 2023 fell on a Thursday, but should
    // have different dayOfWeek numbers in either calendar.
    
    var calendarUS = Calendar(identifier: .gregorian)
    calendarUS.locale = Locale(identifier: "en_US")
    calendarUS.firstWeekday = 1
    CalendarDate.$calendar.withValue(calendarUS) {
        let dayUS = CalendarDate.firstOfJune2023.day
        #expect(dayUS.shortWeekdaySymbol == "Thu")
        #expect(dayUS.dayOfWeek == 5)
    }
    
    var calendarDE = Calendar(identifier: .gregorian)
    calendarDE.locale = Locale(identifier: "de_DE")
    calendarDE.firstWeekday = 2
    CalendarDate.$calendar.withValue(calendarDE) {
        let dayDE = CalendarDate.firstOfJune2023.day
        #expect(dayDE.shortWeekdaySymbol == "Do")
        #expect(dayDE.dayOfWeek == 4)
    }
}

@Test
func subdivisionLosslessStringConvertible() async throws {
    let day = Day(Date.now)
    #expect(Day(day.description) == day)
    
    let month = Month(Date.now)
    #expect(Month(month.description) == month)
    
    let year = Year(Date.now)
    #expect(Year(year.description) == year)
}
