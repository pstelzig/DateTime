# DateTime

**A Modelica-native library for calendrical dates, times, and scheduling.**

DateTime bridges the gap between Modelica's relative simulation clock and the real-world calendar. Drop a single `DateTimeSystem` component into your model and gain access to absolute dates, timezone-aware scheduling, daylight saving transitions, workday logic, and repeating calendar events — all without external C libraries.

---

### Key Capabilities

| Capability | What it does |
|---|---|
| **Time mapping** | Convert simulation time to absolute dates and vice versa |
| **Event scheduling** | Trigger at ISO 8601 dates with `Schedule` |
| **Repetition rules** | `hourly`, `daily`, `weekly`, `workdays`, `monthly`, and more |
| **Timezone support** | 200+ predefined IANA-style timezones with DST transitions |
| **Holiday / workday logic** | Define holidays and workweeks; schedules respect them automatically |

---

### Minimal Example

```modelica
model MyModel
  inner DateTime.DateTimeSystem dateTimeSystem(
    startDateTime = "2025-10-03T08:00:00",
    timezone      = DateTime.Data.Timezones.Europe.Berlin,
    holidays      = {"2025-12-25", "2025-12-26"});

  DateTime.Basic.SimDateTime simDateTime;

  DateTime.Basic.Schedule dailyTrigger(
    triggerDateTime = "2025-10-03T09:00:00",
    onTime          = 3600,
    repetition      = "workdays");
equation
  // simDateTime.year, .month, .day, .hours, .minutes, .seconds
  // dailyTrigger.y is true for 1 h every workday at 09:00
end MyModel;
```

---

### Getting Started

1. Clone the repository:
   ```
   git clone https://github.com/pstelzig/DateTime.git
   ```
2. Load `src/DateTime/package.mo` in your Modelica tool (tested with OpenModelica >= 1.25).
3. Place an `inner DateTimeSystem` in your top-level model and configure the start date, timezone, and holidays.

See the [Getting Started Guide](doc/getting-started.md) for a detailed walkthrough with examples.

---

### Documentation

| Document | Contents |
|---|---|
| [Getting Started](doc/getting-started.md) | Installation, integration, and usage examples |
| [Design Overview](doc/design-overview.md) | Architecture, rationale, and component reference |
| [Timezones & Scheduling](doc/timezones-and-scheduling.md) | Timezone data, ISO 8601 conventions, DST, leap seconds |

---

### Status

The library is in **active development**. Core functionality — date/time conversion, timezone handling, and scheduling — is implemented and covered by unit tests. Leap second support is experimental.

---

### How to Cite

```bibtex
@misc{stelzig2025datetime,
    author       = {Philipp Emanuel Stelzig},
    title        = {DateTime: A Modelica-native library for dates, times, and scheduling},
    year         = {2019--2025},
    howpublished = {\url{https://github.com/pstelzig/DateTime}}
}
```

---

### License

Developed by [Dr. Philipp Emanuel Stelzig](https://github.com/pstelzig) under the [MIT License](LICENSE).

Copyright © Dr. Philipp Emanuel Stelzig, 2019–present.
