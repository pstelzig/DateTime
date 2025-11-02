within DateTime.Examples.UnitTests;
package Repetition
  extends Modelica.Icons.ExamplesPackage;

  model TestAddRepetition "Unit test for addSingleRepetitionToDatetime function"
    extends Modelica.Icons.Example;
    parameter Types.Timezone cet = Data.Timezones.Europe.CET_CEST;
    parameter Types.Timezone pst = Data.Timezones.America.PST_PDT;
    parameter Types.Timezone utc = Data.Timezones.Etc.UTC;
    String holidays[:] = {"2025-01-01", "2025-04-18", "2025-04-21", "2025-05-01", "2025-05-29", "2025-06-09", "2025-10-03", "2025-12-25", "2025-12-26"};
    Types.Datetime dt;
    Types.Datetime dt_expected;
    Types.Datetime result;
  algorithm
    when initial() then
      // Test hourly repetition
      dt := Types.Datetime(2025, 7, 12, 10, 0, 0.0, "");
      dt_expected := Types.Datetime(2025, 7, 12, 11, 0, 0.0, "CEST");
      result := Functions.addSingleRepetitionToDatetime(dt, "hourly", cet, holidays, false, true, "time_from_day_start");
      assert(result == dt_expected, "Hourly repetition failed for " + String(dt) + ", expected was " + String(dt_expected) + ". Got " + String(result));

      // Test hourly repetition
      dt := Types.Datetime(2025, 3, 30, 1, 30, 0.0, "");
      dt_expected := Types.Datetime(2025, 3, 30, 3, 30, 0.0, "CEST");
      result := Functions.addSingleRepetitionToDatetime(dt, "hourly", cet, holidays, false, true, "time_from_day_start");
      assert(result == dt_expected, "Hourly repetition failed for " + String(dt) + ", expected was " + String(dt_expected) + ". Got " + String(result));

      // Test hourly repetition
      dt := Types.Datetime(2025, 10, 26, 2, 30, 0.0, "CEST");
      dt_expected := Types.Datetime(2025, 10, 26, 2, 30, 0.0, "CET");
      result := Functions.addSingleRepetitionToDatetime(dt, "hourly", cet, holidays, false, true, "time_from_day_start");
      assert(result == dt_expected, "Hourly repetition failed for " + String(dt) + ", expected was " + String(dt_expected) + ". Got " + String(result));

      // Test daily repetition
      dt := Types.Datetime(2025, 7, 12, 10, 0, 0.0, "");
      dt_expected := Types.Datetime(2025, 7, 13, 10, 0, 0.0, "PDT");
      result := Functions.addSingleRepetitionToDatetime(dt, "daily", pst, holidays, false, true, "time_from_day_start");
      assert(result == dt_expected, "Daily repetition failed for " + String(dt) + ", expected was " + String(dt_expected) + ". Got " + String(result));

      // Test daily repetition
      dt := Types.Datetime(2025, 12, 31, 10, 0, 0.0, "");
      dt_expected := Types.Datetime(2026, 1, 1, 10, 0, 0.0, "PST");
      result := Functions.addSingleRepetitionToDatetime(dt, "daily", pst, holidays, false, true, "time_from_day_start");
      assert(result == dt_expected, "Daily repetition failed for " + String(dt) + ", expected was " + String(dt_expected) + ". Got " + String(result));

      // Test daily repetition
      dt := Types.Datetime(2025, 3, 8, 7, 30, 0.0, "PST");
      dt_expected := Types.Datetime(2025, 3, 9, 7, 30, 0.0, "PDT");
      result := Functions.addSingleRepetitionToDatetime(dt, "daily", pst, holidays, false, true, "time_from_day_start");
      assert(result == dt_expected, "Daily repetition failed for " + String(dt) + ", expected was " + String(dt_expected) + ". Got " + String(result));

      // Test daily repetition
      dt := Types.Datetime(2025, 3, 8, 2, 30, 0.0, "PST"); // Incrementing day results in inavlid datetime. autocorrect with time_from_day_start
      dt_expected := Types.Datetime(2025, 3, 9, 3, 30, 0.0, "PDT");
      result := Functions.addSingleRepetitionToDatetime(dt, "daily", pst, holidays, false, true, "time_from_day_start");
      assert(result == dt_expected, "Daily repetition failed for " + String(dt) + ", expected was " + String(dt_expected) + ". Got " + String(result));

      // Test weekly repetition
      dt := Types.Datetime(2025, 2, 26, 14, 30, 1.0, "PST");
      dt_expected := Types.Datetime(2025, 3, 5, 14, 30, 1.0, "PST");
      result := Functions.addSingleRepetitionToDatetime(dt, "weekly", pst, holidays, false, true, "time_from_day_start");
      assert(result == dt_expected, "Weekly repetition failed for " + String(dt) + ", expected was " + String(dt_expected) + ". Got " + String(result));

      // Test monthly repetition
      dt := Types.Datetime(2025, 2, 26, 14, 30, 1.0, "PST");
      dt_expected := Types.Datetime(2025, 3, 26, 14, 30, 1.0, "PDT"); // Now in daylight saving
      result := Functions.addSingleRepetitionToDatetime(dt, "monthly", pst, holidays, false, true, "time_from_day_start");
      assert(result == dt_expected, "Monthly repetition failed for " + String(dt) + ", expected was " + String(dt_expected) + ". Got " + String(result));

      // Test monthly repetition
      dt := Types.Datetime(2024, 1, 31, 14, 30, 1.0, "PST");
      dt_expected := Types.Datetime(2024, 2, 29, 14, 30, 1.0, "PST");
      result := Functions.addSingleRepetitionToDatetime(dt, "monthly", pst, holidays, false, true, "time_from_day_start");
      assert(result == dt_expected, "Monthly repetition failed for " + String(dt) + ", expected was " + String(dt_expected) + ". Got " + String(result));

      // Test yearly repetition
      dt := Types.Datetime(2024, 1, 29, 14, 30, 1.0, "PST");
      dt_expected := Types.Datetime(2025, 1, 29, 14, 30, 1.0, "PST");
      result := Functions.addSingleRepetitionToDatetime(dt, "yearly", pst, holidays, false, true, "time_from_day_start");
      assert(result == dt_expected, "Yearly repetition failed for " + String(dt) + ", expected was " + String(dt_expected) + ". Got " + String(result));

      // Test yearly repetition
      dt := Types.Datetime(2024, 2, 29, 14, 30, 1.0, "PST");
      dt_expected := Types.Datetime(2025, 2, 28, 14, 30, 1.0, "PST");
      result := Functions.addSingleRepetitionToDatetime(dt, "yearly", pst, holidays, false, true, "time_from_day_start");
      assert(result == dt_expected, "Yearly repetition failed for " + String(dt) + ", expected was " + String(dt_expected) + ". Got " + String(result));

      // Test workdays repetition
      dt := Types.Datetime(2025, 7, 11, 8, 30, 0.0, "CEST");
      dt_expected := Types.Datetime(2025, 7, 14, 8, 30, 0.0, "CEST");
      result := Functions.addSingleRepetitionToDatetime(dt, "workdays", cet, holidays, false, true, "time_from_day_start");
      assert(result == dt_expected, "Workday repetition failed for " + String(dt) + ", expected was " + String(dt_expected) + ". Got " + String(result));

      // Test workdays repetition
      dt := Types.Datetime(2025, 10, 2, 8, 30, 0.0, "CEST");
      dt_expected := Types.Datetime(2025, 10, 6, 8, 30, 0.0, "CEST");
      result := Functions.addSingleRepetitionToDatetime(dt, "workdays", cet, holidays, false, true, "time_from_day_start");
      assert(result == dt_expected, "Workday repetition failed for " + String(dt) + ", expected was " + String(dt_expected) + ". Got " + String(result));

      // Test firstDayInMonth repetition
      dt := Types.Datetime(2026, 11, 17, 8, 30, 0.0, "CET");
      dt_expected := Types.Datetime(2026, 12, 1, 8, 30, 0.0, "CET");
      result := Functions.addSingleRepetitionToDatetime(dt, "firstDayInMonth", cet, holidays, false, true, "time_from_day_start");
      assert(result == dt_expected, "firstDayInMonth repetition failed for " + String(dt) + ", expected was " + String(dt_expected) + ". Got " + String(result));

      // Test firstDayInMonth repetition
      dt := Types.Datetime(2026, 12, 17, 8, 30, 0.0, "CET");
      dt_expected := Types.Datetime(2027, 1, 1, 8, 30, 0.0, "CET");
      result := Functions.addSingleRepetitionToDatetime(dt, "firstDayInMonth", cet, holidays, false, true, "time_from_day_start");
      assert(result == dt_expected, "firstDayInMonth repetition failed for " + String(dt) + ", expected was " + String(dt_expected) + ". Got " + String(result));

      // Test lastDayInMonth repetition
      dt := Types.Datetime(2026, 11, 17, 8, 30, 0.0, "CET");
      dt_expected := Types.Datetime(2026, 11, 30, 8, 30, 0.0, "CET");
      result := Functions.addSingleRepetitionToDatetime(dt, "lastDayInMonth", cet, holidays, false, true, "time_from_day_start");
      assert(result == dt_expected, "lastDayInMonth repetition failed for " + String(dt) + ", expected was " + String(dt_expected) + ". Got " + String(result));

      // Test lastDayInMonth repetition
      dt := Types.Datetime(2026, 2, 17, 8, 30, 0.0, "CET");
      dt_expected := Types.Datetime(2026, 2, 28, 8, 30, 0.0, "CET");
      result := Functions.addSingleRepetitionToDatetime(dt, "lastDayInMonth", cet, holidays, false, true, "time_from_day_start");
      assert(result == dt_expected, "lastDayInMonth repetition failed for " + String(dt) + ", expected was " + String(dt_expected) + ". Got " + String(result));
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestAddRepetition;

  model TestLargestPreviousTrigger
    extends Modelica.Icons.Example;
    parameter Types.Timezone cet = Data.Timezones.Europe.CET_CEST;
    Real simPosixTime = 1759752900.0; // 2025-10-06T14:15:00
    String holidays[:] = {"2025-01-01", "2025-04-18", "2025-04-21", "2025-05-01", "2025-05-29", "2025-06-09", "2025-10-03", "2025-12-25", "2025-12-26"};
    Types.Datetime initTrigger;
    Types.Datetime prevTrigger_expected;
    Types.Datetime prevTrigger;
    Real prevTriggerPosix;
  algorithm
    when initial() then
      // With workdays repetition: Must go several days back
      initTrigger := Types.Datetime(2025, 9, 26, 15, 30, 0.0, "CEST");
      prevTrigger_expected := Types.Datetime(2025, 10, 2, 15, 30, 0.0, "CEST"); // workdays
      (prevTrigger, prevTriggerPosix) := Functions.largestPreviousTrigger(simPosixTime, initTrigger, "workdays", cet, holidays, false, true, "time_from_day_start");
      assert(prevTrigger == prevTrigger_expected, "largest trigger with workdays repetition failed for " + String(initTrigger) + ", expected was " + String(prevTrigger_expected) + ". Got " + String(prevTrigger));

      // With workdays repetition: Must go several days back
      initTrigger := Types.Datetime(2025, 9, 26, 13, 30, 0.0, "CEST");
      prevTrigger_expected := Types.Datetime(2025, 10, 6, 13, 30, 0.0, "CEST"); // workdays
      (prevTrigger, prevTriggerPosix) := Functions.largestPreviousTrigger(simPosixTime, initTrigger, "workdays", cet, holidays, false, true, "time_from_day_start");
      assert(prevTrigger == prevTrigger_expected, "largest trigger with workdays repetition failed for " + String(initTrigger) + ", expected was " + String(prevTrigger_expected) + ". Got " + String(prevTrigger));
    end when;
    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.5));
  end TestLargestPreviousTrigger;
end Repetition;
