// Copyright (c) 2024 Semantical GmbH & Co. KG
// Licensed under the MIT License. See LICENSE file.

import Foundation

/// A month in the current calendar.
public struct Month: CalendarSubdivision {
    /// Returns the unit `.month`.
    @inlinable
    public static var unit: CalendarDate.Unit { .month }
    
    /// An integer suitable to be used as a key in a database table.
    ///
    /// - note: The ordering of ``Month`` values is the same as the ordering
    /// of their IDs. If both `month1` and `month2` are ``Month`` values,
    /// `month1` is ordered before `month2` when its ID is lower than
    /// `month2`'s.
    public let id: Int
    
    /// Creates a month value from the given identifier.
    ///
    /// - important: Do not try to generate your own IDs. Use this initializer
    /// only to recreate a Month value whose ID has been saved previously.
    @inlinable
    public init(id: Int) {
        self.id = id & (Bits.eraMask + Bits.yearMask + Bits.monthMask)
    }
    
    /// Creates a month in the user's preferred calendar.
    @inlinable
    public init(_ date: CalendarDate) {
        self.init(id: date.id)
    }
    
    // swift-format-ignore
    /// Creates a month in the user's preferred calendar.
    public init(_ date: Date) {
        let components = CalendarDate.calendar.dateComponents(
            [.month, .year, .era], from: date
        )

        let month = (components.month ?? 0) << Bits.monthOffset
        let year  = (components.year  ?? 0) << Bits.yearOffset
        let era   = (components.era   ?? 0) << Bits.eraOffset

        id = month + year + era
    }
    
    // MARK: - Accessing Calendar Components
    
    /// The month component.
    @inlinable
    public var monthOfYear: Int {
        (id & Bits.monthMask) >> Bits.monthOffset
    }
    
    /// The year component.
    @inlinable
    public var yearOfEra: Int {
        (id & Bits.yearMask) >> Bits.yearOffset
    }
    
    /// The era component.
    @inlinable
    public var era: Int {
        (id & Bits.eraMask) >> Bits.eraOffset
    }
    
    /// All date components of the given month.
    @inlinable
    public var components: CalendarDate.Components {
        CalendarDate.Components(eras: era, years: yearOfEra, months: monthOfYear)
    }
    
    // MARK: - Related Dates
    
    @usableFromInline
    var firstInstance: Date {
        CalendarDate.calendar
            .date(from: DateComponents(era: era, year: yearOfEra, month: monthOfYear))!
    }
    
    /// The first moment of this month.
    @inlinable
    public var start: CalendarDate {
        CalendarDate(firstInstance)
    }
    
    /// The list of all days in the given month ordered by date.
    @inlinable
    public var days: [Day] {
        Day.subdivisions(of: .day, in: .month, for: firstInstance)
    }
    
    // MARK: - Retrieving Containing Subdivisions
    
    /// The year containing the receiver.
    @inlinable
    public var year: Year {
        .init(id: id)
    }
}

extension Month: CustomDebugStringConvertible {
    @inlinable
    public var debugDescription: String {
        description
    }
}

extension Month: LosslessStringConvertible, CustomStringConvertible {
    public init?(_ description: String) {
        guard let date = try? Date(description, strategy: .iso8601.year().month()) else {
            return nil
        }
        self.init(date)
    }
    
    @inlinable
    public var description: String {
        "\(yearOfEra)-\(monthOfYear)"
    }
}
