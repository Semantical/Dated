//
//  CalendarDate.swift
//  Dated
//
//  Created by Jürgen on 25.05.23.
//

import Foundation

/// A point in time relative to the current calendar.
public struct CalendarDate: Hashable, Sendable {
    /// An integer suitable to be used as a key in a database table.
    ///
    /// - note: The ordering of ``CalendarDate`` values is the same as the ordering of their IDs. If both `date1` and `date2` are ``CalendarDate`` values, `date1` is ordered before `date2` when its ID is lower than `date2`'s.
    public let id: Int
    
    /// Creates a calendar date from the current date at the moment of access.
    public init() {
        self.init(Date.now)
    }

    /// Creates a calendar date from the given identifier.
    ///
    /// - important: Do not try to generate your own IDs. Use this initializer only to recreate a calendar date whose ID has been saved previously.
    public init(id: Int) {
        self.id = id
    }

    /// Creates a calendar date preserving the hour of day from the original
    /// time zone.
    public init(_ localDate: LocalDate) {
        self = localDate.calendarDate
    }

    /// Creates a calendar date in the user's preferrend calendar.
    public init(_ date: Date) {
        let components = CalendarDate.calendar.dateComponents(
            [.second, .minute, .hour, .day, .month, .year, .era], from: date
        )
        let reconstructedDate = CalendarDate.calendar.date(from: components)!
        // Daylight saving time
        let dLST = abs(date.timeIntervalSince(reconstructedDate)) >= 60.0
        self.init(components: components, dLSTFlag: dLST)
    }

    /// Returns the current date at the moment of access.
    public static var now: CalendarDate { CalendarDate() }

    init(components: DateComponents, dLSTFlag: Bool = false) {
        let dLST   = (dLSTFlag ? 1 : 0)       << dLSTOffset
        let second = (components.second ?? 0) << secondOffset
        let minute = (components.minute ?? 0) << minuteOffset
        let hour   = (components.hour   ?? 0) << hourOffset
        let day    = (components.day    ?? 0) << dayOffset
        let month  = (components.month  ?? 0) << monthOffset
        let year   = (components.year   ?? 0) << yearOffset
        let era    = (components.era    ?? 0) << eraOffset

        id = dLST + second + minute + hour + day + month + year + era
    }


    // MARK: - Working with System Dates

    /// The date represented by the given calendar date.
    public var date: Date {
        let components = DateComponents(era: era,
                                        year: yearOfEra,
                                        month: monthOfYear,
                                        day: dayOfMonth,
                                        hour: hourOfDay,
                                        minute: minuteOfHour,
                                        second: secondOfHour)
        let date = CalendarDate.calendar.date(from: components)!
        return dLST ? date.addingTimeInterval(3600): date
    }

    // Daylight saving time
    var dLST: Bool {
        ((id & dLSTMask) >> dLSTOffset) ==  1
    }


    // MARK: - Retrieving Containing Subdivisions

    /// The day containing the given calendar date.
    public var day: Day {
        .init(id: id)
    }

    /// The week containing the given calendar date.
    public var week: Week {
        return .init(date)
    }

    /// The month containing the given calendar date.
    public var month: Month {
        .init(id: id)
    }

    /// The year containing the given calendar date.
    public var year: Year {
        .init(id: id)
    }

    /// The containing subdivision corresponding to `unit`.
    public func subdivision(for unit: Unit) -> any CalendarSubdivision {
        switch unit {
        case .year:  return year
        case .month: return month
        case .week:  return week
        case .day:   return day
        case .era:
            fatalError("Not implemented")
        }
    }


    // MARK: - Accessing Calendar Components

    /// The second component.
    public var secondOfHour: Int {
        (id & secondMask) >> secondOffset
    }
    
    /// The minute component.
    public var minuteOfHour: Int {
        (id & minuteMask) >> minuteOffset
    }

    /// The hour component.
    public var hourOfDay: Int {
        (id & hourMask) >> hourOffset
    }

