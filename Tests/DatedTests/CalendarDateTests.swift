//
//  CalendarDateTests.swift
//  Dated
//
//  Created by Jürgen on 04.06.23.
//

import XCTest
@testable import Dated

final class CalendarDateTests: XCTestCase {
    func testDate() throws {
        for calendar in Calendar.testCalendars {
            CalendarDate.calendar = calendar

            Date.withRandom(10_000) { date in
                let calendarDate = CalendarDate(date: date)
                let diff = date.timeIntervalSince(calendarDate.date)
                // CalendarDate has a granularity of minute.
                XCTAssertLessThan(abs(diff), 60)
            }
        }
    }

    func testComponents() throws {
        for calendar in Calendar.testCalendars {
            CalendarDate.calendar = calendar

            Date.withRandom(50) { date in
                let calendarDate = CalendarDate(date: date)
                let components = calendar.dateComponents(
                    [.minute, .hour, .day, .month, .year],
                    from: date)
                XCTAssertEqual(calendarDate.minuteOfHour, components.minute!)
                XCTAssertEqual(calendarDate.hourOfDay,    components.hour!)
                XCTAssertEqual(calendarDate.dayOfMonth,   components.day!)
                XCTAssertEqual(calendarDate.monthOfYear,  components.month!)
                XCTAssertEqual(calendarDate.yearOfEra,    components.year!)
            }
        }
    }

    func testContainingSubdivisions() throws {
        for calendar in Calendar.testCalendars {
            CalendarDate.calendar = calendar

            Date.withRandom(50) {
                let date = CalendarDate(date: $0)
                date.tryContainingSubdivision(
                    for: .day,
                    using: [.day, .month, .year, .era], in: calendar
                )
                date.tryContainingSubdivision(
                    for: .month,
                    using: [.month, .year, .era], in: calendar
                )
                date.tryContainingSubdivision(
                    for: .year,
                    using: [.year, .era], in: calendar
                )
            }
        }
    }

    func testIdOrdering() throws {
        for calendar in Calendar.testCalendars {
            CalendarDate.calendar = calendar

            Date.withRandom(20) { date1 in
                Date.withRandom(20) { date2 in
                    let ordering = CalendarDate(date: date1).id < CalendarDate(date: date2).id
                    XCTAssertEqual(date1 < date2, ordering)
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
        XCTAssertEqual(advancedMonth, month)
        // In fact only the day has advanced (from 1 to 30):
        XCTAssertEqual(advancedDay, 30)

        // 30 isn't even in the allowed range for the dates in question:

        // Range of allowed days in the given month.
        let range1 = cal.range(of: .day, in: .month, for: date)!
        let range2 = cal.range(of: .day, in: .month, for: advanced)!
        XCTAssertFalse(range1.contains(30))
        XCTAssertFalse(range2.contains(30))
    }
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
            components, from: date
        )
        let endDate = calendar.date(
            byAdding: unit.nativeComponent, value: 1, to: startDate
        )
        XCTAssertEqual(start, startDate)
        XCTAssertEqual(end, endDate)
    }
}
