//
//  TimeDifference.swift
//  SemanticalKit
//
//  Created by Jürgen on 28.05.23.
//

import Foundation

/// An amount of time.
///
/// On its own, a time difference does not specify a span between specific
/// dates. Combining a time difference with a calendar date yields a CalendarDateInterval value.
public struct TimeDifference: Hashable, Sendable {
    public let minutes: Int
    
    /// Creates a time difference of 0 minutes.
    public init() {
        self.minutes = 0
    }

    /// Creates a time difference based on the given number of minutes.
    public init(minutes: Int) {
        self.minutes = minutes
    }

    public static func minutes(_ value: Int) -> TimeDifference {
        TimeDifference(minutes: value)
    }
}

extension TimeDifference: DurationProtocol {
    public static func + (lhs: TimeDifference, rhs: TimeDifference) -> TimeDifference {
        .minutes(lhs.minutes + rhs.minutes)
    }

    public static func - (lhs: TimeDifference, rhs: TimeDifference) -> TimeDifference {
        .minutes(lhs.minutes - rhs.minutes)
    }

    public static func * (lhs: TimeDifference, rhs: Int) -> TimeDifference {
        .minutes(lhs.minutes * rhs)
    }

    public static func / (lhs: TimeDifference, rhs: Int) -> TimeDifference {
        .minutes(lhs.minutes / rhs)
    }

    public static func / (lhs: TimeDifference, rhs: TimeDifference) -> Double {
        Double(lhs.minutes) / Double(rhs.minutes)
    }

    public static var zero: TimeDifference {
        .minutes(0)
    }

    public static func < (lhs: TimeDifference, rhs: TimeDifference) -> Bool {
        lhs.minutes < rhs.minutes
    }
}

extension TimeDifference: Codable {
    public init(from decoder: Decoder) throws {
        minutes = try Int(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        try minutes.encode(to: encoder)
    }
}
