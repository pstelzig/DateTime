# DateTime: A Modelica-native library for calendaric dates, times, and scheduling

This project provides a self-contained, Modelica-native library that
- is easily integrated into any Modelica simulation model by a simple drag&drop of a single `DateTimeSystem`
- maps relative simulation times to absolute calendaric times and back
- allows for simulation events to be triggered at human-readable calendaric dates and times
- enables modelers to intuitively integrate different timezones into one simulation and simulation time
- supports daylight savings, timezones as well as predefined timezones like `Europe.Berlin` or `America.Los_Angeles`
- makes it possible to repeat events in human scale like `daily`, `workday`, or `firstDayOfMonth`

## TL;DR: Quickstart
Using DateTime in your Modelica models is super easy.

### Get the DateTime library
- Clone the library like `git clone https://github.com/pstelzig/DateTime.git` into `<your_local_dir>/DateTime`
- Open a Modelica environment like OpenModelica, load the DateTime library's `<your_local_dir>/src/DateTime/package.mo`

### Integrate DateTime into your favorite Modelica simulation model
- Open your favorite simulation model  
- Drag&Drop a `DateTime.DateTimeSystem` object into your Modelica model, and set the parameters `startDateTime` to an ISO-8601 string like `2025-12-02T17:30:17.21`, and set `timezone` to a predefined timezone like e.g. `DateTime.Data.Timezones.Europe.Berlin`. This identifies your relative simulation start time with the `startDateTime` datetime interpreted in `timezone`. Optionally, set holidays as a list of ISO-8601 formatted strings like `{"2025-12-25", "2025-12-26"}`

### Convert relative simulation time into calendaric date and time
- Drag&Drop a `DateTime.Basic.SimDateTime` object into your Modelica model.
- Simulate.  

The `SimDateTime` object instance will output the relative simulation time as a calendaric date and time just like a digital watch, i.e. into its integer outputs `year`, `month`, `day`, `hours`, `minutes`, a real output `seconds` as well as the `dayOfWeek` (0=Sunday, 1=Monday,... Negative sign for holidays).

### Schedule events in your simulation model by calendaric dates and times
- Drag&Drop a `DateTime.Basic.Schedule` object into your simulation model
- Set the first `triggerDateTime` to an ISO-8601 string like `2025-12-07T02:33.9512` at which the boolean output will jump to `true` for the first time, the `onTime` parameter for how long it shall stay `true`, and a repetition parameter (empty string for no repetition, or one of `hourly`, `daily`, `weekly`, `monthly`, `yearly`, `workdays`, `firstDayInMonth`, `lastDayInMonth`, or any positive real number)
- Use Modelica's `edge` function on the boolean output of the `Schedule` component signal to detect a Modelica event, namely exactly when the `Schedule` component shall trigger an event in some other part of your simulation.


## Design
The DateTime library has very few components to be actually used by a modeler, while most of the date and time conversion functionality is encapsulated. The idea is that the usage of the library shall be as independent as possible from the actual date and time computations. This design makes it possible to have future versions of the DateTime library either use an evolved Modelica-native implementation of the date and time computations, or even make use of an external e.g. C or C++ library (which I did in a previous version of the library).

### Why Modelica-native instead of an `external "C"` with `time.h` or `std::chrono`?
There are several good reasons to choose a Modelica-native implementation over a 3rd party library. Mainly to ensure independence of simulation results from system libraries, which may vary from system to system, and change over time with updates (which is particularly true for `std::chrono` as it was introduced in its modern form with timezones only as part of C++20). Another reason is the ability to model and simulate different "futures", in particular in light of potential future changes to daylight savings or their abolition altogether. Representation of past times is mostly less important for simulation than for business logic. 

**Note** Currently the DateTime library's `Timezone` objects do not allow for changes of daylight saving definitions during simulation time. 

### DateTime from the modeler's perspective
In essence, the interaction of the Modelica modeler with the DateTime library is restricted to the steps outlined in the Quickstart above. We emphasize here that
- The `DateTime.DateTimeSystem` is supposed to be instantiated named `dateTimeSystem` only once per Modelica model in the topmost component, since it is referred to as an `outer` component in the other DateTime objects in need of this component.
- The `DateTime.Basic.Schedule` component can be given its own `timezone` parameter, so as to model systems or data that stretch multiple timezones and schedule events in different timezones. 
- Other useful classes in `DateTime.Basic` are `SimPosixTime` (relative simulation time to POSIX timestamp), as well as `Timer` (counting down after a trigger datetime is hit)

DateTime comes with **predefined timezones** in `DateTime.Data.Timezones` that are organized into the common `<Region>.<City>` pattern like `Europe.Paris` or `America.Los_Angeles`; like regions there is also `Etc` for the UTC timezone `Etc.UTC` or `Etc.GMT`, or standard offsets like `GMT_plus_8` for Etc/GMT+8 which is UTC-08. Several named timezones like CET (Central European Time) or PST (Pacific Standard Time) or CST (China Standard Time) are included in their respective region, like `Europe.CET_CEST` or `America.PST_PDT` or `Asia.CST`. 

