//
//  _Utilities.swift
//  Dated
//
//  Created by Jürgen on 03.06.23.
//

import Foundation
@testable import Dated

// Dates

extension CalendarDate {
    static var firstOfJune2023: CalendarDate {
        CalendarDate(calendar.date(from: .init(year: 2023, month: 6, day: 1))!)
    }
}

extension Date {
    static func random() -> Date {
        Date(timeIntervalSinceReferenceDate: Double.random(in: 0 ... 20*365*24*60*60))
    }

    static func withRandom(_ count: Int, body: (Date) throws -> Void) rethrows {
        for _ in 0..<count {
            try body(Date.random())
        }
    }
}


// Time Zones

extension TimeZone {
    static func withRandom(_ count: Int, body: (TimeZone) -> Void) {
        let identifiers = TimeZone.knownTimeZoneIdentifiers
        for _ in 0..<count {
            body(TimeZone(identifier: identifiers.randomElement()!)!)
        }
    }
}


// Calendars

enum TestCalendarID {
    case us
    case de
}

extension CalendarDate {
    static func setCurrentCalendar(to id: TestCalendarID) {
        switch id {
        case .us:
            calendar = Calendar(identifier: .gregorian)
            calendar.locale = Locale(identifier: "en_US")
            calendar.firstWeekday = 1
        case .de:
            calendar = Calendar(identifier: .gregorian)
            calendar.locale = Locale(identifier: "de_DE")
            calendar.firstWeekday = 2
        }
    }
}

extension Calendar {
    // Our approach does not work for the Chinese (.chinese) and
    // Islamic (.islamic) calendars. Apple's implementation of the Islamic
    // calendar is buggy, otherwise we'd be fine.
    //
    // I haven't looked into the Chinese calendar as it isn't even used in
    // China anymore. China and the Chinese language community abroad uses the
    // Gregorian and Republic of China calendar.

    // All Apple supported calendars except .chinese and .islamic.
    static var testCalendars: [Calendar] = [.gregorian, .republicOfChina, .indian, .islamicCivil, .islamicTabular, .islamicUmmAlQura, .buddhist, .persian, .hebrew, .ethiopicAmeteAlem, .ethiopicAmeteMihret, .coptic, .iso8601, .japanese].map({ Calendar(identifier: $0) })

    func dateWithComponents(
        _ components: Set<Calendar.Component>, from date: Date
    ) -> Date {
        self.date(from: dateComponents(components, from: date)
        )!
    }
}
