within DateTime;

package Examples "Examples of how to apply the DateTime library. Copyright <html>&copy;</html> Dr. Philipp Emanuel Stelzig, 2019-2025. ALL RIGHTS RESERVED."
  extends Modelica.Icons.ExamplesPackage;

  model ScheduledSignals
    extends Modelica.Icons.Example;
    inner DateTime.DateTimeSystem dateTimeSystem(final startDateTime = "2019-10-03T08:00:00", final timezone = DateTime.Data.Timezones.Europe.CET_CEST, final holidays = {"2019-10-03", "2019-10-31", "2019-12-25", "2019-12-26", "2020-01-01"}) annotation(
      Placement(visible = true, transformation(origin = {-70, 70}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    DateTime.Basic.SimDateTime simDateTime annotation(
      Placement(visible = true, transformation(origin = {-50, 70}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    DateTime.Basic.Schedule hourly1(onTime = 3600, repetition = "hourly", triggerDateTime = "2019-10-05T01:00:00") annotation(
      Placement(visible = true, transformation(origin = {-90, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0))); // Will stay on because onTime is >= repetition interval
    DateTime.Basic.Schedule hourly2(onTime = 1800, repetition = "hourly", triggerDateTime = "2019-10-06T02:00:00") annotation(
      Placement(visible = true, transformation(origin = {-60, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    DateTime.Basic.Schedule daily(onTime = 60, repetition = "daily", triggerDateTime = "2019-10-07T03:00:00") annotation(
      Placement(visible = true, transformation(origin = {-30, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    DateTime.Basic.Schedule weekly(onTime = 1800, repetition = "weekly", triggerDateTime = "2019-10-08T04:00:00") annotation(
      Placement(visible = true, transformation(origin = {0, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    DateTime.Basic.Schedule workdays(onTime = 10800, repetition = "workdays", triggerDateTime = "2019-10-04T00:00:00") annotation(
      Placement(visible = true, transformation(origin = {30, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    DateTime.Basic.Schedule firstDayInMonth(onTime = 10800, repetition = "firstDayInMonth", triggerDateTime = "2019-10-09T05:00:00") annotation(
      Placement(visible = true, transformation(origin = {60, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    DateTime.Basic.Schedule lastDayInMonth(onTime = 10800, repetition = "lastDayInMonth", triggerDateTime = "2019-10-09T06:00:00") annotation(
      Placement(visible = true, transformation(origin = {90, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    DateTime.Basic.Schedule arbitrary(onTime = 900, repetition = "4500", triggerDateTime = "2019-10-09T06:00:00") annotation(
      Placement(visible = true, transformation(origin = {-90, -30}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    DateTime.Basic.Schedule monthly(onTime = 10800, repetition = "monthly", triggerDateTime = "2019-10-06T02:00:00") annotation(
      Placement(visible = true, transformation(origin = {-60, -30}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    DateTime.Basic.Schedule lastDayInMonthAlt(onTime = 10800, repetition = "monthly", triggerDateTime = "2019-10-31T06:00:00") annotation(
      Placement(visible = true, transformation(origin = {90, -30}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    DateTime.Basic.Schedule firstDayInMonthAlt(onTime = 10800, repetition = "monthly", triggerDateTime = "2019-11-01T05:00:00") annotation(
      Placement(visible = true, transformation(origin = {60, -30}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  equation

    annotation(
      experiment(StartTime = 0, StopTime = 10713600, Tolerance = 1e-06, Interval = 450),
      Documentation(info = "<html>
                <p>DateTime.Examples.ScheduledSignals demonstrates how to use the DateTime.Basic.Schedule 
                class in order to trigger events at absolute times and dates in the timezone specified 
                in the respective instantiation of DateTime.DateTimeSystem. It also demonstrates how 
                to use the classes' trigger repetition features.</p>
                </html>"),
      __OpenModelica_simulationFlags(lv = "LOG_STATS", outputFormat = "mat", s = "dassl"));
  end ScheduledSignals;

  model ToSimPosixTime
    extends Modelica.Icons.Example;
    inner DateTime.DateTimeSystem dateTimeSystem(final startDateTime = "2019-10-03T08:00:00", timezone = DateTime.Data.Timezones.Europe.CET_CEST, final holidays = "2019-10-03;2019-10-31;2019-12-25;2019-12-26;2020-01-01") annotation(
      Placement(visible = true, transformation(origin = {-70, 70}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    DateTime.Basic.SimPosixTime simPosixTime annotation(
      Placement(visible = true, transformation(origin = {-50, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  equation

    annotation(
      experiment(StartTime = 0, StopTime = 31536000, Tolerance = 1e-6, Interval = 900),
      Documentation(info = "<html>
<p>DateTime.Examples.ToSimPosixTime demonstrates how to use DateTime.Basic.SimPosixTime 
and DateTime.DateTimeSystem in order to translate the simulation time into a absolute 
Posix timestamp in UTC time.</p>
</html>"),
      __OpenModelica_simulationFlags(lv = "LOG_STATS", outputFormat = "mat", s = "dassl"),
      Documentation);
  end ToSimPosixTime;

  model ToSimDateTime
    extends Modelica.Icons.Example;
    inner DateTime.DateTimeSystem dateTimeSystem(final startDateTime = "2019-10-03T08:00:00", timezone = DateTime.Data.Timezones.Europe.CET_CEST, final holidays = {"2019-10-03", "2019-10-31", "2019-12-25", "2019-12-26", "2020-01-01"}) annotation(
      Placement(visible = true, transformation(origin = {-70, 70}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    DateTime.Basic.SimDateTime simDateTime annotation(
      Placement(visible = true, transformation(origin = {-50, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  equation

    annotation(
      experiment(StartTime = 0, StopTime = 31536000, Tolerance = 1e-6, Interval = 900),
      Documentation(info = "<html>
<p>DateTime.Examples.ToSimDateTime demonstrates how to use DateTime.Basic.SimDateTime in order to 
translate the simulation time into absolute date and time in the local timezone specified
in the respective instantiation of DateTime.DateTimeSystem.</p>
</html>"),
      __OpenModelica_simulationFlags(lv = "LOG_STATS", outputFormat = "mat", s = "dassl"));
  end ToSimDateTime;

  model ToSimWeekday
    extends Modelica.Icons.Example;
    inner DateTime.DateTimeSystem dateTimeSystem(final startDateTime = "2019-10-03T08:00:00", timezone = DateTime.Data.Timezones.Europe.CET_CEST, final holidays = {"2019-10-03", "2019-10-31", "2019-12-25", "2019-12-26", "2020-01-01"}) annotation(
      Placement(visible = true, transformation(origin = {-70, 70}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    DateTime.Basic.SimWeekday simWeekDay annotation(
      Placement(visible = true, transformation(origin = {-50, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  equation

    annotation(
      experiment(StartTime = 0, StopTime = 31536000, Tolerance = 1e-6, Interval = 900),
      Documentation(info = "<html>
<p>DateTime.Examples.ToSimWeekday demonstrates how to use DateTime.Basic.SimWeekday in order to
translate the simulation time into the current day of the week in the local timezone 
specified in the respective instantiation of DateTime.DateTimeSystem.</p> 
</html>"),
      __OpenModelica_simulationFlags(lv = "LOG_STATS", outputFormat = "mat", s = "dassl"));
  end ToSimWeekday;

  model Countdown
    extends Modelica.Icons.Example;
    inner DateTime.DateTimeSystem dateTimeSystem(final startDateTime = "2019-10-03T08:00:00", timezone = DateTime.Data.Timezones.Europe.CET_CEST) annotation(
      Placement(transformation(origin = {-72, 70}, extent = {{-10, -10}, {10, 10}})));
    DateTime.Basic.Timer timer(triggerDateTime = "2019-10-03T09:00:30", countdownTime = 905) annotation(
      Placement(visible = true, transformation(origin = {-50, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    annotation(
      experiment(StartTime = 0, StopTime = 7200, Tolerance = 1e-6, Interval = 5),
      Documentation(info = "<html>
<p>DateTime.Examples.Countdown demostrates how use DateTime.Basic.Timer in order to set 
up a timer starting at an absolute date and time in the timezone specified in the 
respective instantiation of DateTime.DateTimeSystem.</p> 
</html>"),
      __OpenModelica_simulationFlags(lv = "LOG_STATS", outputFormat = "mat", s = "dassl"));
  end Countdown;

  model DifferentTimezones
    extends Modelica.Icons.Example;
    inner DateTimeSystem dateTimeSystem(startDateTime = "2026-03-27T00:00:00", timezone = DateTime.Data.Timezones.Europe.Berlin)  annotation(
        Placement(transformation(origin = {-70, 70}, extent = {{-10, -10}, {10, 10}})));
    Basic.Schedule scheduleUtc(triggerDateTime = "2026-03-27T08:00:00", onTime = 900, repetition = "daily", triggerTimezone = DateTime.Data.Timezones.Etc.UTC)  annotation(
        Placement(transformation(origin = {-50, 10}, extent = {{-10, -10}, {10, 10}})));
    Basic.Schedule scheduleLondon(triggerDateTime = "2026-03-27T08:00:00", onTime = 900, repetition = "daily", triggerTimezone = DateTime.Data.Timezones.Europe.London)  annotation(
        Placement(transformation(origin = {-50, -30}, extent = {{-10, -10}, {10, 10}})));
    Basic.SimDateTime simDateTime annotation(
        Placement(transformation(origin = {-50, 70}, extent = {{-10, -10}, {10, 10}})));annotation(
      experiment(StartTime = 0, StopTime = 432000, Tolerance = 1e-06, Interval = 120));
  end DifferentTimezones;
  
  model LeapSeconds "This example shows the behavior of the DateTime library when a leap second is inserted, visible in the simDateTime.seconds variable going up to 61 instead of 60. The date chosen for this is example is the last know insertion on 2016-12-31T23:59:59 + 1s"
    extends Modelica.Icons.Example;
    inner DateTimeSystem dateTimeSystem(startDateTime = "2016-12-31T23:50:00", timezone = DateTime.Data.Timezones.Etc.UTC, withLeapSeconds = true)  annotation(
        Placement(transformation(origin = {-70, 70}, extent = {{-10, -10}, {10, 10}})));
    Basic.SimDateTime simDateTime annotation(
        Placement(transformation(origin = {-50, 0}, extent = {{-10, -10}, {10, 10}})));
    annotation(
      experiment(StartTime = 0, StopTime = 1200, Tolerance = 1e-06, Interval = 0.1));    
  end LeapSeconds;  
  
  block IntegratorWithScheduledReset "Shows how to use trigger signals from DateTime.Basic.Schedule in Modelica components"
    extends Modelica.Blocks.Icons.Block;
    parameter Real k = 1.0 "Scaling factor for the output";
    Modelica.Blocks.Interfaces.BooleanInput trigger annotation(
        Placement(transformation(origin = {-120, -40}, extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {-120, -50}, extent = {{-20, -20}, {20, 20}})));
    Modelica.Blocks.Interfaces.RealOutput y(start = 0) annotation(
      Placement(transformation(origin = {110, 0}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {110, 0}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Blocks.Interfaces.RealInput u annotation(
      Placement(transformation(origin = {-120, 40}, extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {-120, 50}, extent = {{-20, -20}, {20, 20}})));
    equation
      der(y) = k*u;
      when edge(trigger) then
        reinit(y, 0);
      end when;
  end IntegratorWithScheduledReset;
  
  model PowerMeter "Example for a metering device like a power meter that simple integrates the input and resets every first day of the month at say 02:00 in the morning"
  extends Modelica.Icons.Example;
    Modelica.Blocks.Sources.Sine powerSource(amplitude = 5, f = 1/(86400), offset = 5, startTime = -64800) "Mockup of a power source that makes a half-sine period every day from 0 to 10 kW"  annotation(
        Placement(transformation(origin = {-70, 30}, extent = {{-10, -10}, {10, 10}})));
    inner DateTimeSystem dateTimeSystem(startDateTime = "2026-03-01T00:00")  annotation(
        Placement(transformation(origin = {50, 70}, extent = {{-10, -10}, {10, 10}})));
    Basic.Schedule meterReset(triggerDateTime = "2026-03-01T02:30:00", onTime = 900, repetition = "firstDayInMonth")  annotation(
        Placement(transformation(origin = {-70, -30}, extent = {{-10, -10}, {10, 10}})));
    IntegratorWithScheduledReset integratorWithScheduledReset(k = 1/(3600*1000))  annotation(
        Placement(transformation(extent = {{-10, -10}, {10, 10}})));
    Basic.SimDateTime simDateTime annotation(
        Placement(transformation(origin = {70, 70}, extent = {{-10, -10}, {10, 10}})));
    equation
    connect(powerSource.y, integratorWithScheduledReset.u) annotation(
        Line(points = {{-58, 30}, {-20, 30}, {-20, 6}, {-12, 6}}, color = {0, 0, 127}));
    connect(meterReset.y, integratorWithScheduledReset.trigger) annotation(
        Line(points = {{-58, -30}, {-20, -30}, {-20, -4}, {-12, -4}}, color = {255, 0, 255}));
      annotation(
        experiment(StartTime = 0, StopTime = 1.05408e+07, Tolerance = 1e-06, Interval = 120));
  end PowerMeter;

  class RollingMill "Power consumption pattern of a rolling mill"
    extends Modelica.Blocks.Icons.Block;
    parameter Real powerScalingFactor = 1;
    Modelica.Blocks.Interfaces.BooleanInput trigger annotation(
      Placement(transformation(origin = {-120, 0}, extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {-120, 0}, extent = {{-20, -20}, {20, 20}})));
    Modelica.Blocks.Logical.Timer timer1 annotation(
      Placement(transformation(origin = {-50, 0}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Blocks.Tables.CombiTable1Dv combiTable1D1(table = [0, 0; 1800, 500e3; 3600, 600e3; 7200, 600e3; 9000, 800e3; 9900, 800e3; 10800, 600e3; 12600, 100e3; 14400, 0], tableOnFile = false) annotation(
      Placement(transformation(origin = {2, 0}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Blocks.Math.Gain powerscaling(k = powerScalingFactor) annotation(
      Placement(transformation(origin = {50, 0}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Blocks.Interfaces.RealOutput power annotation(
      Placement(transformation(origin = {110, 0}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {114, -2}, extent = {{-10, -10}, {10, 10}})));
  equation
    connect(combiTable1D1.y[1], powerscaling.u) annotation(
      Line(points = {{13, 0}, {37, 0}, {37, 0}, {37, 0}}, color = {0, 0, 127}));
    connect(timer1.y, combiTable1D1.u[1]) annotation(
      Line(points = {{-39, 0}, {-11, 0}, {-11, 0}, {-11, 0}}, color = {0, 0, 127}));
    connect(trigger, timer1.u) annotation(
      Line(points = {{-120, 0}, {-62, 0}}, color = {255, 0, 255}));
    connect(powerscaling.y, power) annotation(
      Line(points = {{62, 0}, {110, 0}}, color = {0, 0, 127}));
    annotation(
      Icon(graphics = {Rectangle(origin = {4, -5}, fillColor = {238, 238, 236}, fillPattern = FillPattern.Solid, extent = {{-70, 65}, {68, -61}}), Rectangle(origin = {3, -73}, fillPattern = FillPattern.Solid, extent = {{-53, -7}, {53, 7}}), Rectangle(origin = {2, -2}, fillColor = {207, 234, 237}, fillPattern = FillPattern.Solid, extent = {{-56, 48}, {56, -48}}), Rectangle(origin = {-50, 0}, fillColor = {85, 87, 83}, fillPattern = FillPattern.Solid, extent = {{-44, 4}, {28, -4}}), Rectangle(origin = {22, -2}, fillColor = {85, 87, 83}, fillPattern = FillPattern.Solid, extent = {{-44, 4}, {4, 0}}), Rectangle(origin = {70, -4}, fillColor = {85, 87, 83}, fillPattern = FillPattern.Solid, extent = {{-44, 4}, {26, 2}}), Ellipse(origin = {-19, 20}, lineColor = {85, 87, 83}, fillColor = {186, 189, 182}, fillPattern = FillPattern.Sphere, extent = {{-20, 20}, {20, -20}}, endAngle = 360), Ellipse(origin = {-19, -20}, lineColor = {85, 87, 83}, fillColor = {186, 189, 182}, fillPattern = FillPattern.Sphere, extent = {{-20, 20}, {20, -20}}, endAngle = 360), Ellipse(origin = {25, 14}, lineColor = {85, 87, 83}, fillColor = {186, 189, 182}, fillPattern = FillPattern.Sphere, extent = {{-15, 15}, {15, -15}}, endAngle = 360), Ellipse(origin = {25, -16}, lineColor = {85, 87, 83}, fillColor = {186, 189, 182}, fillPattern = FillPattern.Sphere, extent = {{-15, 15}, {15, -15}}, endAngle = 360)}, coordinateSystem(initialScale = 0.1)),
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-6, Interval = 0.002));
  end RollingMill;

  model RollingMillStart "Example for how to model a repeated pattern of a process, e.g. a rolling mill in a manufacturing process as part of a workshift"
    extends Modelica.Icons.Example;
    inner DateTimeSystem dateTimeSystem(startDateTime = "2026-03-26T00:00", timezone = DateTime.Data.Timezones.Etc.UTC)  annotation(
      Placement(transformation(origin = {50, 70}, extent = {{-10, -10}, {10, 10}})));
    Basic.SimDateTime simDateTime annotation(
      Placement(transformation(origin = {70, 70}, extent = {{-10, -10}, {10, 10}})));
    RollingMill rollingMill(powerScalingFactor = 1e-5)  annotation(
      Placement(transformation(origin = {30, 0}, extent = {{-10, -10}, {10, 10}})));
    Basic.Schedule startRollingMill(triggerDateTime = "2026-03-26T08:00", onTime = 14400, repetition = "workdays", triggerTimezone = DateTime.Data.Timezones.Europe.CET_CEST)  annotation(
      Placement(transformation(origin = {-30, 0}, extent = {{-10, -10}, {10, 10}})));
  equation
    connect(startRollingMill.y, rollingMill.trigger) annotation(
      Line(points = {{-18, 0}, {18, 0}}, color = {255, 0, 255}));
  annotation(
    Documentation(info = "<html>
  <p>The rolling mill in this example starts every workday morning, beginning at 2026-03-26T08:00 in CET. Simulation starts on 2026-03-29T00:00. The example's dateTimeSystem is in UTC, thus showing behavior over daylight savings CEST starting on 2026-03-29, i.e. the 5th day of simulation. Note 08:00 CET=07:00 UTC, and 08:00 CEST=06:00 UTC</p>
  </html>"),
    experiment(StartTime = 0, StopTime = 432000, Tolerance = 1e-06, Interval = 60));
  end RollingMillStart;
  
  annotation(
    Documentation(info = "<html>
<p>The package DateTime.Examples exemplifies the actual usage for the most important elements of the Datetime library.</p>
<br>
<p>See the documentation of the individual examples for more details. </p>
</html>"));
end Examples;