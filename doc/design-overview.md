# Design Overview

This document describes the architecture, design rationale, and component structure of the DateTime library.

---

## Architecture

The library is structured around a single shared state object (`DateTimeSystem`) that anchors simulation time to the calendar, and a set of functional blocks that query or act upon that anchor.

```
┌─────────────────────────────────────────────────────────────────────┐
│  User Model (top level)                                             │
│                                                                     │
│  ┌───────────────────────────────────────┐                          │
│  │  inner DateTimeSystem                 │                          │
│  │  ┌─────────────────────────────────┐  │                          │
│  │  │ startDateTime  "2025-10-03T08:00│  │                          │
│  │  │ timezone       Europe.Berlin    │  │                          │
│  │  │ holidays       {"2025-12-25"}   │  │                          │
│  │  │ workdays       {Mon..Fri}       │  │                          │
│  │  └─────────────┬───────────────────┘  │                          │
│  └────────────────│──────────────────────┘                          │
│                   │  outer reference                                │
│     ┌─────────────┼──────────────────────────────────┐              │
│     │             │                                  │              │
│     ▼             ▼                                  ▼              │
│  ┌─────────┐  ┌──────────┐  ┌────────────────┐  ┌────────┐          │
│  │SimDate- │  │Schedule  │  │ SimPosixTime   │  │ Timer  │          │
│  │Time     │  │          │  │                │  │        │          │
│  │         │  │ trigger  │  │ y = POSIX      │  │ y = ↓  │          │
│  │ year    │  │ onTime   │  │   timestamp    │  │ count- │          │
│  │ month   │  │ repeti-  │  │                │  │ down   │          │
│  │ day     │  │ tion     │  └────────────────┘  └────────┘          │
│  │ hours   │  │          │                                          │
│  │ minutes │  │ y: Bool  │                                          │
│  │ seconds │  └──────────┘                                          │
│  │ dayOf   │                                                        │
│  │ Week    │                                                        │
│  └─────────┘                                                        │
└─────────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
  simulation time (t)
        │
        ▼
  ┌───────────────┐    parseDatetime()     ┌──────────────┐
  │ DateTimeSystem├────────────────────►   │ startPosix   │
  │ startDateTime │    datetimeToPosix()   │ (UTC anchor) │
  └──────┬────────┘                        └──────┬───────┘
         │                                        │
         │  posix = startPosix + t                │
         │◄───────────────────────────────────────┘
         │
         ▼
  ┌───────────────────┐
  │ posixToDatetime() │──► year, month, day, hours, min, sec
  │ dayOfWeek()       │──► weekday (negative if holiday)
  └───────────────────┘
```

At initialisation, `DateTimeSystem` converts the user-supplied ISO 8601 string into a POSIX timestamp (seconds since 1970-01-01 UTC). During simulation, each block computes `posix = startPosix + time` and converts back to calendar quantities as needed.

---

## Package Structure

```
DateTime/
├── DateTimeSystem        Central anchor: start date, timezone, holidays
├── UsersGuide            In-model documentation
│
├── Basic/                User-facing blocks
│   ├── SimDateTime       Calendar clock (year … seconds + weekday)
│   ├── SimPosixTime      Absolute POSIX timestamp
│   ├── SimWeekday        Day-of-week with holiday flag
│   ├── Schedule          Boolean trigger with repetition
│   └── Timer             Countdown timer
│
├── Data/                 Static data records
│   ├── Epoch             POSIX epoch (1970-01-01)
│   ├── MonthDays         Days per month (non-leap year)
│   ├── LeapSeconds       27 historical leap seconds
│   ├── WorkDays          Default workweek definition
│   └── Timezones/        200+ predefined timezone records
│       ├── Africa, America, Antarctica, Arctic, Asia,
│       │   Atlantic, Australia, Etc, Europe, Indian, Pacific
│       └── (organised by IANA Region.City convention)
│
├── Functions/            Pure functions (parsing, conversion, arithmetic)
├── Types/                Records: Datetime, Timefield, Timezone
├── Interfaces/           Partial blocks (SO, MO, BooleanSO, …)
├── Icons/                Graphical annotations
└── Examples/
    └── UnitTests/        Automated verification models
```

A modeler typically interacts only with `DateTimeSystem`, `Basic.*`, and `Data.Timezones.*`. Everything else is internal machinery.

---

## Design Rationale

### Why Modelica-native?

The library implements all date/time arithmetic in pure Modelica rather than delegating to `external "C"` calls into `time.h` or `std::chrono`. The reasons are:

1. **Reproducibility.** System-level time libraries differ across platforms and OS versions. A Modelica-native implementation guarantees identical results regardless of the host system.

2. **Forward modelling.** Simulations often run into the future, where DST rules may change or be abolished. Embedding the timezone rules in the model data makes the assumptions explicit and auditable.

3. **Portability.** No compiler toolchain or external library dependency is required. The library works on any Modelica tool that supports MSL 4.0.0.

> A previous version of DateTime used Boost.Date_Time via `external "C"`. The pure-Modelica rewrite eliminated all platform-dependent behaviour.

### Inner/Outer Pattern

`DateTimeSystem` uses Modelica's `inner`/`outer` mechanism. The user places a single `inner DateTimeSystem` at the top level; all `Basic.*` blocks reference it as `outer`. This avoids parameter duplication and ensures a consistent time base throughout the model hierarchy.

### Encapsulation of Internals

The public API consists of block parameters (ISO 8601 strings, timezone records, repetition keywords) and block outputs (Integer/Real signals). The internal conversion pipeline — POSIX arithmetic, DST offset computation, leap second correction — is hidden in `Functions` and `Types`. This separation allows the implementation to evolve without breaking user models.

---

## Limitations

- **Static DST rules.** Timezone records define a single, fixed DST rule. Changes to DST policy during simulation time are not modelled.
- **Leap seconds.** Support is experimental and disabled by default (`withLeapSeconds = false`).
- **Solver sensitivity.** Correct detection of schedule transitions depends on the solver's event-handling capabilities and the chosen communication interval.
