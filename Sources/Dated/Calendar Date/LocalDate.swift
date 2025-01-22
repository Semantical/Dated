// Copyright (c) 2024 Semantical GmbH & Co. KG
// Licensed under the MIT License. See LICENSE file.

import Foundation

/// A date preserving the original time zone at the moment it was created.
public struct LocalDate: Hashable, Sendable {
    public var date: Date
    public var timeZone: TimeZone
    
    /// Creates a new local date from the current date at the moment of access.
    public init() {
        self = .now
    }
    
    /// Creates a new local date using the current time zone.
    public init(_ date: CalendarDate) {
        self.init(date: date.date, timeZone: CalendarDate.calendar.timeZone)
    }
    
    /// Creates a new local date using the current time zone.
    public init(_ date: Date) {
        self.init(date: date, timeZone: CalendarDate.calendar.timeZone)
    }
    
    /// Returns the current date in the current time zone at the
    /// moment of access.
    public static var now: LocalDate {
        .init(Date.now)
    }
    
    public init(date: Date, timeZone: TimeZone) {
        self.date = date
        self.timeZone = TimeZone(secondsFromGMT: timeZone.secondsFromGMT(for: date))!
    }
    
    // MARK: - Getting Calendar Dates
    
    /// Returns a calendar date preserving the hour of day from the original
    /// time zone.
    public var calendarDate: CalendarDate {
        var calendar = CalendarDate.calendar
        if timeZone != CalendarDate.calendar.timeZone {
            calendar.timeZone = timeZone
        }
        return CalendarDate(
            components: calendar.dateComponents(
                [.minute, .hour, .day, .month, .year, .era],
                from: date
            )
        )
    }
    
    // MARK: - Getting Temporal Boundaries
    
    /// A local date in the distant future.
    public static var distantFuture: LocalDate {
        .init(date: .distantFuture, timeZone: .gmt)
    }
    
    /// A local date in the distant past.
    public static var distantPast: LocalDate {
        .init(date: .distantPast, timeZone: .gmt)
    }
}

// MARK: -

// Codable Conformance

extension LocalDate: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        let secondsSince1970 = try container.decode(Double.self)
        date = Date(timeIntervalSince1970: secondsSince1970)
        
        let secondsFromGMT = try container.decode(Int.self)
        timeZone = TimeZone(secondsFromGMT: secondsFromGMT)!
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(date.timeIntervalSince1970)
        try container.encode(timeZone.secondsFromGMT(for: date))
    }
}

// Comparable Conformance

extension LocalDate: Comparable {
    private var _dateComponents: DateComponents {
        Calendar(gregorianWithTimeZone: timeZone)
            .dateComponents(
                [.nanosecond, .second, .minute, .hour, .day, .month, .year, .era],
                from: date
            )
    }
    
    private var _date: Date {
        Calendar(gregorianWithTimeZone: .gmt)
            .date(from: _dateComponents)!
    }
    
    public static func == (lhs: LocalDate, rhs: LocalDate) -> Bool {
        lhs._dateComponents == rhs._dateComponents
    }
    
    public static func < (lhs: LocalDate, rhs: LocalDate) -> Bool {
        lhs._date < rhs._date
    }
}
private extension Calendar {
    init(gregorianWithTimeZone timeZone: TimeZone) {
        self.init(identifier: .gregorian)
        self.timeZone = timeZone
    }
}
