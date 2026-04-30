# Timezones & Scheduling

This document covers timezone data, the ISO 8601 conventions used by DateTime, daylight saving time handling, and leap second support.

---

## ISO 8601 Format

All date and time inputs in DateTime use ISO 8601 strings:

| Format | Example | Used for |
|---|---|---|
| `YYYY-MM-DDTHH:MM:SS` | `2025-10-03T08:00:00` | `startDateTime`, `triggerDateTime` |
| `YYYY-MM-DDTHH:MM:SS.SSSSSS` | `2025-10-03T08:00:00.123456` | Sub-second precision |
| `YYYY-MM-DD` | `2025-12-25` | Holiday definitions |

The `T` separator between date and time is mandatory.

---

## Predefined Timezones

DateTime ships with 200+ timezone definitions in `DateTime.Data.Timezones`, organised by IANA region:

| Package | Examples |
|---|---|
| `Africa` | `Africa.Cairo`, `Africa.Johannesburg` |
| `America` | `America.New_York`, `America.Los_Angeles`, `America.Chicago` |
| `Asia` | `Asia.Tokyo`, `Asia.Shanghai`, `Asia.Kolkata` |
| `Australia` | `Australia.Sydney`, `Australia.Perth` |
| `Europe` | `Europe.Berlin`, `Europe.London`, `Europe.Paris` |
| `Etc` | `Etc.UTC`, `Etc.GMT` |
| `Pacific` | `Pacific.Auckland`, `Pacific.Honolulu` |
| `Antarctica`, `Arctic`, `Atlantic`, `Indian` | Various regional entries |

Named abbreviations are available where conventional, e.g.:

- `Europe.CET_CEST` — Central European Time / Central European Summer Time
- `America.PST_PDT` — Pacific Standard Time / Pacific Daylight Time
- `America.EST_EDT` — Eastern Standard Time / Eastern Daylight Time
- `Asia.CST` — China Standard Time

### Using a Timezone

Assign any predefined timezone to `DateTimeSystem.timezone` or to a `Schedule.triggerTimezone`:

```modelica
inner DateTime.DateTimeSystem dateTimeSystem(
  startDateTime = "2025-06-15T12:00:00",
  timezone      = DateTime.Data.Timezones.America.New_York);
```

A `Schedule` can override the system timezone to trigger in a different region:

```modelica
DateTime.Basic.Schedule londonMeeting(
  triggerDateTime = "2025-06-16T09:00:00",
  onTime          = 3600,
  repetition      = "workdays",
  triggerTimezone  = DateTime.Data.Timezones.Europe.London);
```

---

## Custom Timezones

Custom timezones follow IEEE Std 1003.1 (POSIX TZ) notation:

```
STD_NAME OFFSET_UTC [DST_NAME OFFSET_DST, START_OF_DST/TIME, END_OF_DST/TIME]
```

**Fields** (concatenated without spaces):

| Field | Description | Example |
|---|---|---|
| `STD_NAME` | Standard time abbreviation | `CET` |
| `OFFSET_UTC` | Offset from UTC (signed) | `+01:00:00` |
| `DST_NAME` | Daylight saving abbreviation | `CEST` |
| `OFFSET_DST` | DST offset relative to standard time | `+01:00:00` |
| `START_OF_DST/TIME` | DST start in `Mm.w.d/HH:MM:SS` form | `M3.5.0/02:00:00` |
| `END_OF_DST/TIME` | DST end in `Mm.w.d/HH:MM:SS` form | `M10.5.0/03:00:00` |

In `Mm.w.d`: month `m` in {1..12}, week `w` in {1..5} (5 = last), day `d` in {0..6} (0 = Sunday).

**Example with DST:**
```
CET+01:00:00CEST+01:00:00,M3.5.0/02:00:00,M10.5.0/03:00:00
```
CET is UTC+1. CEST adds 1 h. DST starts last Sunday of March at 02:00, ends last Sunday of October at 03:00.

**Example without DST:**
```
HKT+08:00:00
```
Hong Kong Time, UTC+8, no daylight saving.

---

## Daylight Saving Transitions

DST transitions create two edge cases:

### Spring Forward (Gap)

When clocks jump ahead, a range of local times does not exist. For example, in CET/CEST the interval 02:00–03:00 on the last Sunday of March is skipped. If a `triggerDateTime` falls into this gap and `autocorrect = true` (default), the library adjusts according to the chosen `strategy` parameter:

| Strategy | Behaviour |
|---|---|
| `"time_from_day_start"` | Interpret as elapsed time from midnight |
| `"time_to_day_end"` | Interpret as remaining time to midnight |

### Fall Back (Overlap)

When clocks fall back, a range of local times occurs twice. For example, in CET/CEST the interval 02:00–03:00 on the last Sunday of October is ambiguous.

To resolve this, append a timezone abbreviation to the ISO 8601 string:

```
2025-10-26T02:30 CET     ← standard time (after fall-back)
2025-10-26T02:30 CEST    ← daylight saving time (before fall-back)
```

This disambiguation mechanism is available for all named timezones.

---

## Workdays and Holidays

The `DateTimeSystem` component defines which days constitute the workweek and which dates are holidays:

```modelica
inner DateTime.DateTimeSystem dateTimeSystem(
  startDateTime = "2025-01-01T00:00:00",
  timezone      = DateTime.Data.Timezones.Europe.Berlin,
  workdays      = DateTime.Data.WorkDays(days = {1, 2, 3, 4, 5}),
  holidays      = {"2025-01-01", "2025-04-18", "2025-12-25", "2025-12-26"});
```

Day encoding: 0 = Sunday, 1 = Monday, …, 6 = Saturday.

A `Schedule` with `repetition = "workdays"` will skip holidays and non-workdays automatically. The `SimDateTime` and `SimWeekday` blocks report holidays as negative `dayOfWeek` values.

---

## Leap Seconds

Leap second support is **experimental** and disabled by default. When enabled, the library accounts for the 27 historical leap seconds inserted between 1972 and 2016.

```modelica
inner DateTime.DateTimeSystem dateTimeSystem(
  startDateTime    = "2025-01-01T00:00:00",
  timezone         = DateTime.Data.Timezones.Etc.UTC,
  withLeapSeconds  = true);
```

Internally, POSIX timestamps are adjusted by the cumulative leap second count at each point in time. Since POSIX time is defined as continuous (every day has exactly 86 400 s), a leap-second-adjusted computation shifts timestamps by the number of leap seconds elapsed.

> **Note:** No new leap seconds have been announced since 2016. The data in `DateTime.Data.LeapSeconds` reflects the historical record as of 2025.
