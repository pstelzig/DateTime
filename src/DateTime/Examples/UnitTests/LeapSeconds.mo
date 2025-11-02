within DateTime.Examples.UnitTests;
package LeapSeconds
  extends Modelica.Icons.ExamplesPackage;

  model TestDatetimeToPosixWithLeapSeconds "Testing with leap seconds. Note after latest leap second on 2016-12-31T23:59:59 + 1s we have 37 leap seconds added"
    extends Modelica.Icons.Example;
    Real posixTime;
    Types.Datetime dt;
    Integer leapSecondsAsOf "Number of leap seconds added up to the date used in the test";
    parameter Types.Timezone cet = Data.Timezones.Europe.CET_CEST;
    parameter Types.Timezone pst = Data.Timezones.America.PST_PDT;
    parameter Types.Timezone utc = Data.Timezones.Etc.UTC;
  algorithm
    when initial() then
      // Test case 1 in CET: Unambiguous standard time with leap seconds.
      leapSecondsAsOf := 27; // As of 2023, a total of 27 leap seconds had been added.
      dt := Types.Datetime(year = 2023, month = 10, day = 5, hours = 14, minutes = 48, seconds = 0.0, tz = "");
      posixTime := Functions.datetimeToPosix(dt, cet, true);
      assert(integer(posixTime) == 1696510080 + leapSecondsAsOf, "Test case 1 failed, got: " + String(integer(posixTime)));
  
      // Test case 2 in CET: Time with leap seconds, but well-specified ambiguous time that falls into daylights savings.
      leapSecondsAsOf := 27; // As of 2025, a total of 27 leap seconds had been added.
      dt := Types.Datetime(year = 2025, month = 10, day = 26, hours = 2, minutes = 30, seconds = 0.0, tz = "CEST");
      posixTime := Functions.datetimeToPosix(dt, cet, true);
      assert(integer(posixTime) == 1761438600 + leapSecondsAsOf, "Test case 2 failed, got: " + String(integer(posixTime)));
  
      // Test case 3 in CET: Time with leap seconds, but well-specified ambiguous time that falls into standard time.
      leapSecondsAsOf := 27; // As of 2025, a total of 27 leap seconds had been added.
      dt := Types.Datetime(year = 2025, month = 10, day = 26, hours = 2, minutes = 30, seconds = 0.0, tz = "CET");
      posixTime := Functions.datetimeToPosix(dt, cet, true);
      assert(integer(posixTime) == 1761442200 + leapSecondsAsOf, "Test case 3 failed, got: " + String(integer(posixTime)));
  
      // Test case 4: Unambiguous daylight saving time without leap seconds
      leapSecondsAsOf := 27; // As of 2023, a total of 27 leap seconds had been added.
      dt := Types.Datetime(year = 2023, month = 7, day = 15, hours = 12, minutes = 0, seconds = 0.0, tz = "");
      posixTime := Functions.datetimeToPosix(dt, pst, true);
      assert(integer(posixTime) == 1689447600 + leapSecondsAsOf, "Test case 4 failed, got: " + String(integer(posixTime)));
  
      // Test case 5: Standard time with leap seconds.
      leapSecondsAsOf := 26; // As of of 2016-12-31T23:59:59 a total of 26 leap seconds had been added
      dt := Types.Datetime(year = 2016, month = 12, day = 31, hours = 23, minutes = 59, seconds = 59.0, tz = "");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(integer(posixTime) == 1483228799 + leapSecondsAsOf, "Test case 5 failed, got: " + String(integer(posixTime)));
      
      // Test case 6: 2015-07-01T01:00:00 CEST=2015-06-30T23:00:00 UTC, hence
      // 1 h before adding penultimate leap second on 2015-06-30T23:59:59 + 1s = 1435708800 s POSIX.
      // Thus only 25 s leap second difference
      leapSecondsAsOf := 25;
      dt := Types.Datetime(year = 2015, month = 7, day = 1, hours = 1, minutes = 0, seconds = 0.0, tz = "CEST");
      posixTime := Functions.datetimeToPosix(dt, cet, true);
      assert(integer(posixTime) == 1435708800 - 3600 + leapSecondsAsOf, "Test case 6 failed, got: " + String(integer(posixTime)));
      
      // Test case 7: 2015-07-01T03:00:00 CEST=2015-06-30T01:00:00 UTC, hence
      // 1 h after adding penultimate leap second on 2015-06-30T23:59:59 + 1s = 1435708800 s POSIX.
      // Thus now 26 s leap second difference
      leapSecondsAsOf := 26;
      dt := Types.Datetime(year = 2015, month = 7, day = 1, hours = 3, minutes = 0, seconds = 0.0, tz = "CEST");
      posixTime := Functions.datetimeToPosix(dt, cet, true);
      assert(integer(posixTime) == 1435708800 + 3600 + leapSecondsAsOf, "Test case 7 failed, got: " + String(integer(posixTime)));
      
      // Test case 8: In UTC 0.5 seconds after adding penultimate leap second on 2015-06-30T23:59:59 + 1s = 1435708800 s POSIX.
      // Hence, we have a valid datetime 2015-06-30T26:59:60.5. However, the POSIX time is continuous, and within
      // the leap second it continuously counts from 1435708800+25 s to 1435708800+26s, or continuously from
      // 1435708800 s POSIX + 25s = 2015-06-30T23:59:59 UTC + 1s=2015-06-30T23:59:60.00000... UTC
      // up to 2015-06-30T23:59:60.99999... = 1435708800 s POSIX + 26s
      // Hence, we still start with 25 s leap second difference
      leapSecondsAsOf := 25;
      dt := Types.Datetime(year = 2015, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.5, tz = "");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (1435708800 + leapSecondsAsOf + 0.5)) < 1e-6, "Test case 8 failed, got: " + String(posixTime, format=".6f"));
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestDatetimeToPosixWithLeapSeconds;

  model TestDatetimeToPosixOnLeapInsertion
    extends Modelica.Icons.Example;
    Types.Datetime dt;
    Real posixTime;
    parameter Types.Timezone utc = Data.Timezones.Etc.UTC;
    parameter Data.LeapSeconds ls;
    parameter Real deltaTBefore = 0.001;
    parameter Real deltaTDuring = 0.5;
    parameter Real deltaTAfter = 0.001;
  algorithm
    when initial() then  
      // Leap second insertion on 1972-06-30T23:59:59 + 1s
      
      // Shortly before first leap second inserted at 1972-06-30T23:59:59 + 1s.
      // Timestamp for 1972-06-30T23:59:59.999 must be ls.timestamps[1] - deltaTBefore
      dt := Types.Datetime(year = 1972, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[1] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1972-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[1] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // During first leap second at 1972-06-30T23:59:59 + 1s.
      // Timestamp for 1972-06-30T23:59:59 + 1s + 0.5s must be ls.timestamps[1] + deltaTDuring
      dt := Types.Datetime(year = 1972, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[1] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1972-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[1] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // After first leap second at 1972-06-30T23:59:59 + 1s + 1s + deltaTAfter=1972-07-01T00:00:00.001
      // Timestamp for 1972-07-01T00:00:00.001 must be ls.timestamps[1] + 1s + deltaTAfter
      dt := Types.Datetime(year = 1972, month = 7, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[1] + ls.leaps[1] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1972-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[1] + ls.leaps[1] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 1972-12-31T23:59:59 + 1s
      dt := Types.Datetime(year = 1972, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[2] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1972-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[2] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1972, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[2] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1972-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[2] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1973, month = 1, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[2] + ls.leaps[2] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1972-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[2] + ls.leaps[2] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 1973-12-31T23:59:59 + 1s
      dt := Types.Datetime(year = 1973, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[3] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1973-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[3] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1973, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[3] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1973-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[3] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1974, month = 1, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[3] + ls.leaps[3] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1973-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[3] + ls.leaps[3] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 1974-12-31T23:59:59 + 1s
      dt := Types.Datetime(year = 1974, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[4] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1974-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[4] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1974, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[4] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1974-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[4] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1975, month = 1, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[4] + ls.leaps[4] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1974-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[4] + ls.leaps[4] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 1975-12-31T23:59:59 + 1s
      dt := Types.Datetime(year = 1975, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[5] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1975-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[5] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1975, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[5] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1975-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[5] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1976, month = 1, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[5] + ls.leaps[5] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1975-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[5] + ls.leaps[5] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 1976-12-31T23:59:59 + 1s
      dt := Types.Datetime(year = 1976, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[6] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1976-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[6] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1976, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[6] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1976-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[6] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1977, month = 1, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[6] + ls.leaps[6] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1976-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[6] + ls.leaps[6] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 1977-12-31T23:59:59 + 1s
      dt := Types.Datetime(year = 1977, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[7] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1977-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[7] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1977, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[7] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1977-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[7] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1978, month = 1, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[7] + ls.leaps[7] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1977-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[7] + ls.leaps[7] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 1978-12-31T23:59:59 + 1s
      dt := Types.Datetime(year = 1978, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[8] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1978-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[8] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1978, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[8] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1978-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[8] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1979, month = 1, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[8] + ls.leaps[8] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1978-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[8] + ls.leaps[8] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 1979-12-31T23:59:59 + 1s
      dt := Types.Datetime(year = 1979, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[9] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1979-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[9] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1979, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[9] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1979-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[9] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1980, month = 1, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[9] + ls.leaps[9] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1979-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[9] + ls.leaps[9] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 1981-06-30T23:59:59 + 1s
      dt := Types.Datetime(year = 1981, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[10] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1981-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[10] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1981, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[10] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1981-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[10] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1981, month = 7, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[10] + ls.leaps[10] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1981-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[10] + ls.leaps[10] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 1982-06-30T23:59:59 + 1s
      dt := Types.Datetime(year = 1982, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[11] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1982-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[11] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1982, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[11] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1982-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[11] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1982, month = 7, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[11] + ls.leaps[11] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1982-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[11] + ls.leaps[11] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 1983-06-30T23:59:59 + 1s
      dt := Types.Datetime(year = 1983, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[12] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1983-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[12] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1983, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[12] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1983-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[12] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1983, month = 7, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[12] + ls.leaps[12] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1983-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[12] + ls.leaps[12] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 1985-06-30T23:59:59 + 1s
      dt := Types.Datetime(year = 1985, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[13] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1985-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[13] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1985, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[13] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1985-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[13] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1985, month = 7, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[13] + ls.leaps[13] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1985-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[13] + ls.leaps[13] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 1987-12-31T23:59:59 + 1s
      dt := Types.Datetime(year = 1987, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[14] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1987-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[14] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1987, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[14] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1987-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[14] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1988, month = 1, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[14] + ls.leaps[14] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1987-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[14] + ls.leaps[14] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 1989-12-31T23:59:59 + 1s
      dt := Types.Datetime(year = 1989, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[15] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1989-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[15] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1989, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[15] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1989-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[15] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1990, month = 1, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[15] + ls.leaps[15] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1989-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[15] + ls.leaps[15] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 1990-12-31T23:59:59 + 1s
      dt := Types.Datetime(year = 1990, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[16] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1990-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[16] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1990, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[16] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1990-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[16] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1991, month = 1, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[16] + ls.leaps[16] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1990-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[16] + ls.leaps[16] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 1992-06-30T23:59:59 + 1s
      dt := Types.Datetime(year = 1992, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[17] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1992-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[17] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1992, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[17] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1992-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[17] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1992, month = 7, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[17] + ls.leaps[17] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1992-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[17] + ls.leaps[17] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 1993-06-30T23:59:59 + 1s
      dt := Types.Datetime(year = 1993, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[18] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1993-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[18] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1993, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[18] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1993-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[18] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1993, month = 7, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[18] + ls.leaps[18] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1993-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[18] + ls.leaps[18] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 1994-06-30T23:59:59 + 1s
      dt := Types.Datetime(year = 1994, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[19] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1994-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[19] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1994, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[19] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1994-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[19] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1994, month = 7, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[19] + ls.leaps[19] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1994-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[19] + ls.leaps[19] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 1995-12-31T23:59:59 + 1s
      dt := Types.Datetime(year = 1995, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[20] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1995-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[20] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1995, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[20] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1995-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[20] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1996, month = 1, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[20] + ls.leaps[20] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1995-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[20] + ls.leaps[20] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 1997-06-30T23:59:59 + 1s
      dt := Types.Datetime(year = 1997, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[21] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1997-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[21] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1997, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[21] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1997-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[21] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1997, month = 7, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[21] + ls.leaps[21] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1997-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[21] + ls.leaps[21] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 1998-12-31T23:59:59 + 1s
      dt := Types.Datetime(year = 1998, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[22] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 1998-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[22] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1998, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[22] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 1998-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[22] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 1999, month = 1, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[22] + ls.leaps[22] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 1998-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[22] + ls.leaps[22] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 2005-12-31T23:59:59 + 1s
      dt := Types.Datetime(year = 2005, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[23] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 2005-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[23] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 2005, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[23] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 2005-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[23] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 2006, month = 1, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[23] + ls.leaps[23] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 2005-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[23] + ls.leaps[23] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 2008-12-31T23:59:59 + 1s
      dt := Types.Datetime(year = 2008, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[24] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 2008-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[24] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 2008, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[24] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 2008-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[24] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 2009, month = 1, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[24] + ls.leaps[24] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 2008-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[24] + ls.leaps[24] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 2012-06-30T23:59:59 + 1s
      dt := Types.Datetime(year = 2012, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[25] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 2012-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[25] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 2012, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[25] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 2012-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[25] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 2012, month = 7, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[25] + ls.leaps[25] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 2012-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[25] + ls.leaps[25] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 2015-06-30T23:59:59 + 1s
      dt := Types.Datetime(year = 2015, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[26] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 2015-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[26] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 2015, month = 6, day = 30, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[26] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 2015-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[26] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 2015, month = 7, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[26] + ls.leaps[26] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 2015-06-30T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[26] + ls.leaps[26] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));

      // Leap second insertion on 2016-12-31T23:59:59 + 1s
      dt := Types.Datetime(year = 2016, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 - deltaTBefore, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[27] - deltaTBefore)) < 1e-6, "UTC leap second test before insertion on 2016-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[27] - deltaTBefore, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 2016, month = 12, day = 31, hours = 23, minutes = 59, seconds = 60.0 + deltaTDuring, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[27] + deltaTDuring)) < 1e-6, "UTC leap second test during insertion on 2016-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[27] + deltaTDuring, format=".5f") + " but got " + String(posixTime, format=".5f"));
      dt := Types.Datetime(year = 2017, month = 1, day = 1, hours = 0, minutes = 0, seconds = 0.0 + deltaTAfter, tz = "UTC");
      posixTime := Functions.datetimeToPosix(dt, utc, true);
      assert(abs(posixTime - (ls.timestamps[27] + ls.leaps[27] + deltaTAfter)) < 1e-6, "UTC leap second test after insertion on 2016-12-31T23:59:59 + 1s failed. Wanted " + String(ls.timestamps[27] + ls.leaps[27] + deltaTAfter, format=".5f") + " but got " + String(posixTime, format=".5f"));
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestDatetimeToPosixOnLeapInsertion;

  model TestPosixToDatetimeWithLeapSeconds
    extends Modelica.Icons.Example;
    Types.Datetime dt;
    Integer leapSecondsAsOf "Number of leap seconds added up to the date used in the test";
    // Define test timezones
    parameter Types.Timezone cet = Data.Timezones.Europe.CET_CEST;
    parameter Types.Timezone acst = Data.Timezones.Australia.ACST_ACDT;
    parameter Types.Timezone utc = Data.Timezones.Etc.UTC;
  algorithm
    when initial() then
      // Test CET timezone
      // 1. Standard time (2024-01-15T12:00:00 CET=2024-01-15T11:00:00 UTC)
      leapSecondsAsOf := 27; // As of 2024, a total of 27 leap seconds had been added.
      dt := Functions.posixToDatetime(1705316400 + leapSecondsAsOf, cet, true);
      assert(dt.year == 2024 and dt.month == 1 and dt.day == 15 and dt.hours == 12 and dt.minutes == 0 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "CET", "CET standard time conversion failed. Got " + String(dt));

      // 2. Daylight saving time (2024-07-15T12:00:00 CEST=2024-07-15T10:00:00 UTC)
      leapSecondsAsOf := 27; // As of 2024, a total of 27 leap seconds had been added.
      dt := Functions.posixToDatetime(1721037600 + leapSecondsAsOf, cet, true);
      assert(dt.year == 2024 and dt.month == 7 and dt.day == 15 and dt.hours == 12 and dt.minutes == 0 and abs(dt.seconds - 0.0) < 1e-6, "CET daylight saving time conversion failed. Got " + String(dt));

      // 3. Spring forward transition (2024-03-31T03:30:00 CEST=2024-03-31T02:30:00 CET=2024-03-31T01:30:00 UTC)
      leapSecondsAsOf := 27; // As of 2024, a total of 27 leap seconds had been added.
      dt := Functions.posixToDatetime(1711848600 + leapSecondsAsOf, cet, true);
      assert(dt.year == 2024 and dt.month == 3 and dt.day == 31 and dt.hours == 3 and dt.minutes == 30 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "CEST", "CET spring forward transition failed. Got " + String(dt));
      
      // 4. Fall back transition (2024-10-27T02:30:00 CEST=2024-10-27T01:30:00 CET=2024-10-27T00:30:00 UTC)
      leapSecondsAsOf := 27; // As of 2024, a total of 27 leap seconds had been added.
      dt := Functions.posixToDatetime(1729989000 + leapSecondsAsOf, cet, true);
      assert(dt.year == 2024 and dt.month == 10 and dt.day == 27 and dt.hours == 2 and dt.minutes == 30 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "CEST", "CET fall back transition 1 failed. Got " + String(dt));

      // 5. Fall back transition (2024-10-27T02:30:00 CET=2024-10-27T01:30:00 UTC)
      leapSecondsAsOf := 27; // As of 2024, a total of 27 leap seconds had been added.
      dt := Functions.posixToDatetime(1729992600 + leapSecondsAsOf, cet, true);
      assert(dt.year == 2024 and dt.month == 10 and dt.day == 27 and dt.hours == 2 and dt.minutes == 30 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "CET", "CET fall back transition 2 failed. Got " + String(dt));

      // Test ACST timezone
      // 1. Standard time (2024-06-15T12:00:00 ACST=2024-06-15T02:30:00 UTC)
      leapSecondsAsOf := 27; // As of 2024, a total of 27 leap seconds had been added.
      dt := Functions.posixToDatetime(1718418600 + leapSecondsAsOf, acst, true);
      assert(dt.year == 2024 and dt.month == 6 and dt.day == 15 and dt.hours == 12 and dt.minutes == 0 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "ACST", "ACST standard time conversion failed. Got " + String(dt));
      
      // 2. Daylight saving time (2024-12-15T12:00:00 ACDT=2024-12-15T01:30:00 UTC)
      leapSecondsAsOf := 27; // As of 2024, a total of 27 leap seconds had been added.
      dt := Functions.posixToDatetime(1734226200 + leapSecondsAsOf, acst, true);
      assert(dt.year == 2024 and dt.month == 12 and dt.day == 15 and dt.hours == 12 and dt.minutes == 0 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "ACDT", "ACST daylight saving time conversion failed. Got " + String(dt));
      
      // 3. Spring forward transition (2024-10-06T03:30:00 ACDT=2024-10-06T02:30:00 ACST=2024-10-05T17:00:00 UTC)
      leapSecondsAsOf := 27; // As of 2024, a total of 27 leap seconds had been added.
      dt := Functions.posixToDatetime(1728147600 + leapSecondsAsOf, acst, true);
      assert(dt.year == 2024 and dt.month == 10 and dt.day == 6 and dt.hours == 3 and dt.minutes == 30 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "ACDT", "ACST spring forward transition failed. Got " + String(dt));
      
      // 4. Fall back transition (2024-04-07T02:30:00 ACDT=2024-04-07T01:30:00 ACST=2024-04-06T16:00 UTC)
      leapSecondsAsOf := 27; // As of 2024, a total of 27 leap seconds had been added.
      dt := Functions.posixToDatetime(1712419200 + leapSecondsAsOf, acst, true);
      assert(dt.year == 2024 and dt.month == 4 and dt.day == 7 and dt.hours == 2 and dt.minutes == 30 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "ACDT", "ACST fall back transition failed. Got " + String(dt));

      // Test UTC timezone
      // 1. Standard time test 1 (January 15, 2024 12:00:00 UTC)
      leapSecondsAsOf := 27; // As of 2024, a total of 27 leap seconds had been added.
      dt := Functions.posixToDatetime(1705320000 + leapSecondsAsOf, utc, true);
      assert(dt.year == 2024 and dt.month == 1 and dt.day == 15 and dt.hours == 12 and dt.minutes == 0 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "UTC", "UTC standard time test 1 failed. Got " + String(dt));
      
      // 2. Standard time test 2 (July 15, 2024 12:00:00 UTC)
      leapSecondsAsOf := 27; // As of 2024, a total of 27 leap seconds had been added.
      dt := Functions.posixToDatetime(1721044800 + leapSecondsAsOf, utc, true);
      assert(dt.year == 2024 and dt.month == 7 and dt.day == 15 and dt.hours == 12 and dt.minutes == 0 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "UTC", "UTC standard time test 2 failed. Got " + String(dt));

      // 3. Standard time test 3 (March 31, 2024 12:00:00 UTC)
      leapSecondsAsOf := 27; // As of 2024, a total of 27 leap seconds had been added.
      dt := Functions.posixToDatetime(1711886400 + leapSecondsAsOf, utc, true);
      assert(dt.year == 2024 and dt.month == 3 and dt.day == 31 and dt.hours == 12 and dt.minutes == 0 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "UTC", "UTC standard time test 3 failed. Got " + String(dt));

      // 4. Standard time test 4 (October 27, 2024 12:00:00 UTC)
      leapSecondsAsOf := 27; // As of 2024, a total of 27 leap seconds had been added.
      dt := Functions.posixToDatetime(1730030400 + leapSecondsAsOf, utc, true);
      assert(dt.year == 2024 and dt.month == 10 and dt.day == 27 and dt.hours == 12 and dt.minutes == 0 and abs(dt.seconds - 0.0) < 1e-6 and dt.tz == "UTC", "UTC standard time test 4 failed. Got " + String(dt));
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestPosixToDatetimeWithLeapSeconds;

  model TestPosixToDatetimeOnLeapInsertion "Unit test dedicated for behavior around leap second insertion"
  extends Modelica.Icons.Example;
    Types.Datetime dt;
    parameter Types.Timezone utc = Data.Timezones.Etc.UTC;
    parameter Data.LeapSeconds ls;
    parameter Real deltaTBefore = 0.001;
    parameter Real deltaTDuring = 0.5;
    parameter Real deltaTAfter = 0.001;
  algorithm
    when initial() then  
      // Leap second insertion on 1972-06-30T23:59:59 + 1s
      
      // Shortly before first leap second inserted at 1972-06-30T23:59:59 + 1s.
      // Timestamp for 1972-06-30T23:59:59.999=ls.timestamps[1]-deltaTBefore should translate to same datetime
      dt := Functions.posixToDatetime(ls.timestamps[1] - deltaTBefore, utc, true);
      assert(dt.year == 1972 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1972-06-30T23:59:59 + 1s failed. Wanted 1972-06-30T23:59:59.999 UTC but got " + String(dt));

      // During first leap second at 1972-06-30T23:59:59 + 1s.
      // Timestamp for 1972-06-30T23:59:59 + 1s + 0.5s=ls.timestamps[1] + deltaTDuring should translate 1972-06-30T23:59:60.5
      dt := Functions.posixToDatetime(ls.timestamps[1] + deltaTDuring, utc, true);
      assert(dt.year == 1972 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1972-06-30T23:59:59 + 1s failed. Wanted 1972-06-30T23:59:60.5 UTC but got " + String(dt));

      // After first leap second at 1972-06-30T23:59:59 + 1s + 1s + deltaTAfter.
      // Timestamp for 1972-07-01T00:00:00 + deltaTAfter=ls.timestamps[1] + ls.leaps[1] + deltaTAfter should translate to same datetime
      dt := Functions.posixToDatetime(ls.timestamps[1] + ls.leaps[1] + deltaTAfter, utc, true);
      assert(dt.year == 1972 and dt.month == 7 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1972-06-30T23:59:59 + 1s failed. Wanted 1972-07-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 1972-12-31T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[2] - deltaTBefore, utc, true);
      assert(dt.year == 1972 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1972-12-31T23:59:59 + 1s failed. Wanted 1972-12-31T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[2] + deltaTDuring, utc, true);
      assert(dt.year == 1972 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1972-12-31T23:59:59 + 1s failed. Wanted 1972-12-31T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[2] + ls.leaps[2] + deltaTAfter, utc, true);
      assert(dt.year == 1973 and dt.month == 1 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1972-12-31T23:59:59 + 1s failed. Wanted 1973-01-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 1973-12-31T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[3] - deltaTBefore, utc, true);
      assert(dt.year == 1973 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1973-12-31T23:59:59 + 1s failed. Wanted 1973-12-31T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[3] + deltaTDuring, utc, true);
      assert(dt.year == 1973 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1973-12-31T23:59:59 + 1s failed. Wanted 1973-12-31T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[3] + ls.leaps[3] + deltaTAfter, utc, true);
      assert(dt.year == 1974 and dt.month == 1 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1973-12-31T23:59:59 + 1s failed. Wanted 1974-01-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 1974-12-31T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[4] - deltaTBefore, utc, true);
      assert(dt.year == 1974 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1974-12-31T23:59:59 + 1s failed. Wanted 1974-12-31T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[4] + deltaTDuring, utc, true);
      assert(dt.year == 1974 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1974-12-31T23:59:59 + 1s failed. Wanted 1974-12-31T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[4] + ls.leaps[4] + deltaTAfter, utc, true);
      assert(dt.year == 1975 and dt.month == 1 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1974-12-31T23:59:59 + 1s failed. Wanted 1975-01-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 1975-12-31T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[5] - deltaTBefore, utc, true);
      assert(dt.year == 1975 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1975-12-31T23:59:59 + 1s failed. Wanted 1975-12-31T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[5] + deltaTDuring, utc, true);
      assert(dt.year == 1975 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1975-12-31T23:59:59 + 1s failed. Wanted 1975-12-31T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[5] + ls.leaps[5] + deltaTAfter, utc, true);
      assert(dt.year == 1976 and dt.month == 1 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1975-12-31T23:59:59 + 1s failed. Wanted 1976-01-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 1976-12-31T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[6] - deltaTBefore, utc, true);
      assert(dt.year == 1976 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1976-12-31T23:59:59 + 1s failed. Wanted 1976-12-31T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[6] + deltaTDuring, utc, true);
      assert(dt.year == 1976 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1976-12-31T23:59:59 + 1s failed. Wanted 1976-12-31T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[6] + ls.leaps[6] + deltaTAfter, utc, true);
      assert(dt.year == 1977 and dt.month == 1 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1976-12-31T23:59:59 + 1s failed. Wanted 1977-01-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 1977-12-31T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[7] - deltaTBefore, utc, true);
      assert(dt.year == 1977 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1977-12-31T23:59:59 + 1s failed. Wanted 1977-12-31T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[7] + deltaTDuring, utc, true);
      assert(dt.year == 1977 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1977-12-31T23:59:59 + 1s failed. Wanted 1977-12-31T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[7] + ls.leaps[7] + deltaTAfter, utc, true);
      assert(dt.year == 1978 and dt.month == 1 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1977-12-31T23:59:59 + 1s failed. Wanted 1978-01-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 1978-12-31T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[8] - deltaTBefore, utc, true);
      assert(dt.year == 1978 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1978-12-31T23:59:59 + 1s failed. Wanted 1978-12-31T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[8] + deltaTDuring, utc, true);
      assert(dt.year == 1978 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1978-12-31T23:59:59 + 1s failed. Wanted 1978-12-31T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[8] + ls.leaps[8] + deltaTAfter, utc, true);
      assert(dt.year == 1979 and dt.month == 1 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1978-12-31T23:59:59 + 1s failed. Wanted 1979-01-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 1979-12-31T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[9] - deltaTBefore, utc, true);
      assert(dt.year == 1979 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1979-12-31T23:59:59 + 1s failed. Wanted 1979-12-31T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[9] + deltaTDuring, utc, true);
      assert(dt.year == 1979 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1979-12-31T23:59:59 + 1s failed. Wanted 1979-12-31T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[9] + ls.leaps[9] + deltaTAfter, utc, true);
      assert(dt.year == 1980 and dt.month == 1 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1979-12-31T23:59:59 + 1s failed. Wanted 1980-01-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 1981-06-30T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[10] - deltaTBefore, utc, true);
      assert(dt.year == 1981 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1981-06-30T23:59:59 + 1s failed. Wanted 1981-06-30T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[10] + deltaTDuring, utc, true);
      assert(dt.year == 1981 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1981-06-30T23:59:59 + 1s failed. Wanted 1981-06-30T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[10] + ls.leaps[10] + deltaTAfter, utc, true);
      assert(dt.year == 1981 and dt.month == 7 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1981-06-30T23:59:59 + 1s failed. Wanted 1981-07-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 1982-06-30T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[11] - deltaTBefore, utc, true);
      assert(dt.year == 1982 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1982-06-30T23:59:59 + 1s failed. Wanted 1982-06-30T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[11] + deltaTDuring, utc, true);
      assert(dt.year == 1982 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1982-06-30T23:59:59 + 1s failed. Wanted 1982-06-30T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[11] + ls.leaps[11] + deltaTAfter, utc, true);
      assert(dt.year == 1982 and dt.month == 7 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1982-06-30T23:59:59 + 1s failed. Wanted 1982-07-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 1983-06-30T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[12] - deltaTBefore, utc, true);
      assert(dt.year == 1983 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1983-06-30T23:59:59 + 1s failed. Wanted 1983-06-30T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[12] + deltaTDuring, utc, true);
      assert(dt.year == 1983 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1983-06-30T23:59:59 + 1s failed. Wanted 1983-06-30T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[12] + ls.leaps[12] + deltaTAfter, utc, true);
      assert(dt.year == 1983 and dt.month == 7 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1983-06-30T23:59:59 + 1s failed. Wanted 1983-07-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 1985-06-30T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[13] - deltaTBefore, utc, true);
      assert(dt.year == 1985 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1985-06-30T23:59:59 + 1s failed. Wanted 1985-06-30T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[13] + deltaTDuring, utc, true);
      assert(dt.year == 1985 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1985-06-30T23:59:59 + 1s failed. Wanted 1985-06-30T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[13] + ls.leaps[13] + deltaTAfter, utc, true);
      assert(dt.year == 1985 and dt.month == 7 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1985-06-30T23:59:59 + 1s failed. Wanted 1985-07-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 1987-12-31T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[14] - deltaTBefore, utc, true);
      assert(dt.year == 1987 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1987-12-31T23:59:59 + 1s failed. Wanted 1987-12-31T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[14] + deltaTDuring, utc, true);
      assert(dt.year == 1987 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1987-12-31T23:59:59 + 1s failed. Wanted 1987-12-31T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[14] + ls.leaps[14] + deltaTAfter, utc, true);
      assert(dt.year == 1988 and dt.month == 1 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1987-12-31T23:59:59 + 1s failed. Wanted 1988-01-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 1989-12-31T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[15] - deltaTBefore, utc, true);
      assert(dt.year == 1989 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1989-12-31T23:59:59 + 1s failed. Wanted 1989-12-31T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[15] + deltaTDuring, utc, true);
      assert(dt.year == 1989 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1989-12-31T23:59:59 + 1s failed. Wanted 1989-12-31T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[15] + ls.leaps[15] + deltaTAfter, utc, true);
      assert(dt.year == 1990 and dt.month == 1 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1989-12-31T23:59:59 + 1s failed. Wanted 1990-01-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 1990-12-31T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[16] - deltaTBefore, utc, true);
      assert(dt.year == 1990 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1990-12-31T23:59:59 + 1s failed. Wanted 1990-12-31T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[16] + deltaTDuring, utc, true);
      assert(dt.year == 1990 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1990-12-31T23:59:59 + 1s failed. Wanted 1990-12-31T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[16] + ls.leaps[16] + deltaTAfter, utc, true);
      assert(dt.year == 1991 and dt.month == 1 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1990-12-31T23:59:59 + 1s failed. Wanted 1991-01-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 1992-06-30T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[17] - deltaTBefore, utc, true);
      assert(dt.year == 1992 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1992-06-30T23:59:59 + 1s failed. Wanted 1992-06-30T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[17] + deltaTDuring, utc, true);
      assert(dt.year == 1992 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1992-06-30T23:59:59 + 1s failed. Wanted 1992-06-30T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[17] + ls.leaps[17] + deltaTAfter, utc, true);
      assert(dt.year == 1992 and dt.month == 7 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1992-06-30T23:59:59 + 1s failed. Wanted 1992-07-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 1993-06-30T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[18] - deltaTBefore, utc, true);
      assert(dt.year == 1993 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1993-06-30T23:59:59 + 1s failed. Wanted 1993-06-30T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[18] + deltaTDuring, utc, true);
      assert(dt.year == 1993 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1993-06-30T23:59:59 + 1s failed. Wanted 1993-06-30T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[18] + ls.leaps[18] + deltaTAfter, utc, true);
      assert(dt.year == 1993 and dt.month == 7 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1993-06-30T23:59:59 + 1s failed. Wanted 1993-07-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 1994-06-30T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[19] - deltaTBefore, utc, true);
      assert(dt.year == 1994 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1994-06-30T23:59:59 + 1s failed. Wanted 1994-06-30T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[19] + deltaTDuring, utc, true);
      assert(dt.year == 1994 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1994-06-30T23:59:59 + 1s failed. Wanted 1994-06-30T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[19] + ls.leaps[19] + deltaTAfter, utc, true);
      assert(dt.year == 1994 and dt.month == 7 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1994-06-30T23:59:59 + 1s failed. Wanted 1994-07-01T00:00:00.001 UTC but got " + String(dt));      

      // Leap second insertion on 1995-12-31T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[20] - deltaTBefore, utc, true);
      assert(dt.year == 1995 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1995-12-31T23:59:59 + 1s failed. Wanted 1995-12-31T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[20] + deltaTDuring, utc, true);
      assert(dt.year == 1995 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1995-12-31T23:59:59 + 1s failed. Wanted 1995-12-31T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[20] + ls.leaps[20] + deltaTAfter, utc, true);
      assert(dt.year == 1996 and dt.month == 1 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1995-12-31T23:59:59 + 1s failed. Wanted 1996-01-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 1997-06-30T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[21] - deltaTBefore, utc, true);
      assert(dt.year == 1997 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1997-06-30T23:59:59 + 1s failed. Wanted 1997-06-30T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[21] + deltaTDuring, utc, true);
      assert(dt.year == 1997 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1997-06-30T23:59:59 + 1s failed. Wanted 1997-06-30T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[21] + ls.leaps[21] + deltaTAfter, utc, true);
      assert(dt.year == 1997 and dt.month == 7 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1997-06-30T23:59:59 + 1s failed. Wanted 1997-07-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 1998-12-31T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[22] - deltaTBefore, utc, true);
      assert(dt.year == 1998 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 1998-12-31T23:59:59 + 1s failed. Wanted 1998-12-31T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[22] + deltaTDuring, utc, true);
      assert(dt.year == 1998 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1998-12-31T23:59:59 + 1s failed. Wanted 1998-12-31T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[22] + ls.leaps[22] + deltaTAfter, utc, true);
      assert(dt.year == 1999 and dt.month == 1 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 1998-12-31T23:59:59 + 1s failed. Wanted 1999-01-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 2005-12-31T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[23] - deltaTBefore, utc, true);
      assert(dt.year == 2005 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 2005-12-31T23:59:59 + 1s failed. Wanted 2005-12-31T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[23] + deltaTDuring, utc, true);
      assert(dt.year == 2005 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 2005-12-31T23:59:59 + 1s failed. Wanted 2005-12-31T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[23] + ls.leaps[23] + deltaTAfter, utc, true);
      assert(dt.year == 2006 and dt.month == 1 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 2005-12-31T23:59:59 + 1s failed. Wanted 2006-01-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 2008-12-31T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[24] - deltaTBefore, utc, true);
      assert(dt.year == 2008 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 2008-12-31T23:59:59 + 1s failed. Wanted 2008-12-31T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[24] + deltaTDuring, utc, true);
      assert(dt.year == 2008 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 2008-12-31T23:59:59 + 1s failed. Wanted 2008-12-31T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[24] + ls.leaps[24] + deltaTAfter, utc, true);
      assert(dt.year == 2009 and dt.month == 1 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 2008-12-31T23:59:59 + 1s failed. Wanted 2009-01-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 2012-06-30T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[25] - deltaTBefore, utc, true);
      assert(dt.year == 2012 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 2012-06-30T23:59:59 + 1s failed. Wanted 2012-06-30T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[25] + deltaTDuring, utc, true);
      assert(dt.year == 2012 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 2012-06-30T23:59:59 + 1s failed. Wanted 2012-06-30T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[25] + ls.leaps[25] + deltaTAfter, utc, true);
      assert(dt.year == 2012 and dt.month == 7 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 2012-06-30T23:59:59 + 1s failed. Wanted 2012-07-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 2015-06-30T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[26] - deltaTBefore, utc, true);
      assert(dt.year == 2015 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 2015-06-30T23:59:59 + 1s failed. Wanted 2015-06-30T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[26] + deltaTDuring, utc, true);
      assert(dt.year == 2015 and dt.month == 6 and dt.day == 30 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 2015-06-30T23:59:59 + 1s failed. Wanted 2015-06-30T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[26] + ls.leaps[26] + deltaTAfter, utc, true);
      assert(dt.year == 2015 and dt.month == 7 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 2015-06-30T23:59:59 + 1s failed. Wanted 2015-07-01T00:00:00.001 UTC but got " + String(dt));

      // Leap second insertion on 2016-12-31T23:59:59 + 1s
      dt := Functions.posixToDatetime(ls.timestamps[27] - deltaTBefore, utc, true);
      assert(dt.year == 2016 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 - deltaTBefore)) < 1e-6 and dt.tz == "UTC", "UTC leap second test before insertion on 2016-12-31T23:59:59 + 1s failed. Wanted 2016-12-31T23:59:59.999 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[27] + deltaTDuring, utc, true);
      assert(dt.year == 2016 and dt.month == 12 and dt.day == 31 and dt.hours == 23 and dt.minutes == 59 and abs(dt.seconds - (60 + deltaTDuring)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 2016-12-31T23:59:59 + 1s failed. Wanted 2016-12-31T23:59:60.5 UTC but got " + String(dt));
      dt := Functions.posixToDatetime(ls.timestamps[27] + ls.leaps[27] + deltaTAfter, utc, true);
      assert(dt.year == 2017 and dt.month == 1 and dt.day == 1 and dt.hours == 0 and dt.minutes == 0 and abs(dt.seconds - (0.0 + deltaTAfter)) < 1e-6 and dt.tz == "UTC", "UTC leap second test after insertion on 2016-12-31T23:59:59 + 1s failed. Wanted 2017-01-01T00:00:00.001 UTC but got " + String(dt));
    end when;
  annotation(
    experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));  
  end TestPosixToDatetimeOnLeapInsertion;  
end LeapSeconds;
