within DateTime;

package Data "This package provides basic time computation constants like the Posix epoch, month days, leap seconds, and in particular predefined timezone definitions"
  extends Modelica.Icons.RecordsPackage;
  
  record Epoch "The Posix epoch on 1970-01-01T00:00:00"
    extends Modelica.Icons.Record;
    parameter Types.Datetime dt(year=1970, month=1, day=1, hours=0, minutes=0, seconds=0.0);  
  end Epoch;

  record MonthDays "An array of the number of days in each month for a non-leap year"
    extends Modelica.Icons.Record;
    parameter Integer daysInMonth[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
  end MonthDays;
  
  record LeapSeconds "Contains data for leap seconds as of 2025. year contains the year added, dayAdded index of the day in the year it was added on"
    extends Modelica.Icons.Record;
    parameter Integer num = 27;
    parameter Integer years[27] =    {1972, 1972, 1973, 1974, 1975, 1976, 1977, 1978, 1979, 1981, 1982, 1983, 1985, 1987, 1989, 1990, 1992, 1993, 1994, 1995, 1997, 1998, 2005, 2008, 2012, 2015, 2016};
    parameter Integer dayAdded[27] = { 182,  366,  365,  365,  365,  366,  365,  365,  365,  182,  182,  182,  182,  365,  365,  365,  182,  182,  182,  365,  182,  365,  365,  366,  182,  182,  366};  
    parameter Types.Datetime datetimes[27] = {Types.Datetime(year=1972, month=6, day=30, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=1972, month=12, day=31, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=1973, month=12, day=31, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=1974, month=12, day=31, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=1975, month=12, day=31, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=1976, month=12, day=31, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=1977, month=12, day=31, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=1978, month=12, day=31, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=1979, month=12, day=31, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=1981, month=6, day=30, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=1982, month=6, day=30, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=1983, month=6, day=30, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=1985, month=6, day=30, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=1987, month=12, day=31, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=1989, month=12, day=31, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=1990, month=12, day=31, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=1992, month=6, day=30, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=1993, month=6, day=30, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=1994, month=6, day=30, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=1995, month=12, day=31, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=1997, month=6, day=30, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=1998, month=12, day=31, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=2005, month=12, day=31, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=2008, month=12, day=31, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=2012, month=6, day=30, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=2015, month=6, day=30, hours=23, minutes=59, seconds=60.0, tz="UTC"), 
      Types.Datetime(year=2016, month=12, day=31, hours=23, minutes=59, seconds=60.0, tz="UTC")};
    parameter Integer leaps[27] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
    /* The following array contains the timestamps for the time instances in which a leap seond was added computed
     * from _non-leap second adjusted_ UTC times using Python's datetime library:
     *   78796800 s POSIX = 1972-06-30T23:59:59+1s UTC_{non-leap second adjusted}, ...,
     * 1483228800 s POSIX = 2016-12-31T23:59:59+1s UTC_{non-leap second adjusted}
     * The correct POSIX timestamps for the _leap second adjusted_ UTC dates at which the leap seconds are inserted
     * must be added all the leap seconds added up to this point. This is because the POSIX time is continuous.
     * For instance, the the day before a leap second is added has standard 86400 s, but the day a positive leap second
     * is added has 86401 s. Hence, the POSIX time counting over all subsequent days is now always 1 s longer.*/
    parameter Integer timestamps[27] = {78796800+0, 94694400+1, 126230400+2, 157766400+3, 189302400+4, 220924800+5, 252460800+6, 283996800+7, 315532800+8, 362793600+9, 394329600+10, 425865600+11, 489024000+12, 567993600+13, 631152000+14, 662688000+15, 709948800+16, 741484800+17, 773020800+18, 820454400+19, 867715200+20, 915148800+21, 1136073600+22, 1230768000+23, 1341100800+24, 1435708800+25, 1483228800+26};
  end LeapSeconds;
  
  record WorkDays "An array of workdays, by default Monday,...,Friday. 0=Sunday, 1=Monday,..."
    extends Modelica.Icons.Record;
    parameter Integer days[:] = {1, 2, 3, 4, 5};
  end WorkDays;
end Data;