    /// The day component.
    public var dayOfMonth: Int {
        (id & dayMask) >> dayOffset
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


    // MARK: - Adding and Subtracting Components

    public enum Unit {
        case era, year, month, week, day

        var nativeComponent: Calendar.Component {
            switch self {
            case .era:   return .era
            case .year:  return .year
            case .month: return .month
            case .week:  return .weekOfYear
            case .day:   return .day
            }
        }
    }

    public struct Components {
        public let eras:   Int?
        public let years:  Int?
        public let months: Int?
        public let weeks:  Int?
        public let days:   Int?

        public init(eras:   Int? = nil,
                    years:  Int? = nil,
                    months: Int? = nil,
                    weeks:  Int? = nil,
                    days:   Int? = nil) {
            self.eras   = eras
            self.years  = years
            self.months = months
            self.weeks  = weeks
            self.days   = days
        }

        public static func   eras(_ count: Int) -> Self { .init(eras: count) }
        public static func  years(_ count: Int) -> Self { .init(years: count) }
        public static func months(_ count: Int) -> Self { .init(months: count) }
        public static func  weeks(_ count: Int) -> Self { .init(weeks: count) }
        public static func   days(_ count: Int) -> Self { .init(days: count) }

        public static func count(_ count: Int, of unit: CalendarDate.Unit) -> Self {
            switch unit {
            case .era:   return eras(count)
            case .year:  return years(count)
            case .month: return months(count)
            case .week:  return weeks(count)
            case .day:   return days(count)
            }
        }

        var nativeComponents: DateComponents {
            DateComponents(era: eras, year: years, month: months, day: days, weekOfYear: weeks)
        }

        func negated() -> Self {
            .init(eras: negate(eras), years: negate(years), months: negate(months), weeks: negate(weeks), days: negate(days))
        }

        private func negate(_ value: Int?) -> Int? {
            guard let value = value else { return nil }
            return -value
        }
    }

    /// Returns a calendar date offset by adding components to a given
    /// calendar date.
    public static func + (lhs: CalendarDate, rhs: Components) -> CalendarDate {
        .init(CalendarDate.calendar.date(byAdding: rhs.nativeComponents, to: lhs.date)!)
    }

    /// Returns a calendar date offset by subtracting components from a
    /// given calendar date.
    public static func - (lhs: CalendarDate, rhs: Components) -> CalendarDate {
        .init(CalendarDate.calendar.date(byAdding: rhs.negated().nativeComponents, to: lhs.date)!)
    }

    /// Adds the given components to a calendar date.
    public static func += (lhs: inout CalendarDate, rhs: Components) {
        lhs = lhs + rhs
    }

    /// Subtracts the given components from a calendar date.
    public static func -= (lhs: inout CalendarDate, rhs: Components) {
        lhs = lhs - rhs
    }


    // MARK: - Getting Temporal Boundaries

    /// A calendar date in the distant future.
    public static let distantFuture = CalendarDate(Date.distantFuture)

    /// A local calendar in the distant past.
    public static let distantPast = CalendarDate(Date.distantPast)


    // MARK: - Current Calendar

    // We make the current calendar testable by going through a static
    // variable that can be changed during testing.
    nonisolated(unsafe) static var calendar = Calendar.current
}


// MARK: - Conformances

// InstantProtocol Conformance

extension CalendarDate: InstantProtocol {
    public func advanced(by duration: TimeDifference) -> CalendarDate {
        .init(date + Double(duration.seconds))
    }

    public func duration(to other: CalendarDate) -> TimeDifference {
        .seconds(Int(other.date.timeIntervalSince(date)))
    }
}

// Codable Conformance

extension CalendarDate: Codable {
    /// Creates a calendar date by decoding from the given decoder.
    public init(from decoder: Decoder) throws {
        self.init(id: try Int(from: decoder))
    }

    public func encode(to encoder: Encoder) throws {
        try id.encode(to: encoder)
    }
}

// Comparable Conformance

extension CalendarDate: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.id < rhs.id
    }
}

extension CalendarDate: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(yearOfEra)-\(monthOfYear)-\(dayOfMonth) \(hourOfDay):\(minuteOfHour):\(secondOfHour)"
    }
}

// MARK: - Bitmasks

// Number of bits each calendar subdivision is represented with.

let dLSTBits   = 1
let secondBits = 6 // 0...59
let minuteBits = 6 // 0...59
let hourBits   = 5 // 0...23
let dayBits    = 5 // 1...31
let monthBits  = 4 // 1..<13 (Hebrew, Ethiopic)

// Our bit patterns are either going to use `dayBits` + `monthsBits`, or:
let weekBits  =  6 // 1...55 (Hebrew)

// The following two components will always be present.
let yearBits  = 20 // 0..<1_048_576 (> 7515, Ethiopic Amete Alem)
let eraBits   = 16 // 0..<65_536 (>  236, Japanese)


// The offset at which a calendar subdivision appears in the bit pattern.

let dLSTOffset   = 0
let secondOffset = dLSTOffset   + dLSTBits
let minuteOffset = secondOffset + secondBits
let hourOffset   = minuteOffset + minuteBits
let dayOffset    = hourOffset   + hourBits
let monthOffset  = dayOffset    + dayBits
let yearOffset   = monthOffset  + monthBits
let eraOffset    = yearOffset   + yearBits

// Our types use either (days, months) or weeks, so they can share the same
// place in the bit pattern:
let weekOffset   = dayOffset


// A mask starting at the lowest significant bit with a given length.
func mask(_ bits: Int) -> Int { (1 << bits) - 1 }

let dLSTMask   = mask(dLSTBits)   << dLSTOffset
let secondMask = mask(secondBits) << secondOffset
let minuteMask = mask(minuteBits) << minuteOffset
let hourMask   = mask(hourBits)   << hourOffset
let dayMask    = mask(dayBits)    << dayOffset
let monthMask  = mask(monthBits)  << monthOffset
let weekMask   = mask(weekBits)   << dayOffset
let yearMask   = mask(yearBits)   << yearOffset
let eraMask    = mask(eraBits)    << eraOffset
