within DateTime;

package UsersGuide "User's Guide to the DateTime package. Copyright <html>&copy;</html> Dr. Philipp Emanuel Stelzig, 2019-2025. ALL RIGHTS RESERVED."
  extends Modelica.Icons.Information;

  class GeneralInformation "General Information"
    extends Modelica.Icons.Information;
    annotation(
      Documentation(info = "<html>
  <p>The package DateTime <b>enables Modelica to handle dates, absolute times and timezones including daylight saving times</b> (DST). It can be used to
  <ul>
    <li> <b>translate the relative simulation time into an absolute time in a certain timezone</b> by placing a <b>DateTime.DateTimeSystem</b> object into your simulation model's top model
    <li> <b>trigger events in the simulation such as scheduled triggers (with or without repetition) or timers, both at absolute times</b> with the package <b>DateTime.Basic</b>
  </ul>
  </p>
  <p>In the <b>specification of absolute dates and times this package follows the standard ISO 8601</b>: Date times are specified in the format
  <p align=\"center\">YYYY-MM-DDTHH:MM:SS.SSSSSS, e.g. 2023-07-02T18:30:00</p>
  dates are specified in the format
  <p align=\"center\">YYYY-MM-DD, , e.g. 2027-03-02</p>
  </p>
  <br><p>For timezones <b>this package provides the most common timezones in the DateTime.Data.Timezones</b> record, 
  and they are organized in the common &lt;Region&gt;.&lt;City&gt; pattern, e.g. <b>DateTime.Data.Timezones.Europe.Berlin</b>.</p>
  <p>It is also possible to <b>define custom timezones by following the standard IEEE Std 1003.1</b></p>
  <p align=\"center\">STD_NAME OFFSET_UTC DST_NAME OFFSET_DST,START_OF_DST/TIME_DST_START,END_OF_DST/TIME_DST_END (written without spaces!)</p>
  with
  <ul>
    <li> STD_NAME the abbreviation code of the timezone, e.g. \"CET\" (central european time) or \"EST\" (eastern standard time)
    <li> OFFSET_UTC the offset of the timezone STD_NAME from UTC time (must start with a sign!), e.g. \"+01:00:00\" for CET or \"-05:00:00\" for EST
    <li> DST_NAME the abbreviation code of the timezone with daylight saving time, e.g. \"CEST\" (central european summer time) or 
            \"EDT\" (eastern daylight time)
    <li> OFFSET_DST the offset of the of the daylight saving time in DST_NAME w.r.t. the normal time of the zone STD_NAME (must start with a sign!), e.g.
            \"+01:00:00\" for CEST w.r.t. CET and \"+01:00:00\" for EDT w.r.t. EST. 
    <li> START_OF_DST/TIME_DST_START denotes the start of the daylight saving time each year. 
            <br>START_OF_DST is in the form Mm.w.d where month is in {1,...,12}, week in {1,...,5} the week of the month (5 last week), 
              day in {0,...,6} (0=Sunday, 1=Monday,...). 
            <br> TIME_DST_START is in the form HH:MM:SS
    <li> END_OF_DST/TIME_DST_END takes the same format as START_OF_DST/TIME_DST_START
  </ul></p>
  <p>An example is
  <p align=\"center\">CET+01:00:00CEST+01:00:00,M3.5.0/02:00:00,M10.5.0/03:00:00</p>
  which is the CET with offset +1 h to UTC, its summer time CEST jumps 1 h ahead w.r.t. CET. Daylight saving time for 
  CET starts on sunday (d=0) of the last week (w=5) of March (m=3) at 02:00, thus M3.5.0/02:00:00. Daylight 
  saving time ends on sunday (d=0) of the last week (w=5) of October (m=10) at 03:00:00, thus M10.5.0/03:00:00.</p>
  <p>Another example without daylight savings is e.g.
  <p align=\"center\">HKT+08:00:00</p>
  </p>
  which is the Hong Kong Time having an offset of 8 h w.r.t. UTC time.</p>
  <br><p>The DateTime package comes with a set of <b>predefined examples in DateTime.Examples that illustrate how to use</b> the library.</p>
  <br><p>When using the DateTime library the user must acknowledge that the eventual simulation results when using this library strongly depend on 
  the employed numerical solver and the solver parameters. In particular, <b>how well time discrete changes in discrete date and time 
  quantities are resolved in the simulation result depends on how the solver evaluates the states</b> in DateTime.Basic blocks, and <b>how it detects event changes in those states</b>. Hence, like with any other dynamic simulation, quantities like the 
  simulation timestep size must be chosen carefully and impacts of such quantities on the results must be studied individually by the user. 
  Also, the user is responsible for judging the quality, correctness and usability of the simulation results for his purposes. It is advised to use Modelica builtin functions like <code>edge()</code> on the discrete
  time and date outputs of blocks in DateTime.Basic like DateTime.Basic.Schedule to help the solver detect changes in time.</p>
  </html>"));
  end GeneralInformation;

  class License "License"
    extends Modelica.Icons.Information;
    annotation(
      Documentation(info = "<html>
&copy; Dr. Philipp Emanuel Stelzig, 2019-2025. ALL RIGHTS RESERVED. 
<br>
<br><b>The DateTime library and all its components are subject to the license conditions in the file named LICENSE as found in the root directory of the DateTime library source code. 
In particular, the license conditions apply to all files in the root directory of the DateTime library's source code, and to all subdirectories and their contents.</b>
</html>"));
  end License;

  class Contact "Contact"
    extends Modelica.Icons.Contact;
    annotation(
      Documentation(info = "<html>
<br>The DateTime library is being developed by Philipp Emanuel Stelzig. 
<br>
<br>&copy; Dr. Philipp Emanuel Stelzig, 2019-2025. ALL RIGHTS RESERVED. 
<br>
<br> <u><b>Contact information</b></u>
<br>
<br><b>Dr. Philipp Emanuel Stelzig</b>
<br>
<br>Made with Love in Bavaria, Germany
</html>"));
  end Contact;
  annotation(
    DocumentationClass = true,
    preferredView = "info",
    Documentation(info = "<html>
<p>The DateTime library provides a collection of <b>Modelica blocks to facilitate the use of dates, absolute times and timezones including daylight saving times</b> in Modelica. </p>
</html>"));
end UsersGuide;