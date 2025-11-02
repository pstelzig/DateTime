within DateTime;

package Functions
  import Strings = Modelica.Utilities.Strings;
  import DateTime.Types.*;
  extends Modelica.Icons.FunctionsPackage;
  
  function heaviside "Computes the Heaviside step function"
    extends Modelica.Icons.Function;
    input Real x;
    output Real y;
  algorithm
    if x < 0 then
      y := 0;
    else
      y := 1;
    end if;
  annotation(
    Documentation(info="<html>
<p>This function computes the Heaviside step function.</p>
<p>It returns 0 for any negative input <code>x</code> and 1 for any non-negative input.</p>
<p>This is a fundamental function in engineering and mathematics.</p>
</html>"));
  end heaviside;
  
  function splitAtFirst "Splits a string along the first occurrence of the delimiter"
    extends Modelica.Icons.Function;
    input String str;
    input String delimiter;
    output String firstPart;
    output String secondPart;
  protected
    Integer pos;
  algorithm
    pos := Modelica.Utilities.Strings.find(str, delimiter);
    if pos > 0 then
      firstPart := Strings.substring(str, 1, pos - 1);
      secondPart := Strings.substring(str, pos + Strings.length(delimiter), Strings.length(str));
    else
      firstPart := str;
      secondPart := "";
    end if;
  annotation(
    Documentation(info="<html>
<p>This function splits a string into two parts at the first occurrence of a specified delimiter.</p>
<p>It returns the part of the string before the delimiter and the part after it.</p>
<p>If the delimiter is not found, the entire string is returned as the first part, and the second part is empty.</p>
</html>"));
  end splitAtFirst;

  function split "Splits a string along all occurrences of the delimiter"
    extends Modelica.Icons.Function;
    input String str;
    input String delimiter;
    output String[:] parts;
  protected
    String first;
    String remainder;
  algorithm
    // Initialize parts array with a size that can hold all parts
    remainder := str;
    while remainder <> "" loop
      (first, remainder) := splitAtFirst(remainder, delimiter);
      if size(parts, 1) > 0 then
        parts := cat(1, parts, {first});
      else
        parts := {first};
      end if;
    end while;
  annotation(
    Documentation(info="<html>
<p>This function splits a string into an array of substrings based on a specified delimiter.</p>
<p>It repeatedly calls the <code>splitAtFirst</code> function to divide the string at each occurrence of the delimiter.</p>
<p>The resulting substrings are returned as an array of strings.</p>
</html>"));
  end split;
  
  function isDigit "Checks if a string is a single digit"
    extends Modelica.Icons.Function;
    input String c;
    output Boolean result;
  algorithm
    assert(Strings.length(c) == 1, "isDigit must be given a single character, but got " + c);
    result := false;
    for i in 0:9 loop
      if c == String(i) then
        result := true;
      end if;    
    end for;
  annotation(
    Documentation(info="<html>
<p>This function determines whether a given single-character string is a digit from '0' to '9'.</p>
<p>It asserts that the input string contains exactly one character.</p>
<p>The function returns <code>true</code> if the character is a digit, and <code>false</code> otherwise.</p>
</html>"));
  end isDigit;  
  
  function findFirstDigit "Returns the index of the first digit found in the input string. If none is found, -1 is returned"
    extends Modelica.Icons.Function;
    input String str;
    output Integer pos = -1;
  protected
    Integer i;
  algorithm
    for i in 1:Strings.length(str) loop
      if isDigit(Strings.substring(str, i, i)) then
        pos := i;
        break;
      end if;
    end for;
  annotation(
    Documentation(info="<html>
<p>This function searches for the first occurrence of a digit within a string.</p>
<p>It iterates through the string and uses the <code>isDigit</code> function to check each character.</p>
<p>The function returns the 1-based index of the first digit found, or -1 if no digits are present.</p>
</html>"));
  end findFirstDigit;
  
  function parseTimefield "Parses a timefield like [sign]HH:MM or [sign]HH:MM:SS.SSSSSS into its contituents"
    extends Modelica.Icons.Function;
    input String str;
    output Timefield t;
  protected
    String sign;
    Integer offset;
    String hours;
    String rest;  
  algorithm
    (hours, rest) := splitAtFirst(str, ":");
    if Strings.length(hours) == 3 then
      sign := Strings.substring(hours, 1, 1);
      assert(sign == "+" or sign == "-", "Expected sign in time field " + str + " to be + or minus, got " + sign);
      if sign == "-" then
        t.sign := -1;
      else
        t.sign := 1;
      end if;      
      t.hours := Strings.scanInteger(Strings.substring(hours, 2, 3));
    else
      t.sign := 1;
      t.hours := Strings.scanInteger(Strings.substring(hours, 1, 2));
    end if;
    t.minutes := Strings.scanInteger(Strings.substring(rest, 1, 2));
    if Strings.length(rest) > 2 then
      t.seconds := Strings.scanReal(Strings.substring(rest, 4, Strings.length(rest)));
    else
      t.seconds := 0.0;
    end if;
  annotation(
    Documentation(info="<html>
<p>This function parses a string representing a time field in the format <code>[sign]HH:MM:SS</code>.</p>
<p>It extracts the sign, hours, minutes, and seconds into a <code>Timefield</code> record.</p>
<p>The sign is optional and is assumed to be positive if not present.</p>
</html>"));
  end parseTimefield;
  
  function parseTransition "Parses a timezone transition string"
    extends Modelica.Icons.Function;
    input String transitionString;
    output Integer month;
    output Integer week;
    output Integer day;
    output Timefield switchTime;
  protected
    String transitionMonth;
    String transitionWeekDayTime;
    Integer offsetStart;  
  algorithm
    // Example transition string: "M3.5.0/02:00:00" or "M10.5.0/02:00:00". Splitting into M10 and 5.0/02:00:00
    (transitionMonth, transitionWeekDayTime) := splitAtFirst(transitionString, ".");
    month := Strings.scanInteger(Strings.substring(transitionMonth, 2, Strings.length(transitionMonth)));
    week := Strings.scanInteger(Strings.substring(transitionWeekDayTime, 1, 1));
    day := Strings.scanInteger(Strings.substring(transitionWeekDayTime, 3, 3));
    switchTime := parseTimefield(Strings.substring(transitionWeekDayTime, 5, Strings.length(transitionWeekDayTime)));
  annotation(
    Documentation(info="<html>
<p>This function parses a string that defines a timezone transition, such as the start or end of daylight saving time.</p>
<p>The expected format is like <code>M3.5.0/02:00:00</code>, representing the month, week, day, and time of the transition.</p>
<p>It returns the parsed month, week, day, and a <code>Timefield</code> record for the switch time.</p>
</html>"));
  end parseTransition;  
  
  function parseTimezone "Parses timezone definitions according to IEEE 1003.1, i.e. std offset dst [offset],start[/time],end[/time]. This works only for named timezones that have a letter-only abbreviation"
    extends Modelica.Icons.Function;
    input String timezoneString;
    output Timezone tz;
  protected
    String standardPart;
    String summerTransition;
    String winterTransition;
    String transitionMonth;
    String transitionTime;
    Integer offsetStart;
  algorithm
    // Split the string into standard, daylight, and transition parts. E.g. CET+01:00:00CEST+01:00:00,M3.5.0/02:00:00,M10.5.0/03:00:00
    (standardPart, summerTransition) := splitAtFirst(timezoneString, ",");  
    
    if summerTransition == "" then
      tz.hasDaylightSaving := false;    
      offsetStart := findFirstDigit(timezoneString);
      tz.standardName := Strings.substring(timezoneString, 1, offsetStart-2);  //Offset starts with a sign
      tz.standardOffset := parseTimefield(Strings.substring(timezoneString, offsetStart-1, Strings.length(timezoneString)));
      
      // Setting defaults
      tz.daylightName := tz.standardName;
      tz.daylightOffset := Timefield(1, 0, 0, 0.0);
      tz.startMonth := 0;
      tz.startWeek := 0;
      tz.startDay := 0;
      tz.startTime := Timefield(1, 0, 0, 0.0);
      tz.endMonth := 0;
      tz.endWeek := 0;
      tz.endDay := 0;
      tz.endTime := Timefield(1, 0, 0, 0.0);    
    else
      tz.hasDaylightSaving := true;
      
      (summerTransition, winterTransition) := splitAtFirst(summerTransition, ",");
    
      // Find the position of the first digit in the standard part CET+01:00:00CEST+01:00:00
      offsetStart := findFirstDigit(standardPart);
      tz.standardName := Strings.substring(standardPart, 1, offsetStart-2);  //Offset starts with a sign
      tz.standardOffset := parseTimefield(Strings.substring(standardPart, offsetStart-1, Strings.length(standardPart)));
      tz.daylightName := Strings.substring(standardPart, offsetStart+8, Strings.length(standardPart));
      offsetStart := findFirstDigit(tz.daylightName);  //Offset starts with a sign
      tz.daylightOffset := parseTimefield(Strings.substring(tz.daylightName, offsetStart-1, Strings.length(tz.daylightName)));
      tz.daylightName := Strings.substring(tz.daylightName, 1, offsetStart-2);
      
        // Parse transition summer transition part M3.5.0/02:00:00
      (tz.startMonth, tz.startWeek, tz.startDay, tz.startTime) := parseTransition(summerTransition);
      
        // Parse transition winter transition part M10.5.0/03:00:00
      (tz.endMonth, tz.endWeek, tz.endDay, tz.endTime) := parseTransition(winterTransition);
     end if;
  annotation(Documentation(info = "<html>
  <p>
  This function parses a POSIX-compliant timezone string according to the format specified in IEEE Std 1003.1.
  The format is <code>std offset dst [offset],start[/time],end[/time]</code>.
  It extracts standard and daylight saving time information, including names, offsets, and transition rules, into a <code>Timezone</code> record.
  </p>
  
  <p>
    <ul>
      <li> 'std' specifies the abbrev of the time zone. 'offset' is the offset from UTC.
      <li>'dst' specifies the abbrev of the time zone during daylight savings time.
      <li>The second offset is how many hours changed during DST.
      <li>'start' and 'end' are the dates when DST goes into (and out of) effect.
      <li>'offset' takes the form of [+|-]hh[:mm[:ss]] {h=0-23, m/s=0-59}.
      <li>'start' and 'end' can be one of three forms:
      <ul>
        <li>Mm.w.d {month=1-12, week=1-5 (5 is always last), day=0-6}
        <li>Jn {n=1-365 Feb29 is never counted}
        <li>n {n=0-365 Feb29 is counted in leap years}
      </ul>
    </ul>
  </p>
  
  <p>
  Examples are CET+01:00:00CEST01:00:00,M3.5.0/02:00:00,M10.5.0/03:00:00 for Central European Time with daylight saving time
  CEST with an offset of 1 h. The daylight saving period is defined by M3.5.0/02:00:00, i.e. it starts in March (month 3), 
  on the last week (week 5), on Sunday (day 0) at 02:00:00 by jumping ahead +01:00:00. 
  Its end is defined by M10.5.0/03:00:00 i.e. October (month 10), last week (week 5), on Sunday Sunday (day 0) at 03:00:00 
  by jumping back +01:00:00.
  </p>
  </html>"));
  end parseTimezone;

  function parseDate "Parses a date string according to ISO 8601 into a Date object"
    extends Modelica.Icons.Function;
    input String dateString "Date string in ISO 8601 format (e.g., 2023-10-05)";
    output Date d "Parsed Date object";
  protected
    Integer year;
    Integer month;
    Integer day;
  algorithm
// We expect a date string in the format YYYY-MM-DD
    year := Modelica.Utilities.Strings.scanInteger(Strings.substring(dateString, 1, 4));
    month := Modelica.Utilities.Strings.scanInteger(Strings.substring(dateString, 6, 7));
    day := Modelica.Utilities.Strings.scanInteger(Strings.substring(dateString, 9, 10));
    
    // Assign parsed values to the Date record
    d.year := year;
    d.month := month;
    d.day := day;
  annotation(
    Documentation(info="<html>
<p>This function parses a date string in ISO 8601 format (YYYY-MM-DD).</p>
<p>It extracts the year, month, and day from the string.</p>
<p>The parsed values are returned in a <code>Date</code> object.</p>
</html>"));
  end parseDate;

  function parseDatetime "Parses a datetime string according to ISO 8601 format YYYY-MM-DDTHH:MM:SS.SSSSSSS into a Datetime object"
    extends Modelica.Icons.Function;
    input String datetimeString "Datetime string in ISO 8601 format (e.g., 2023-10-05T14:48:00)";
    output Datetime dt "Parsed Datetime object";
  protected
    Integer year;
    Integer month;
    Integer day;
    Integer hours;
    Integer minutes;
    Real seconds;
    String isopart;
    String tz;
  algorithm
// We expect a either full ISO 8601 string like YYYY-MM-DDTHH:MM or YYYY-MM-DDTHH:MM:SS.SSSSSSS, or it being appended the explicit offset name like YYYY-MM-DDTHH:MM:SS.SSSSSSS [offset].
// Example ISO 8601 datetime strings: "2023-10-05T14:48:00.17" or "2025-10-26T02:30:00.00 CEST"
    (isopart, tz) := splitAtFirst(datetimeString, " ");
    
    year := Modelica.Utilities.Strings.scanInteger(Strings.substring(isopart, 1, 4));
    month := Modelica.Utilities.Strings.scanInteger(Strings.substring(isopart, 6, 7));
    day := Modelica.Utilities.Strings.scanInteger(Strings.substring(isopart, 9, 10));
    hours := Modelica.Utilities.Strings.scanInteger(Strings.substring(isopart, 12, 13));
    minutes := Modelica.Utilities.Strings.scanInteger(Strings.substring(isopart, 15, 16));
    
    if Strings.length(isopart) == 16 then  // We only have YYYY-MM-DDTHH:MM
      seconds := 0;
    else  // YYYY-MM-DDTHH:MM:SS.SSSSSSS
      seconds := Modelica.Utilities.Strings.scanReal(Strings.substring(isopart, 18, Strings.length(isopart)));
    end if;
    
    if not tz == "" then
      tz := Strings.substring(tz, 1, Strings.length(tz));
    end if;
  
    // Assign parsed values to the Datetime record
    dt.year := year;
    dt.month := month;
    dt.day := day;
    dt.hours := hours;
    dt.minutes := minutes;
    dt.seconds := seconds;
    dt.tz := tz;
  annotation(
    Documentation(info="<html>
<p>This function parses a datetime string in ISO 8601 format, such as <code>YYYY-MM-DDTHH:MM:SS.SSSSSSS</code>.</p>
<p>It can also handle an optional timezone abbreviation appended to the string.</p>
<p>The function extracts all date and time components and returns them in a <code>Datetime</code> object.</p>
</html>"));
  end parseDatetime;

  function isDateHoliday "Checks if a given date is in the list of holiday strings"
    extends Modelica.Icons.Function;
    input Date d;
    input String holidayStrings[:];
    output Boolean isHoliday;
  algorithm
    isHoliday := false;
    for i in 1:size(holidayStrings, 1) loop
      if String(d) == holidayStrings[i] then
        isHoliday := true;
        break;
      end if;
    end for;
  annotation(
    Documentation(info="<html>
<p>This function checks if a given <code>Date</code> object corresponds to a holiday.</p>
<p>It compares the string representation of the date with a list of holiday strings.</p>
<p>The function returns <code>true</code> if the date is found in the holiday list, and <code>false</code> otherwise.</p>
</html>"));
  end isDateHoliday;

  function isDatetimeHoliday "Checks if a given datetime is in the list of holiday strings"
    extends Modelica.Icons.Function;
    input Datetime dt;
    input String holidayStrings[:];
    output Boolean isHoliday;
  protected
    Date d;
  algorithm
    d := Date(year=dt.year, month=dt.month, day=dt.day);
    isHoliday := false;
    for i in 1:size(holidayStrings, 1) loop
      if String(d) == holidayStrings[i] then
        isHoliday := true;
        break;
      end if;
    end for;
  annotation(
    Documentation(info="<html>
<p>This function determines if a given <code>Datetime</code> object falls on a holiday.</p>
<p>It extracts the date part from the datetime object and checks it against a list of holiday strings.</p>
<p>The function returns <code>true</code> if the date is a holiday, and <code>false</code> otherwise.</p>
</html>"));
  end isDatetimeHoliday;

  function isLeapYear "Determines if the year is a leap year according to the Gregorian calendar"
    extends Modelica.Icons.Function;
    input Integer year;
    output Boolean isLeap;
  algorithm
    if (mod(year, 4) == 0 and (mod(year, 100) <> 0 or mod(year, 400) == 0)) then
      isLeap := true;
    else
      isLeap := false;  
    end if;
  annotation(
    Documentation(info="<html>
<p>This function determines if a given year is a leap year based on the Gregorian calendar rules.</p>
<p>A year is a leap year if it is divisible by 4, except for end-of-century years, which must be divisible by 400.</p>
<p>It returns <code>true</code> if the year is a leap year, and <code>false</code> otherwise.</p>
</html>"));
  end isLeapYear;
  
  function daysInYear "Computes the number of days in a year"
    extends Modelica.Icons.Function;
    input Integer year;
    output Integer days;  
  algorithm
    if isLeapYear(year) then
      days := 366;
    else
      days := 365;
    end if;
  annotation(
    Documentation(info="<html>
<p>This function calculates the number of days in a given year.</p>
<p>It uses the <code>isLeapYear</code> function to determine if the year is a leap year.</p>
<p>The function returns 366 for a leap year and 365 for a common year.</p>
</html>"));
  end daysInYear;
  
  function daysInMonth "Computes the number of days in a month for a given year"
    extends Modelica.Icons.Function;
    input Integer year;
    input Integer month "January=1, February=2,...,December=12";
    output Integer days;
  protected
    parameter Data.MonthDays md;
  algorithm
    if month == 2 and isLeapYear(year) then
      days := md.daysInMonth[month]+1;
    else
      days := md.daysInMonth[month];
    end if;
  annotation(
    Documentation(info="<html>
<p>This function computes the number of days in a specific month of a given year.</p>
<p>It accounts for leap years when calculating the number of days in February.</p>
<p>The function returns an integer representing the total days in the specified month.</p>
</html>"));
  end daysInMonth;
  
  function dayOfWeek "Computes the day of week with 0=Sunday, 1=Monday,... according to Zeller's congruence"
    extends Modelica.Icons.Function;
    input Integer year;
    input Integer month;
    input Integer day;
    output Integer w;
  protected
    Integer Y, m, k, j, h;
  algorithm
    Y := year;
    m := month;
    if m <= 2 then
      m := m + 12;
      Y := Y - 1;
    end if;
    k := mod(Y, 100);
    j := integer(floor(Y/100.0));
    // Zeller's congruence: h=0 => Saturday, h=1 => Sunday, ...
    h := mod(integer(day + floor(13*(m+1)/5.0) + k + floor(k/4.0) + floor(j/4.0) + 5*j), 7);
    // Shift so that Sunday=0
    w := mod((h + 6), 7);
  annotation(
    Documentation(info="<html>
<p>This function calculates the day of the week for a given date using Zeller's congruence.</p>
<p>The output is an integer where 0 represents Sunday, 1 represents Monday, and so on.</p>
<p>It is a mathematical formula to calculate the day of the week for any Gregorian calendar date.</p>
</html>"));
  end dayOfWeek;
  
  
  function dayOfYear "Returns day-of-year (1,...,365 for standard years, or 1,...,366 for leap years)"
    extends Modelica.Icons.Function;
    input Integer year;
    input Integer month;
    input Integer day;
    output Integer doy;
  protected
    Integer i;
  algorithm
    doy := 0;
    for i in 1:(month-1) loop
      doy := doy + daysInMonth(year, i);
    end for;
    doy := doy + day;
  annotation(
    Documentation(info="<html>
<p>This function calculates the day of the year for a given date.</p>
<p>The day of the year is an integer from 1 to 365 (or 366 in a leap year).</p>
<p>It is useful for various scheduling and time-based calculations.</p>
</html>"));
  end dayOfYear;
  
  function addSecondsToDatetime "Adds a time delta to a datetime. This is done naively by splitting the time delta into days. Does not take into account timezone information, i.e. this will _not_ correctly adapt for daylight savings"
    extends Modelica.Icons.Function;
    input Datetime dt;
    input Real deltaT;
    output Datetime dt_out;
  protected
    Real secondsInDay;
  algorithm
    // Initialize output with input values
    dt_out := dt;
    
    // Calculate total seconds
    secondsInDay := dt.hours*3600 + dt.minutes*60 + dt.seconds + deltaT;
  
    if secondsInDay < 0 then  // Falls into previous day
      while secondsInDay < 0 loop
        secondsInDay := secondsInDay + 86400;
        dt_out.day := dt_out.day - 1;
        if dt_out.day < 1 then  // Day falls into previous month
          dt_out.month := dt_out.month - 1;
          if dt_out.month < 1 then  // Month falls into previous year
            dt_out.year := dt_out.year - 1;
            dt_out.month := 12;
          end if;
          dt_out.day := daysInMonth(dt_out.year, dt_out.month);      
        end if;
      end while;
    else  // Check if falls into future days
      while secondsInDay >= 86400 loop
        secondsInDay := secondsInDay - 86400;
        dt_out.day := dt_out.day + 1;
        if dt_out.day > daysInMonth(dt_out.year, dt_out.month) then  // Day falls into next month
          dt_out.day := 1;
          dt_out.month := dt_out.month + 1;
          if dt_out.month > 12 then  // Month falls into next year
            dt_out.year := dt_out.year + 1;
            dt_out.month := 1;
          end if;
        end if;
      end while;
    end if;
  
    // Calculate final hours, minutes, seconds
    dt_out.hours := div(integer(secondsInDay), 3600);
    dt_out.minutes := div(integer(secondsInDay - dt_out.hours*3600), 60);
    dt_out.seconds := secondsInDay - dt_out.hours*3600 - dt_out.minutes*60;
  
    // Delete timezone info since this cannot be decided without a full timezone specification
    dt_out.tz := "";
  annotation(
    Documentation(info="<html>
<p>This function adds a specified number of seconds to a <code>Datetime</code> object.</p>
<p>It handles rolling over to subsequent days, months, and years, but does not account for timezone changes or daylight saving time.</p>
<p>The resulting <code>Datetime</code> object will have its timezone information cleared.</p>
</html>"));
  end addSecondsToDatetime;
  
  function yearToTransitionDatetime "Computes for a certain year and a certain timezone at which datetimes the transition to summer time starts (dst_start_tic), when the transition interval to summer time stop (dst_start_toc), when the transition jump back at summer time end starts (dst_end_tic), and when to when it jumps back (dst_end_toc)"
    extends Modelica.Icons.Function;
    input Timezone tz "Timezone object";
    input Integer year "Year to compute the daylight start time in";
    input String event "Events that mark the start (tic) and stop (toc) of the transition hops. Valid values are dst_start_tic, dst_start_toc, dst_end_tic, dst_end_toc";
    output Datetime dt "Datetime object";
  protected
    Integer firstDowStartWeek "First day of the week of the start week";
    Integer firstStartDowInMonth "First time the desired transition day (0=Sunday,1=Monday,...) occurs in the transition start month";
    Integer transitionStartDay "Day in month at which the transition starts";
    Integer firstDowEndWeek "First day of the week of the end week";
    Integer firstEndDowInMonth "First time the desired transition day (0=Sunday,1=Monday,...) occurs in the transition end month";
    Integer transitionEndDay "Day in month at which the transition ends";
    
  algorithm
    assert(event == "dst_start_tic" or event == "dst_start_toc" or event == "dst_end_tic" or event == "dst_end_toc", 
           "Expected event to have one of the values dst_start_tic, dst_start_toc, dst_end_tic, dst_end_toc, but got " + event);
           
    dt.year := year;
    
    // Compute day of transition start
    firstDowStartWeek := dayOfWeek(year, tz.startMonth, 1);

    if tz.startDay >= firstDowStartWeek then  
      firstStartDowInMonth := 1 + (tz.startDay - firstDowStartWeek);
    else
      firstStartDowInMonth := 1 + (7 - (firstDowStartWeek - tz.startDay));
    end if;    

    transitionStartDay := firstStartDowInMonth + 7*(tz.startWeek-1);
    
    if tz.startWeek == 5 and transitionStartDay > daysInMonth(year, tz.startMonth) then   // Adjust if week=5 (last)
      transitionStartDay := transitionStartDay - 7;
    end if;    
    
    // Compute day of transition end
    firstDowEndWeek := dayOfWeek(year, tz.endMonth, 1);

    if tz.endDay >= firstDowEndWeek then  
      firstEndDowInMonth := 1 + (tz.endDay - firstDowEndWeek);
    else
      firstEndDowInMonth := 1 + (7 - (firstDowEndWeek - tz.endDay));
    end if;    

    transitionEndDay := firstEndDowInMonth + 7*(tz.endWeek-1);
    
    if tz.endWeek == 5 and transitionEndDay > daysInMonth(year, tz.endMonth) then   // Adjust if week=5 (last)
      transitionEndDay := transitionEndDay - 7;
    end if;     
  
    if event == "dst_start_tic" then
      dt.month := tz.startMonth;  
      dt.day := transitionStartDay;   
      dt.hours := tz.startTime.hours;
      dt.minutes := tz.startTime.minutes;
      dt.seconds := tz.startTime.seconds;
      dt.tz := tz.standardName;
    elseif event == "dst_start_toc" then
      dt.month := tz.startMonth;  
      dt.day := transitionStartDay;   
      dt.hours := tz.startTime.hours + tz.daylightOffset.sign*tz.daylightOffset.hours;
      dt.minutes := tz.startTime.minutes + tz.daylightOffset.sign*tz.daylightOffset.minutes;
      dt.seconds := tz.startTime.seconds + tz.daylightOffset.sign*tz.daylightOffset.seconds;      
      dt.tz := tz.daylightName;
      assert(dt.hours >= 0 and dt.minutes >= 0 and dt.seconds >= 0, "Time field invalid, have dt.hours=" + String(dt.hours) + ", dt.minutes=" + String(dt.minutes) + ", dt.seconds=" + String(dt.seconds));
    elseif event == "dst_end_tic" then
      dt.month := tz.endMonth;
      dt.day := transitionEndDay;   
      dt.hours := tz.endTime.hours;
      dt.minutes := tz.endTime.minutes;
      dt.seconds := tz.endTime.seconds;   
      dt.tz := tz.daylightName;           
    elseif event == "dst_end_toc" then
      dt.month := tz.endMonth;
      dt.day := transitionEndDay;   
      dt.hours := tz.endTime.hours - tz.daylightOffset.sign*tz.daylightOffset.hours;
      dt.minutes := tz.endTime.minutes - tz.daylightOffset.sign*tz.daylightOffset.minutes;
      dt.seconds := tz.endTime.seconds - tz.daylightOffset.sign*tz.daylightOffset.seconds; 
      dt.tz := tz.standardName;
      assert(dt.hours >= 0 and dt.minutes >= 0 and dt.seconds >= 0, "Time field invalid, have dt.hours=" + String(dt.hours) + ", dt.minutes=" + String(dt.minutes) + ", dt.seconds=" + String(dt.seconds));
    end if;
  annotation(
    Documentation(info="<html>
<p>This function computes the exact datetime of a timezone transition event for a given year.</p>
<p>It calculates the start and end times for daylight saving time based on the rules defined in the <code>Timezone</code> object.</p>
<p>The specific event to compute is specified by the <code>event</code> input string. The valid values for <code>event</code> are:</p>
<ul>
<li><b>dst_start_tic</b>: The moment the transition to daylight saving time begins.</li>
<li><b>dst_start_toc</b>: The moment the transition to daylight saving time ends.</li>
<li><b>dst_end_tic</b>: The moment the transition back from daylight saving time begins.</li>
<li><b>dst_end_toc</b>: The moment the transition back from daylight saving time ends.</li>
</ul>
</html>"));
  end yearToTransitionDatetime;
  
  function isValidTimefield "Checks if a timefield is valid in the 24 h clock"
    extends Modelica.Icons.Function;
    input Timefield tf;
    input Boolean withLeapSeconds;
    output Boolean isValid;
  algorithm
    isValid := (tf.sign == 1 or tf.sign == -1) and
               (tf.hours >=0 and tf.hours <= 23) and
               (tf.minutes >= 0 and tf.minutes <= 59) and
               (tf.seconds >= 0.0);
               
    if withLeapSeconds then
      isValid := isValid and (tf.seconds < 61); 
    else
      isValid := isValid and (tf.seconds < 60); 
    end if;
  annotation(
    Documentation(info="<html>
<p>This function checks if a <code>Timefield</code> record represents a valid time.</p>
<p>It validates the ranges for hours, minutes, and seconds, and can optionally account for leap seconds.</p>
<p>The function returns <code>true</code> if the timefield is valid, and <code>false</code> otherwise.</p>
</html>"));
  end isValidTimefield;

  function isValidDate "Checks if a Date object d is a valid date"
    extends Modelica.Icons.Function;
    input Date d;
    output Boolean isValid;
  algorithm
    isValid := d.year >= 0 and
               d.month >= 1 and d.month <= 12 and
               d.day >= 1 and d.day <= daysInMonth(d.year, d.month);
  annotation(
    Documentation(info="<html>
<p>This function checks if a <code>Date</code> object represents a valid calendar date.</p>
<p>It ensures that the month is between 1 and 12, and the day is within the valid range for that month and year.</p>
<p>The function returns <code>true</code> if the date is valid, and <code>false</code> otherwise.</p>
</html>"));
  end isValidDate;
  
  function isValidDatetime "Checks if a Datetime object dt expressed in a certain timezone is a valid date and time in that timezone. This is not necessarily the case at transition times. See annotation for explanation of return values."
    extends Modelica.Icons.Function;
    input Datetime dt "Datetime object";
    input Timezone tz "Timezone object";
    input Boolean withLeapSeconds = false;
    output Integer isValid;
  protected
    Date d;
    Timefield tod;
    Datetime dst_start_tic;
    Datetime dst_start_toc;
    Datetime dst_end_tic;
    Datetime dst_end_toc;
    
    Datetime jump_forward_tic;
    Datetime jump_forward_toc;
    Datetime jump_backward_tic;
    Datetime jump_backward_toc;
  algorithm
    // Check date validity
    d.year := dt.year;
    d.month := dt.month;
    d.day := dt.day;

    if not isValidDate(d) then
      isValid := -3;
      return;
    end if;
    
    // Check numeric boundaries of time
    tod.sign := 1;
    tod.hours := dt.hours;
    tod.minutes := dt.minutes;
    tod.seconds := dt.seconds;
    
    if not isValidTimefield(tod, withLeapSeconds) then
      isValid := -4;
      return;
    end if;   
    
    // Check if datetime is valid in timezone: If daylight savings are applicable, then see if ambiguous or nonexistent
    if tz.hasDaylightSaving then
      dst_start_tic := yearToTransitionDatetime(tz, dt.year, "dst_start_tic");
      dst_start_toc := yearToTransitionDatetime(tz, dt.year, "dst_start_toc");
      dst_end_tic := yearToTransitionDatetime(tz, dt.year, "dst_end_tic");
      dst_end_toc := yearToTransitionDatetime(tz, dt.year, "dst_end_toc");
      
      if tz.daylightOffset.sign > 0 then
        jump_forward_tic := dst_start_tic;
        jump_forward_toc := dst_start_toc;
        jump_backward_tic := dst_end_toc;  // The end_toc is earlier than end_tic when jumping back
        jump_backward_toc := dst_end_tic;
      else
        jump_forward_tic := dst_end_tic;
        jump_forward_toc := dst_end_toc;
        jump_backward_tic := dst_start_toc;  // The end_toc is earlier than end_tic when jumping back
        jump_backward_toc := dst_start_tic;    
      end if;
      
      if not dt < jump_forward_tic and dt < jump_forward_toc then 
        isValid := 0;  // Falls into nonexistent times in [jump_forward_tic, jump_forward_toc)
      else
        if not dt < jump_backward_tic and dt < jump_backward_toc then
          if dt.tz == "" then
            isValid := -1;  // Falls into ambiguous times [jump_backward_tic, jump_backward_toc) and is not explicitly specified
          else
            if dt.tz == tz.daylightName or dt.tz == tz.standardName then
              isValid := 2;  // Falls into ambiguous times [jump_backward_tic, jump_backward_toc) but is explicitly specified
            else
              isValid := -2;
            end if;
          end if;
        else
          isValid := 1;  // Does not fall into transition periods
        end if;
      end if;  
    else
      isValid := 1;
    end if;
    annotation(
      Documentation(info = "<html>
<p>This function checks if a <code>Datetime</code> object is valid within a specific timezone, especially around daylight saving transitions.</p>
<p>It returns an integer code indicating the validity status, such as whether the time is unambiguous, nonexistent, or ambiguous.</p>
<p>
The return values are as follows
<ul>
  <li>If the datetime <code>dt</code> is valid and unambiguous interpreted as a date and time in the timezone <code>tz</code>, the return is <b>1</b>.</li>
  <li>If it falls into a daylight savings transition where time jumps forward and is thus inexistent, the return is <b>0</b>.</li>
  <li>If it falls into a daylight savings transition where time jumps backwards and is ambiguous, we distinguish:
    <ul>
      <li>Either the timezone is not explicitly specified, then the return is <b>-1</b>.</li>
      <li>Or the datetime <code>dt.tz</code> field explicitly specifies the timezone, then:
        <ul>
          <li>If the <code>tz</code> field specified does not match the timezone names, then the return is <b>-2</b>.</li>
          <li>Otherwise, if the specified <code>tz</code> matches, then the return is <b>2</b>.</li>
        </ul>
      </li>
    </ul>
  </li>
  <li>If the calendar date part is invalid, a <b>-3</b> is returned.</li>
  <li>If the timefield is not a valid 24 h clock time, a <b>-4</b> is returned.</li>
</ul>
</html>"));
  end isValidDatetime;
  
  function isWatchtimeInDaylightSaving "Checks if a datetime dt as intepreted in the timezone tz is in tz's daylight saving period or not. This function can be thought of as if you were looking at a watch that displays time dt in the timezone tz and determining if you are in daylight savings or not."
    extends Modelica.Icons.Function;
    input Datetime dt "Datetime object";
    input Timezone tz "Timezone object";
    output Boolean isDst;
  protected
    Integer validity;  
    Datetime dst_start_toc;
    Datetime dst_end_tic;    
    Datetime dst_start;
    Datetime dst_end;
  algorithm  
    validity := isValidDatetime(dt, tz, true);  // Allow for leapsecond timefields, not relevant for judgement
  
    assert(validity == 1 or validity == 2, "Invalid datetime in this timezone, must neither be inexistent (0) nor ambiguous (-1), nor ill-specified (-2) but is " + String(isValidDatetime(dt, tz)) + ". The datetime is " + String(dt) + " in timezone " + String(tz));
  
    if validity == 2 then  // Falls into ambiguous time, but if daylight savings or not is explicitly specified
      if dt.tz == tz.daylightName then
        isDst := true;
      else
        isDst := false;
      end if;
    else  // Is valid and unambiguous
      dst_start_toc := yearToTransitionDatetime(tz, dt.year, "dst_start_toc");
      dst_end_tic := yearToTransitionDatetime(tz, dt.year, "dst_end_tic");
      
      dst_start := dst_start_toc;
      dst_end := dst_end_tic;
      
      if dst_start < dst_end then  // Northern hemisphere: DST falls within year: DST = [dst_start, dst_end)
        if not dt < dst_start and dt < dst_end then
          isDst := true;
        else
          isDst := false;
        end if;
      else  // Southern hemisphere: DST extends beyond year boundary: DST = [year_start, dst_end) \cup [dst_start, year_end]
        if dt < dst_end or not dt < dst_start then
          isDst := true;
        else
          isDst := false;
        end if;
      end if;
    end if;
  annotation(
    Documentation(info="<html>
<p>This function determines if a given wall-clock time (watch time) falls within the daylight saving period of a specified timezone.</p>
<p>It handles both Northern and Southern Hemisphere DST logic, where DST can cross year boundaries.</p>
<p>The function asserts that the input datetime is valid and unambiguous before making the determination.</p>
</html>"));
  end isWatchtimeInDaylightSaving;
  
  function isStandardtimeInDaylightSaving "Checks if a datetime dt as intepreted as the standard time of a timezone tz is in tz's daylight saving period or not. "
    extends Modelica.Icons.Function;
    input Datetime dt;
    input Timezone tz;
    output Boolean isDst;
  protected
    Datetime dst_start_tic;
    Datetime dst_end_toc;    
    Datetime dst_start;
    Datetime dst_end;
    String dst_start_str; // temp
    String dst_end_str; // temp
    String dt_str; // temp
  algorithm
    dst_start_tic := yearToTransitionDatetime(tz, dt.year, "dst_start_tic");
    dst_end_toc := yearToTransitionDatetime(tz, dt.year, "dst_end_toc");
    
    dst_start := dst_start_tic;
    dst_end := dst_end_toc;
    dt_str := String(dt);
    dst_start_str := String(dst_start);
    dst_end_str := String(dst_end);
    
    if dst_start < dst_end then  // Northern hemisphere: DST falls within year: DST = [dst_start, dst_end)
      if not dt < dst_start and dt < dst_end then
        isDst := true;
      else
        isDst := false;
      end if;
    else  // Southern hemisphere: DST extends beyond year boundary: DST = [year_start, dst_end) \cup [dst_start, year_end]
      if dt < dst_end or not dt < dst_start then
        isDst := true;
      else
        isDst := false;
      end if;
    end if;
  annotation(
    Documentation(info="<html>
<p>This function checks if a datetime, interpreted as standard time, falls within the daylight saving period of a timezone.</p>
<p>It compares the standard time against the DST transition moments for the given year.</p>
<p>This is useful for determining DST status without considering the wall-clock time ambiguity during transitions.</p>
</html>"));
  end isStandardtimeInDaylightSaving;
  
  function datetimeToPosix "Converts a Datetime object to a POSIX timestamp"
    extends Modelica.Icons.Function;
    input Datetime dt "Datetime object";
    input Timezone tz "Timezone object";
    input Boolean withLeapSeconds = false "Flag to account for leap seconds";
    output Real posixTime "POSIX timestamp";
  protected
    Datetime dt_utc;
    String dt_utcStr;
    Real standardOffsetSeconds;
    Real daylightOffsetSeconds;
    Real offset;
    Boolean isDaylightSaving;
    Integer daysSinceEpoch;
    Integer i;
    Integer leapSeconds;
    Real preliminaryPosixTime;
    parameter Data.Epoch ep;
    parameter Data.LeapSeconds ls;
  algorithm
    assert(ep.dt <= dt, "The datetime must not be earlier than the epoch, but have ep=" + String(ep.dt) + " and dt=" + String(dt));
  
    // Calculate the number of days since the Unix epoch (1970-01-01)
    daysSinceEpoch := 0;
    for i in ep.dt.year:(dt.year - 1) loop
      daysSinceEpoch := daysSinceEpoch + daysInYear(i);
    end for;
  
    for i in 1:(dt.month - 1) loop
      daysSinceEpoch := daysSinceEpoch + daysInMonth(dt.year, i);
    end for;
  
    daysSinceEpoch := daysSinceEpoch + (dt.day - 1);
  
    // Convert standard and daylight offsets to seconds
    standardOffsetSeconds := tz.standardOffset.sign * (tz.standardOffset.hours * 3600 + tz.standardOffset.minutes * 60 + tz.standardOffset.seconds);
    daylightOffsetSeconds := tz.daylightOffset.sign * (tz.daylightOffset.hours * 3600 + tz.daylightOffset.minutes * 60 + tz.daylightOffset.seconds);
  
    // Apply the appropriate offset
    if isWatchtimeInDaylightSaving(dt, tz) then
      offset := standardOffsetSeconds + daylightOffsetSeconds;
    else
      offset := standardOffsetSeconds;
    end if;
  
    // Calculate a preliminary POSIX time without leap seconds
    preliminaryPosixTime := daysSinceEpoch * 86400 + dt.hours * 3600 + dt.minutes * 60 + dt.seconds - offset;

    // Calculate the POSIX timestamp.
    leapSeconds := 0;
    // Problem: The preliminaryPosixTime for e.g. 1972-06-30T23:59:60.5 is undistuingishable from 1972-07-01T00:00:00.5
    // Thus, we need to take into account the calendar date as well, so we convert it back to UTC and compare
    if withLeapSeconds then
      if dt.seconds >= 60.0 then
        // Walk over all leap seconds added and add if we're past it
        for i in 1:ls.num loop
          if preliminaryPosixTime + leapSeconds >= ls.timestamps[i] + ls.leaps[i] then
            leapSeconds := leapSeconds + ls.leaps[i];
          end if;
        end for;          
      else
        dt_utc := addSecondsToDatetime(dt, -offset);
        dt_utc.tz := "UTC";
        dt_utcStr := String(dt_utc);
    
        // Walk over all leap seconds added and add if we're past it
        for i in 1:ls.num loop
          if dt_utc > ls.datetimes[i] then
            leapSeconds := leapSeconds + ls.leaps[i];
          end if;
        end for;
      end if;
    end if;
    
    posixTime := preliminaryPosixTime + leapSeconds;
  annotation(
    Documentation(info="<html>
<p>This function converts a <code>Datetime</code> object to a POSIX timestamp (seconds since 1970-01-01 UTC).</p>
<p>It accounts for the specified timezone, including daylight saving offsets, and can optionally include leap seconds.</p>
<p>The function ensures the datetime is not earlier than the Unix epoch before conversion.</p>
</html>"));
  end datetimeToPosix;
  
  function posixToDatetime "Converts a nonnegative POSIX timestamp to a Datetime object in the timezone tz given"
    extends Modelica.Icons.Function;
    input Real tstamp;
    input Timezone tz;
    input Boolean withLeapSeconds = false "Flag to account for leap seconds";
    output Datetime dt;
  protected
    Integer i;
    Integer normalDays;  // Days without leap second adjustments
    Integer shortLeapDays;  // Days shortened by a negative leap second to have 86400 s -1 s = 86399 s
    Integer longLeapDays;  // Days extended by a positive leap second to have 86400 s +1 s = 86401 s
    parameter Data.LeapSeconds ls;
    parameter Data.Epoch ep;
    Datetime dt_utc;
    Integer day;
    Integer year;
    Integer month;
    Integer hours;
    Integer minutes;
    Real offset;
    Real seconds;
    Integer hoursInDay;
    Integer minutesInDay;
    Real secondsInDay;
    Boolean isDst;
  algorithm
    assert(tstamp >= 0, "The timestamp must not be negative, but is " + String(tstamp));
    // Compute UTC time from tstamp
    
    // Calculate the number of leap seconds that have already passed if withLeapSeconds is true
    shortLeapDays := 0;
    longLeapDays := 0;
    i := 1;  
    if withLeapSeconds then
      while i <= ls.num and integer(tstamp) > ls.timestamps[i] loop
        if ls.leaps[i] == -1 then
          shortLeapDays := shortLeapDays + 1;
        elseif  ls.leaps[i] == 1 then
          longLeapDays := longLeapDays + 1;
        end if;
        i := i+1;  // When loop stops i will hold the index of the first leap second event in the future, i.e. ls.timestamps[i] > tstamp
      end while;
    end if;
   
    normalDays := integer(floor((tstamp - shortLeapDays*(86400-1) - longLeapDays*(86400+1)) / 86400));
    day := normalDays + shortLeapDays + longLeapDays;
  
    seconds := tstamp - normalDays*86400 - shortLeapDays*(86400-1) - longLeapDays*(86400+1);
    
    year := ep.dt.year;
    while day >= daysInYear(year) loop
        day := day - daysInYear(year);
        year := year + 1;
    end while;
    
    month := 1;
    while day >= daysInMonth(year, month) loop
      day := day - daysInMonth(year, month);
      month := month + 1;      
    end while;
    
    day := day + 1;
    
    dt_utc.year := year;
    dt_utc.month := month;
    dt_utc.day := day;
    dt_utc.hours := integer(div(seconds, 3600));
    dt_utc.minutes := integer(div(seconds - dt_utc.hours*3600, 60));
    dt_utc.seconds := seconds - dt_utc.hours*3600 - dt_utc.minutes*60;
    dt_utc.tz := "";
    
    // Apply standard offset from timezone and recompute. Offset is never larger than 24 h
    offset := tz.standardOffset.sign*(tz.standardOffset.hours*3600 + tz.standardOffset.minutes*60 + tz.standardOffset.seconds);
    dt := addSecondsToDatetime(dt_utc, offset);
    
    // Check if standard time is in daylight savings
    if isStandardtimeInDaylightSaving(dt, tz) then
      offset := tz.daylightOffset.sign*(tz.daylightOffset.hours*3600 + tz.daylightOffset.minutes*60 + tz.daylightOffset.seconds);
      dt := addSecondsToDatetime(dt, offset);
      dt.tz := tz.daylightName;
      isDst := true;
    else
      dt.tz := tz.standardName;
      isDst := false;
    end if;
    
    // Check if UTC datetime in entire seconds is a leap second event. If so, correct the time 00:00:00 to 23:59:60 and keep fractional seconds
    if i <= ls.num and integer(tstamp) == ls.timestamps[i] then
      dt := addSecondsToDatetime(dt, -ls.leaps[i]);
      dt.seconds := dt.seconds + ls.leaps[i];
    end if;
    
    // Re-add dt.tz information since addSecondsToDatetime loses it
    if isDst then
      dt.tz := tz.daylightName;
    else
      dt.tz := tz.standardName;
    end if;  
  annotation(
    Documentation(info="<html>
  <p>This function converts a POSIX timestamp into a <code>Datetime</code> object for a specified timezone.</p>
  <p>It correctly handles timezone offsets, daylight saving adjustments, and can optionally account for leap seconds.</p>
  <p>The function ensures the resulting <code>Datetime</code> is a valid representation of the timestamp in the target timezone.</p>
  </html>"));
  end posixToDatetime;

  function correctInvalidDate "Corrects an invalid date for overflowing days by adjusting the day to the last valid day of the month"
    extends Modelica.Icons.Function;
    input Date d "Date object to correct";
    output Date d_corrected "Corrected date object";
  algorithm
    d_corrected := d;
    
    // Check if the date is valid
    if not isValidDate(d) then
      // If the month is February and the year is a leap year, set to 29th
      if d.month == 2 and isLeapYear(d.year) then
        d_corrected.day := 29;
      else
        // Otherwise, set to the last day of the month
        d_corrected.day := daysInMonth(d.year, d.month);
      end if;
      
      // Optionally, raise an assertion if autocorrect is not succesful
      assert(isValidDate(d_corrected), "Correcting invalid date resulted in an invalid date: " + String(d_corrected));
    end if;
  annotation(
    Documentation(info="<html>
<p>This function corrects an invalid <code>Date</code> object where the day exceeds the number of days in the month.</p>
<p>It adjusts the day to the last valid day of that month, for instance, correcting February 30th to February 28th or 29th.</p>
<p>The function ensures that the returned date is always a valid calendar date.</p>
</html>"));
  end correctInvalidDate;
  
  function addYearsToDate "Adds discrete years to a date in that in increments the respective year field"
    extends Modelica.Icons.Function;
    input Date d;
    input Integer years;
    input Boolean autocorrect = true;  // Will autocorrect if days overflow when adding years or months: Use last day in month, e.g. 2024-01-31 + 1 month will result in 2024-02-29
    output Date d_added;
  algorithm
    d_added := d;
    
    // Add years
    d_added.year := d_added.year + years;

    // Validate, then autocorrect or raise assertion
    if not isValidDate(d_added) then
      if autocorrect then
        d_added := correctInvalidDate(d_added);
      else 
        assert(isValidDate(d_added), "Adding years to date resulted in an invalid date: " + String(d_added));
      end if;
    end if;
  annotation(
    Documentation(info="<html>
<p>This function adds a specified number of years to a given <code>Date</code> object.</p>
<p>It can automatically correct for invalid dates, such as when adding a year to a leap day results in a non-leap year.</p>
<p>The function returns a new <code>Date</code> object representing the resulting date.</p>
</html>"));
  end addYearsToDate;

  function addMonthsToDate "Adds discrete months to a date in that in increments the respective month field"
    extends Modelica.Icons.Function;
    input Date d;
    input Integer months;
    input Boolean autocorrect = true;  // Will autocorrect if days overflow when adding years or months: Use last day in month, e.g. 2024-01-31 + 1 month will result in 2024-02-29
    output Date d_added;
  algorithm
    d_added := d;
    
    // Add months
    d_added.month := d_added.month + months;
    if d_added.month > 12 then
      d_added.year := d_added.year + div(d_added.month-1, 12);
      d_added.month := mod(d_added.month, 12) + 1;
    end if;    
    
    // Validate, then autocorrect or raise assertion
    if not isValidDate(d_added) then
      if autocorrect then
        d_added := correctInvalidDate(d_added);
      else 
        assert(isValidDate(d_added), "Adding years to date resulted in an invalid date: " + String(d_added));
      end if;
    end if;
  annotation(
    Documentation(info="<html>
<p>This function adds a specified number of months to a given <code>Date</code> object.</p>
<p>It handles rolling over to subsequent years and can automatically correct for invalid dates.</p>
<p>For example, adding one month to January 31st will result in the last day of February.</p>
</html>"));
  end addMonthsToDate;

  function addDaysToDate "Adds a number of days to a date in that it increments the respective day field and adjusts month and year if necessary"
    extends Modelica.Icons.Function;
    input Date d;
    input Integer days "Number of days to add";
    output Date d_added;
  algorithm
    d_added := d;
    
    // Add days
    d_added.day := d_added.day + days;
    
    // Adjust month and year if necessary
    while d_added.day > daysInMonth(d_added.year, d_added.month) loop
      d_added.day := d_added.day - daysInMonth(d_added.year, d_added.month);  // Reset to first day of month
      d_added.month := d_added.month + 1;  // Increment month
      
      // Check if month exceeds December
      if d_added.month > 12 then
        d_added.month := 1;  // Reset to January
        d_added.year := d_added.year + 1;  // Increment year
      end if;
    end while;
    
    // Validate, then autocorrect or raise assertion
    assert(isValidDate(d_added), "Adding days to date resulted in an invalid date: " + String(d_added));
  annotation(
    Documentation(info="<html>
<p>This function adds a specified number of days to a given <code>Date</code> object.</p>
<p>It correctly handles rolling over to subsequent months and years.</p>
<p>The function ensures that the resulting date is always valid.</p>
</html>"));
  end addDaysToDate;

  function correctInvalidDatetime "Corrects an invalid datetime where a time falls into transition periods according to different strategies: time_from_day_start and time_to_day_end. See annotation for explanation of strategies."
    extends Modelica.Icons.Function;
    input Datetime dt "Datetime object to correct";
    input Timezone tz "Timezone object";
    input String strategy = "time_from_day_start" "Correction strategy. Valid values: time_from_day_start, time_to_day_end";
    input Boolean withLeapSeconds = false "Flag to account for leap seconds";
    output Datetime dt_corrected "Corrected date object";
  protected
    Date d;
    Timefield tf;
    Real timedelta;
  algorithm
    d.year := dt.year;
    d.month := dt.month;
    d.day := dt.day;

    assert(isValidDate(d), "Will not attempt to correct invalid date in datetime object. Invalid date " + String(d) + " in " + String(dt));

    tf.sign := 1;  
    tf.hours := dt.hours;
    tf.minutes := dt.minutes;
    tf.seconds := dt.seconds;

    assert(isValidTimefield(tf, withLeapSeconds), "Will not attempt to correct invalid time field in datetime object. Invalid time field " + String(tf) + " in " + String(dt));

    if isValidDatetime(dt, tz) <> 1 then
      if strategy == "time_from_day_start" then        
        dt_corrected.year := dt.year;
        dt_corrected.month := dt.month;
        dt_corrected.day := dt.day;
        dt_corrected.hours := 0;
        dt_corrected.minutes := 0;
        dt_corrected.seconds := 0;

        timedelta := 3600*tf.hours + 60*tf.minutes + tf.seconds;
        dt_corrected := posixToDatetime(datetimeToPosix(dt_corrected, tz, withLeapSeconds) + timedelta, tz, withLeapSeconds);
      elseif strategy == "time_to_day_end" then
        d.year := dt.year;
        d.month := dt.month;
        d.day := dt.day;

        d := addDaysToDate(d, 1);

        dt_corrected.year := d.year;
        dt_corrected.month := d.month;
        dt_corrected.day := d.day;
        dt_corrected.hours := 0;
        dt_corrected.minutes := 0;
        dt_corrected.seconds := 0;

        timedelta := 84600 - 3600*tf.hours + 60*tf.minutes + tf.seconds;
        dt_corrected := posixToDatetime(datetimeToPosix(dt_corrected, tz, withLeapSeconds) - timedelta, tz, withLeapSeconds);
      else
        assert(false, "Invalid strategy for correcting invalid datetime: " + strategy + ". Valid values are time_from_day_start and time_to_day_end.");
      end if;
    end if;
  annotation(
    Documentation(info = "<html>
<p>This function corrects an invalid datetime that falls into a daylight saving transition period.</p>
<p>It uses different strategies to resolve ambiguity, such as calculating the time from the start or end of the day.</p>
<p>The function ensures that the returned datetime is valid and unambiguous within the specified timezone.</p>
<p>
<ul>
  <li>
    <b>Strategy <code>time_from_day_start</code></b><br>
    <ul>
      <li>
        <b>Jump-forward case:</b> If, e.g., in CET a time 2025-03-30T02:30 is given (falls into jump forward transition), then the corrected time is the point in time that started 2 hours and 30 minutes after 2025-03-30T00:00:00.
      </li>
      <li>
        <b>Jump-backward case:</b> If, e.g., in CET a time 2025-10-26T02:30 is given (falls into jump backward transition), then the corrected time is the point in time that started 2 hours and 30 minutes after 2025-10-26T00:00:00.
      </li>
    </ul>
  </li>
  <li>
    <b>Strategy <code>time_to_day_end</code></b><br>
    <ul>
      <li>
        <b>Jump-forward case:</b> If, e.g., in CET a time 2025-03-30T02:30 is given (falls into jump forward transition), then the corrected time is the point in time that occurs at 24 h - 2 hours and 30 minutes = 21.5 h before 2025-03-31T00:00:00.
      </li>
      <li>
        <b>Jump-backward case:</b> If, e.g., in CET a time 2025-10-26T02:30 is given (falls into jump backward transition), then the corrected time is the point in time that occurs at 24 h - 2 hours and 30 minutes = 21.5 h before 2025-10-27T00:00:00.
      </li>
    </ul>
  </li>
</ul>
</p> 
</html>"));
  end correctInvalidDatetime;
  
  function addSingleRepetitionToDatetime "Adds a single repetition to a datetime object according to a repetition pattern."
    extends Modelica.Icons.Function;
    input Datetime dt "Datetime object to which to add a repetition";
    input String repetition "Valid values are hourly, daily, weekly, monthly, yearly, workdays firstDayInMonth, lastDayInMonth, or a floating point number specifying a repetition interval in seconds";
    input Timezone tz "Timezone object the DateTime object is interpreted in";
    input String holidays[:] "List of holidays in YYYY-MM-DD format";
    input Boolean withLeapSeconds = false "Flag to account for leap seconds";
    input Boolean autocorrect = true "If date after incrementing by discrete quanitities is invalid (days in month flow over, will correct to latest day in month). If time of day is invalid in timezone, will correct using correctInvalidDatetime according to the strategy chosen";
    input String strategy = "time_from_day_start" "If autocorrect == true, this strategy will be used to correct for invalid times of day (when falling into transition periods for daylight savings). Valid values are time_from_day_start and time_to_day_end";
    output Datetime dt_added;
  protected
    Real tstamp;
    Date d;
    Date d_added;
    Timefield tod;  // Time of day
    Real r;
    Data.WorkDays wd;
    Integer i;
    Integer dow;  // Day of week
    Boolean nextWdFound;
  algorithm
    tstamp := datetimeToPosix(dt, tz, withLeapSeconds);  
  
    d.year := dt.year;
    d.month := dt.month;
    d.day := dt.day;
    tod.sign := 1;
    tod.hours := dt.hours;
    tod.minutes := dt.minutes;
    tod.seconds := dt.seconds;
  
    // Repeation hourly
    if repetition == "hourly" then
      dt_added := posixToDatetime(tstamp + 3600, tz, withLeapSeconds);
    
    // Repeation daily
    elseif repetition == "daily" then
      d_added := addDaysToDate(d, 1);
      dt_added.year := d_added.year;
      dt_added.month := d_added.month;
      dt_added.day := d_added.day;
      dt_added.hours := tod.hours;
      dt_added.minutes := tod.minutes;
      dt_added.seconds := tod.seconds;
  
      if not isValidDatetime(dt_added, tz) == 1 and autocorrect then  
        dt_added := correctInvalidDatetime(dt_added, tz, strategy, withLeapSeconds);
      end if;
      
      if isWatchtimeInDaylightSaving(dt_added, tz) then
        dt_added.tz := tz.daylightName;
      else
        dt_added.tz := tz.standardName;
      end if;
  
      assert(isValidDatetime(dt_added, tz) == 1, "Adding daily repetition to datetime resulted in an invalid datetime: " + String(dt_added));
      
     // Repetition weekly
    elseif repetition == "weekly" then
      d_added := addDaysToDate(d, 7);
      dt_added.year := d_added.year;
      dt_added.month := d_added.month;
      dt_added.day := d_added.day;
      dt_added.hours := tod.hours;
      dt_added.minutes := tod.minutes;
      dt_added.seconds := tod.seconds;
      if isWatchtimeInDaylightSaving(dt_added, tz) then
        dt_added.tz := tz.daylightName;
      else
        dt_added.tz := tz.standardName;
      end if;    
  
      if not isValidDatetime(dt_added, tz) == 1 and autocorrect then  
        dt_added := correctInvalidDatetime(dt_added, tz, strategy, withLeapSeconds);
      end if;
      
      if isWatchtimeInDaylightSaving(dt_added, tz) then
        dt_added.tz := tz.daylightName;
      else
        dt_added.tz := tz.standardName;
      end if;
  
      assert(isValidDatetime(dt_added, tz) == 1, "Adding weekly repetition to datetime resulted in an invalid datetime: " + String(dt_added));
      
    // Repetition monthly
    elseif repetition == "monthly" then
      d_added := addMonthsToDate(d, 1);
      dt_added.year := d_added.year;
      dt_added.month := d_added.month;
      dt_added.day := d_added.day;
      dt_added.hours := tod.hours;
      dt_added.minutes := tod.minutes;
      dt_added.seconds := tod.seconds;
      
      if not isValidDatetime(dt_added, tz) == 1 and autocorrect then  
        dt_added := correctInvalidDatetime(dt_added, tz, strategy, withLeapSeconds);
      end if;
  
      if isWatchtimeInDaylightSaving(dt_added, tz) then
        dt_added.tz := tz.daylightName;
      else
        dt_added.tz := tz.standardName;
      end if;
  
      assert(isValidDatetime(dt_added, tz) == 1, "Adding monthly repetition to datetime resulted in an invalid datetime: " + String(dt_added));
  
    // Repetition yearly
    elseif repetition == "yearly" then
      d_added := addYearsToDate(d, 1);
      dt_added.year := d_added.year;
      dt_added.month := d_added.month;
      dt_added.day := d_added.day;
      dt_added.hours := tod.hours;
      dt_added.minutes := tod.minutes;
      dt_added.seconds := tod.seconds;
  
      if not isValidDatetime(dt_added, tz) == 1 and autocorrect then  
        dt_added := correctInvalidDatetime(dt_added, tz, strategy, withLeapSeconds);
      end if;
      
      if isWatchtimeInDaylightSaving(dt_added, tz) then
        dt_added.tz := tz.daylightName;
      else
        dt_added.tz := tz.standardName;
      end if;
  
      assert(isValidDatetime(dt_added, tz) == 1, "Adding yearly repetition to datetime resulted in an invalid datetime: " + String(dt_added));
  
    // Repetition until first workday is hit from wd is hit, and the date is not in datetimeSystem.holidays;
    elseif repetition == "workdays" then
      nextWdFound := false;
      d_added := d;
      while not nextWdFound loop
        d_added := addDaysToDate(d_added, 1); 
        dow := dayOfWeek(d_added.year, d_added.month, d_added.day);
        
        // Is standard workday
        nextWdFound := (Modelica.Math.Vectors.find(dow, wd.days) <> 0);      
        
        // Happens to fall on a holiday?
        for i in 1:size(holidays, 1) loop
          if String(d_added) == holidays[i] then
            nextWdFound := false;
            break;
          end if;
        end for;
      end while;
      
      dt_added.year := d_added.year;
      dt_added.month := d_added.month;
      dt_added.day := d_added.day;
      dt_added.hours := tod.hours;
      dt_added.minutes := tod.minutes;
      dt_added.seconds := tod.seconds;
  
      if not isValidDatetime(dt_added, tz) == 1 and autocorrect then  
        dt_added := correctInvalidDatetime(dt_added, tz, strategy, withLeapSeconds);
      end if;
      
      if isWatchtimeInDaylightSaving(dt_added, tz) then
        dt_added.tz := tz.daylightName;
      else
        dt_added.tz := tz.standardName;
      end if;    
  
      assert(isValidDatetime(dt_added, tz) == 1, "Adding workdays repetition to datetime resulted in an invalid datetime: " + String(dt_added));          
      
    // Keep adding days until we reach the first day of the next month
    elseif repetition == "firstDayInMonth" then
      d_added := d;
      while true loop
        d_added := addDaysToDate(d_added, 1);
        if d_added.day == 1 then
          break;
        end if;
      end while;
  
      dt_added.year := d_added.year;
      dt_added.month := d_added.month;
      dt_added.day := d_added.day;
      dt_added.hours := tod.hours;
      dt_added.minutes := tod.minutes;
      dt_added.seconds := tod.seconds;
      
      if not isValidDatetime(dt_added, tz) == 1 and autocorrect then  
        dt_added := correctInvalidDatetime(dt_added, tz, strategy, withLeapSeconds);
      end if;
      
      if isWatchtimeInDaylightSaving(dt_added, tz) then
        dt_added.tz := tz.daylightName;
      else
        dt_added.tz := tz.standardName;
      end if;
      
      assert(isValidDatetime(dt_added, tz) == 1, "Adding firstDayInMonth repetition to datetime resulted in an invalid datetime: " + String(dt_added));
  
    // Keep adding days until we reach the last day of the next month
    elseif repetition == "lastDayInMonth" then
      d_added := d;
      while true loop
        d_added := addDaysToDate(d_added, 1);
        if d_added.day == daysInMonth(d_added.year, d_added.month) then
          break;
        end if;
      end while;
  
      dt_added.year := d_added.year;
      dt_added.month := d_added.month;
      dt_added.day := d_added.day;
      dt_added.hours := tod.hours;
      dt_added.minutes := tod.minutes;
      dt_added.seconds := tod.seconds;
  
      if not isValidDatetime(dt_added, tz) == 1 and autocorrect then  
        dt_added := correctInvalidDatetime(dt_added, tz, strategy, withLeapSeconds);
      end if;
  
      if isWatchtimeInDaylightSaving(dt_added, tz) then
        dt_added.tz := tz.daylightName;
      else
        dt_added.tz := tz.standardName;
      end if;
  
      assert(isValidDatetime(dt_added, tz) == 1, "Adding lastDayInMonth repetition to datetime resulted in an invalid datetime: " + String(dt_added));
  
    else  // Try to interpret repetition as floating point number. If not successful will raise assert
      r := Modelica.Utilities.Strings.scanReal(repetition);
      
      dt_added := posixToDatetime(tstamp + r, tz, withLeapSeconds);
    end if;    
  annotation(
    Documentation(info = "<html>
<p>This function returns a next datetime object with the next date and time where the initial date and time
in the given <code>dt</code> would repeat according to the repetition pattern chosen.</p>
<p> If the repetition pattern is any of daily, weekly, monthly, yearly, workdays firstDayInMonth, or 
lastDayInMonth, then the time-of-day of the <code>dt</code> is kept and put into the respective next day 
that matches the repetition.<br>Note that that time-of-day might not always be valid, e.g. if it falls
into a transition period for daylight savings. To recover from that, one can let the function try to autocorrect
and specify a autocorrection strategy (see the variable description for how that works).</p> 
<p>If the repetition pattern is hourly or any floating point number, then the next event will be simply obtained
by letting 3600 s (for hourly) or the respective floating point number of seconds elapse.</p>
</html>"));  
  end addSingleRepetitionToDatetime;

  function largestPreviousTrigger "Given the simulation time in Posix and the trigger definition, returns the largest previous trigger with \"trigger time\" &le; \"the current simulation time\" as a Datetime object and in Posix if the initial trigger is already &ge; the current simulation time, the initial trigger is returned" 
    extends Modelica.Icons.Function;
    input Real simTimePosix;
    input Datetime initTrigger;
    input String repetition;
    input Timezone tz;
    input String holidays[:];
    input Boolean withLeapSeconds = false "Flag to account for leap seconds";
    input Boolean autocorrect = true "If date after incrementing by discrete quanitities is invalid (days in month flow over, will correct to latest day in month). If time of day is invalid in timezone, will correct using correctInvalidDatetime according to the strategy chosen";
    input String strategy = "time_from_day_start" "If autocorrect == true, this strategy will be used to correct for invalid times of day (when falling into transition periods for daylight savings). Valid values are time_from_day_start and time_to_day_end";
    output Datetime prevTrigger;
    output Real prevTriggerPosix;
  protected
    Real nextTriggerPosix;
    Datetime nextTrigger;
    Boolean prevFound;
  algorithm
    prevTrigger := initTrigger;
    prevTriggerPosix := datetimeToPosix(prevTrigger, tz, withLeapSeconds);
    prevFound := false;
    
    // If initial trigger is already >= sim
    if prevTriggerPosix >= simTimePosix then
      return;
    end if;
  
    // Loop to find largest previous trigger
    while not prevFound loop
      nextTrigger := addSingleRepetitionToDatetime(prevTrigger, repetition, tz, holidays, withLeapSeconds, autocorrect, strategy);
      nextTriggerPosix := datetimeToPosix(nextTrigger, tz, withLeapSeconds);
      if nextTriggerPosix <= simTimePosix then
        prevTrigger := nextTrigger;
        prevTriggerPosix := nextTriggerPosix;
        prevFound := false;
      else
        prevFound := true;
        break;
      end if;
    end while;
annotation(
    Documentation(info = "<html>
<p>
Returns the largest previous trigger datetime and the corresponding POSIX timestamp which, according to the chosen 
repetition pattern and the initial <code>initTrigger</code> date and time, is &le; <code>simTimePosix</code>. 
</p>
<p>
If the <code>initTrigger</code> is still ahead of <code>simTimePosix</code>, then <code>initTrigger</code> will be returned
together with its POSIX timestamp. 
</p>
<p>
Otherwise the implementation iteratively adds a single repetition to <code>initTrigger</code> until it has found
the largest repetition such that its POSIX timestamp is &le; <code>simTimePosix</code>.
</p>
</html>"));     
  end largestPreviousTrigger;
  
end Functions;