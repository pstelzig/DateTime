within DateTime.Examples.UnitTests;
package Basic
  extends Modelica.Icons.ExamplesPackage;
  import Strings = Modelica.Utilities.Strings;

  block TestSplitString
    extends Modelica.Icons.Example;
    parameter String str = "CET+01:00:00CEST01:00:00,M3.5.0/02:00:00,M10.5.0/03:00:00";
    parameter String delimiter = ",";
    String firstPart;
    String secondPart;
  algorithm
    when initial() then
      (firstPart, secondPart) := DateTime.Functions.splitAtFirst(str, delimiter);
      assert(firstPart == "CET+01:00:00CEST01:00:00", "First part is incorrect: " + firstPart);
      assert(secondPart == "M3.5.0/02:00:00,M10.5.0/03:00:00", "Second part is incorrect: " + secondPart);
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestSplitString;

  block TestSplit
    extends Modelica.Icons.Example;
    parameter String str = "2024-01-01T12:00:00;2023-12-31T23:59:59;2022-06-15T08:30:00";
    parameter String delimiter = ";";
    String parts[3];
  algorithm
    when initial() then
      parts := DateTime.Functions.split(str, delimiter);
      assert(parts[1] == "2024-01-01T12:00:00", "First part is incorrect: " + parts[1]);
      assert(parts[2] == "2023-12-31T23:59:59", "Second part is incorrect: " + parts[2]);
      assert(parts[3] == "2022-06-15T08:30:00", "Third part is incorrect: " + parts[3]);
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestSplit;

  block TestIsDigit
    extends Modelica.Icons.Example;
    parameter String expectedSuccesses = "0123456789";
    parameter String expectedFailures = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+-.:!$";
    Boolean result;
  algorithm
    when initial() then
      // Test for successful detection of single digits
      for i in 1:Strings.length(expectedSuccesses) loop
        result := DateTime.Functions.isDigit(Strings.substring(expectedSuccesses, i, i));
        assert(result, "Test case " + Strings.substring(expectedSuccesses, i, i) + " failed");
      end for;
      
      // Test for successful detection of non-digits
      for i in 1:Strings.length(expectedFailures) loop
        result := DateTime.Functions.isDigit(Strings.substring(expectedFailures, i, i));
        assert(not result, "Test case " + Strings.substring(expectedFailures, i, i) + " failed");
      end for;
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestIsDigit;

  block TestFindFirstDigit
    extends Modelica.Icons.Example;
    Integer pos;
  algorithm
    when initial() then
      // Test cases for findFirstDigit function
      pos := DateTime.Functions.findFirstDigit("CET+01:00:00");
      assert(pos == 5, "Test case 'CET+01:00:00' failed, got position: " + String(pos));
      pos := DateTime.Functions.findFirstDigit("CEST01:00:00");
      assert(pos == 5, "Test case 'CEST01:00:00' failed, got position: " + String(pos));
      pos := DateTime.Functions.findFirstDigit("M3.5.0/02:00:00");
      assert(pos == 2, "Test case 'M3.5.0/02:00:00' failed, got position: " + String(pos));
      pos := DateTime.Functions.findFirstDigit("NoDigitsHere");
      assert(pos == -1, "Test case 'NoDigitsHere' failed, got position: " + String(pos));
      pos := DateTime.Functions.findFirstDigit("12345");
      assert(pos == 1, "Test case '12345' failed, got position: " + String(pos));
      pos := DateTime.Functions.findFirstDigit("abc123");
      assert(pos == 4, "Test case 'abc123' failed, got position: " + String(pos));
      pos := DateTime.Functions.findFirstDigit("a1b2c3");
      assert(pos == 2, "Test case 'a1b2c3' failed, got position: " + String(pos));
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestFindFirstDigit;

  block TestParseTimefield
    extends Modelica.Icons.Example;
    Types.Timefield t;
    String timeStr;
  algorithm
    when initial() then
      // Test case for parseTimefield function: Includes seconds part
      timeStr := "12:34:56";
      t := DateTime.Functions.parseTimefield(timeStr);
      assert(t.sign == 1, "Test case " + timeStr + " failed for sign, got: " + String(t.sign));
      assert(t.hours == 12, "Test case " + timeStr + " failed for hours, got: " + String(t.hours));
      assert(t.minutes == 34, "Test case " + timeStr + " failed for minutes, got: " + String(t.minutes));
      assert(abs(t.seconds - 56.0) < 1e-6, "Test case " + timeStr + " failed for seconds, got: " + String(t.seconds));
      timeStr := "+01:02:03.456";
      t := DateTime.Functions.parseTimefield(timeStr);
      assert(t.sign == 1, "Test case " + timeStr + " failed for sign, got: " + String(t.sign));
      assert(t.hours == 1, "Test case " + timeStr + " failed for hours, got: " + String(t.hours));
      assert(t.minutes == 2, "Test case " + timeStr + " failed for minutes, got: " + String(t.minutes));
      assert(abs(t.seconds - 3.456) < 1e-6, "Test case " + timeStr + " failed for seconds, got: " + String(t.seconds));
      timeStr := "-01:02:03.456";
      t := DateTime.Functions.parseTimefield(timeStr);
      assert(t.sign == -1, "Test case " + timeStr + " failed for sign, got: " + String(t.sign));
      assert(t.hours == 1, "Test case " + timeStr + " failed for hours, got: " + String(t.hours));
      assert(t.minutes == 2, "Test case " + timeStr + " failed for minutes, got: " + String(t.minutes));
      assert(abs(t.seconds - 3.456) < 1e-6, "Test case " + timeStr + " failed for seconds, got: " + String(t.seconds));
      timeStr := "00:00:00";
      t := DateTime.Functions.parseTimefield(timeStr);
      assert(t.sign == 1, "Test case " + timeStr + " failed for sign, got: " + String(t.sign));
      assert(t.hours == 0, "Test case " + timeStr + " failed for hours, got: " + String(t.hours));
      assert(t.minutes == 0, "Test case " + timeStr + " failed for minutes, got: " + String(t.minutes));
      assert(abs(t.seconds - 0.0) < 1e-6, "Test case " + timeStr + " failed for seconds, got: " + String(t.seconds));
      timeStr := "23:59:59.999";
      t := DateTime.Functions.parseTimefield(timeStr);
      assert(t.sign == 1, "Test case " + timeStr + " failed for sign, got: " + String(t.sign));
      assert(t.hours == 23, "Test case " + timeStr + " failed for hours, got: " + String(t.hours));
      assert(t.minutes == 59, "Test case " + timeStr + " failed for minutes, got: " + String(t.minutes));
      assert(abs(t.seconds - 59.999) < 1e-6, "Test case " + timeStr + " failed for seconds, got: " + String(t.seconds));
      timeStr := "-23:59:59.999";
      t := DateTime.Functions.parseTimefield(timeStr);
      assert(t.sign == -1, "Test case " + timeStr + " failed for sign, got: " + String(t.sign));
      assert(t.hours == 23, "Test case " + timeStr + " failed for hours, got: " + String(t.hours));
      assert(t.minutes == 59, "Test case " + timeStr + " failed for minutes, got: " + String(t.minutes));
      assert(abs(t.seconds - 59.999) < 1e-6, "Test case " + timeStr + " failed for seconds, got: " + String(t.seconds));

      // Test case for parseTimefield function: Without seconds part
      timeStr := "12:34";
      t := DateTime.Functions.parseTimefield(timeStr);
      assert(t.sign == 1, "Test case " + timeStr + " failed for sign, got: " + String(t.sign));
      assert(t.hours == 12, "Test case " + timeStr + " failed for hours, got: " + String(t.hours));
      assert(t.minutes == 34, "Test case " + timeStr + " failed for minutes, got: " + String(t.minutes));
      assert(abs(t.seconds - 0.0) < 1e-6, "Test case " + timeStr + " failed for seconds, got: " + String(t.seconds));
      timeStr := "+01:02";
      t := DateTime.Functions.parseTimefield(timeStr);
      assert(t.sign == 1, "Test case " + timeStr + " failed for sign, got: " + String(t.sign));
      assert(t.hours == 1, "Test case " + timeStr + " failed for hours, got: " + String(t.hours));
      assert(t.minutes == 2, "Test case " + timeStr + " failed for minutes, got: " + String(t.minutes));
      assert(abs(t.seconds - 0.0) < 1e-6, "Test case " + timeStr + " failed for seconds, got: " + String(t.seconds));
      timeStr := "-01:02";
      t := DateTime.Functions.parseTimefield(timeStr);
      assert(t.sign == -1, "Test case " + timeStr + " failed for sign, got: " + String(t.sign));
      assert(t.hours == 1, "Test case " + timeStr + " failed for hours, got: " + String(t.hours));
      assert(t.minutes == 2, "Test case " + timeStr + " failed for minutes, got: " + String(t.minutes));
      assert(abs(t.seconds - 0.0) < 1e-6, "Test case " + timeStr + " failed for seconds, got: " + String(t.seconds));
      timeStr := "00:00";
      t := DateTime.Functions.parseTimefield(timeStr);
      assert(t.sign == 1, "Test case " + timeStr + " failed for sign, got: " + String(t.sign));
      assert(t.hours == 0, "Test case " + timeStr + " failed for hours, got: " + String(t.hours));
      assert(t.minutes == 0, "Test case " + timeStr + " failed for minutes, got: " + String(t.minutes));
      assert(abs(t.seconds - 0.0) < 1e-6, "Test case " + timeStr + " failed for seconds, got: " + String(t.seconds));
      timeStr := "23:59";
      t := DateTime.Functions.parseTimefield(timeStr);
      assert(t.sign == 1, "Test case " + timeStr + " failed for sign, got: " + String(t.sign));
      assert(t.hours == 23, "Test case " + timeStr + " failed for hours, got: " + String(t.hours));
      assert(t.minutes == 59, "Test case " + timeStr + " failed for minutes, got: " + String(t.minutes));
      assert(abs(t.seconds - 0.0) < 1e-6, "Test case " + timeStr + " failed for seconds, got: " + String(t.seconds));
      timeStr := "-23:59";
      t := DateTime.Functions.parseTimefield(timeStr);
      assert(t.sign == -1, "Test case " + timeStr + " failed for sign, got: " + String(t.sign));
      assert(t.hours == 23, "Test case " + timeStr + " failed for hours, got: " + String(t.hours));
      assert(t.minutes == 59, "Test case " + timeStr + " failed for minutes, got: " + String(t.minutes));
      assert(abs(t.seconds - 0.0) < 1e-6, "Test case " + timeStr + " failed for seconds, got: " + String(t.seconds));
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestParseTimefield;

  block TestParseTransition
    extends Modelica.Icons.Example;
    Integer month;
    Integer week;
    Integer day;
    DateTime.Types.Timefield switchTime;
  algorithm
    when initial() then
      // Test case for parseTransition function
      (month, week, day, switchTime) := DateTime.Functions.parseTransition("M3.5.0/02:00:00");
      assert(month == 3, "Test case 'M3.5.0/02:00:00' failed for month, got: " + String(month));
      assert(week == 5, "Test case 'M3.5.0/02:00:00' failed for week, got: " + String(week));
      assert(day == 0, "Test case 'M3.5.0/02:00:00' failed for day, got: " + String(day));
      assert(switchTime.hours == 2, "Test case 'M3.5.0/02:00:00' failed for switchTime.hours, got: " + String(switchTime.hours));
      assert(switchTime.minutes == 0, "Test case 'M3.5.0/02:00:00' failed for switchTime.minutes, got: " + String(switchTime.minutes));
      assert(abs(switchTime.seconds - 0.0) < 1e-6, "Test case 'M3.5.0/02:00:00' failed for switchTime.seconds, got: " + String(switchTime.seconds));
      (month, week, day, switchTime) := DateTime.Functions.parseTransition("M10.5.0/03:00:00");
      assert(month == 10, "Test case 'M10.5.0/03:00:00' failed for month, got: " + String(month));
      assert(week == 5, "Test case 'M10.5.0/03:00:00' failed for week, got: " + String(week));
      assert(day == 0, "Test case 'M10.5.0/03:00:00' failed for day, got: " + String(day));
      assert(switchTime.hours == 3, "Test case 'M10.5.0/03:00:00' failed for switchTime.hours, got: " + String(switchTime.hours));
      assert(switchTime.minutes == 0, "Test case 'M10.5.0/03:00:00' failed for switchTime.minutes, got: " + String(switchTime.minutes));
      assert(abs(switchTime.seconds - 0.0) < 1e-6, "Test case 'M10.5.0/03:00:00' failed for switchTime.seconds, got: " + String(switchTime.seconds));
      (month, week, day, switchTime) := DateTime.Functions.parseTransition("M1.1.1/00:00:00");
      assert(month == 1, "Test case 'M1.1.1/00:00:00' failed for month, got: " + String(month));
      assert(week == 1, "Test case 'M1.1.1/00:00:00' failed for week, got: " + String(week));
      assert(day == 1, "Test case 'M1.1.1/00:00:00' failed for day, got: " + String(day));
      assert(switchTime.hours == 0, "Test case 'M1.1.1/00:00:00' failed for switchTime.hours, got: " + String(switchTime.hours));
      assert(switchTime.minutes == 0, "Test case 'M1.1.1/00:00:00' failed for switchTime.minutes, got: " + String(switchTime.minutes));
      assert(abs(switchTime.seconds - 0.0) < 1e-6, "Test case 'M1.1.1/00:00:00' failed for switchTime.seconds, got: " + String(switchTime.seconds));
      (month, week, day, switchTime) := DateTime.Functions.parseTransition("M12.4.6/23:59:59");
      assert(month == 12, "Test case 'M12.4.6/23:59:59' failed for month, got: " + String(month));
      assert(week == 4, "Test case 'M12.4.6/23:59:59' failed for week, got: " + String(week));
      assert(day == 6, "Test case 'M12.4.6/23:59:59' failed for day, got: " + String(day));
      assert(switchTime.hours == 23, "Test case 'M12.4.6/23:59:59' failed for switchTime.hours, got: " + String(switchTime.hours));
      assert(switchTime.minutes == 59, "Test case 'M12.4.6/23:59:59' failed for switchTime.minutes, got: " + String(switchTime.minutes));
      assert(abs(switchTime.seconds - 59.0) < 1e-6, "Test case 'M12.4.6/23:59:59' failed for switchTime.seconds, got: " + String(switchTime.seconds));
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestParseTransition;

  model TestParseTimezone
    extends Modelica.Icons.Example;
    Types.Timezone tz;
    String tzIeee1013;
  algorithm
    when initial() then
      // Test case for parseTimezone function: Central European Time and daylight saving
      tzIeee1013 := "CET+01:00:00CEST+01:00:00,M3.5.0/02:00:00,M10.5.0/03:00:00";
      tz := Functions.parseTimezone(tzIeee1013);
      
      // Check standard time details
      assert(tz.standardName == "CET", "Test case " + tzIeee1013 + " failed for standardName, got: " + tz.standardName);
      assert(tz.standardOffset.sign == 1, "Test case " + tzIeee1013 + " failed for standardOffset.sign, got: " + String(tz.standardOffset.sign));
      assert(tz.standardOffset.hours == 1, "Test case " + tzIeee1013 + " failed for standardOffset.hours, got: " + String(tz.standardOffset.hours));
      assert(tz.standardOffset.minutes == 0, "Test case " + tzIeee1013 + " failed for standardOffset.minutes, got: " + String(tz.standardOffset.minutes));
      assert(abs(tz.standardOffset.seconds - 0.0) < 1e-6, "Test case " + tzIeee1013 + " failed for standardOffset.seconds, got: " + String(tz.standardOffset.seconds));
      
      // Check daylight saving time details
      assert(tz.daylightName == "CEST", "Test case " + tzIeee1013 + " failed for daylightName, got: " + tz.daylightName);
      assert(tz.daylightOffset.sign == 1, "Test case " + tzIeee1013 + " failed for daylightOffset.sign, got: " + String(tz.daylightOffset.sign));
      assert(tz.daylightOffset.hours == 1, "Test case " + tzIeee1013 + " failed for daylightOffset.hours, got: " + String(tz.daylightOffset.hours));
      assert(tz.daylightOffset.minutes == 0, "Test case " + tzIeee1013 + " failed for daylightOffset.minutes, got: " + String(tz.daylightOffset.minutes));
      assert(abs(tz.daylightOffset.seconds - 0.0) < 1e-6, "Test case " + tzIeee1013 + " failed for daylightOffset.seconds, got: " + String(tz.daylightOffset.seconds));

      // Check summer transition details
      assert(tz.startMonth == 3, "Test case " + tzIeee1013 + " failed for startMonth, got: " + String(tz.startMonth));
      assert(tz.startWeek == 5, "Test case " + tzIeee1013 + " failed for startWeek, got: " + String(tz.startWeek));
      assert(tz.startDay == 0, "Test case " + tzIeee1013 + " failed for startDay, got: " + String(tz.startDay));
      assert(tz.startTime.sign == 1, "Test case " + tzIeee1013 + " failed for startTime.sign, got: " + String(tz.startTime.sign));
      assert(tz.startTime.hours == 2, "Test case " + tzIeee1013 + " failed for startTime.hours, got: " + String(tz.startTime.hours));
      assert(tz.startTime.minutes == 0, "Test case " + tzIeee1013 + " failed for startTime.minutes, got: " + String(tz.startTime.minutes));
      assert(abs(tz.startTime.seconds - 0.0) < 1e-6, "Test case " + tzIeee1013 + " failed for startTime.seconds, got: " + String(tz.startTime.seconds));
      
      // Check winter transition details
      assert(tz.endMonth == 10, "Test case " + tzIeee1013 + " failed for endMonth, got: " + String(tz.endMonth));
      assert(tz.endWeek == 5, "Test case " + tzIeee1013 + " failed for endWeek, got: " + String(tz.endWeek));
      assert(tz.endDay == 0, "Test case " + tzIeee1013 + " failed for endDay, got: " + String(tz.endDay));
      assert(tz.endTime.sign == 1, "Test case " + tzIeee1013 + " failed for endTime.sign, got: " + String(tz.endTime.sign));
      assert(tz.endTime.hours == 3, "Test case " + tzIeee1013 + " failed for endTime.hours, got: " + String(tz.endTime.hours));
      assert(tz.endTime.minutes == 0, "Test case " + tzIeee1013 + " failed for endTime.minutes, got: " + String(tz.endTime.minutes));
      assert(abs(tz.endTime.seconds - 0.0) < 1e-6, "Test case " + tzIeee1013 + " failed for endTime.seconds, got: " + String(tz.endTime.seconds));
      
      // Test case for parseTimezone function: Pacific Standard Time and daylight saving
      tzIeee1013 := "PST-08:00:00PDT+01:00:00,M3.2.0/02:00:00,M11.1.0/02:00:00";
      tz := Functions.parseTimezone(tzIeee1013);
      
      // Check standard time details
      assert(tz.standardName == "PST", "Test case " + tzIeee1013 + " failed for standardName, got: " + tz.standardName);
      assert(tz.standardOffset.sign == -1, "Test case " + tzIeee1013 + " failed for standardOffset.sign, got: " + String(tz.standardOffset.sign));
      assert(tz.standardOffset.hours == 8, "Test case " + tzIeee1013 + " failed for standardOffset.hours, got: " + String(tz.standardOffset.hours));
      assert(tz.standardOffset.minutes == 0, "Test case " + tzIeee1013 + " failed for standardOffset.minutes, got: " + String(tz.standardOffset.minutes));
      assert(abs(tz.standardOffset.seconds - 0.0) < 1e-6, "Test case " + tzIeee1013 + " failed for standardOffset.seconds, got: " + String(tz.standardOffset.seconds));
      
      // Check daylight saving time details
      assert(tz.daylightName == "PDT", "Test case " + tzIeee1013 + " failed for daylightName, got: " + tz.daylightName);
      assert(tz.daylightOffset.sign == 1, "Test case " + tzIeee1013 + " failed for daylightOffset.sign, got: " + String(tz.daylightOffset.sign));
      assert(tz.daylightOffset.hours == 1, "Test case " + tzIeee1013 + " failed for daylightOffset.hours, got: " + String(tz.daylightOffset.hours));
      assert(tz.daylightOffset.minutes == 0, "Test case " + tzIeee1013 + " failed for daylightOffset.minutes, got: " + String(tz.daylightOffset.minutes));
      assert(abs(tz.daylightOffset.seconds - 0.0) < 1e-6, "Test case " + tzIeee1013 + " failed for daylightOffset.seconds, got: " + String(tz.daylightOffset.seconds));

      // Check summer transition details
      assert(tz.startMonth == 3, "Test case " + tzIeee1013 + " failed for startMonth, got: " + String(tz.startMonth));
      assert(tz.startWeek == 2, "Test case " + tzIeee1013 + " failed for startWeek, got: " + String(tz.startWeek));
      assert(tz.startDay == 0, "Test case " + tzIeee1013 + " failed for startDay, got: " + String(tz.startDay));
      assert(tz.startTime.sign == 1, "Test case " + tzIeee1013 + " failed for startTime.sign, got: " + String(tz.startTime.sign));
      assert(tz.startTime.hours == 2, "Test case " + tzIeee1013 + " failed for startTime.hours, got: " + String(tz.startTime.hours));
      assert(tz.startTime.minutes == 0, "Test case " + tzIeee1013 + " failed for startTime.minutes, got: " + String(tz.startTime.minutes));
      assert(abs(tz.startTime.seconds - 0.0) < 1e-6, "Test case " + tzIeee1013 + " failed for startTime.seconds, got: " + String(tz.startTime.seconds));
      
      // Check winter transition details
      assert(tz.endMonth == 11, "Test case " + tzIeee1013 + " failed for endMonth, got: " + String(tz.endMonth));
      assert(tz.endWeek == 1, "Test case " + tzIeee1013 + " failed for endWeek, got: " + String(tz.endWeek));
      assert(tz.endDay == 0, "Test case " + tzIeee1013 + " failed for endDay, got: " + String(tz.endDay));
      assert(tz.endTime.sign == 1, "Test case " + tzIeee1013 + " failed for endTime.sign, got: " + String(tz.endTime.sign));
      assert(tz.endTime.hours == 2, "Test case " + tzIeee1013 + " failed for endTime.hours, got: " + String(tz.endTime.hours));
      assert(tz.endTime.minutes == 0, "Test case " + tzIeee1013 + " failed for endTime.minutes, got: " + String(tz.endTime.minutes));
      assert(abs(tz.endTime.seconds - 0.0) < 1e-6, "Test case " + tzIeee1013 + " failed for endTime.seconds, got: " + String(tz.endTime.seconds));
      
      // Test case for parseTimezone function: UTC. No daylight savings
      tzIeee1013 := "UTC+00:00:00";
      tz := Functions.parseTimezone(tzIeee1013);
      
      // Check standard time details
      assert(tz.standardName == "UTC", "Test case " + tzIeee1013 + " failed for standardName, got: " + tz.standardName);
      assert(tz.standardOffset.sign == 1, "Test case " + tzIeee1013 + " failed for standardOffset.sign, got: " + String(tz.standardOffset.sign));
      assert(tz.standardOffset.hours == 0, "Test case " + tzIeee1013 + " failed for standardOffset.hours, got: " + String(tz.standardOffset.hours));
      assert(tz.standardOffset.minutes == 0, "Test case " + tzIeee1013 + " failed for standardOffset.minutes, got: " + String(tz.standardOffset.minutes));
      assert(abs(tz.standardOffset.seconds - 0.0) < 1e-6, "Test case " + tzIeee1013 + " failed for standardOffset.seconds, got: " + String(tz.standardOffset.seconds));
      
      // Check daylight saving time details
      assert(tz.daylightName == "UTC", "Test case " + tzIeee1013 + " failed for daylightName, got: " + tz.daylightName);
      assert(tz.daylightOffset.sign == 1, "Test case " + tzIeee1013 + " failed for daylightOffset.sign, got: " + String(tz.daylightOffset.sign));
      assert(tz.daylightOffset.hours == 0, "Test case " + tzIeee1013 + " failed for daylightOffset.hours, got: " + String(tz.daylightOffset.hours));
      assert(tz.daylightOffset.minutes == 0, "Test case " + tzIeee1013 + " failed for daylightOffset.minutes, got: " + String(tz.daylightOffset.minutes));
      assert(abs(tz.daylightOffset.seconds - 0.0) < 1e-6, "Test case " + tzIeee1013 + " failed for daylightOffset.seconds, got: " + String(tz.daylightOffset.seconds));
      
      // Check summer transition details
      assert(tz.startMonth == 0, "Test case " + tzIeee1013 + " failed for startMonth, got: " + String(tz.startMonth));
      assert(tz.startWeek == 0, "Test case " + tzIeee1013 + " failed for startWeek, got: " + String(tz.startWeek));
      assert(tz.startDay == 0, "Test case " + tzIeee1013 + " failed for startDay, got: " + String(tz.startDay));
      assert(tz.startTime.sign == 1, "Test case " + tzIeee1013 + " failed for startTime.sign, got: " + String(tz.startTime.sign));
      assert(tz.startTime.hours == 0, "Test case " + tzIeee1013 + " failed for startTime.hours, got: " + String(tz.startTime.hours));
      assert(tz.startTime.minutes == 0, "Test case " + tzIeee1013 + " failed for startTime.minutes, got: " + String(tz.startTime.minutes));
      assert(abs(tz.startTime.seconds - 0.0) < 1e-6, "Test case " + tzIeee1013 + " failed for startTime.seconds, got: " + String(tz.startTime.seconds));
      
      // Check winter transition details
      assert(tz.endMonth == 0, "Test case " + tzIeee1013 + " failed for endMonth, got: " + String(tz.endMonth));
      assert(tz.endWeek == 0, "Test case " + tzIeee1013 + " failed for endWeek, got: " + String(tz.endWeek));
      assert(tz.endDay == 0, "Test case " + tzIeee1013 + " failed for endDay, got: " + String(tz.endDay));
      assert(tz.endTime.sign == 1, "Test case " + tzIeee1013 + " failed for endTime.sign, got: " + String(tz.endTime.sign));
      assert(tz.endTime.hours == 0, "Test case " + tzIeee1013 + " failed for endTime.hours, got: " + String(tz.endTime.hours));
      assert(tz.endTime.minutes == 0, "Test case " + tzIeee1013 + " failed for endTime.minutes, got: " + String(tz.endTime.minutes));
      assert(abs(tz.endTime.seconds - 0.0) < 1e-6, "Test case " + tzIeee1013 + " failed for endTime.seconds, got: " + String(tz.endTime.seconds));
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestParseTimezone;

  model TestParseDate
    extends Modelica.Icons.Example;
    DateTime.Types.Date d;
    String dateStr;
  algorithm
    when initial() then
      // Test case 1: Standard date
      dateStr := "2024-06-15";
      d := Functions.parseDate(dateStr);
      assert(d.year == 2024, "Test case " + dateStr + " failed for year, got: " + String(d.year));
      assert(d.month == 6, "Test case " + dateStr + " failed for month, got: " + String(d.month));
      assert(d.day == 15, "Test case " + dateStr + " failed for day, got: " + String(d.day));

      // Test case 2: Leap year
      dateStr := "2020-02-29";
      d := Functions.parseDate(dateStr);
      assert(d.year == 2020, "Test case " + dateStr + " failed for year, got: " + String(d.year));
      assert(d.month == 2, "Test case " + dateStr + " failed for month, got: " + String(d.month));
      assert(d.day == 29, "Test case " + dateStr + " failed for day, got: " + String(d.day));

      // Test case 3: End of year
      dateStr := "1999-12-31";
      d := Functions.parseDate(dateStr);
      assert(d.year == 1999, "Test case " + dateStr + " failed for year, got: " + String(d.year));
      assert(d.month == 12, "Test case " + dateStr + " failed for month, got: " + String(d.month));
      assert(d.day == 31, "Test case " + dateStr + " failed for day, got: " + String(d.day));
      
      // Test case 4: Beginning of year
      dateStr := "2000-01-01";
      d := Functions.parseDate(dateStr);
      assert(d.year == 2000, "Test case " + dateStr + " failed for year, got: " + String(d.year));
      assert(d.month == 1, "Test case " + dateStr + " failed for month, got: " + String(d.month));
      assert(d.day == 1, "Test case " + dateStr + " failed for day, got: " + String(d.day));

      // Test roundtrip
      d := DateTime.Types.Date(year = 1998, month = 2, day = 17);
      assert(d == Functions.parseDate(String(d)), "Roundtrip test failed for " + String(d) + ", got: " + String(Functions.parseDate(String(d))));
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestParseDate;

  model TestParseDatetime
    extends Modelica.Icons.Example;
    Types.Datetime dt;
    String datetimeStr;
  algorithm
    when initial() then
      // Test case 1
      datetimeStr := "2023-10-05T14:48";
      dt := Functions.parseDatetime(datetimeStr);
      assert(dt.year == 2023, "Test case " + datetimeStr + " failed for year, got: " + String(dt.year));
      assert(dt.month == 10, "Test case " + datetimeStr + " failed for month, got: " + String(dt.month));
      assert(dt.day == 5, "Test case " + datetimeStr + " failed for day, got: " + String(dt.day));
      assert(dt.hours == 14, "Test case " + datetimeStr + " failed for hours, got: " + String(dt.hours));
      assert(dt.minutes == 48, "Test case " + datetimeStr + " failed for minutes, got: " + String(dt.minutes));
      assert(abs(dt.seconds - 0.0) < 1e-6, "Test case " + datetimeStr + " failed for seconds, got: " + String(dt.seconds));
      assert(dt.tz == "", "Test case " + datetimeStr + " failed for tz, got: " + dt.tz);

      // Test case 2
      datetimeStr := "2021-01-01T00:00:00";
      dt := Functions.parseDatetime(datetimeStr);
      assert(dt.year == 2021, "Test case " + datetimeStr + " failed for year, got: " + String(dt.year));
      assert(dt.month == 1, "Test case " + datetimeStr + " failed for month, got: " + String(dt.month));
      assert(dt.day == 1, "Test case " + datetimeStr + " failed for day, got: " + String(dt.day));
      assert(dt.hours == 0, "Test case " + datetimeStr + " failed for hours, got: " + String(dt.hours));
      assert(dt.minutes == 0, "Test case " + datetimeStr + " failed for minutes, got: " + String(dt.minutes));
      assert(abs(dt.seconds - 0.0) < 1e-6, "Test case " + datetimeStr + " failed for seconds, got: " + String(dt.seconds));
      assert(dt.tz == "", "Test case " + datetimeStr + " failed for tz, got: " + dt.tz);

      // Test case 3
      datetimeStr := "1999-12-31T23:59:59.999";
      dt := Functions.parseDatetime(datetimeStr);
      assert(dt.year == 1999, "Test case " + datetimeStr + " failed for year, got: " + String(dt.year));
      assert(dt.month == 12, "Test case " + datetimeStr + " failed for month, got: " + String(dt.month));
      assert(dt.day == 31, "Test case " + datetimeStr + " failed for day, got: " + String(dt.day));
      assert(dt.hours == 23, "Test case " + datetimeStr + " failed for hours, got: " + String(dt.hours));
      assert(dt.minutes == 59, "Test case " + datetimeStr + " failed for minutes, got: " + String(dt.minutes));
      assert(abs(dt.seconds - 59.999) < 1e-6, "Test case " + datetimeStr + " failed for seconds, got: " + String(dt.seconds));
      assert(dt.tz == "", "Test case " + datetimeStr + " failed for tz, got: " + dt.tz);
      
      // Test case 4
      datetimeStr := "2025-10-26T02:30:01.1234 CET";
      dt := Functions.parseDatetime(datetimeStr);
      assert(dt.year == 2025, "Test case " + datetimeStr + " failed for year, got: " + String(dt.year));
      assert(dt.month == 10, "Test case " + datetimeStr + " failed for month, got: " + String(dt.month));
      assert(dt.day == 26, "Test case " + datetimeStr + " failed for day, got: " + String(dt.day));
      assert(dt.hours == 2, "Test case " + datetimeStr + " failed for hours, got: " + String(dt.hours));
      assert(dt.minutes == 30, "Test case " + datetimeStr + " failed for minutes, got: " + String(dt.minutes));
      assert(abs(dt.seconds - 1.1234) < 1e-6, "Test case " + datetimeStr + " failed for seconds, got: " + String(dt.seconds));
      assert(dt.tz == "CET", "Test case " + datetimeStr + " failed for tz, got: " + dt.tz);

      // Test case 5
      datetimeStr := "2025-10-26T02:30 CET";
      dt := Functions.parseDatetime(datetimeStr);
      assert(dt.year == 2025, "Test case " + datetimeStr + " failed for year, got: " + String(dt.year));
      assert(dt.month == 10, "Test case " + datetimeStr + " failed for month, got: " + String(dt.month));
      assert(dt.day == 26, "Test case " + datetimeStr + " failed for day, got: " + String(dt.day));
      assert(dt.hours == 2, "Test case " + datetimeStr + " failed for hours, got: " + String(dt.hours));
      assert(dt.minutes == 30, "Test case " + datetimeStr + " failed for minutes, got: " + String(dt.minutes));
      assert(abs(dt.seconds - 0.0) < 1e-6, "Test case " + datetimeStr + " failed for seconds, got: " + String(dt.seconds));
      assert(dt.tz == "CET", "Test case " + datetimeStr + " failed for tz, got: " + dt.tz);

      // Test roundtrip 1
      dt := DateTime.Types.Datetime(year = 1998, month = 2, day = 17, hours = 11, minutes = 17, seconds = 22.76201, tz = "CET");
      assert(dt == Functions.parseDatetime(String(dt)), "Roundtrip test failed for " + String(dt) + ", got: " + String(Functions.parseDatetime(String(dt))));

      // Test roundtrip 2
      dt := DateTime.Types.Datetime(year = 1998, month = 2, day = 17, hours = 11, minutes = 17, seconds = 0, tz = "CET");
      assert(dt == Functions.parseDatetime(String(dt)), "Roundtrip test failed for " + String(dt) + ", got: " + String(Functions.parseDatetime(String(dt))));
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestParseDatetime;

  model TestDatetimeToString
    extends Modelica.Icons.Example;
    Types.Datetime dt;
    String dtStr;
    String expectedStr;
  algorithm
    when initial() then
      // Test case 1: Full datetime with fractional seconds and timezone
      dt := Types.Datetime(year=2024, month=6, day=15, hours=10, minutes=30, seconds=45.123, tz="CET");
      dtStr := String(dt);
      expectedStr := "2024-06-15T10:30:45.123000 CET";
      assert(dtStr == expectedStr, "Test case 1 failed. Expected '" + expectedStr + "', got '" + dtStr + "'");

      // Test case 2: Datetime with integer seconds and timezone
      dt := Types.Datetime(year=2023, month=1, day=1, hours=0, minutes=0, seconds=0.0, tz="UTC");
      dtStr := String(dt);
      expectedStr := "2023-01-01T00:00:00 UTC";
      assert(dtStr == expectedStr, "Test case 2 failed. Expected '" + expectedStr + "', got '" + dtStr + "'");

      // Test case 3: Datetime without timezone and with fractional seconds
      dt := Types.Datetime(year=1999, month=12, day=31, hours=23, minutes=59, seconds=59.999, tz="");
      dtStr := String(dt);
      expectedStr := "1999-12-31T23:59:59.999000";
      assert(dtStr == expectedStr, "Test case 3 failed. Expected '" + expectedStr + "', got '" + dtStr + "'");

      // Test case 4: Datetime without timezone and with integer seconds
      dt := Types.Datetime(year=2000, month=2, day=29, hours=12, minutes=0, seconds=0.0, tz="");
      dtStr := String(dt);
      expectedStr := "2000-02-29T12:00:00";
      assert(dtStr == expectedStr, "Test case 4 failed. Expected '" + expectedStr + "', got '" + dtStr + "'");

      // Test case 5: Datetime with integer seconds and without timezone
      dt := Types.Datetime(year=2021, month=5, day=20, hours=8, minutes=45, seconds=0.0, tz="");
      dtStr := String(dt);
      expectedStr := "2021-05-20T08:45:00";
      assert(dtStr == expectedStr, "Test case 5 failed. Expected '" + expectedStr + "', got '" + dtStr + "'");

      // Test case 6: Datetime with integer seconds and with timezone
      dt := Types.Datetime(year=2022, month=11, day=8, hours=18, minutes=0, seconds=0.0, tz="PST");
      dtStr := String(dt);
      expectedStr := "2022-11-08T18:00:00 PST";
      assert(dtStr == expectedStr, "Test case 6 failed. Expected '" + expectedStr + "', got '" + dtStr + "'");
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestDatetimeToString;
end Basic;