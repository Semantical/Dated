// Copyright (c) 2024 Semantical GmbH & Co. KG
// Licensed under the MIT License. See LICENSE file.

import Foundation

/// A date preserving the original time zone at the moment it was created.
public struct LocalDate: Hashable, Sendable {
    public var date: Date
    public var timeZone: TimeZone
    
    /// Creates a new local date from the current date at the moment of access.
    @inlinable
    public init() {
        self = .now
    }
    
    /// Creates a new local date using the current time zone.
    @inlinable
    public init(_ date: CalendarDate) {
        self.init(date: date.date, timeZone: CalendarDate.calendar.timeZone)
    }
    
    /// Creates a new local date using the current time zone.
    @inlinable
    public init(_ date: Date) {
        self.init(date: date, timeZone: CalendarDate.calendar.timeZone)
    }
    
    /// Returns the current date in the current time zone at the
    /// moment of access.
    @inlinable
    public static var now: LocalDate {
        .init(Date.now)
    }
    
    @inlinable
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
    @inlinable
    public static var distantFuture: LocalDate {
        .init(date: .distantFuture, timeZone: .gmt)
    }
    
    /// A local date in the distant past.
    @inlinable
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
    @inlinable var _dateComponents: DateComponents {
        Calendar(_gregorianWithTimeZone: timeZone)
            .dateComponents(
                [.nanosecond, .second, .minute, .hour, .day, .month, .year, .era],
                from: date
            )
    }
    
    @inlinable
    var _date: Date {
        Calendar(_gregorianWithTimeZone: .gmt).date(from: _dateComponents)!
    }
    
    @inlinable
    public static func == (lhs: LocalDate, rhs: LocalDate) -> Bool {
        lhs._dateComponents == rhs._dateComponents
    }
    
    @inlinable
    public static func < (lhs: LocalDate, rhs: LocalDate) -> Bool {
        lhs._date < rhs._date
    }
}

extension Calendar {
    @inlinable
    init(_gregorianWithTimeZone timeZone: TimeZone) {
        self.init(identifier: .gregorian)
        self.timeZone = timeZone
    }
}