In order to facilitate modeling of human-centric activities like shifts in industrial processes or energy systems, the `DateTime.DateTimeSystem` class allows to define a set of holidays, as well as workdays. Holidays and workdays will only be relevant in a `Schedule` component that has its repetition parameter set to `workdays`. In that case, it will only trigger days that are not workdays in the sense of `DateTimeSystem.workdays`, and on days that are not holidays as in `DateTimeSystem.holidays`. The default value of `DateTimeSystem.workdays` is Monday, Tuesday,...,Friday. 

### Defining dates and times: Use ISO-8601 strings
Throughout the **components to be used by the Modelica modeler, for ease of use dates and times shall always be given as simple ISO-8601 strings** like YYYY-MM-DDTHH:MM:SS, YYYY-MM-DDTHH:MM:SS.SSSSS, or YYYY-MM-DD for dates. Note that for datetimes that would be ambiguous, i.e. if they fall into "jump-backs" in transition from daylight savings to standard time, the strings must be added a timezone identifier to resolve the ambiguity. For instance, `2025-10-26T02:30 CET` to interpret the time and date in standard CET time, rather than `2025-10-26T02:30 CEST` which would interpret it as still in daylight savings of `Europe.CET_CEST`. It is the intention to make DateTime as simple to use as possible, and to have all date and time definitions by the modeler self-contained and human readable. 

### Experimental elements
Currently, the support of leap seconds is purely experimental. By default, when instantiating a `DateTime.DateTimeSystem` object, the use of leap seconds is turned off through the `withLeapSeconds = false` parameter. To enable leap second insertion, set this parameter to true. The leap second insertions are defined in `DateTime.Data.LeapSeconds`, containing all insertions up to the last on 2016-12-31.

## Library structure
The library structure is
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
As explained above, `DateTimeSystem`, `Basic` and `Data` contain what typical Modelica modelers would need. The `Examples` package contains basic usage examples, as well as an extensive set of unit tests to check the date and time conversion functions from the `Functions` package. The `Types` package contains classes to hold date and time objects like `DateTime.Types.Datetime`, `DateTime.Types.Date`, or `DateTime.Types.Timezone`. Note that all come with an `encapsulated operator function 'String'` so as to be able to print e.g. a `DateTime.Types.Datetime dt` like `String(dt)`. 

## Examples
The `DateTime.Examples` contains several basic usage examples that illustrate how to use the library to convert the relative simulation time into absolute calendaric times and dates, see example models `ScheduledSignals`, `DifferentTimezones`, or `LeapSeconds`. 

### How to create components that trigger on a calendar schedule
The `DateTime.Examples` package also shows how to create Modelica models that would consume the ouput of a `Schedule` component in order to trigger a Modelica event. The `PowerMeter` example implements such a scenario, where a simple Modelica class called `IntegratorWithScheduledReset` integrates a Real input signal, ouputs the integrated value, and resets when a boolean input signal `trigger` has a rising edge. In `PowerMeter`, this `trigger` input of `IntegratorWithScheduledReset` is connected to a `Schedule` component's output. The `Schedule` component starts at `2026-03-01T02:30:00` and uses the `firstDayInMonth` repetition pattern. In essence, `PowerMeter` models a power meter which resets the accumulated energy every start of a new month.

### How to repeat patterns or events with DateTime
The other important example is how to use the DateTime library to model repeating schedules, like e.g. from industrial work shifts or discrete production processes. In general this is challenging, since the repetitions are not periodic but distorted by holidays or daylight saving timeshifts, or occur at natural human intervals like first day in month, last day in month. DateTime makes that extremely easy. 

The example `DateTime.Examples.RollingMillStart` shows an example where a dedicated component, here `DateTime.Examples.RollingMill` has a fixed power profile defined in `RollingMill.combiTable1D1` of length of 14400 s = 4 h. Every time the `RollingMill` is started, it shall run this profile. Now in `DateTime.Examples.RollingMillStart` we want that the `RollingMill` to be started every workday at 8:00. A way to achieve this is to equip `RollingMill` with a boolean input signal, and connect that with a `Modelica.Blocks.Logical.Timer` component that counts the time the input signal is on and inputs that on-time into `RollingMill.combiTable1D1`. Now, all we have to do is to instantiate a `Schedule` component in `RollingMillStart` with repetition set to `workdays`, and we set the `onTime` parameter to exactly the profile length of 14400 s. Then, every workday at 8:00 this `Schedule` component will output an output signal an have it stay on for 14400 s, which the `RollingMill` component's timer will then count up from 0 to 14400 s. Hence, in the simulation result we see the desired pattern.

This approach can be easily adopted to create entire timeseries e.g. for loads from single, repeated patterns defined in interpolation tables, or from functional blocks like in `Modelica.Blocks.Math`.


## How to cite
A dedicated technical report is in the making. For now, please cite the DateTime library like
```bibtex
@misc{stelzig2025datetime,
    author       = {Philipp Emanuel Stelzig},
    title        = {DateTime: A Modelica-native library for calendaric dates, times, and scheduling},
    year         = {2019--2025},
    howpublished = {\url{https://github.com/pstelzig/DateTime}}
}
```

# Authors
The DateTime library is being developed by [Dr. Philipp Emanuel Stelzig](https://github.com/pstelzig)

Copyright (c) Dr. Philipp Emanuel Stelzig, 2019-2025