//
//  Day.swift
//  Dated
//
//  Created by Jürgen on 19.05.23.
//

import Foundation

/// A day in the current calendar.
public struct Day: CalendarSubdivision {
    /// Returns the unit `.day`.
    public static var unit: CalendarDate.Unit { .day }

    /// An integer suitable to be used as a key in a database table.
    ///
    /// - note: The ordering of ``Day`` values is the same as the ordering
    /// of their IDs. If both `day1` and `day2` are ``Day`` values,
    /// `day1` is ordered before `day2` when its ID is lower than `day2`'s.
    public let id: Int

    /// Creates a day value from the given identifier.
    ///
    /// - important: Do not try to generate your own IDs. Use this initializer
    /// only to recreate a Day value whose ID has been saved previously.
    public init(id: Int) {
        self.id = id & (eraMask + yearMask + monthMask + dayMask)
    }

    /// Creates a day in the user's preferrend calendar.
    public init(_ date: CalendarDate) {
        self.init(id: date.id)
    }

    /// Creates a day in the user's preferrend calendar.
    public init(_ date: Date) {
        let components = CalendarDate.calendar.dateComponents(
            [.day, .month, .year, .era], from: date
        )

        let day    = (components.day   ?? 0) << dayOffset
        let month  = (components.month ?? 0) << monthOffset
        let year   = (components.year  ?? 0) << yearOffset
        let era    = (components.era   ?? 0) << eraOffset

        id = day + month + year + era
    }


    // MARK: - Accessing Calendar Components

    /// The day component.
    public var dayOfMonth: Int {
        (id & dayMask) >> dayOffset
    }

    private var nativeWeekday: Int {
        CalendarDate.calendar.component(.weekday, from: firstInstance)
    }

    /// The day of the week, represented by a number from 1 to 7.
    ///
    /// A day of week of 1 denotes the first day of the week as defined
    /// by the user's preferred calendar.
    ///
    /// - important: Note that this differs from the weekday component
    /// as returned by Apple's corresponding `Calendar` method, which
    /// always represents Sunday as 1
    public var dayOfWeek: Int {
        // `+ 7` is to ensure the result is a positive integer.
        (nativeWeekday - CalendarDate.calendar.firstWeekday + 7) % 7 + 1
    }

    /// The month component.
    public var monthOfYear: Int {
        (id & monthMask) >> monthOffset
    }

    /// The year component.
    public var yearOfEra: Int {
        (id & yearMask) >> yearOffset
    }

    /// The era component.
    public var era: Int {
        (id & eraMask) >> eraOffset
    }

    /// All date components of the given day.
    public var components: CalendarDate.Components {
        CalendarDate.Components(eras: era, years: yearOfEra, months: monthOfYear, days: dayOfMonth)
    }


    // MARK: - Related Dates

    private var firstInstance: Date {
        CalendarDate.calendar.date(from: components.nativeComponents)!
    }

    /// The first moment of this day.
    public var start: CalendarDate {
        CalendarDate(firstInstance)
    }


    // MARK: - Retrieving Containing Subdivisions

    /// The week containing the receiver.
    public var week: Week {
        return .init(firstInstance)
    }

    /// The month containing the receiver.
    public var month: Month {
        .init(id: id)
    }

    /// The year containing the receiver.
    public var year: Year {
        .init(id: id)
    }


    // MARK: - Getting Weekday Symbols

    /// The standalone weekday symbol of this day in the current calendar.
    public var weekdaySymbol: String {
        CalendarDate.calendar.standaloneWeekdaySymbols[nativeWeekday - 1]
    }

    /// The shorter-named standalone weekday symbol of this day in
    /// the current calendar.
    public var shortWeekdaySymbol: String {
        CalendarDate.calendar.shortStandaloneWeekdaySymbols[nativeWeekday - 1]
    }

    /// The very-shortly-named standalone weekday symbol of this day in
    /// the current calendar.
    public var veryShortWeekdaySymbol: String {
        CalendarDate.calendar.veryShortStandaloneWeekdaySymbols[nativeWeekday - 1]
    }


    // MARK: - Comparing Dates

    /// Returns a Boolean value indicating whether the receiver is today.
    public var isToday: Bool {
        CalendarDate.calendar.isDateInToday(firstInstance)
    }

    /// Returns a Boolean value indicating whether the receiver is tomorrow.
    public var isTomorrow: Bool {
        CalendarDate.calendar.isDateInTomorrow(firstInstance)
    }

    /// Returns a Boolean value indicating whether the receiver is yesterday.
    public var isYesterday: Bool {
        CalendarDate.calendar.isDateInYesterday(firstInstance)
    }

    /// Returns a Boolean value indicating whether the receiver is
    /// within a weekend period.
    public var isInWeekend: Bool {
        CalendarDate.calendar.isDateInWeekend(firstInstance)
    }
    
    /// Returns a Boolean value indicating whether the receiver is
    /// within a week period.
    public var isInWeek: Bool {
        CalendarDate.calendar.isDate(firstInstance, equalTo: .now, toGranularity: .weekOfYear)
    }
}

extension Day: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(yearOfEra)-\(monthOfYear)-\(dayOfMonth)"
    }
}
