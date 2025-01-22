// Copyright (c) 2024 Semantical GmbH & Co. KG
// Licensed under the MIT License. See LICENSE file.

import Testing
import Dated
import Foundation

@Test(arguments: Calendar.testCalendars)
func calendarDateGranularity(with calendar: Calendar) throws {
    CalendarDate.$calendar.withValue(calendar) {
        Date.withRandom(10_000) { date in
            let calendarDate = CalendarDate(date)
            let diff = date.timeIntervalSince(calendarDate.date)
            // CalendarDate has a granularity of minute.
            #expect(abs(diff) < 60)
        }
    }
}

@Test(arguments: Calendar.testCalendars)
func components(with calendar: Calendar) throws {
    CalendarDate.$calendar.withValue(calendar) {
        Date.withRandom(50) { date in
            let calendarDate = CalendarDate(date)
            let components = calendar.dateComponents(
                [.minute, .hour, .day, .month, .year],
                from: date
            )
            #expect(calendarDate.minuteOfHour == components.minute!)
            #expect(calendarDate.hourOfDay == components.hour!)
            #expect(calendarDate.dayOfMonth == components.day!)
            #expect(calendarDate.monthOfYear == components.month!)
            #expect(calendarDate.yearOfEra == components.year!)
        }
    }
}

@Test(arguments: Calendar.testCalendars)
func containingSubdivisions(with calendar: Calendar) throws {
    CalendarDate.$calendar.withValue(calendar) {
        Date.withRandom(50) {
            let date = CalendarDate($0)
            date.tryContainingSubdivision(
                for: .day,
                using: [.day, .month, .year, .era],
                in: calendar
            )
            date.tryContainingSubdivision(
                for: .month,
                using: [.month, .year, .era],
                in: calendar
            )
            date.tryContainingSubdivision(
                for: .year,
                using: [.year, .era],
                in: calendar
            )
        }
    }
}

@Test(arguments: Calendar.testCalendars)
func idOrdering(with calendar: Calendar) throws {
    CalendarDate.$calendar.withValue(calendar) {
        Date.withRandom(20) { date1 in
            Date.withRandom(20) { date2 in
                let ordering = CalendarDate(date1).id < CalendarDate(date2).id
                #expect((date1 < date2) == ordering)
            }
        }
    }
}

// This test describes a bug in Apple's calendar code for the Islamic
// calendar. It will fail when the bug is fixed. We can then add the
// .islamic calendar back to the test calendars.
//
// I filed a bug with Apple on June 13th, 2023 (FB12336002)
// "Islamic calendar returns invalid calendar components".
@Test
func testIslamic() throws {
    let cal = Calendar(identifier: .islamic)
    
    // First moment of a certain month.
    let components = DateComponents(year: 1428, month: 7, day: 1)
    let date = cal.date(from: components)!
    
    // Get components of `date`.
    let month = cal.component(.month, from: date)
    
    // Advance `date` by one month.
    let advanced = cal.date(byAdding: .month, value: 1, to: date)!
    
    // Get components of `advanced`.
    let advancedDay = cal.component(.day, from: advanced)
    let advancedMonth = cal.component(.month, from: advanced)
    
    // `advancedMonth` should be different to `month` but isn't.
    #expect(advancedMonth == month)
    // In fact only the day has advanced (from 1 to 30):
    #expect(advancedDay == 30)
    
    // 30 isn't even in the allowed range for the dates in question:
    
    // Range of allowed days in the given month.
    let range1 = cal.range(of: .day, in: .month, for: date)!
    let range2 = cal.range(of: .day, in: .month, for: advanced)!
    #expect(!range1.contains(30))
    #expect(!range2.contains(30))
}

extension CalendarDate {
    func tryContainingSubdivision(
        for unit: Unit,
        using components: Set<Calendar.Component>,
        in calendar: Calendar
    ) {
        let interval = subdivision(for: unit).dateInterval
        let start = interval.start.date
        let end = interval.end.date
        let startDate = calendar.dateWithComponents(
            components,
            from: date
        )
        let endDate = calendar.date(
            byAdding: unit.calendarComponent,
            value: 1,
            to: startDate
        )
        #expect(start == startDate)
        #expect(end == endDate)
    }
}
