/**
 * @file DateTimeExternalC.h
 * @brief Header-only C implementation of core UTC calendar arithmetic for the DateTime Modelica library.
 *
 * Wraps the C standard library's time functions (timegm / gmtime_r)
 * with a thin portability layer for Windows (_mkgmtime / gmtime_s).
 *
 * @copyright Copyright Dr. Philipp Emanuel Stelzig, 2019-present. ALL RIGHTS RESERVED.
 */

#ifndef PSTELZIG_DATETIME_EXTERNAL_C
#define PSTELZIG_DATETIME_EXTERNAL_C

// Expose POSIX functions (timegm, gmtime_r) on glibc/Linux
#if !defined(_WIN32) && !defined(_DEFAULT_SOURCE)
  #define _DEFAULT_SOURCE
#endif

#include <time.h>
#include <math.h>
#include <string.h>

// Ensure platform portability shims
#ifdef _WIN32
  #define DateTime_timegm _mkgmtime
  static struct tm *DateTime_gmtime_r(const time_t *t, struct tm *result)
  {
      return (gmtime_s(result, t) == 0) ? result : NULL;
  }
#else
  #define DateTime_timegm  timegm
  #define DateTime_gmtime_r gmtime_r
#endif

/**
 * @brief Convert a UTC date-time to epoch seconds (seconds since 1970-01-01T00:00:00 UTC).
 *
 * Pure UTC calendar arithmetic via the C standard library. No timezone or
 * leap-second handling.
 *
 * Called from Modelica as:
 *   external "C" epoch = utcDatetimeToEpoch(year, month, day, hours, minutes, seconds);
 *
 * @param year The year.
 * @param month The month.
 * @param day The day.
 * @param hours The hours.
 * @param minutes The minutes.
 * @param seconds The seconds.
 * @return The epoch time in seconds.
 */
static double utcDatetimeToEpoch(int year, int month, int day,
  int hours, int minutes, double seconds)
{
    struct tm tm_val;
    time_t epoch;
    const double intSec  = floor(seconds);
    const double fracSec = seconds - intSec;

    memset(&tm_val, 0, sizeof(tm_val));
    tm_val.tm_year  = year - 1900;
    tm_val.tm_mon   = month - 1;
    tm_val.tm_mday  = day;
    tm_val.tm_hour  = hours;
    tm_val.tm_min   = minutes;
    tm_val.tm_sec   = (int)intSec;
    tm_val.tm_isdst = 0;

    epoch = DateTime_timegm(&tm_val);
    return (double)epoch + fracSec;
}

/**
 * @brief Convert epoch seconds to UTC date-time components.
 *
 * Pure UTC calendar arithmetic via the C standard library — no timezone or
 * leap-second handling.
 *
 * Called from Modelica as:
 *   external "C" epochToUtcDatetime(epoch, year, month, day, hours, minutes, seconds);
 *   (output arguments are passed by pointer automatically)
 *
 * @param epoch The epoch time in seconds.
 * @param year Pointer to store the year.
 * @param month Pointer to store the month.
 * @param day Pointer to store the day.
 * @param hours Pointer to store the hours.
 * @param minutes Pointer to store the minutes.
 * @param seconds Pointer to store the seconds.
 */
static void epochToUtcDatetime(double epoch,
  int *year, int *month, int *day,
  int *hours, int *minutes, double *seconds)
{
    const double intEpoch = floor(epoch);
    const double fracSec  = epoch - intEpoch;
    const time_t t = (time_t)intEpoch;
    struct tm result;

    DateTime_gmtime_r(&t, &result);

    *year    = result.tm_year + 1900;
    *month   = result.tm_mon  + 1;
    *day     = result.tm_mday;
    *hours   = result.tm_hour;
    *minutes = result.tm_min;
    *seconds = (double)result.tm_sec + fracSec;
}

#endif // PSTELZIG_DATETIME_EXTERNAL_C
