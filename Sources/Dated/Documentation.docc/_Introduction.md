# Creating and using calendar dates

Learn about the relationships between calendar date, local date, and how to represent calendrical concepts.

## Creating calendar dates

Create a ``LocalDate`` value to capture the current time zone automatically. Before using it in view models, convert the local calendar date to a ``CalendarDate`` value. You can create a calendar date directly from a system date. However, bear in mind that a calendar date is only valid until the user changes their preferred calendar.

```swift
// Capture the current moment and time zone.
let now = LocalDate.now

// If you have a date value, for example from a system call, you can use
// it to create a local date that preserves the time zone in which
// it was created.
let localDate = LocalDate(date)

let date = CalendarDate(localDate)

// Create a calendar date directly from a system date.
let anotherDate = CalendarDate(date: Date()))
```

``LocalDate`` conforms to `Codable` in a way that guarantees its binary representation is platform-independent.


## Days, weeks, months, and years

Values of type ``Day``, ``Week``, ``Month``, and ``Year``, which conform to the ``CalendarSubdivision`` protocol, represent the corresponding concepts in the user's preferred calendar. You can easily create a calendar subdivision from a calendar date.

```swift
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
// first weekday, we get ["S", "M", "T", "W", "T", "F", "S"]] instead.

let today = Day.current

print(today.isInWeekend)
// Returns `true` when called on a weekend.

print(today.isToday)
// Always `true`.

// Print 10 days starting today.
for day in today ..< today + .days(10) {
    print(day.dayOfMonth)
}

// The same day next year.
let sameDayNextYear = today + .years(1)
```
