//
//  SubdivisionTests.swift
//  Dated
//
//  Created by Jürgen on 22.05.23.
//

import XCTest
@testable import Dated

final class SubdivisionTests: XCTestCase {
    func testWeekdays() throws {
        for calendar in Calendar.testCalendars {
            CalendarDate.calendar = calendar
            XCTAssertEqual(
                Week.current.days.map(\.dayOfWeek),
                [1, 2, 3, 4, 5, 6, 7]
            )
        }
    }
    
    func testFirstWeekday() throws {
        // We look at the US and DE calendar as they have different first
        // weekdays. The first of June 2023 fell on a Thursday, but should
        // have different dayOfWeek numbers in either calendar.
        
        CalendarDate.setCurrentCalendar(to: .us)
        let dayUS = CalendarDate.firstOfJune2023.day
        XCTAssertEqual(dayUS.shortWeekdaySymbol, "Thu")
        XCTAssertEqual(dayUS.dayOfWeek, 5)
        
        CalendarDate.setCurrentCalendar(to: .de)
        let dayDE = CalendarDate.firstOfJune2023.day
        XCTAssertEqual(dayDE.shortWeekdaySymbol, "Do")
        XCTAssertEqual(dayDE.dayOfWeek, 4)
    }
}
