# ``Dated``

Work with dates in a way that aligns with a users' mental model, rather than physical time.

## Overview

The Dated framework provides types for modeling calendrical concepts in a way that resembles a paper-based calendar. This is distinct from Apple's `Date` type, which can change interpretation depending on the time zone. For instance, a journaling app user who creates an entry at 10 in the morning may find that when they travel to a different time zone, the same journal entry may appear at a different hour of day, or even on a different day, when modeled using the `Date` type. The Dated framework, on the other hand, provides a ``CalendarDate`` type that stores calendar components such as year, month, day, and hour of day directly, so it does not change when the time zone changes.

The ``CalendarDate`` type depends on the current calendar. If a user changes their preferred calendar, this type of date becomes invalid. To avoid this, Dated offers the ``LocalDate`` type, which stores both a time zone and date value. This allows local date values to be interpreted correctly regardless of the calendar. Use local dates as your source of truth, and ``CalendarDate`` values in caches or memory. This will ensure that calendar date values behave correctly, while still allowing users to change their preferred calendar.

It is acceptable to store ``CalendarDate`` values in persistent memory, such as a cache. To do this, calendar dates can be represented by an integer whose order is equivalent to the order of the dates they represent. However, if a user changes their preferred calendar, it is essential to rebuild the cache.

## Topics

### Introduction

- <doc:_Introduction>

### Dates and Intervals

- ``CalendarDate``
- ``CalendarDateInterval``
- ``TimeDifference``
- ``LocalDate``

### Days, Weeks, Months, and Years

- ``Day``
- ``Week``
- ``Month``
- ``Year``
- ``CalendarSubdivision``
