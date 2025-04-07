// Copyright (c) 2024 Semantical GmbH & Co. KG
// Licensed under the MIT License. See LICENSE file.

import Foundation

/// An amount of time.
///
/// On its own, a time difference does not specify a span between specific
/// dates. Combining a time difference with a calendar date yields a CalendarDateInterval value.
public struct TimeDifference: Hashable, Sendable, RawRepresentable {
   
    public var seconds: Int
    
    public var minutes: Int { seconds / 60 }
    
    public var rawValue: Int { seconds }
    
    /// Creates a time difference of 0 seconds.
    public init() {
        self.seconds = 0
    }
    
    /// Creates a time difference based on the given number of minutes.
    public init(seconds: Int) {
        self.seconds = seconds
    }
    
    public init?(rawValue: Int) {
        self.seconds = rawValue
    }
    
    public static func seconds(_ value: Int) -> TimeDifference {
        TimeDifference(seconds: value)
    }
    
    public static func minutes(_ value: Int) -> TimeDifference {
        TimeDifference(seconds: value * 60)
    }
}

extension TimeDifference: DurationProtocol {
    public static func + (lhs: TimeDifference, rhs: TimeDifference) -> TimeDifference {
        .seconds(lhs.seconds + rhs.seconds)
    }
    
    public static func - (lhs: TimeDifference, rhs: TimeDifference) -> TimeDifference {
        .seconds(lhs.seconds - rhs.seconds)
    }
    
    public static func * (lhs: TimeDifference, rhs: Int) -> TimeDifference {
        .seconds(lhs.seconds * rhs)
    }
    
    public static func / (lhs: TimeDifference, rhs: Int) -> TimeDifference {
        .seconds(lhs.seconds / rhs)
    }
    
    public static func / (lhs: TimeDifference, rhs: TimeDifference) -> Double {
        Double(lhs.seconds) / Double(rhs.seconds)
    }
    
    public static var zero: TimeDifference {
        .seconds(0)
    }
    
    public static func < (lhs: TimeDifference, rhs: TimeDifference) -> Bool {
        lhs.seconds < rhs.seconds
    }
}

extension TimeDifference: Codable {
    public init(from decoder: Decoder) throws {
        seconds = try Int(from: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        try seconds.encode(to: encoder)
    }
}
