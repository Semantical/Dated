//
//  CalendarDateInterval.swift
//  SemanticalKit
//
//  Created by Jürgen on 18.05.23.
//

import Foundation

/// The span of time between a specific start date and end date.
public struct CalendarDateInterval: Equatable {
    /// The start date.
    public let start: CalendarDate

    /// The duration.
    public let duration: TimeDifference

    /// Initializes a date interval with start and end dates set to the
    /// current date and the duration set to 0.
    public init() {
        self.init(start: .now, duration: .minutes(0))
    }

    /// Initializes a date interval with the specified start date and duration.
    public init(start: CalendarDate, duration: TimeDifference) {
        self.start = start
        self.duration = duration
    }

    /// Initializes a date interval with the specified start and end date.
    public init(start: CalendarDate, end: CalendarDate) {
        self.start = start
        duration = start.duration(to: end)
    }

    /// The end date.
    public var end: CalendarDate {
        start.advanced(by: duration)
    }

    /// Indicates whether this interval contains the given date.
    public func contains(_ date: CalendarDate) -> Bool {
        return start <= date && date <= end
    }

    /// Returns smaller intervals, one per day the given date
    /// interval intersects.
    public func intervalsPerDay() -> [CalendarDateInterval] {
        let calendar = CalendarDate.calendar
        var result: [CalendarDateInterval] = []

        func addInterval(from start: Date, to end: Date) {
            let interval = CalendarDateInterval(
                start: CalendarDate(date: start),
                end: CalendarDate(date: end))
            result.append(interval)
        }

        var date = start.date
        let endDate = end.date

        while true {
            guard let nextDay = calendar.date(
                byAdding: .day, value: 1,
                to: calendar.startOfDay(for: date)
            ), nextDay < endDate else {
                addInterval(from: date, to: endDate)
                break
            }

            addInterval(from: date, to: nextDay)
            date = nextDay
        }

        return result
    }
}

extension CalendarDateInterval: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        start = try container.decode(CalendarDate.self)
        duration = try container.decode(TimeDifference.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(start)
        try container.encode(duration)
    }
}