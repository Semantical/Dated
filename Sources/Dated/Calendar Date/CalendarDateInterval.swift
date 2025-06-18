// Copyright (c) 2024 Semantical GmbH & Co. KG
// Licensed under the MIT License. See LICENSE file.

import Foundation

/// The span of time between a specific start date and end date.
public struct CalendarDateInterval: Hashable, Sendable {
    /// The start date.
    public var start: CalendarDate
    
    /// The duration.
    public var duration: TimeDifference
    
    /// Initializes a date interval with start and end dates set to the
    /// current date and the duration set to 0.
    @inlinable
    public init() {
        self.init(start: .now, duration: .seconds(0))
    }
    
    /// Initializes a date interval with the specified start date and duration.
    @inlinable
    public init(start: CalendarDate, duration: TimeDifference) {
        self.start = start
        self.duration = duration
    }
    
    /// Initializes a date interval with the specified start and end date.
    @inlinable
    public init(start: CalendarDate, end: CalendarDate) {
        self.start = start
        duration = start.duration(to: end)
    }
    
    /// The end date.
    @inlinable
    public var end: CalendarDate {
        start.advanced(by: duration)
    }
    
    /// Indicates whether this interval contains the given date.
    @inlinable
    public func contains(_ date: CalendarDate) -> Bool {
        start <= date && date <= end
    }
    
    /// Returns smaller intervals, one per day the given date
    /// interval intersects.
    public func intervalsPerDay() -> [CalendarDateInterval] {
        let calendar = CalendarDate.calendar
        var result: [CalendarDateInterval] = []
        
        func addInterval(from start: Date, to end: Date) {
            let interval = CalendarDateInterval(
                start: CalendarDate(start),
                end: CalendarDate(end)
            )
            result.append(interval)
        }
        
        var date = start.date
        let endDate = end.date
        
        while true {
            guard
                let nextDay = calendar.date(
                    byAdding: .day,
                    value: 1,
                    to: calendar.startOfDay(for: date)
                ), nextDay < endDate
            else {
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
    @inlinable
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        start = try container.decode(CalendarDate.self)
        duration = try container.decode(TimeDifference.self)
    }
    
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(start)
        try container.encode(duration)
    }
}
