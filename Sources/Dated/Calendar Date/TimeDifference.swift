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

// MARK: - FormatStyle

extension TimeDifference {
    public var duration: Duration {
        .seconds(seconds)
    }
    
    public func formatted() -> String {
        UnitsFormatStyle.units().format(self)
    }
    
    public func formatted<Style>(_ style: Style) -> String
    where Style: FormatStyle, Style.FormatInput == TimeDifference, Style.FormatOutput == String {
        style.format(self)
    }
    
    public struct UnitsFormatStyle: FormatStyle {
        public typealias FormatInput = TimeDifference
        public typealias FormatOutput = String
        
        private var formatStyle: Duration.UnitsFormatStyle
        
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
        
        public func format(_ value: TimeDifference) -> String {
            formatStyle.format(value.duration)
        }
    }
}

extension FormatStyle where Self == TimeDifference.UnitsFormatStyle {
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

#if canImport(Playgrounds)
import Playgrounds

#Playground("TimeDifference.FormatStyle") {
    let fiveMin = TimeDifference.seconds(5 * 60).formatted()
    let twoHr = TimeDifference.seconds(2 * 60 * 60).formatted()
}
#endif
