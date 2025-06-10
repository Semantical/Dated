// Copyright (c) 2024 Semantical GmbH & Co. KG
// Licensed under the MIT License. See LICENSE file.

import Foundation

/// A week in the current calendar.
public struct Week: CalendarSubdivision {
    /// Returns the unit `.week`.
    public static var unit: CalendarDate.Unit { .week }
    
    /// An integer suitable to be used as a key in a database table.
    ///
    /// - note: The ordering of ``Week`` values is the same as the ordering
    /// of their IDs. If both `week1` and `week2` are ``Week`` values,
    /// `week1` is ordered before `week2` when its ID is lower than `week2`'s.
    public let id: Int
    
    /// Creates a week value from the given identifier.
    ///
    /// - important: Do not try to generate your own IDs. Use this initializer
    /// only to recreate a week value whose ID has been saved previously.
    public init(id: Int) {
        self.id = id & (Bits.weekMask + Bits.yearMask + Bits.eraMask)
    }
    
    /// Creates a week in the user's preferred calendar.
    public init(_ date: CalendarDate) {
        self.init(date.date)
    }
    
    // swift-format-ignore
    /// Creates a week in the user's preferred calendar.
    public init(_ date: Date) {
        let components = CalendarDate.calendar.dateComponents(
            [.weekOfYear, .yearForWeekOfYear, .era], from: date
        )

        let week = (components.weekOfYear        ?? 0) << Bits.weekOffset
        let year = (components.yearForWeekOfYear ?? 0) << Bits.yearOffset
        let era  = (components.era               ?? 0) << Bits.eraOffset

        id = week + year + era
    }
    
    // MARK: - Accessing Calendar Components
    
    /// The week component.
    public var weekOfYear: Int {
        (id & Bits.weekMask) >> Bits.weekOffset
    }
    
    /// The year component.
    public var yearOfEra: Int {
        (id & Bits.yearMask) >> Bits.yearOffset
    }
    
    /// The era component.
    public var era: Int {
        (id & Bits.eraMask) >> Bits.eraOffset
    }
    
    /// All date components of the given week.
    public var components: CalendarDate.Components {
        CalendarDate.Components(eras: era, years: yearOfEra, weeks: weekOfYear)
    }
    
    // MARK: - Related Dates
    
    private var firstInstance: Date {
        CalendarDate.calendar.date(
            from: DateComponents(
                era: era,
                weekOfYear: weekOfYear,
                yearForWeekOfYear: yearOfEra
            )
        )!
    }
    
    /// The first moment of this week.
    public var start: CalendarDate {
        CalendarDate(firstInstance)
    }
    
    /// The list of weekdays ordered by date.
    public var days: [Day] {
        Day.subdivisions(of: .weekday, in: .weekOfYear, for: firstInstance)
    }
    
    // MARK: - Retrieving Containing Subdivisions
    
    /// The year containing the receiver.
    public var year: Year {
        .init(id: id)
    }
}

extension Week: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(yearOfEra)-\(weekOfYear)"
    }
}
