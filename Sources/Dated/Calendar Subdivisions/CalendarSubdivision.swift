// Copyright (c) 2024 Semantical GmbH & Co. KG
// Licensed under the MIT License. See LICENSE file.

import Foundation

/// A type that represents a calendar subdivision like day, week, month,
/// or year.
public protocol CalendarSubdivision:
    Sendable, Hashable, Comparable, Strideable, Codable, RawRepresentable
where Stride == Int {
    
    /// The calendrical unit of the given calendar subdivision.
    static var unit: CalendarDate.Unit { get }
    
    /// An integer identifying the calendar subdivision uniquely among all
    /// subdivisions of the same type in the calendar.
    ///
    /// This identifier is suitable to be used as a key in a database table.
    var id: Int { get }
    
    /// Creates a new instance from the given identifier.
    ///
    /// - important: Do not try to generate your own IDs. Use this
    /// initializer only to recreate a calendar subdivision whose ID
    /// has been saved previously.
    init(id: Int)
    
    /// Creates a calendar subdivision in the user's preferrend calendar.
    init(_ date: Date)
    
    /// Creates a calendar subdivision in the user's preferrend calendar.
    init(_ date: CalendarDate)
    
    /// The first moment of this calendar subdivision.
    var start: CalendarDate { get }
    
    /// All date components of the given subdivision.
    var components: CalendarDate.Components { get }
}

extension CalendarSubdivision {
    /// Returns a calendar subdivision containing the current date at the
    /// moment of access.
    public static var current: Self {
        self.init()
    }
    
    /// Creates a calendar subdivision containing the current date at the
    /// moment of access.
    public init() {
        self.init(Date.now)
    }
    
    /// The time span covered by the given calendar subdivision.
    public var dateInterval: CalendarDateInterval {
        CalendarDateInterval(start: start, end: self.advanced(by: 1).start)
    }
    
    /// Returns a calendar subdivision offset by adding components to a
    /// given calendar subdivision.
    public static func + (lhs: Self, rhs: CalendarDate.Components) -> Self {
        // (lhs.start + rhs).subdivision(for: self.unit) as! Self
        .init((lhs.start + rhs).date)
    }
    
    /// Returns a calendar subdivision offset by subtracting components from a
    /// given calendar subdivision.
    public static func - (lhs: Self, rhs: CalendarDate.Components) -> Self {
        .init((lhs.start + rhs.negated).date)
    }
    
    /// Adds the given components to a calendar subdivision.
    public static func += (lhs: inout Self, rhs: CalendarDate.Components) {
        lhs = lhs + rhs
    }
    
    /// Subtracts the given components from a calendar subdivision.
    public static func -= (lhs: inout Self, rhs: CalendarDate.Components) {
        lhs = lhs - rhs
    }
}

// Conform to Codable
extension CalendarSubdivision {
    public init(from decoder: Decoder) throws {
        self.init(id: try Int(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try id.encode(to: encoder)
    }
}

// Conform to Comparable
extension CalendarSubdivision {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.id < rhs.id
    }
}

// Conform to Strideable
extension CalendarSubdivision {
    public func advanced(by n: Int) -> Self {
        .init(start + .count(n, of: Self.unit))
    }
    
    public func distance(to other: Self) -> Int {
        // Using the variation of `dateComponents(_:from:to:)`
        // that accepts the CalendarSubdivision `DateComponents`
        // as arguments always returns 0 for some reason,
        // so we just use the `Date` variation here.
        CalendarDate.calendar
            .dateComponents(
                [Self.unit.calendarComponent],
                from: start.date,
                to: other.start.date
            )
            .value(for: Self.unit.calendarComponent)!
    }
}

// Conform to RawRepresentable
extension CalendarSubdivision {
    public init?(rawValue: Int) {
        self.init(id: rawValue)
    }
    
    public var rawValue: Int {
        id
    }
}

// Conform to Equatable
extension CalendarSubdivision {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension CalendarSubdivision {
    static func subdivisions(
        of smaller: Calendar.Component,
        in larger: Calendar.Component,
        for date: Date
    ) -> [Self] {
        let calendar = CalendarDate.calendar
        let range = calendar.range(of: smaller, in: larger, for: date)!
        let result = range.map {
            Self(calendar.date(bySetting: smaller, value: $0, of: date)!)
        }
        if smaller == .weekday {
            // The range for a week is not arranged in chronological order,
            // with the first day of the week first. Let's fix this.
            let start = range.lowerBound - 1
            let split = calendar.firstWeekday - 1
            let end = range.upperBound - 1
            return Array<Self>(result[split..<end] + result[start..<split])
        }
        return result
    }
}
