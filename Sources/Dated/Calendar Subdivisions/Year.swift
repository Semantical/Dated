//
//  Year.swift
//  Semantical Kit
//
//  Created by Jürgen on 19.05.23.
//

import Foundation

/// A year in the current calendar.
public struct Year: CalendarSubdivision {
    /// Returns the unit `.year`.
    public static var unit: CalendarDate.Unit { .year }

    /// An integer suitable to be used as a key in a database table.
    ///
    /// - note: The ordering of ``Year`` values is the same as the ordering
    /// of their IDs. If both `year1` and `year2` are ``Year`` values,
    /// `year1` is ordered before `year2` when its ID is lower than `year2`'s.
    public let id: Int

    /// Creates a year value from the given identifier.
    ///
    /// - important: Do not try to generate your own IDs. Use this initializer
    /// only to recreate a year value whose ID has been saved previously.
    public init(id: Int) {
        self.id = id & (eraMask + yearMask)
    }

    /// Creates a year in the user's preferrend calendar.
    public init(_ date: CalendarDate) {
        self.init(id: date.id)
    }

    /// Creates a year in the user's preferrend calendar.
    public init(date: Date = .now) {
        let components = CalendarDate.calendar.dateComponents(
            [.year, .era], from: date
        )

        let year   = (components.year  ?? 0) << yearOffset
        let era    = (components.era   ?? 0) << eraOffset

        id = year + era
    }

    
    // MARK: - Accessing Calendar Components

    /// The year component.
    public var yearOfEra: Int {
        (id & yearMask) >> yearOffset
    }

    /// The era component.
    public var era: Int {
        (id & eraMask) >> eraOffset
    }

    /// All date components of the given year.
    public var components: CalendarDate.Components {
        CalendarDate.Components(eras: era, years: yearOfEra)
    }


    // MARK: - Related Dates

    private var firstInstance: Date {
        CalendarDate.calendar
            .date(from: DateComponents(era: era, year: yearOfEra))!
    }

    /// The first moment of this year.
    public var start: CalendarDate {
        CalendarDate(date: firstInstance)
    }

    /// The list of all weeks in the given year ordered by date.
    public var weeks: [Week] {
        Week.subdivisions(
            of: .weekOfYear, in: .yearForWeekOfYear, for: firstInstance
        )
    }

    /// The list of all months in the given year ordered by date.
    public var months: [Month] {
        Month.subdivisions(
            of: .month, in: .year, for: firstInstance
        )
    }
}


extension Year: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(yearOfEra)"
    }
}