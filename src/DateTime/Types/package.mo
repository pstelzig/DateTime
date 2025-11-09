within DateTime;

package Types "Library of dedicated data types and classes for the DateTime package. Copyright <html>&copy;</html> Dr. Philipp Emanuel Stelzig, 2019-present. ALL RIGHTS RESERVED."
  extends Modelica.Icons.TypesPackage;

  record Timefield "[sign]HH:MM:SS[.digits]"
    extends Modelica.Icons.Record;
    Integer sign;
    Integer hours;
    Integer minutes;
    Real seconds;  
    
    encapsulated operator function 'String'
      import Timefield = DateTime.Types.Timefield;
      input Timefield tf "Timefield to convert";
      input Boolean useSign = false "Whether to use the sign in the string representation";
      output String str "String representation of the timefield";
    protected
      String sign_str;
      String hours_str;
      String minutes_str;
      String seconds_str;
      String fraction_str;
      Integer fraction;
    algorithm
      // Determine sign string
      if useSign then
        if tf.sign == 1 then
          sign_str := "+";
        elseif tf.sign == -1 then
          sign_str := "-";
        else
          assert(false, "Invalid sign in timefield, must be either 1 or -1, but got " + String(tf.sign));
        end if;
      else
        sign_str := "";
      end if;
    
      // Format hours with leading zero if needed
      if tf.hours < 10 then
        hours_str := "0" + String(tf.hours);
      else
        hours_str := String(tf.hours);
      end if;
    
      // Format minutes with leading zero if needed
      if tf.minutes < 10 then
        minutes_str := "0" + String(tf.minutes);
      else
        minutes_str := String(tf.minutes);
      end if;
    
      // Format seconds with leading zero and handle fractional part
      fraction := integer(floor((tf.seconds - floor(tf.seconds))*1000000));
      if fraction > 0 then
        fraction_str := "." + String(fraction);
      else
        fraction_str := ".000000";
      end if;
      
      if floor(tf.seconds) < 10 then
        seconds_str := "0" + String(integer(floor(tf.seconds)));
      else
        seconds_str := String(integer(floor(tf.seconds)));
      end if;
  
    
      // Combine all parts into the final string
      str := sign_str + hours_str + ":" + minutes_str + ":" + seconds_str;
    end 'String';  
  end Timefield;

  record Timezone "Holds information from an IEEE std 1003.1 string in format std offset dst [offset],start[/time],end[/time], e.g. CET+01:00:00CEST+01:00:00,M3.5.0/02:00:00,M10.5.0/03:00:00. We require any time to be given like HH:MM:SS, and offsets must start with a sign"
    extends Modelica.Icons.Record;
    String standardName;
    Timefield standardOffset;
    
    // Daylight savings definition
    Boolean hasDaylightSaving "True if timezone uses daylight saving time";
    
    String daylightName "Daylight saving time name (empty if no DST)";
    Timefield daylightOffset "Daylight saving time offset (default if no DST)";
    Integer startMonth "Month when DST starts (0 if no DST)";
    Integer startWeek "Week when DST starts (0 if no DST)";
    Integer startDay "Day when DST starts (0 if no DST)";
    Timefield startTime "Time when DST starts (default if no DST)";
    Integer endMonth "Month when DST ends (0 if no DST)";
    Integer endWeek "Week when DST ends (0 if no DST)";
    Integer endDay "Day when DST ends (0 if no DST)";
    Timefield endTime "Time when DST ends (default if no DST)";
    
    encapsulated operator function 'String'
      import Timezone = DateTime.Types.Timezone;
      input Timezone tz "Timezone to convert";
      output String str "String representation of the Timezone";
    algorithm
      // Format standard offset
      str := tz.standardName + String(tz.standardOffset, useSign=true);

      // Format daylight offset only if DST is used
      if tz.hasDaylightSaving then
        str := str + tz.daylightName + String(tz.daylightOffset, useSign=true);
        
        // Format start rule
        str := str + ",M" + String(tz.startMonth) + "." + String(tz.startWeek) + "." + String(tz.startDay) +
           "/" + String(tz.startTime);

        // Format end rule
        str := str + ",M" + String(tz.endMonth) + "." + String(tz.endWeek) + "." + String(tz.endDay) +
           "/" + String(tz.endTime);
      end if;
    end 'String';  
  
  end Timezone;

  operator record Date "Holds the information for a date object"
    extends Modelica.Icons.Record;
    Integer year;
    Integer month;
    Integer day;
    
    encapsulated operator function '==' "Compares two DateTime.Types.Date objects itemwise"
      import Date = DateTime.Types.Date;
      input Date d1 "First date object";
      input Date d2 "Second date object";
      output Boolean isEqual "True if the two datetime objects are equal within the specified tolerance";
    algorithm
      isEqual := d1.year == d2.year and
                 d1.month == d2.month and
                 d1.day == d2.day;
    end '==';
    
    encapsulated operator function 'String' "Converts a Date object to ISO 8601 format string"
      import Date = DateTime.Types.Date;
      input Date d "Date to convert";
      output String str "ISO 8601 formatted string";
    protected
      String year_str;
      String month_str;
      String day_str;
    algorithm
      year_str := String(d.year);
    
      // Format month with leading zero if needed
      if d.month < 10 then
        month_str := "0" + String(d.month);
      else
        month_str := String(d.month);
      end if;
    
      // Format day with leading zero if needed
      if d.day < 10 then
        day_str := "0" + String(d.day);
      else
        day_str := String(d.day);
      end if;
  
      // Combine all parts
      str := year_str + "-" + month_str + "-" + day_str;    
    end 'String';
     
  end Date;
  
  record Datetime "Holds the time information for a datetime object"
    extends Modelica.Icons.Record;
    Integer year;
    Integer month;
    Integer day;
    Integer hours;
    Integer minutes;
    Real seconds;
    String tz;  // Optional string appended to specify if daylight saving or not for ambiguous times when time jumps back, e.g. "2025-10-26T02:30 CEST" vs "2025-10-26T02:30 CET"
    
    encapsulated operator 'constructor'
      import Datetime = DateTime.Types.Datetime;
      input Integer year;
      input Integer month;
      input Integer day;
      input Integer hours;
      input Integer minutes;
      input Real seconds;
      input String tz = "";
      output Datetime result(year, month, day, hours, minutes, seconds, tz);     
      annotation(Inline=true);   
    end 'constructor';
    
    encapsulated operator function '==' "Compares two DateTime.Types.Datetime objects itemwise with a tolerance for seconds"
      import Datetime = DateTime.Types.Datetime;
      input Datetime dt1 "First datetime object";
      input Datetime dt2 "Second datetime object";
      output Boolean isEqual "True if the two datetime objects are equal within the specified tolerance";
    protected
      parameter Real tolerance = 1e-6 "Tolerance for comparing the seconds field";
    algorithm
      isEqual := dt1.year == dt2.year and
                 dt1.month == dt2.month and
                 dt1.day == dt2.day and
                 dt1.hours == dt2.hours and
                 dt1.minutes == dt2.minutes and
                 abs(dt1.seconds - dt2.seconds) < tolerance and
                 dt1.tz == dt2.tz;
    end '==';
   
    
    encapsulated operator function '<' "Returns true if by lexicographic comparison dt1 < dt2 is true"
      import Datetime = DateTime.Types.Datetime;
      input Datetime dt1;
      input Datetime dt2;
      output Boolean isLess;
    algorithm
      if dt1.year < dt2.year then
        isLess := true;
      elseif dt1.year > dt2.year then
        isLess := false;
      elseif dt1.month < dt2.month then
        isLess := true;
      elseif dt1.month > dt2.month then
        isLess := false;
      elseif dt1.day < dt2.day then
        isLess := true;
      elseif dt1.day > dt2.day then
        isLess := false;
      elseif dt1.hours < dt2.hours then
        isLess := true;
      elseif dt1.hours > dt2.hours then
        isLess := false;
      elseif dt1.minutes < dt2.minutes then
        isLess := true;
      elseif dt1.minutes > dt2.minutes then
        isLess := false;
      elseif dt1.seconds < dt2.seconds then
        isLess := true;
      else
        isLess := false;
      end if;
    end '<';
    
    encapsulated operator function '<=' "Returns true if by lexicographic comparison dt1 <= dt2 is true"
      import Datetime = DateTime.Types.Datetime;
      input Datetime dt1;
      input Datetime dt2;
      output Boolean isLessEqual;
    algorithm  
      if dt1.year < dt2.year then
        isLessEqual := true;
      elseif dt1.year > dt2.year then
        isLessEqual := false;
      elseif dt1.month < dt2.month then
        isLessEqual := true;
      elseif dt1.month > dt2.month then
        isLessEqual := false;
      elseif dt1.day < dt2.day then
        isLessEqual := true;
      elseif dt1.day > dt2.day then
        isLessEqual := false;
      elseif dt1.hours < dt2.hours then
        isLessEqual := true;
      elseif dt1.hours > dt2.hours then
        isLessEqual := false;
      elseif dt1.minutes < dt2.minutes then
        isLessEqual := true;
      elseif dt1.minutes > dt2.minutes then
        isLessEqual := false;
      elseif dt1.seconds < dt2.seconds then
        isLessEqual := true;
      elseif dt1.seconds > dt2.seconds then
        isLessEqual := false;
      else
        isLessEqual := true;  // Difference from isLessThanDatetime - equal datetimes return true for <=
      end if;    
    end '<=';
    
    encapsulated operator function '>=' "Returns true if by lexicographic comparison dt1 >= dt2 is true"
      import Datetime = DateTime.Types.Datetime;
      input Datetime dt1;
      input Datetime dt2;
      output Boolean isGreaterEqual;
    algorithm
      isGreaterEqual := not (dt1 < dt2);
    end '>='; 
    
    encapsulated operator function '>' "Returns true if by lexicographic comparison dt1 > dt2 is true"
      import Datetime = DateTime.Types.Datetime;
      input Datetime dt1;
      input Datetime dt2;
      output Boolean isGreaterEqual;
    algorithm
      isGreaterEqual := not (dt1 <= dt2);
    end '>';     
    
    encapsulated operator function 'String' "Converts a Datetime object to ISO 8601 format string"
      import Datetime = DateTime.Types.Datetime;
      import Strings = Modelica.Utilities.Strings;
      input Datetime dt "Datetime to convert";
      output String str "ISO 8601 formatted string";
    protected
      String year_str;
      String month_str;
      String day_str;
      String hours_str;
      String minutes_str;
      String seconds_str;
      String fraction_str;
      Integer fraction;
      Integer numDigits;
    algorithm
      year_str := String(dt.year);
    
      // Format month with leading zero if needed
      if dt.month < 10 then
        month_str := "0" + String(dt.month);
      else
        month_str := String(dt.month);
      end if;
    
      // Format day with leading zero if needed
      if dt.day < 10 then
        day_str := "0" + String(dt.day);
      else
        day_str := String(dt.day);
      end if;
    
      // Format hours with leading zero if needed
      if dt.hours < 10 then
        hours_str := "0" + String(dt.hours);
      else
        hours_str := String(dt.hours);
      end if;
    
      // Format minutes with leading zero if needed
      if dt.minutes < 10 then
        minutes_str := "0" + String(dt.minutes);
      else
        minutes_str := String(dt.minutes);
      end if;
    
      // Format seconds with leading zero and handle fractional part up
      if abs(dt.seconds - floor(dt.seconds)) < 1e-6 then
        seconds_str := String(integer(dt.seconds - floor(dt.seconds)));
      elseif abs(dt.seconds - floor(dt.seconds)) < 1e-6 then
        seconds_str := String(integer(dt.seconds - ceil(dt.seconds)));
      else
        seconds_str := String(dt.seconds, format=".6f");
      end if;
    
      if floor(dt.seconds) < 10 then
        seconds_str := "0" + seconds_str;
      end if;
    
      // Combine all parts
      str := year_str + "-" + month_str + "-" + day_str + "T" + 
             hours_str + ":" + minutes_str + ":" + seconds_str;
    
      // Append timezone name if present
      if dt.tz <> "" then
        str := str + " " + dt.tz;
      end if;
    end 'String';
   
  end Datetime;
end Types;