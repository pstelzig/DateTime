within DateTime;

package Basic "Library of basic blocks to handle absolute times, timezones, calendaric events, schedules and more. Copyright <html>&copy;</html> Dr. Philipp Emanuel Stelzig, 2019-2025. ALL RIGHTS RESERVED."
  extends DateTime.Icons.DatetimeIcon;

  block SimPosixTime "A block representing a simulation of POSIX time."
    extends DateTime.Interfaces.SO;
    extends DateTime.Icons.ConverterIcon;
    extends DateTime.Icons.StopWatchIcon_tl;
    extends DateTime.Icons.CalendarIcon_br;
    outer DateTime.DateTimeSystem dateTimeSystem;
  algorithm
    y := dateTimeSystem.startPosix + time;
    annotation(
      defaultComponentName = "simPosixTime",
      Documentation(info = "<html>
  <p>Converts the current simulation time (seconds from simulation start) to the posix timestamp
  in UTC time that corresponds to adding the current simulation time to the start date time defined in the
  DateTimeSystem.</p>
  <br><p>Output is the Posix timestamp in UTC time for the current simulation time.</p>
  <br><p>Usage of this block requires the instantiation of a DateTime.DateTimeSystem object in this or a parent
  model of where SimPosixTime is used.</p>
  </html>"));
  end SimPosixTime;

  block SimDateTime "Acts as a digital watch. y := [year, month, day, hours, minutes, seconds, dayOfWeek] where seconds are discrete. 0=Sunday, 1=Monday,..."
    extends Modelica.Blocks.Icons.Block;
    extends DateTime.Icons.ConverterIcon;
    extends DateTime.Icons.StopWatchIcon_tl;
    extends DateTime.Icons.CalendarIcon_br;
    extends DateTime.Icons.ClockIcon_br;
    outer DateTime.DateTimeSystem dateTimeSystem;
    Modelica.Blocks.Interfaces.IntegerOutput year annotation (Placement(
          transformation(origin = {0, 90}, extent = {{100, -10}, {120, 10}}), iconTransformation(origin = {0, 90}, extent = {{100, -10}, {120, 10}})));
    Modelica.Blocks.Interfaces.IntegerOutput month annotation (Placement(
          transformation(origin = {0, 60}, extent = {{100, -10}, {120, 10}}), iconTransformation(origin = {0, 60}, extent = {{100, -10}, {120, 10}})));
    Modelica.Blocks.Interfaces.IntegerOutput day annotation (Placement(
          transformation(origin = {0, 30}, extent = {{100, -10}, {120, 10}}), iconTransformation(origin = {0, 30}, extent = {{100, -10}, {120, 10}})));
    Modelica.Blocks.Interfaces.IntegerOutput hours annotation (Placement(
          transformation(extent = {{100, -10}, {120, 10}}), iconTransformation(extent = {{100, -10}, {120, 10}})));
    Modelica.Blocks.Interfaces.IntegerOutput minutes annotation (Placement(
          transformation(origin = {0, -30}, extent = {{100, -10}, {120, 10}}), iconTransformation(origin = {0, -30}, extent = {{100, -10}, {120, 10}})));
    Modelica.Blocks.Interfaces.RealOutput seconds annotation (Placement(
          transformation(origin = {0, -60}, extent = {{100, -10}, {120, 10}}), iconTransformation(origin = {0, -60}, extent = {{100, -10}, {120, 10}})));
    Modelica.Blocks.Interfaces.IntegerOutput dayOfWeek annotation (Placement(
          transformation(origin = {0, -90}, extent = {{100, -10}, {120, 10}}), iconTransformation(origin = {0, -90}, extent = {{100, -10}, {120, 10}})));  
  protected
    DateTime.Types.Datetime dt;
    Integer holidaySign;
  algorithm
    dt := DateTime.Functions.posixToDatetime(dateTimeSystem.startPosix + time, dateTimeSystem.timezone, dateTimeSystem.withLeapSeconds);

    if DateTime.Functions.isDatetimeHoliday(dt, dateTimeSystem.holidays) then
      holidaySign := -1;
    else
      holidaySign := 1;
    end if;

    year := dt.year;
    month := dt.month;
    day := dt.day;
    hours := dt.hours;
    minutes := dt.minutes;
    seconds := dt.seconds;
    dayOfWeek := holidaySign*DateTime.Functions.dayOfWeek(dt.year, dt.month, dt.day);
    annotation(
      defaultComponentName = "simDateTime",
      Documentation(info = "<html>
  <p>Converts the current simulation time (seconds from simulation start as specified in the outer
  DateTimeSystem) to the absolute date and time in the timezone specified in the DateTimeSystem. 
  </p>
  <br><p>Output is a 7-tupel of reals which for every simulation time reads as the corresponding</p>
  <p align=\"center\">(year, month, dayInMonth, hourOfDay, minuteInHour, secondsInMinute, weekday)</p> 
  <p>Here, weekday is an integer with 1=Sunday, 2=Monday,...,7=Saturday. A negative weekday indicates
  a holiday as defined in the outer DateTimeSystem. </p>
  <br><p>Usage of this block requires the instantiation of a DateTime.DateTimeSystem object in this or a parent
  model of where SimPosixTime is used.</p>
  </html>"));
  end SimDateTime;

  block SimWeekday "Outputs the day of the week for the current simulation time. 0=Sunday, 1=Monday,..."
    extends DateTime.Interfaces.SO;
    extends DateTime.Icons.ConverterIcon;
    extends DateTime.Icons.StopWatchIcon_tl;
    extends DateTime.Icons.DayIcon_br;
    outer DateTime.DateTimeSystem dateTimeSystem;
  protected
    DateTime.Types.Datetime dt;
    Integer holidaySign;
  algorithm
    dt := DateTime.Functions.posixToDatetime(dateTimeSystem.startPosix + time, dateTimeSystem.timezone, dateTimeSystem.withLeapSeconds);
    
    if DateTime.Functions.isDatetimeHoliday(dt, dateTimeSystem.holidays) then
      holidaySign := -1;
    else
      holidaySign := 1;
    end if;
    
    y := holidaySign*DateTime.Functions.dayOfWeek(dt.year, dt.month, dt.day);
    annotation(
      defaultComponentName = "simWeekday",
      Documentation(info = "<html>
<p>Computes for the current simulation time (seconds from simulation start as specified in the outer
DateTimeSystem) the current day of the week in the local time specified in the DateTimeSystem. </p>
<br><p>Output is an integer with 0=Sunday, 1=Monday,.... A negative weekday indicates
a holiday as defined in the DateTimeSystem. </p>
<br><p>Usage of this block requires the instantiation of a DateTime.DateTimeSystem object in the
model in which SimWeekday is used.</p>
</html>"));
  end SimWeekday;

  block Schedule
    extends DateTime.Interfaces.BooleanSO;
    extends DateTime.Icons.CalendarIcon;
    outer DateTime.DateTimeSystem dateTimeSystem;
    parameter String triggerDateTime = "2025-01-01T00:00:00" "Trigger date time in ISO 8601 format YYYY-MM-DDTHH:MM:SS";
    parameter Modelica.Units.SI.Time onTime = 1800 "On time after trigger is hit [s]";
    parameter String repetition = "daily" "Repetition intervals as string. Valid values are &lt;empty string&gt;, hourly, daily, weekly, monthly, yearly, workdays, firstDayInMonth, lastDayInMonth, &lt;%f&gt; where &lt;%f&gt; is a string describing any positive floating point number in seconds";
    parameter DateTime.Types.Timezone triggerTimezone = dateTimeSystem.timezone;
    parameter Boolean autocorrect = true "If date after incrementing by discrete quanitities is invalid (days in month flow over, will correct to latest day in month). If time of day is invalid in timezone, will correct using correctInvalidDatetime according to the strategy chosen";
    parameter String strategy = "time_from_day_start" "If autocorrect == true, this strategy will be used to correct for invalid times of day (when falling into transition periods for daylight savings). Valid values are time_from_day_start and time_to_day_end";
  protected
    Real simTimePosix;
    DateTime.Types.Datetime initTrigger;
    Real initTriggerPosix;
    DateTime.Types.Datetime prevTrigger;
    Real prevTriggerPosix;
  algorithm
    when initial() then
      initTrigger := DateTime.Functions.parseDatetime(triggerDateTime);
      initTriggerPosix := DateTime.Functions.datetimeToPosix(initTrigger, triggerTimezone, dateTimeSystem.withLeapSeconds);
      (prevTrigger, prevTriggerPosix) := DateTime.Functions.largestPreviousTrigger(dateTimeSystem.startPosix + time, initTrigger, repetition, triggerTimezone, dateTimeSystem.workDays, dateTimeSystem.holidays, dateTimeSystem.withLeapSeconds, autocorrect, strategy);
    end when;

    simTimePosix := dateTimeSystem.startPosix + time;

    // Update previous trigger and next trigger once sim time is past the previous trigger
    when repetition <> "" and simTimePosix >= prevTriggerPosix + onTime then
      prevTrigger := DateTime.Functions.addSingleRepetitionToDatetime(prevTrigger, repetition, triggerTimezone, dateTimeSystem.workDays, dateTimeSystem.holidays, dateTimeSystem.withLeapSeconds, autocorrect, strategy);
      prevTriggerPosix := DateTime.Functions.datetimeToPosix(prevTrigger, triggerTimezone, dateTimeSystem.withLeapSeconds);
    end when;

    if simTimePosix >= prevTriggerPosix and simTimePosix < prevTriggerPosix + onTime then
      y := true;
    else
      y := false;
    end if;          
  
    annotation(
      Documentation(info = "<html>
  <p>At the specified trigger date time (triggerDatetime) this block produces a real output signal
  with value 1 from the time the trigger date time has first been reached by the simulation time
  (seconds from simulation start as specified in the outer DateTimeSystem) and stays at 1 for onTime 
  seconds. The trigger date time is in the local time zone. Otherwise the output value is always 0. </p> 
  <br><p>It is possible to define repetitions for the trigger (see the parameter repetition): 
  &lt;empty string&gt;, hourly, daily, weekly, monthly, yearly, workdays, firstDayInMonth, lastDayInMonth and an arbitrary interval
  in seconds. Note that all repetitions except the arbitrary interval depend on the local time 
  zones, in particular at time shifts due to daylight saving times. </p>
  <br><p>Usage of this block requires the instantiation of a DateTime.DateTimeSystem object in the
  model in which Schedule is used.</p>
    </html>"));
  end Schedule;

  block Timer
    extends DateTime.Interfaces.SO;
    extends DateTime.Icons.HourglassIcon;
    outer DateTime.DateTimeSystem dateTimeSystem;
    parameter String triggerDateTime = "2025-01-01T00:00:00" "Start date time in ISO 8601 format YYYY-MM-DDTHH:MM:SS the timer begins counting down";
    parameter Modelica.Units.SI.Time countdownTime = 3600 "Time the timer is counting down after being triggered [s]";
  protected
    Real triggerPosix;
  algorithm
    when initial() then
      triggerPosix := DateTime.Functions.datetimeToPosix(DateTime.Functions.parseDatetime(triggerDateTime), dateTimeSystem.timezone, dateTimeSystem.withLeapSeconds); 
    end when;
    y := DateTime.Functions.heaviside(dateTimeSystem.startPosix + time - triggerPosix) * max(countdownTime - (dateTimeSystem.startPosix + time - triggerPosix), 0);  
    annotation(
      Documentation(info = "<html>
  <p>At the specified trigger date time (triggerDatetime) once the simulation time (seconds from 
  simulation start as specified in the outer DateTimeSystem) has reached it, the value of the real
  output signal jumps from 0 to the specified countdown time and then linearly decreases with the 
  simulation time (slope=-1) until it reaches 0. Thus, the output signal is the remaining time 
  obtained by counting down countdownTime seconds from beginning of the trigger date time. 
  Before the triggerDatetime and after triggerDatetime + countdownTime the output signal is always 0. </p>
  <br><p>Usage of this block requires the instantiation of a DateTime.DateTimeSystem object in the
  model in which Schedule is used.</p>
  </html>"));
  end Timer;
  annotation(
    Documentation(info = "<html>
<p>The package DateTime.Basic provides a collection of blocks to 
<ul>
  <li> Translate the current simulation time as used by the numerical solver into absolute dates and times 
       in a specific timezone
  <li> Trigger events like at scheduled dates and times (possibly with repetition) or a Timer functionality
</ul>
All the classes in DateTime.Basic required the the instantiation of a DateTime.DateTimeSystem object in the
model in which the respective classes are used used. The DateTime.DateTimeSystem defines the absolute
start date and time at which the simulation starts and also defines the local timezone in which the
simulation takes place. 
</p>
<br>
<p>
The individual classes inside DateTime.Basic provide detailed information on their functionality and usage. 
</p>
</html>"));
end Basic;