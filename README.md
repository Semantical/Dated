# Dated

Welcome to **Dated**, a Swift framework designed to help you work with dates in a way that aligns with a user's mental model, rather than physical time. This framework provides types for modeling calendrical concepts in a way that resembles a paper-based calendar, ensuring that dates and times remain consistent with user expectations, even across different time zones and calendar preferences.

### Key Features

- **`CalendarDate`**: A type that stores calendar components up to second precision, ensuring that dates are interpreted correctly regardless of the time zone.
- **`LocalDate`**: A type that stores both a time zone and date value, allowing dates to be interpreted correctly regardless of the calendar.
- **`Day`, `Week`, `Month`, `Year`**: Types for days, weeks, months, and years that conform to the `CalendarSubdivision` protocol, making it easy to perform calculations and iterate over ranges.
- **`CalendarDateInterval`**: A type for representing the span of time between a specific start date and end date.

`CalendarDate` and its subdivisions are wall-calendar-based, meaning that they are not affected by time zone changes. This makes them ideal for modeling dates and times in a way that aligns with a user's mental model. Another benefit is that this family of types can be persisted using a simple, ordered integer representation. However, they should only be used in caches.

> [!important]
> Use `LocalDate` in your source of truth. It is essential to invalidate cached `CalendarDate` or `CalendarSubdivision` (Day/Week/etc.) values if a user changes their preferred calendar.

## Installation

Add the following dependency to your `Package.swift` file:

```swift
.package(url: "https://github.com/semantical/Dated.git", from: "0.0.1")
```

> [!WARNING]
> This package is in beta and breaking changes may occur in patch releases.

## Usage

### Calendar Subdivisions

```swift
let localDate = LocalDate.now
let date = CalendarDate(localDate) // or: CalendarDate.now

let day   = date.day
let week  = date.week
let month = date.month
let year  = date.year
```

Perform calculations or iterate over ranges of calendar subdivisions.

```swift
let weekdays = Week.current.days

print(weekdays.map(\.veryShortWeekdaySymbol))
// On a system that uses a calendar with Monday as the first weekday,
// the result is ["M", "T", "W", "T", "F", "S", "S"]. If Sunday is the
// first weekday, we get ["S", "M", "T", "W", "T", "F", "S"] instead.

let today = Day.current

print(today.isInWeekend)
// Returns `true` when called on a weekend.

print(today.isToday)
// Always `true`.

// Print 10 days starting today.
for day in today..<(today + .days(10)) {
    print(day.dayOfMonth)
}

// The same day next year.
let sameDayNextYear = today + .years(1)
```

### Time Differences and Date Intervals

You can create and manipulate time differences and date intervals easily.

```swift
let startDate = CalendarDate.now
let endDate = startDate + .days(5)

let interval = CalendarDateInterval(start: startDate, end: endDate)

print(interval.contains(CalendarDate.now)) // true

let duration = TimeDifference.minutes(120)
let newEndDate = startDate + duration

// Iterate over the daily intervals within the date interval.
for interval in interval.intervalsPerDay() {
    // ...
}
```
