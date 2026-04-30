# Getting Started

This guide walks through installing the DateTime library, integrating it into a Modelica model, and using its core components.

---

## Installation

1. **Clone the repository:**
   ```
   git clone https://github.com/pstelzig/DateTime.git
   ```

2. **Load in your Modelica environment:**
   Open `<clone_dir>/src/DateTime/package.mo` in your Modelica IDE.
   The library has been tested with OpenModelica >= 1.25. It depends on `Modelica 4.0.0`.

---

## Integration in Three Steps

### 1. Add a `DateTimeSystem`

Every model using DateTime requires exactly one `inner DateTimeSystem` at the top level. This component anchors the simulation clock to an absolute calendar date and timezone.

```modelica
inner DateTime.DateTimeSystem dateTimeSystem(
  startDateTime = "2025-10-03T08:00:00",
  timezone      = DateTime.Data.Timezones.Europe.Berlin,
  holidays      = {"2025-12-25", "2025-12-26"});
```

| Parameter | Description |
|---|---|
| `startDateTime` | ISO 8601 string mapped to simulation time `t = 0` |
| `timezone` | A predefined `DateTime.Types.Timezone` record |
| `holidays` | Array of ISO 8601 date strings (`YYYY-MM-DD`) |
| `workdays` | Which days of the week are workdays (default: Mon–Fri) |
| `withLeapSeconds` | Enable experimental leap second correction (default: `false`) |

### 2. Read the Calendar Clock

Add a `DateTime.Basic.SimDateTime` component. It outputs the current calendar date and time decomposed into individual signals:

```modelica
DateTime.Basic.SimDateTime simDateTime;
```

**Outputs:** `year`, `month`, `day`, `hours`, `minutes` (Integer), `seconds` (Real), `dayOfWeek` (Integer, 0 = Sunday, negative = holiday).

### 3. Schedule Events

Add a `DateTime.Basic.Schedule` component to trigger a boolean output at a specific calendar time, optionally with repetition:

```modelica
DateTime.Basic.Schedule shift(
  triggerDateTime = "2025-10-03T08:00:00",
  onTime          = 28800,
  repetition      = "workdays");
```

The output `y` is `true` for `onTime` seconds starting at each trigger. Use `edge(shift.y)` to detect transitions.

**Available repetition rules:**

| Rule | Meaning |
|---|---|
| `""` (empty) | Single trigger, no repetition |
| `"hourly"` | Every hour |
| `"daily"` | Every day |
| `"weekly"` | Every week |
| `"monthly"` | Same day each month |
| `"yearly"` | Same date each year |
| `"workdays"` | Every workday (respects holidays) |
| `"firstDayInMonth"` | First day of each month |
| `"lastDayInMonth"` | Last day of each month |
| `"<number>"` | Arbitrary interval in seconds (e.g., `"4500"`) |

---

## Additional Components

### `SimPosixTime`

Converts the current simulation time to an absolute POSIX timestamp (seconds since 1970-01-01 UTC):

```modelica
DateTime.Basic.SimPosixTime simPosixTime;
// simPosixTime.y is the POSIX timestamp
```

### `Timer`

A countdown timer that begins at a specified calendar time and counts down linearly:

```modelica
DateTime.Basic.Timer timer(
  triggerDateTime = "2025-12-31T23:59:00",
  countdownTime   = 60);
// timer.y counts from 60 down to 0 starting at 23:59
```

---

## Worked Examples

The `DateTime.Examples` package contains ready-to-simulate models.

### Calendar-Triggered Reset (`PowerMeter`)

A power meter accumulates energy and resets on the first day of each month. The `Schedule` component drives the reset input of an integrator — a pattern useful for metering, billing, or periodic reporting, e.g. in energy system models.

### Workday Load Profile (`RollingMillStart`)

A rolling mill with a 4-hour power profile (14 400 s) must run every workday at 08:00. The setup:

1. A `Schedule` component with `repetition = "workdays"` and `onTime = 14400` produces a boolean signal.
2. The boolean input starts a `Modelica.Blocks.Logical.Timer` that feeds elapsed time into a `CombiTable1D` holding the load profile.

Holidays and DST transitions are handled automatically. This pattern generalises to any repeating industrial or building load profile.

### Other Examples

| Model | Purpose |
|---|---|
| `ToSimPosixTime` | Demonstrate POSIX timestamp conversion |
| `ToSimDateTime` | Demonstrate calendar date output |
| `ToSimWeekday` | Demonstrate weekday / holiday detection |
| `ScheduledSignals` | Multiple schedules with different repetition rules |

---

## Solver Considerations

DateTime introduces discrete-time events into continuous simulations. For correct results:

- Use an event-capable solver.
- Choose a communication interval small enough to capture schedule transitions.
- Apply `edge()` on boolean outputs of `Schedule` to help the solver detect state events.
- Verify that solver tolerance and step size adequately resolve the time-discrete outputs.
