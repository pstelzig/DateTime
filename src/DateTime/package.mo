within ;
package DateTime "A Modelica-native library for calendrical dates, times, and scheduling. Copyright <html>&copy;</html> Dr. Philipp Emanuel Stelzig, 2019-2025. ALL RIGHTS RESERVED."
  extends DateTime.Icons.DatetimeIcon;

  model DateTimeSystem "System properties for Datetime (common absolute start date time, holidays)"
    extends DateTime.Icons.WorldIcon;
    extends DateTime.Icons.ClockIconWhiteTransparent;
    parameter String startDateTime "Start datemolib (identified with simulation time 0) passed as a string in ISO 8601 format YYYY-MM-DDTHH:MM:SS.SSSSSS";
    parameter DateTime.Types.Timezone timezone = DateTime.Data.Timezones.Europe.CET_CEST "The timezone used in this date and time system";
    parameter DateTime.Data.WorkDays workdays = DateTime.Data.WorkDays(days = {1, 2, 3, 4, 5}) "Workdays, by default Monday,...,Friday. 0=Sunday, 1=Monday,...";
    parameter String holidays[:] = fill("", 0) "Array of dates in format YYYY-MM-DD";
    parameter Boolean withLeapSeconds = false "Whether to use leap second correction or not";
    Real startPosix;
  algorithm
    when initial() then    
      startPosix := DateTime.Functions.datetimeToPosix(DateTime.Functions.parseDatetime(startDateTime), timezone, withLeapSeconds);
    end when;

    annotation(
      defaultComponentName = "dateTimeSystem",
      defaultComponentPrefixes = "inner",
      Documentation(info = "<html>
  <p>This object defines the absolute time regime the simulation takes place in. It defines a startDatetime, 
  which marks the same point in time as the simulation start time defined in the simulation setup. This
  startDatetime is interpreted in the timezone given. The user can also specify a list of holidays in this
  object, which are identifed in DateTime.Basic.SimDatetime and DateTime.Basic.SimWeekday, as well as
  in the DateTime.Basic.Schedule when using \"workdays\" as repetition interval for the schedule trigger.</p>
  <p>See the package's general information DateTime.UsersGuid.GeneralInformation for the explanation of 
  time, date and timezone formats. </p>
  The absolute simulation time is internally computed as a posix timestamp by adding the relative simulation time to the
  simulation time defined for the start of the simulation. Note that this might be any real number, 
  with arbitrary sign. For instance, if startDatetime is \"2020-01-10T00:00:00\" and the simulation
  start time in the simulation setup is \"-1.5\", then the absolute simulation start date time 
  expressed in the local time zone is \"2020-01-09:23:59:58.5\". It is advised to set the simulation
  start time to 0.</p>
  <p>This object shall be instantiated only once per model. It is referred to as an outer parameter
  by all blocks in DateTime.Basic</p>
  </html>"));
  end DateTimeSystem;

  annotation(
    uses(Modelica(version = "4.0.0")),
    Documentation(info = "<html>
<p>The package DateTime <b>enables Modelica to handle dates, absolute times and timezones including daylight saving times</b> (DST).</p>
<br>
<p>For a more detailed overview of the DateTime package and its capabilities see the 
<b>User's Guide in DateTime.UsersGuide.</b></p>
<br>
<p>For license information on the DateTime package see DateTime.UsersGuide.License.</p>
</html>"));
end DateTime;