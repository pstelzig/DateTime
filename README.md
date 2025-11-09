# DateTime: A Modelica-native library for dates, times, and scheduling

This library provides a self-contained, Modelica-native solution for:
- **Easy Integration**: Add to any Modelica model with a simple drag-and-drop of the `DateTimeSystem` component.
- **Time Mapping**: Convert relative simulation times to absolute calendrical dates and times, and vice-versa.
- **Event Triggering**: Schedule simulation events at human-readable dates and times.
- **Timezone Support**: Intuitively integrate multiple timezones, including daylight saving, into a single simulation.
- **Event Repetition**: Repeat events on human-centric schedules like `daily`, `workday`, or `firstDayOfMonth`.

## Quickstart
Using DateTime in your Modelica models is straightforward.

### Get the library
- Clone the repository: `git clone https://github.com/pstelzig/DateTime.git`
- Load the library in your Modelica environment (OpenModelica >= 1.25 works) by opening `<your_clone_dir>/src/DateTime/package.mo`.

### Integrate into your model
- Drag and drop a `DateTime.DateTimeSystem` component into your model.
- Set `startDateTime` to an ISO-8601 string (e.g., `2025-12-02T17:30:17.21`).
- Set `timezone` to a predefined value (e.g., `DateTime.Data.Timezones.Europe.Berlin`).
- Optionally, define `holidays` as a list of ISO-8601 strings (e.g., `{"2025-12-25", "2025-12-26"}`).

### Convert simulation time to calendrical time
- Add a `DateTime.Basic.SimDateTime` component to your model.
- After simulation, this component provides the date and time as integer outputs (`year`, `month`, `day`, `hours`, `minutes`), a real output (`seconds`), and the day of the week.

### Schedule events
- Add a `DateTime.Basic.Schedule` component to your model.
- Set `triggerDateTime` to an ISO-8601 string (e.g., `2025-12-07T02:33.9512`).
- Define `onTime` (duration the output is `true`) and a `repetition` rule (e.g., `daily`, `weekly`, `workdays`, `firstDayInMonth`).
- Use Modelica's `edge()` function on the component's boolean output to trigger events.


## Design
The DateTime library is designed for ease of use, encapsulating complex time conversion functionality. This approach allows future updates to the implementation of the computation itself -- whether Modelica-native or an external C/C++ library -- without altering the user-facing components. In fact, a previous implementation of the DateTime libray used Boost.Date_Time for the date and time conversions.

### Why Modelica-native instead of an `external "C"` with `time.h` or `std::chrono`?
The main reason to choose a Modelica-native implementation over a 3rd party library is to ensure independence of simulation results from system libraries. System libraries may vary from system to system, and change over time with updates. This is most obvious with `std::chrono`, which was introduced in its modern form with timezones only as part of C++20. Another reason is the ability to model and simulate different "futures", in particular in light of potential changes to daylight saving definitons or their abolition altogether. 

**Note** Currently, the DateTime library's `Timezone` objects do not allow for changes of daylight saving definitions during simulation time. 

### DateTime from the modeler's perspective
A typical Modelica modeler will interact with only a few components from the DateTime library:
- **`DateTimeSystem`**: Instantiate this component once at the top level of your model. It is referenced as an `outer` component by other DateTime objects.
- **`Schedule`**: This component can be assigned its own `timezone` to manage events across different regions.
- **Other Utilities**: `DateTime.Basic` includes other useful components like `SimPosixTime` (converts simulation time to a POSIX timestamp) and `Timer` (a countdown timer).

DateTime includes predefined timezones in `DateTime.Data.Timezones`, following the `<Region>.<City>` pattern (e.g., `Europe.Paris`, `America.Los_Angeles`). It also supports standard specifications like `Etc.UTC`. Several named timezones like CET (Central European Time) or PST (Pacific Standard Time) or CST (China Standard Time) are included in their respective region, like `Europe.CET_CEST` or `America.PST_PDT` or `Asia.CST`.

To model human-centric activities, you can define `holidays` and `workdays` in the `DateTimeSystem` component. A `Schedule` with its repetition set to `workdays` will only trigger on days that are not defined as holidays and are part of the workweek. This particularly useful when modeling e.g. shifts in industrial processes or energy systems. 

### Date and Time Formatting: ISO 8601
For ease of use, all date and time inputs should be ISO 8601 strings (e.g., `YYYY-MM-DDTHH:MM:SS`). To resolve ambiguity during daylight saving transitions, modelers must add a timezone identifier. For example, the time `2025-10-26T02:30` in the CET/CEST timezone falls into the "jump-back" transition when daylight saving ends, and is therefore ambiguous. Write `2025-10-26T02:30 CET` to interpret that time in standard time, or `2025-10-26T02:30 CEST` to interpret it as still in daylight saving time.

**Note**: DateTime was designed to make date and time definitions as human-readable and self-contained as possible. Modelers can use familiar ISO 8601 strings. Adding a timezone identifier to resolve ambiguities - effectively restricting this mechanism to named timezones - was chosen as a practical compromise for this edge case.

### Experimental feature: Leap seconds
Leap second support is experimental and disabled by default. To enable it, set `withLeapSeconds = true` in the `DateTime.DateTimeSystem` object.

## Library structure
```
└── DateTime
    ├── DateTimeSystem
    ├── UsersGuide
    ├── Examples
    │   └── UnitTests
    ├── Basic
    ├── Interfaces
    ├── Icons
    ├── Data
    │   └── Timezones
    ├── Types
    └── Functions
```
Modelers will primarily use components from `DateTimeSystem`, `Basic`, and `Data`. The `Examples` package provides usage demonstrations and unit tests. The `Types` package contains data types for date and time objects.

## Examples
The `DateTime.Examples` package illustrates how to use the library for common tasks.

### Triggering on a Calendar Schedule
The `PowerMeter` example shows how to create a component that resets on a schedule. It uses an `IntegratorWithScheduledReset` that is triggered by a `Schedule` component set to repeat on the first day of each month.

### Repeating events
Repeating schedules, such as industrial work shifts, can be challenging due to holidays and daylight saving shifts. DateTime simplifies this considerably.

The example `DateTime.Examples.RollingMillStart` shows a strategy that modelers can easily adopt. The component `DateTime.Examples.RollingMill` has a fixed power profile defined in `RollingMill.combiTable1D1` with a length of 14400 s (=4 h). Every time the `RollingMill` is started by a boolean input, it must run this profile. To start the `RollingMill` every workday at 8:00, we add the boolean input signal to `RollingMill` and connect it to a `Modelica.Blocks.Logical.Timer` that counts the time the input signal is true and feeds this into `RollingMill.combiTable1D1`. Then, we instantiate a `Schedule` component in `RollingMillStart` with the repetition parameter set to `workdays`, and set the `onTime` parameter to the profile length of 14400 s. The simulation result will show the desired repeated load pattern every workday at 8:00.

This approach can be easily adopted to create entire timeseries e.g. from single, repeated patterns defined in interpolation tables, or from functional blocks like in `Modelica.Blocks.Math`.


## How to cite
A technical report is in preparation. For now, please cite the library as:
```bibtex
@misc{stelzig2025datetime,
    author       = {Philipp Emanuel Stelzig},
    title        = {DateTime: A Modelica-native library for dates, times, and scheduling},
    year         = {2019--2025},
    howpublished = {\url{https://github.com/pstelzig/DateTime}}
}
```

# Authors
The DateTime library is being developed by [Dr. Philipp Emanuel Stelzig](https://github.com/pstelzig)

Copyright (c) Dr. Philipp Emanuel Stelzig, 2019-2025