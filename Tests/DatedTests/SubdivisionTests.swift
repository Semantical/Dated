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

@Test
func subdivisionComponentInitializers() throws {
    var calendar = Calendar(identifier: .iso8601)
    calendar.locale = Locale(identifier: "en_US_POSIX")
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    
    CalendarDate.$calendar.withValue(calendar) {
        let date = calendar.date(from: DateComponents(year: 2023, month: 6, day: 1))!
        let dayComponents = calendar.dateComponents([.era, .year, .month, .day], from: date)
        #expect(Day(components: dayComponents) == Day(date))
        #expect(Day(1, month: 6, year: 2023) == Day(date))
        let overflowDayComponents = DateComponents(year: 2023, month: 13, day: 1)
        let overflowDayDate = calendar.date(from: overflowDayComponents)!
        #expect(Day(components: overflowDayComponents) == Day(overflowDayDate))
        
        let monthComponents = calendar.dateComponents([.era, .year, .month], from: date)
        #expect(Month(components: monthComponents) == Month(date))
        #expect(Month(6, year: 2023) == Month(date))
        let overflowMonthComponents = DateComponents(year: 2023, month: 13)
        let overflowMonthDate = calendar.date(from: overflowMonthComponents)!
        #expect(Month(components: overflowMonthComponents) == Month(overflowMonthDate))
        
        let weekComponents = calendar.dateComponents(
            [.era, .weekOfYear, .yearForWeekOfYear],
            from: date
        )
        #expect(Week(components: weekComponents) == Week(date))
        guard
            let week = weekComponents.weekOfYear,
            let year = weekComponents.yearForWeekOfYear
        else {
            #expect(false)
            return
        }
        #expect(week == 22)
        #expect(year == 2023)
        #expect(Week(22, year: 2023) == Week(date))
        var overflowWeekComponents = DateComponents()
        overflowWeekComponents.weekOfYear = 60
        overflowWeekComponents.yearForWeekOfYear = 2023
        overflowWeekComponents.era = 1
        let overflowWeekDate = calendar.date(from: overflowWeekComponents)!
        #expect(Week(components: overflowWeekComponents) == Week(overflowWeekDate))
        
        let yearComponents = calendar.dateComponents([.era, .year], from: date)
        #expect(Year(components: yearComponents) == Year(date))
        #expect(Year(2023) == Year(date))
        let emptyYearComponents = DateComponents()
        let emptyYearDate = calendar.date(from: emptyYearComponents)!
        #expect(Year(components: emptyYearComponents) == Year(emptyYearDate))
    }
}
