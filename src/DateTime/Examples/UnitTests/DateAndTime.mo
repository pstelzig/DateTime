within DateTime.Examples.UnitTests;
package DateAndTime
  extends Modelica.Icons.ExamplesPackage;

  model TestDayOfWeek
    extends Modelica.Icons.Example;
    Integer w;
    String dateStr;
  algorithm
    when initial() then
      // Test case 1: Known Monday (2024-01-01)
      dateStr := "2024-01-01";
      w := Functions.dayOfWeek(2024, 1, 1);
      assert(w == 1, "Test case " + dateStr + " should be Monday (1), got: " + String(w));

      // Test case 2: Known Sunday (2023-12-31)
      dateStr := "2023-12-31";
      w := Functions.dayOfWeek(2023, 12, 31);
      assert(w == 0, "Test case " + dateStr + " should be Sunday (0), got: " + String(w));

      // Test case 3: February in leap year (2024-02-29)
      dateStr := "2024-02-29";
      w := Functions.dayOfWeek(2024, 2, 29);
      assert(w == 4, "Test case " + dateStr + " should be Thursday (4), got: " + String(w));

      // Test case 4: Different century (1900-01-01)
      dateStr := "1900-01-01";
      w := Functions.dayOfWeek(1900, 1, 1);
      assert(w == 1, "Test case " + dateStr + " should be Monday (1), got: " + String(w));

      // Test case 5: Mid-month, mid-year (2023-07-15)
      dateStr := "2023-07-15";
      w := Functions.dayOfWeek(2023, 7, 15);
      assert(w == 6, "Test case " + dateStr + " should be Saturday (6), got: " + String(w));

      // Test case 6: End of century (1999-12-31)
      dateStr := "1999-12-31";
      w := Functions.dayOfWeek(1999, 12, 31);
      assert(w == 5, "Test case " + dateStr + " should be Friday (5), got: " + String(w));
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestDayOfWeek;

  model TestAddSecondsToDatetime
    extends Modelica.Icons.Example;
    Types.Datetime dt;
    Types.Datetime result;
  algorithm
    when initial() then
      // Test case 1: Add positive time, stay in same day
      dt := Types.Datetime(2024, 3, 15, 12, 0, 0.0, "");
      result := Functions.addSecondsToDatetime(dt, 3600.0);

      // Add 1 hour
      assert(result.year == 2024 and result.month == 3 and result.day == 15 and result.hours == 13 and result.minutes == 0 and abs(result.seconds - 0.0) < 1e-6, "Test case 1 failed: Adding 1 hour to 12:00");

      // Test case 2: Add negative time, stay in same day
      dt := Types.Datetime(2024, 3, 15, 12, 0, 0.0, "");
      result := Functions.addSecondsToDatetime(dt, -3600.0);

      // Subtract 1 hour
      assert(result.year == 2024 and result.month == 3 and result.day == 15 and result.hours == 11 and result.minutes == 0 and abs(result.seconds - 0.0) < 1e-6, "Test case 2 failed: Subtracting 1 hour from 12:00");

      // Test case 3: Add positive time, next day
      dt := Types.Datetime(2024, 3, 15, 23, 30, 0.0, "");
      result := Functions.addSecondsToDatetime(dt, 3600.0);

      // Add 1 hour
      assert(result.year == 2024 and result.month == 3 and result.day == 16 and result.hours == 0 and result.minutes == 30 and abs(result.seconds - 0.0) < 1e-6, "Test case 3 failed: Adding 1 hour to 23:30");
      
      // Test case 4: Add negative time, previous day
      dt := Types.Datetime(2024, 3, 15, 0, 30, 0.0, "");
      result := Functions.addSecondsToDatetime(dt, -3600.0);

      // Subtract 1 hour
      assert(result.year == 2024 and result.month == 3 and result.day == 14 and result.hours == 23 and result.minutes == 30 and abs(result.seconds - 0.0) < 1e-6, "Test case 4 failed: Subtracting 1 hour from 00:30");

      // Test case 5: Add positive time, next month
      dt := Types.Datetime(2024, 3, 31, 23, 30, 0.0, "");
      result := Functions.addSecondsToDatetime(dt, 3600.0);

      // Add 1 hour
      assert(result.year == 2024 and result.month == 4 and result.day == 1 and result.hours == 0 and result.minutes == 30 and abs(result.seconds - 0.0) < 1e-6, "Test case 5 failed: Adding 1 hour to March 31 23:30");

      // Test case 6: Add negative time, previous month
      dt := Types.Datetime(2024, 4, 1, 0, 30, 0.0, "");
      result := Functions.addSecondsToDatetime(dt, -3600.0);

      // Subtract 1 hour
      assert(result.year == 2024 and result.month == 3 and result.day == 31 and result.hours == 23 and result.minutes == 30 and result.seconds == 0.0, "Test case 6 failed: Subtracting 1 hour from April 1 00:30");
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestAddSecondsToDatetime;

  model TestYearToTransitionDatetime
    extends Modelica.Icons.Example;
    Types.Datetime dt;
    // Define test timezones
    parameter Types.Timezone cet = Data.Timezones.Europe.CET_CEST;
    parameter Types.Timezone pst = Data.Timezones.America.PST_PDT;
    parameter Types.Timezone acst = Data.Timezones.Australia.ACST_ACDT;
  algorithm
    when initial() then
      // Test CET transitions for 1987
      dt := Functions.yearToTransitionDatetime(cet, 1987, "dst_start_tic");
      assert(dt.year == 1987 and dt.month == 3 and dt.day == 29 and dt.hours == 2 and dt.minutes == 0 and (dt.seconds - 0.0) < 1e-6 and dt.tz == cet.standardName, "CET DST start 1987 failed: expected 1987-03-29T02:00:00 CET, got " + String(dt.year) + "-" + String(dt.month) + "-" + String(dt.day) + "T" + String(dt.hours) + ":" + String(dt.minutes) + ":" + String(dt.seconds) + " " + dt.tz);
      
      dt := Functions.yearToTransitionDatetime(cet, 1987, "dst_start_toc");
      assert(dt.year == 1987 and dt.month == 3 and dt.day == 29 and dt.hours == 3 and dt.minutes == 0 and (dt.seconds - 0.0) < 1e-6 and dt.tz == cet.daylightName, "CET DST start_toc 1987 failed: expected 1987-03-29T03:00:00 CEST, got " + String(dt.year) + "-" + String(dt.month) + "-" + String(dt.day) + "T" + String(dt.hours) + ":" + String(dt.minutes) + ":" + String(dt.seconds) + " " + dt.tz);
      
      dt := Functions.yearToTransitionDatetime(cet, 1987, "dst_end_tic");
      assert(dt.year == 1987 and dt.month == 10 and dt.day == 25 and dt.hours == 3 and dt.minutes == 0 and (dt.seconds - 0.0) < 1e-6 and dt.tz == cet.daylightName, "CET DST end 1987 failed: expected 1987-10-25T03:00:00 CEST, got " + String(dt.year) + "-" + String(dt.month) + "-" + String(dt.day) + "T" + String(dt.hours) + ":" + String(dt.minutes) + ":" + String(dt.seconds) + " " + dt.tz);
      
      dt := Functions.yearToTransitionDatetime(cet, 1987, "dst_end_toc");
      assert(dt.year == 1987 and dt.month == 10 and dt.day == 25 and dt.hours == 2 and dt.minutes == 0 and (dt.seconds - 0.0) < 1e-6 and dt.tz == cet.standardName, "CET DST end_toc 1987 failed: expected 1987-10-25T02:00:00 CET, got " + String(dt.year) + "-" + String(dt.month) + "-" + String(dt.day) + "T" + String(dt.hours) + ":" + String(dt.minutes) + ":" + String(dt.seconds) + " " + dt.tz);
      
      // Test CET transitions for 2028
      dt := Functions.yearToTransitionDatetime(cet, 2028, "dst_start_tic");
      assert(dt.year == 2028 and dt.month == 3 and dt.day == 26 and dt.hours == 2 and dt.minutes == 0 and (dt.seconds - 0.0) < 1e-6 and dt.tz == cet.standardName, "CET DST start 2028 failed: expected 2028-03-26T02:00:00 CET, got " + String(dt.year) + "-" + String(dt.month) + "-" + String(dt.day) + "T" + String(dt.hours) + ":" + String(dt.minutes) + ":" + String(dt.seconds) + " " + dt.tz);
      
      dt := Functions.yearToTransitionDatetime(cet, 2028, "dst_start_toc");
      assert(dt.year == 2028 and dt.month == 3 and dt.day == 26 and dt.hours == 3 and dt.minutes == 0 and (dt.seconds - 0.0) < 1e-6 and dt.tz == cet.daylightName, "CET DST start_toc 2028 failed: expected 2028-03-26T03:00:00 CEST, got " + String(dt.year) + "-" + String(dt.month) + "-" + String(dt.day) + "T" + String(dt.hours) + ":" + String(dt.minutes) + ":" + String(dt.seconds) + " " + dt.tz);
      
      dt := Functions.yearToTransitionDatetime(cet, 2028, "dst_end_tic");
      assert(dt.year == 2028 and dt.month == 10 and dt.day == 29 and dt.hours == 3 and dt.minutes == 0 and (dt.seconds - 0.0) < 1e-6 and dt.tz == cet.daylightName, "CET DST end 2028 failed: expected 2028-10-29T03:00:00 CEST, got " + String(dt.year) + "-" + String(dt.month) + "-" + String(dt.day) + "T" + String(dt.hours) + ":" + String(dt.minutes) + ":" + String(dt.seconds) + " " + dt.tz);
      
      dt := Functions.yearToTransitionDatetime(cet, 2028, "dst_end_toc");
      assert(dt.year == 2028 and dt.month == 10 and dt.day == 29 and dt.hours == 2 and dt.minutes == 0 and (dt.seconds - 0.0) < 1e-6 and dt.tz == cet.standardName, "CET DST end_toc 2028 failed: expected 2028-10-29T02:00:00 CET, got " + String(dt.year) + "-" + String(dt.month) + "-" + String(dt.day) + "T" + String(dt.hours) + ":" + String(dt.minutes) + ":" + String(dt.seconds) + " " + dt.tz);
      
      // Test CET transitions for 2024
      dt := Functions.yearToTransitionDatetime(cet, 2024, "dst_start_tic");
      assert(dt.month == 3 and dt.day == 31 and dt.hours == 2 and dt.minutes == 0 and (dt.seconds - 0.0) < 1e-6 and dt.tz == cet.standardName, "CET DST start tic 2024 failed: expected 2024-03-31T02:00 CET, got " + String(dt.year) + "-" + String(dt.month) + "-" + String(dt.day) + "T" + String(dt.hours) + ":" + String(dt.minutes) + ":" + String(dt.seconds) + " " + dt.tz);
      
      dt := Functions.yearToTransitionDatetime(cet, 2024, "dst_start_toc");
      assert(dt.month == 3 and dt.day == 31 and dt.hours == 3 and dt.minutes == 0 and (dt.seconds - 0.0) < 1e-6 and dt.tz == cet.daylightName, "CET DST start toc 2024 failed: expected 2024-03-31T03:00 CEST, got " + String(dt.year) + "-" + String(dt.month) + "-" + String(dt.day) + "T" + String(dt.hours) + ":" + String(dt.minutes) + ":" + String(dt.seconds) + " " + dt.tz);
      
      dt := Functions.yearToTransitionDatetime(cet, 2024, "dst_end_tic");
      assert(dt.month == 10 and dt.day == 27 and dt.hours == 3 and dt.minutes == 0 and (dt.seconds - 0.0) < 1e-6 and dt.tz == cet.daylightName, "CET DST end tic 2024 failed: expected 2024-10-27T03:00 CEST, got " + String(dt.year) + "-" + String(dt.month) + "-" + String(dt.day) + "T" + String(dt.hours) + ":" + String(dt.minutes) + ":" + String(dt.seconds) + " " + dt.tz);
      
      dt := Functions.yearToTransitionDatetime(cet, 2024, "dst_end_toc");
      assert(dt.month == 10 and dt.day == 27 and dt.hours == 2 and dt.minutes == 0 and (dt.seconds - 0.0) < 1e-6 and dt.tz == cet.standardName, "CET DST end toc 2024 failed: expected 2024-10-27T02:00 CET, got " + String(dt.year) + "-" + String(dt.month) + "-" + String(dt.day) + "T" + String(dt.hours) + ":" + String(dt.minutes) + ":" + String(dt.seconds) + " " + dt.tz);

      // Test PST transitions for 2024
      dt := Functions.yearToTransitionDatetime(pst, 2024, "dst_start_tic");
      assert(dt.month == 3 and dt.day == 10 and dt.hours == 2 and dt.minutes == 0 and (dt.seconds - 0.0) < 1e-6 and dt.tz == pst.standardName, "PST DST start tic 2024 failed: expected 2024-03-10T02:00 PST, got " + String(dt.year) + "-" + String(dt.month) + "-" + String(dt.day) + "T" + String(dt.hours) + ":" + String(dt.minutes) + ":" + String(dt.seconds) + " " + dt.tz);

      dt := Functions.yearToTransitionDatetime(pst, 2024, "dst_start_toc");
      assert(dt.month == 3 and dt.day == 10 and dt.hours == 3 and dt.minutes == 0 and (dt.seconds - 0.0) < 1e-6 and dt.tz == pst.daylightName, "PST DST start toc 2024 failed: expected 2024-03-10T03:00 PDT, got " + String(dt.year) + "-" + String(dt.month) + "-" + String(dt.day) + "T" + String(dt.hours) + ":" + String(dt.minutes) + ":" + String(dt.seconds) + " " + dt.tz);

      dt := Functions.yearToTransitionDatetime(pst, 2024, "dst_end_tic");
      assert(dt.month == 11 and dt.day == 3 and dt.hours == 2 and dt.minutes == 0 and (dt.seconds - 0.0) < 1e-6 and dt.tz == pst.daylightName, "PST DST end 2024 failed: expected 2024-11-03T02:00 PDT, got " + String(dt.year) + "-" + String(dt.month) + "-" + String(dt.day) + "T" + String(dt.hours) + ":" + String(dt.minutes) + ":" + String(dt.seconds) + " " + dt.tz);

      dt := Functions.yearToTransitionDatetime(pst, 2024, "dst_end_toc");
      assert(dt.month == 11 and dt.day == 3 and dt.hours == 1 and dt.minutes == 0 and (dt.seconds - 0.0) < 1e-6 and dt.tz == pst.standardName, "PST DST end 2024 failed: expected 2024-11-03T01:00 PST, got " + String(dt.year) + "-" + String(dt.month) + "-" + String(dt.day) + "T" + String(dt.hours) + ":" + String(dt.minutes) + ":" + String(dt.seconds) + " " + dt.tz);

      // Test ACST transitions for 2024
      dt := Functions.yearToTransitionDatetime(acst, 2024, "dst_start_tic");
      assert(dt.month == 10 and dt.day == 6 and dt.hours == 2 and dt.minutes == 0 and (dt.seconds - 0.0) < 1e-6 and dt.tz == acst.standardName, "ACST DST start 2024 failed: expected 2024-10-06T02:00 ACST, got " + String(dt.year) + "-" + String(dt.month) + "-" + String(dt.day) + "T" + String(dt.hours) + ":" + String(dt.minutes) + ":" + String(dt.seconds) + " " + dt.tz);
 
      dt := Functions.yearToTransitionDatetime(acst, 2024, "dst_start_toc");
      assert(dt.month == 10 and dt.day == 6 and dt.hours == 3 and dt.minutes == 0 and (dt.seconds - 0.0) < 1e-6 and dt.tz == acst.daylightName, "ACST DST start 2024 failed: expected 2024-10-06T03:00 ACDT, got " + String(dt.year) + "-" + String(dt.month) + "-" + String(dt.day) + "T" + String(dt.hours) + ":" + String(dt.minutes) + ":" + String(dt.seconds) + " " + dt.tz);

      dt := Functions.yearToTransitionDatetime(acst, 2024, "dst_end_tic");
      assert(dt.month == 4 and dt.day == 7 and dt.hours == 3 and dt.minutes == 0 and (dt.seconds - 0.0) < 1e-6 and dt.tz == acst.daylightName, "ACST DST end 2024 failed: expected 2024-04-07T03:00 ACDT, got " + String(dt.year) + "-" + String(dt.month) + "-" + String(dt.day) + "T" + String(dt.hours) + ":" + String(dt.minutes) + ":" + String(dt.seconds) + " " + dt.tz);

      dt := Functions.yearToTransitionDatetime(acst, 2024, "dst_end_toc");
      assert(dt.month == 4 and dt.day == 7 and dt.hours == 2 and dt.minutes == 0 and (dt.seconds - 0.0) < 1e-6 and dt.tz == acst.standardName, "ACST DST end 2024 failed: expected 2024-04-07T02:00 ACST, got " + String(dt.year) + "-" + String(dt.month) + "-" + String(dt.day) + "T" + String(dt.hours) + ":" + String(dt.minutes) + ":" + String(dt.seconds) + " " + dt.tz);
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestYearToTransitionDatetime;

  model TestIsValidDatetime
    extends Modelica.Icons.Example;
    Integer validity;
    // Define test timezones
    parameter Types.Timezone cet = Data.Timezones.Europe.CET_CEST;
    parameter Types.Timezone act = Data.Timezones.Australia.ACST_ACDT;
  algorithm
    when initial() then
      // Test CET timezone
      // Test valid time in standard time (winter)
      validity := Functions.isValidDatetime(Types.Datetime(2024, 1, 15, 12, 0, 0.0, ""), // January 15, 2024 12:00:00
      cet);
      assert(validity == 1, "CET: Regular winter time should be valid (1), got " + String(validity));

      // Test valid time in daylight saving time (summer)
      validity := Functions.isValidDatetime(Types.Datetime(2024, 7, 15, 12, 0, 0.0, ""), // July 15, 2024 12:00:00
      cet);
      assert(validity == 1, "CET: Regular summer time should be valid (1), got " + String(validity));

      // Test invalid time during spring forward
      validity := Functions.isValidDatetime(Types.Datetime(2024, 3, 31, 2, 30, 0.0, ""), // March 31, 2024 02:30:00 (skipped hour)
      cet);
      assert(validity == 0, "CET: Skipped spring forward time should be invalid (0), got " + String(validity));

      // Test ambiguous time during fall back
      validity := Functions.isValidDatetime(Types.Datetime(2024, 10, 27, 2, 30, 0.0, ""), // October 27, 2024 02:30:00 (repeated hour)
      cet);
      assert(validity == -1, "CET: Ambiguous fall back time should be ambiguous (-1), got " + String(validity));

      // Test ambiguous time during fall back but with ill specification
      validity := Functions.isValidDatetime(Types.Datetime(2024, 10, 27, 2, 30, 0.0, "PST"), // October 27, 2024 02:30:00 (repeated hour)
      cet);
      assert(validity == -2, "CET: Ambiguous fall back time should be ambiguous and ill-specified timezone be detected (-2), got " + String(validity));
      
      // Test ambiguous time during fall back but with correct specification
      validity := Functions.isValidDatetime(Types.Datetime(2024, 10, 27, 2, 30, 0.0, "CET"), // October 27, 2024 02:30:00 (repeated hour), interpreted as standard time CET
      cet);
      assert(validity == 2, "CET: Ambiguous fall back time should be ambiguous and well-specified timezone be detected (2), got " + String(validity));

      // Test ambiguous time during fall back but with correct specification
      validity := Functions.isValidDatetime(Types.Datetime(2024, 10, 27, 2, 30, 0.0, "CEST"), // October 27, 2024 02:30:00 (repeated hour), interpreted as daylight savings CEST
      cet);
      assert(validity == 2, "CET: Ambiguous fall back time should be ambiguous and well-specified timezone be detected (2), got " + String(validity));

      // Test ACT timezone
      // Test valid time in standard time (winter)
      validity := Functions.isValidDatetime(Types.Datetime(2024, 7, 15, 12, 0, 0.0, ""), // July 15, 2024 12:00:00
      act);
      assert(validity == 1, "ACT: Regular winter time should be valid (1), got " + String(validity));
      
      // Test valid time in daylight saving time (summer)
      validity := Functions.isValidDatetime(Types.Datetime(2024, 12, 15, 12, 0, 0.0, ""), // December 15, 2024 12:00:00
      act);
      assert(validity == 1, "ACT: Regular summer time should be valid (1), got " + String(validity));

      // Test invalid time during spring forward
      validity := Functions.isValidDatetime(Types.Datetime(2024, 10, 6, 2, 30, 0.0, ""), // October 6, 2024 02:30:00 (skipped hour)
      act);
      assert(validity == 0, "ACT: Skipped spring forward time should be invalid (0), got " + String(validity));

      // Test ambiguous time during fall back
      validity := Functions.isValidDatetime(Types.Datetime(2024, 4, 7, 2, 30, 0.0, ""), // April 7, 2024 02:30:00 (repeated hour)
      act);
      assert(validity == -1, "ACT: Ambiguous fall back time should be ambiguous (-1), got " + String(validity));
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestIsValidDatetime;

  model TestIsWatchtimeInDaylightSaving
    extends Modelica.Icons.Example;
    Boolean isDst;
    // Define test timezones
    parameter Types.Timezone cet = Data.Timezones.Europe.CET_CEST;
    parameter Types.Timezone act = Data.Timezones.Australia.ACST_ACDT;
  algorithm
    when initial() then
      // Test CET timezone (Northern hemisphere)
      // Test summer time (should be in DST)
      isDst := Functions.isWatchtimeInDaylightSaving(Types.Datetime(2024, 7, 15, 12, 0, 0.0, ""), // July 15, 2024 12:00:00
      cet);
      assert(isDst == true, "CET: July 15 should be in DST, got false");
      isDst := Functions.isWatchtimeInDaylightSaving(Types.Datetime(2025, 10, 26, 2, 30, 0.0, "CEST"), // October 26, 2025 02:30:00: In transition time, but intepreted as DST
      cet);
      assert(isDst == true, "CET: October 26, 2025 02:30:00 CEST should be in DST, got false");

      // Test winter time (should not be in DST)
      isDst := Functions.isWatchtimeInDaylightSaving(Types.Datetime(2024, 1, 15, 12, 0, 0.0, ""), // January 15, 2024 12:00:00
      cet);
      assert(isDst == false, "CET: January 15 should not be in DST, got true");
      isDst := Functions.isWatchtimeInDaylightSaving(Types.Datetime(2025, 10, 26, 2, 30, 0.0, "CET"), // October 26, 2025 02:30:00: In transition time, but intepreted as standard time
      cet);
      assert(isDst == false, "CET: October 26, 2025 02:30:00 CET should be in standard time, got true");
      
      // Test ACT timezone (Southern hemisphere)
      // Test summer time (should be in DST)
      isDst := Functions.isWatchtimeInDaylightSaving(Types.Datetime(2024, 12, 15, 12, 0, 0.0, ""), // December 15, 2024 12:00:00
      act);
      assert(isDst == true, "ACT: December 15 should be in DST, got false");

      // Test winter time (should not be in DST)
      isDst := Functions.isWatchtimeInDaylightSaving(Types.Datetime(2024, 6, 15, 12, 0, 0.0, ""), // June 15, 2024 12:00:00
      act);
      assert(isDst == false, "ACT: June 15 should not be in DST, got true");
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestIsWatchtimeInDaylightSaving;

  model TestIsStandardTimeInDaylightSaving
    extends Modelica.Icons.Example;
    Boolean isDst;
    // Define test timezones
    parameter Types.Timezone cet = Data.Timezones.Europe.CET_CEST;
    parameter Types.Timezone act = Data.Timezones.Australia.ACST_ACDT;
  algorithm
    when initial() then
      // Test CET timezone (Northern hemisphere)
      // Test summer time (should be in DST)
      isDst := Functions.isStandardtimeInDaylightSaving(Types.Datetime(2024, 7, 15, 12, 0, 0.0, ""), // July 15, 2024 12:00:00
      cet);
      assert(isDst == true, "CET: July 15 standard time should be in DST period, got false");
      isDst := Functions.isStandardtimeInDaylightSaving(Types.Datetime(2024, 3, 31, 2, 30, 0.0, ""), // March 31, 2024 02:30:00 (during spring forward)
      cet);
      assert(isDst == true, "CET: March 31, 2024 02:30:00 standard time should be in DST period, got false");

      // Test winter time (should not be in DST)
      isDst := Functions.isStandardtimeInDaylightSaving(Types.Datetime(2024, 1, 15, 12, 0, 0.0, ""), // January 15, 2024 12:00:00
      cet);
      assert(isDst == false, "CET: January 15 standard time should not be in DST period, got true");
      isDst := Functions.isStandardtimeInDaylightSaving(Types.Datetime(2024, 10, 27, 2, 30, 0.0, ""), // October 27, 2024 02:30:00 (during fall back)
      cet);
      assert(isDst == false, "CET: October 27, 2024 02:30:00 standard time should not be in DST period, got true");

      // Test ACT timezone (Southern hemisphere)
      // Test summer time (should be in DST)
      isDst := Functions.isStandardtimeInDaylightSaving(Types.Datetime(2024, 12, 15, 12, 0, 0.0, ""), // December 15, 2024 12:00:00
      act);
      assert(isDst == true, "ACT: December 15 standard time should be in DST period, got false");

      // Test winter time (should not be in DST)
      isDst := Functions.isStandardtimeInDaylightSaving(Types.Datetime(2024, 6, 15, 12, 0, 0.0, ""), // June 15, 2024 12:00:00
      act);
      assert(isDst == false, "ACT: June 15 standard time should not be in DST period, got true");
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestIsStandardTimeInDaylightSaving;

  model TestDatetimeToPosix
    extends Modelica.Icons.Example;
    Real posixTime;
    Types.Datetime dt;
    parameter Types.Timezone cet = Data.Timezones.Europe.CET_CEST;
    parameter Types.Timezone pst = Data.Timezones.America.PST_PDT;
    parameter Types.Timezone utc = Data.Timezones.Etc.UTC;
  algorithm
    when initial() then
      // Test case 1 in CET: Unambiguous standard time without leap seconds
      dt := Types.Datetime(year = 2023, month = 10, day = 5, hours = 14, minutes = 48, seconds = 0.0, tz = "");
      posixTime := Functions.datetimeToPosix(dt, cet, false);
      assert(integer(posixTime) == integer(1696510080), "Test case 1 failed, got: " + String(integer(posixTime)));

      // Test case 2 in CET: Time without leap seconds, but well-specified ambiguous time that falls into daylights savings
      dt := Types.Datetime(year = 2025, month = 10, day = 26, hours = 2, minutes = 30, seconds = 0.0, tz = "CEST");
      posixTime := Functions.datetimeToPosix(dt, cet, false);
      assert(integer(posixTime) == 1761438600, "Test case 2 failed, got: " + String(integer(posixTime)));

      // Test case 3 in CET: Time without leap seconds, but well-specified ambiguous time that falls into standard time
      dt := Types.Datetime(year = 2025, month = 10, day = 26, hours = 2, minutes = 30, seconds = 0.0, tz = "CET");
      posixTime := Functions.datetimeToPosix(dt, cet, false);
      assert(integer(posixTime) == 1761442200, "Test case 3 failed, got: " + String(integer(posixTime)));
      
      // Test case 4: Unambiguous daylight saving time without leap seconds
      dt := Types.Datetime(year = 2023, month = 7, day = 15, hours = 12, minutes = 0, seconds = 0.0, tz = "");
      posixTime := Functions.datetimeToPosix(dt, pst, false);
      assert(integer(posixTime) == integer(1689447600), "Test case 4 failed, got: " + String(integer(posixTime)));
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-12, Interval = 0.5));
  end TestDatetimeToPosix;

  model TestPosixToDatetime
    extends Modelica.Icons.Example;
    Types.Datetime dt;
    // Define test timezones
    parameter Types.Timezone cet = Data.Timezones.Europe.CET_CEST;
    parameter Types.Timezone acst = Data.Timezones.Australia.ACST_ACDT;
    parameter Types.Timezone utc = Data.Timezones.Etc.UTC;
  algorithm
    when initial() then
      // Test CET timezone
      // 1. Standard time (2024-01-15T12:00:00 CET=2024-01-15T11:00:00 UTC)
      dt := Functions.posixToDatetime(1705316400, cet, false);
      assert(dt.year == 2024 and dt.month == 1 and dt.day == 15 and dt.hours == 12 and dt.minutes == 0 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "CET", "CET standard time conversion failed. Got " + String(dt));

      // 2. Daylight saving time (2024-07-15T12:00:00 CEST=2024-07-15T10:00:00 UTC)
      dt := Functions.posixToDatetime(1721037600, cet, false);
      assert(dt.year == 2024 and dt.month == 7 and dt.day == 15 and dt.hours == 12 and dt.minutes == 0 and abs(dt.seconds - 0.0) < 1e-6, "CET daylight saving time conversion failed. Got " + String(dt));

      // 3. Spring forward transition (2024-03-31T03:30:00 CEST=2024-03-31T02:30:00 CET=2024-03-31T01:30:00 UTC)
      dt := Functions.posixToDatetime(1711848600, cet, false);
      assert(dt.year == 2024 and dt.month == 3 and dt.day == 31 and dt.hours == 3 and dt.minutes == 30 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "CEST", "CET spring forward transition failed. Got " + String(dt));

      // 4. Fall back transition (2024-10-27T02:30:00 CEST=2024-10-27T01:30:00 CET=2024-10-27T00:30:00 UTC)
      dt := Functions.posixToDatetime(1729989000, cet, false);
      assert(dt.year == 2024 and dt.month == 10 and dt.day == 27 and dt.hours == 2 and dt.minutes == 30 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "CEST", "CET fall back transition 1 failed. Got " + String(dt));

      // 5. Fall back transition (2024-10-27T02:30:00 CET=2024-10-27T01:30:00 UTC)
      dt := Functions.posixToDatetime(1729992600, cet, false);
      assert(dt.year == 2024 and dt.month == 10 and dt.day == 27 and dt.hours == 2 and dt.minutes == 30 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "CET", "CET fall back transition 2 failed. Got " + String(dt));
      
      // Test ACST timezone
      // 1. Standard time (2024-06-15T12:00:00 ACST=2024-06-15T02:30:00 UTC)
      dt := Functions.posixToDatetime(1718418600, acst, false);
      assert(dt.year == 2024 and dt.month == 6 and dt.day == 15 and dt.hours == 12 and dt.minutes == 0 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "ACST", "ACST standard time conversion failed. Got " + String(dt));

      // 2. Daylight saving time (2024-12-15T12:00:00 ACDT=2024-12-15T01:30:00 UTC)
      dt := Functions.posixToDatetime(1734226200, acst, false);
      assert(dt.year == 2024 and dt.month == 12 and dt.day == 15 and dt.hours == 12 and dt.minutes == 0 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "ACDT", "ACST daylight saving time conversion failed. Got " + String(dt));

      // 3. Spring forward transition (2024-10-06T03:30:00 ACDT=2024-10-06T02:30:00 ACST=2024-10-05T17:00:00 UTC)
      dt := Functions.posixToDatetime(1728147600, acst, false);
      assert(dt.year == 2024 and dt.month == 10 and dt.day == 6 and dt.hours == 3 and dt.minutes == 30 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "ACDT", "ACST spring forward transition failed. Got " + String(dt));

      // 4. Fall back transition (2024-04-07T02:30:00 ACDT=2024-04-07T01:30:00 ACST=2024-04-06T16:00 UTC)
      dt := Functions.posixToDatetime(1712419200, acst, false);
      assert(dt.year == 2024 and dt.month == 4 and dt.day == 7 and dt.hours == 2 and dt.minutes == 30 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "ACDT", "ACST fall back transition failed. Got " + String(dt));

      // Test UTC timezone
      // 1. Standard time test 1 (January 15, 2024 12:00:00 UTC)
      dt := Functions.posixToDatetime(1705320000, utc, false);
      assert(dt.year == 2024 and dt.month == 1 and dt.day == 15 and dt.hours == 12 and dt.minutes == 0 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "UTC", "UTC standard time test 1 failed. Got " + String(dt));

      // 2. Standard time test 2 (July 15, 2024 12:00:00 UTC)
      dt := Functions.posixToDatetime(1721044800, utc, false);
      assert(dt.year == 2024 and dt.month == 7 and dt.day == 15 and dt.hours == 12 and dt.minutes == 0 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "UTC", "UTC standard time test 2 failed. Got " + String(dt));

      // 3. Standard time test 3 (March 31, 2024 12:00:00 UTC)
      dt := Functions.posixToDatetime(1711886400, utc, false);
      assert(dt.year == 2024 and dt.month == 3 and dt.day == 31 and dt.hours == 12 and dt.minutes == 0 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "UTC", "UTC standard time test 3 failed. Got " + String(dt));

      // 4. Standard time test 4 (October 27, 2024 12:00:00 UTC)
      dt := Functions.posixToDatetime(1730030400, utc, false);
      assert(dt.year == 2024 and dt.month == 10 and dt.day == 27 and dt.hours == 12 and dt.minutes == 0 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "UTC", "UTC standard time test 4 failed. Got " + String(dt));
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestPosixToDatetime;  

  model TestRoundTripPosixToPosix "Unit test that takes a POSIX time, converts it to a datetime, back to POSIX and checks equality"
    extends Modelica.Icons.Example;
    // Define test timezones
    parameter Types.Timezone cet = Data.Timezones.Europe.CET_CEST;
    parameter Types.Timezone pst = Data.Timezones.America.PST_PDT;
    parameter Types.Timezone acst = Data.Timezones.Australia.ACST_ACDT;
    parameter Types.Timezone utc = Data.Timezones.Etc.UTC;
    Real posixTime;
    Types.Datetime dt;
    Real roundTripPosixTime;
    Boolean useLeapSecons[2] = {false, true};
    Boolean withLeaps;
  algorithm
    when initial() then
      for i in 1:2 loop
        withLeaps := useLeapSecons[i];
        print("Running unit test TestRoundTripPosixToPosix with withLeaps=" + String(withLeaps) + "\n\n");

        // Test CET timezone
        posixTime := 1705316400; // 2024-01-15T12:00:00 CET
        dt := Functions.posixToDatetime(posixTime, cet, withLeaps);
        roundTripPosixTime := Functions.datetimeToPosix(dt, cet, withLeaps);
        assert(abs(posixTime - roundTripPosixTime) < 1e-6, "CET standard time round trip failed with withLeaps=" + String(withLeaps));
        posixTime := 1721037600; // 2024-07-15T12:00:00 CEST
        dt := Functions.posixToDatetime(posixTime, cet, withLeaps);
        roundTripPosixTime := Functions.datetimeToPosix(dt, cet, withLeaps);
        assert(abs(posixTime - roundTripPosixTime) < 1e-6, "CET daylight saving time round trip failed with withLeaps=" + String(withLeaps));

        // Test PST timezone
        posixTime := 1705348800; // 2024-01-15T12:00:00 PST
        dt := Functions.posixToDatetime(posixTime, pst, withLeaps);
        roundTripPosixTime := Functions.datetimeToPosix(dt, pst, withLeaps);
        assert(abs(posixTime - roundTripPosixTime) < 1e-6, "PST standard time round trip failed with withLeaps=" + String(withLeaps));
        
        posixTime := 1721070000; // 2024-07-15T12:00:00 PDT
        dt := Functions.posixToDatetime(posixTime, pst, withLeaps);
        roundTripPosixTime := Functions.datetimeToPosix(dt, pst, withLeaps);
        assert(abs(posixTime - roundTripPosixTime) < 1e-6, "PST daylight saving time round trip failed with withLeaps=" + String(withLeaps));

        // Test ACST timezone
        posixTime := 1718418600; // 2024-06-15T12:00:00 ACST
        dt := Functions.posixToDatetime(posixTime, acst, withLeaps);
        roundTripPosixTime := Functions.datetimeToPosix(dt, acst, withLeaps);
        assert(abs(posixTime - roundTripPosixTime) < 1e-6, "ACST standard time round trip failed with withLeaps=" + String(withLeaps));
        
        posixTime := 1734226200; // 2024-12-15T12:00:00 ACDT
        dt := Functions.posixToDatetime(posixTime, acst, withLeaps);
        roundTripPosixTime := Functions.datetimeToPosix(dt, acst, withLeaps);
        assert(abs(posixTime - roundTripPosixTime) < 1e-6, "ACST daylight saving time round trip failed with withLeaps=" + String(withLeaps));

        // Test UTC timezone
        posixTime := 1705320000; // 2024-01-15T12:00:00 UTC
        dt := Functions.posixToDatetime(posixTime, utc, withLeaps);
        roundTripPosixTime := Functions.datetimeToPosix(dt, utc, withLeaps);
        assert(abs(posixTime - roundTripPosixTime) < 1e-6, "UTC standard time round trip failed with withLeaps=" + String(withLeaps));
      end for;
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestRoundTripPosixToPosix;

  model TestRoundTripDatetimeToDatetime "Unit test that takes a Datetime, converts it to POSIX, back to Datetime and checks equality"
    extends Modelica.Icons.Example;
    // Define test timezones
    parameter Types.Timezone cet = Data.Timezones.Europe.CET_CEST;
    parameter Types.Timezone pst = Data.Timezones.America.PST_PDT;
    parameter Types.Timezone acst = Data.Timezones.Australia.ACST_ACDT;
    parameter Types.Timezone utc = Data.Timezones.Etc.UTC;
    Types.Datetime dt;
    Real posixTime;
    Types.Datetime roundTripDatetime;
    Boolean useLeapSecons[2] = {false, true};
    Boolean withLeaps;
  algorithm
    when initial() then
      for i in 1:2 loop
        withLeaps := useLeapSecons[i];
        print("Running unit test TestRoundTripPosixToPosix with withLeaps=" + String(withLeaps) + "\n\n");

        // Test CET timezone
        dt := Types.Datetime(2024, 1, 15, 12, 0, 0.0, "CET"); // Standard time
        posixTime := Functions.datetimeToPosix(dt, cet, withLeaps);
        roundTripDatetime := Functions.posixToDatetime(posixTime, cet, withLeaps);
        assert(dt == roundTripDatetime, "CET standard time round trip failed with withLeaps=" + String(withLeaps) + ". Assumed dt=" + String(dt) + ", is roundTripDatetime=" + String(roundTripDatetime));
        
        dt := Types.Datetime(2024, 7, 15, 12, 0, 0.0, "CEST"); // Daylight saving time
        posixTime := Functions.datetimeToPosix(dt, cet, withLeaps);
        roundTripDatetime := Functions.posixToDatetime(posixTime, cet, withLeaps);
        assert(dt == roundTripDatetime, "CET daylight saving time round trip failed with withLeaps=" + String(withLeaps) + ". Assumed dt=" + String(dt) + ", is roundTripDatetime=" + String(roundTripDatetime));
        
        // Test PST timezone
        dt := Types.Datetime(2024, 1, 15, 12, 0, 0.0, "PST"); // Standard time
        posixTime := Functions.datetimeToPosix(dt, pst, withLeaps);
        roundTripDatetime := Functions.posixToDatetime(posixTime, pst, withLeaps);
        assert(dt == roundTripDatetime, "PST standard time round trip failed with withLeaps=" + String(withLeaps) + ". Assumed dt=" + String(dt) + ", is roundTripDatetime=" + String(roundTripDatetime));
        
        dt := Types.Datetime(2024, 7, 15, 12, 0, 0.0, "PDT"); // Daylight saving time
        posixTime := Functions.datetimeToPosix(dt, pst, withLeaps);
        roundTripDatetime := Functions.posixToDatetime(posixTime, pst, withLeaps);
        assert(dt == roundTripDatetime, "PST daylight saving time round trip failed with withLeaps=" + String(withLeaps) + ". Assumed dt=" + String(dt) + ", is roundTripDatetime=" + String(roundTripDatetime));
        
        // Test ACST timezone
        dt := Types.Datetime(2024, 6, 15, 12, 0, 0.0, "ACST"); // Standard time
        posixTime := Functions.datetimeToPosix(dt, acst, withLeaps);
        roundTripDatetime := Functions.posixToDatetime(posixTime, acst, withLeaps);
        assert(dt == roundTripDatetime, "ACST standard time round trip failed with withLeaps=" + String(withLeaps) + ". Assumed dt=" + String(dt) + ", is roundTripDatetime=" + String(roundTripDatetime));
        
        dt := Types.Datetime(2024, 12, 15, 12, 0, 0.0, "ACDT"); // Daylight saving time
        posixTime := Functions.datetimeToPosix(dt, acst, withLeaps);
        roundTripDatetime := Functions.posixToDatetime(posixTime, acst, withLeaps);
        assert(dt == roundTripDatetime, "ACST daylight saving time round trip failed with withLeaps=" + String(withLeaps) + ". Assumed dt=" + String(dt) + ", is roundTripDatetime=" + String(roundTripDatetime));

        // Test UTC timezone
        dt := Types.Datetime(2024, 1, 15, 12, 0, 0.0, "UTC"); // Standard time
        posixTime := Functions.datetimeToPosix(dt, utc, withLeaps);
        roundTripDatetime := Functions.posixToDatetime(posixTime, utc, withLeaps);
        assert(dt == roundTripDatetime, "UTC standard time round trip failed with withLeaps=" + String(withLeaps) + ". Assumed dt=" + String(dt) + ", is roundTripDatetime=" + String(roundTripDatetime));
      end for;
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestRoundTripDatetimeToDatetime;  

  model TestCorrectInvalidDatetime "Unit test that takes an invalid Datetime object and tries to correct it"
    extends Modelica.Icons.Example;
    // Define test timezones
    parameter Types.Timezone pst = Data.Timezones.America.PST_PDT;
    Types.Datetime dt;
    Types.Datetime dt_expected;
    Types.Datetime result;
  algorithm
    when initial() then
      dt := Types.Datetime(2025, 3, 9, 2, 30, 0.0, "PST");

      // Incrementing day results in inavlid datetime. autocorrect with time_from_day_start
      dt_expected := Types.Datetime(2025, 3, 9, 3, 30, 0.0, "PDT");
      result := Functions.correctInvalidDatetime(dt, pst, "time_from_day_start", false);
      assert(result == dt_expected, "Correction of invalid datetime failed for " + String(dt) + ", expected was " + String(dt_expected) + ". Got " + String(result));
    end when;
  end TestCorrectInvalidDatetime;
end DateAndTime;
