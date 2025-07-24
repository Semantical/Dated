// Copyright (c) 2024 Semantical GmbH & Co. KG
// Licensed under the MIT License. See LICENSE file.

import Foundation

/// An amount of time.
///
/// On its own, a time difference does not specify a span between specific
/// dates. Combining a time difference with a calendar date yields a CalendarDateInterval value.
public struct TimeDifference: Hashable, Sendable, RawRepresentable {
   
    public var seconds: Int
    
    @inlinable
    public var minutes: Int { seconds / 60 }
    
    @inlinable
    public var rawValue: Int { seconds }
    
    /// Creates a time difference of 0 seconds.
    @inlinable
    public init() {
        self.seconds = 0
    }
    
    /// Creates a time difference based on the given number of minutes.
    @inlinable
    public init(seconds: Int) {
        self.seconds = seconds
    }
    
    @inlinable
    public init?(rawValue: Int) {
        self.seconds = rawValue
    }
    
    @inlinable
    public static func seconds(_ value: Int) -> TimeDifference {
        TimeDifference(seconds: value)
    }
    
    @inlinable
    public static func minutes(_ value: Int) -> TimeDifference {
        TimeDifference(seconds: value * 60)
    }
}

extension TimeDifference: DurationProtocol {
    @inlinable
    public static func + (lhs: TimeDifference, rhs: TimeDifference) -> TimeDifference {
        .seconds(lhs.seconds + rhs.seconds)
    }
    
    @inlinable
    public static func - (lhs: TimeDifference, rhs: TimeDifference) -> TimeDifference {
        .seconds(lhs.seconds - rhs.seconds)
    }
    
    @inlinable
    public static func * (lhs: TimeDifference, rhs: Int) -> TimeDifference {
        .seconds(lhs.seconds * rhs)
    }
    
    @inlinable
    public static func / (lhs: TimeDifference, rhs: Int) -> TimeDifference {
        .seconds(lhs.seconds / rhs)
    }
    
    @inlinable
    public static func / (lhs: TimeDifference, rhs: TimeDifference) -> Double {
        Double(lhs.seconds) / Double(rhs.seconds)
    }
    
    @inlinable
    public static var zero: TimeDifference {
        .seconds(0)
    }
    
    @inlinable
    public static func < (lhs: TimeDifference, rhs: TimeDifference) -> Bool {
        lhs.seconds < rhs.seconds
    }
}

extension TimeDifference: Codable {
    @inlinable
    public init(from decoder: Decoder) throws {
        seconds = try Int(from: decoder)
    }
    
    @inlinable
    public func encode(to encoder: Encoder) throws {
        try seconds.encode(to: encoder)
    }
}

/// Negate a ``TimeDifference``.
public prefix func - (rhs: TimeDifference) -> TimeDifference {
    .seconds(-rhs.seconds)
}

// MARK: - FormatStyle

extension TimeDifference {
    @inlinable
    public var duration: Duration {
        .seconds(seconds)
    }
    
    @inlinable
    public func formatted() -> String {
        UnitsFormatStyle.units().format(self)
    }
    
    @inlinable
    public func formatted<Style>(_ style: Style) -> String
    where Style: FormatStyle, Style.FormatInput == TimeDifference, Style.FormatOutput == String {
        style.format(self)
    }
    
    public struct UnitsFormatStyle: FormatStyle {
        public typealias FormatInput = TimeDifference
        public typealias FormatOutput = String
        
        @usableFromInline
        var formatStyle: Duration.UnitsFormatStyle
        
        @inlinable
        public init(
            allowedUnits: Set<Duration.UnitsFormatStyle.Unit>,
            width: Duration.UnitsFormatStyle.UnitWidth,
            maximumUnitCount: Int? = nil,
            zeroValueUnits: Duration.UnitsFormatStyle.ZeroValueUnitsDisplayStrategy = .hide,
            valueLength: Int? = nil,
            fractionalPart: Duration.UnitsFormatStyle.FractionalPartDisplayStrategy = .hide,
        ) {
            self.formatStyle = .init(
                allowedUnits: allowedUnits,
                width: width,
                maximumUnitCount: maximumUnitCount,
                zeroValueUnits: zeroValueUnits,
                valueLength: valueLength,
                fractionalPart: fractionalPart,
            )
        }
        
        @inlinable
        public func format(_ value: TimeDifference) -> String {
            formatStyle.format(value.duration)
        }
    }
}

extension FormatStyle where Self == TimeDifference.UnitsFormatStyle {
    @inlinable
    public static func units(
        allowed units: Set<Duration.UnitsFormatStyle.Unit> = [.hours, .minutes, .seconds],
        width: Duration.UnitsFormatStyle.UnitWidth = .abbreviated,
        maximumUnitCount: Int? = nil,
        zeroValueUnits: Duration.UnitsFormatStyle.ZeroValueUnitsDisplayStrategy = .hide,
        valueLength: Int? = nil,
        fractionalPart: Duration.UnitsFormatStyle.FractionalPartDisplayStrategy = .hide
    ) -> Self {
        .init(
            allowedUnits: units,
            width: width,
            maximumUnitCount: maximumUnitCount,
            zeroValueUnits: zeroValueUnits,
            valueLength: valueLength,
            fractionalPart: fractionalPart,
        )
    }
}

//#if canImport(Playgrounds)
//import Playgrounds
//
//#Playground("TimeDifference.FormatStyle") {
//    let fiveMin = TimeDifference.seconds(5 * 60).formatted()
//    let twoHr = TimeDifference.seconds(2 * 60 * 60).formatted()
//}
//#endif
