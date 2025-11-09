import pathlib
from datetime import datetime, timedelta
import pytz
import re
   

def tz_to_transition_datetimes(tz_name: str, year: int) -> tuple[datetime, datetime, float]:
    """
    Compute the start and end datetimes of daylight saving time transitions for a given timezone and year.

    Parameters
    ----------
    tz_name : str
        The name of the timezone (e.g., "Europe/Berlin").
    year : int
        The year for which to compute the transitions.

    Returns
    -------
    out : tuple[datetime, datetime, float]
        A tuple (start_dst, end_dst) where each is a string in the format "YYYY-MM-DDTHH:MM:SS.SSSS".
        If the timezone does not use daylight saving time, returns (None, None).
    """
    tz = pytz.timezone(tz_name)
    transitions = []

    # Iterate through all days of the year to find DST transitions
    for month in range(1, 13):
        for day in range(1, 32):
            try:
                dt = tz.localize(datetime(year, month, day, 0, 0, 0))
                next_dt = tz.localize(datetime(year, month, day, 0, 0, 0) + timedelta(days=1))
                if abs((next_dt.timestamp() - dt.timestamp()) - 86400) >= 0.5: 
                    transitions.append(dt)
            except ValueError:
                continue

    if len(transitions) != 2:
        # No DST transitions found
        return None
    
    start_dst = None
    end_dst = None

    # This heuristic works only for DST shifts of 1 h that do not occur at start or end of day
    for i in range(0, 2):
        t = transitions[i]        
        daystart = tz.localize(datetime(t.year, t.month, t.day, hour=0, minute=30, second=0))
        for h in range(0, 23):
            dt = datetime.fromtimestamp(daystart.timestamp() + h*3600, tz=tz)
            if dt.hour > h:
                start_dst = tz.localize(datetime(t.year, t.month, t.day, hour=h, minute=0, second=0))
                break
            elif dt.hour < h:
                end_dst = tz.localize(datetime(t.year, t.month, t.day, hour=h, minute=0, second=0))
                break

    if not start_dst:
        raise ValueError(f"Cannot find start of DST for {tz_name} in {year}")
    if not end_dst:
        raise ValueError(f"Cannot find end of DST for {tz_name} in {year}")

    return start_dst, end_dst


def transition_correction(start, end, apply_from=4):
    """
    This is a heuristic: 5 in IEEE 1003.1 denotes the last week, the computation below might sometimes 
    wrongly return 4. Since this rule is mostly identical for start and end, we take the maximum

    Some timezones like PST_PDT have start week 2 and end week 1, so we must make sure that this
    heuristic is only applied when both transition start and end week are at least apply_from=4.
    """

    transition_week_start =(start.day-1)//7+1
    transition_week_stop = (end.day-1)//7+1

    if abs(transition_week_start - transition_week_stop) <= 1 and (transition_week_start >= apply_from and transition_week_stop >= apply_from):
        transition_week_start = transition_week_stop = max(transition_week_start, transition_week_stop)    

    return transition_week_start, transition_week_stop


def offsetnum_to_timezone_name(tz_name: str, dst: bool) -> str:
    abbrev = "UTC" + tz_name

    if dst:
        abbrev += " DST"

    return abbrev


def tz_to_timezone_offset(tz_name: str, force_abbrev: bool=False) -> tuple:
    tz = pytz.timezone(tz_name)

    # Get standard and DST names and offsets using January (standard) and July (DST)
    jan = tz.localize(datetime(2025, 1, 1))
    jul = tz.localize(datetime(2025, 7, 1))
    
    # Get standard time info
    std_name = jan.tzname()

    if std_name.strip(" +-").isdigit():
        is_named_tz = False
    else:
        is_named_tz = True

    if not is_named_tz and force_abbrev:
        std_name = offsetnum_to_timezone_name(std_name, False)     
       
    std_offset = jan.utcoffset()
    std_hours, remainder = divmod(int(std_offset.total_seconds()), 3600)
    std_minutes, std_seconds = divmod(remainder, 60)
    
    # Get DST info
    dst_name = jul.tzname()

    if not is_named_tz and force_abbrev:
        dst_name = offsetnum_to_timezone_name(dst_name, True)
    
    dst_offset = jul.utcoffset() - jan.utcoffset()

    # This timezone lies on the southern hemisphere, i.e. July date is standard time. Redo computation
    if dst_offset.total_seconds() < 0:  
        std_name = jul.tzname()

        if std_name.strip(" +-").isdigit():
            is_named_tz = False        
        else:
            is_named_tz = True

        if not is_named_tz and force_abbrev:
            std_name = offsetnum_to_timezone_name(std_name, False)
        
        std_offset = jul.utcoffset()
        std_hours, remainder = divmod(int(std_offset.total_seconds()), 3600)
        std_minutes, std_seconds = divmod(remainder, 60)
        
        # Get DST info
        dst_name = jan.tzname()

        if not is_named_tz and force_abbrev:
            dst_name = offsetnum_to_timezone_name(dst_name, True)
        
        dst_offset = jan.utcoffset() - jul.utcoffset()

    dst_hours, remainder = divmod(int(dst_offset.total_seconds()), 3600)
    dst_minutes, dst_seconds = divmod(remainder, 60)    

    offsets = {"std_name": std_name, "dst_name": dst_name, "std_offset": (std_hours, std_minutes, std_seconds), "dst_offset": (dst_hours, dst_minutes, dst_seconds), "is_named_tz": is_named_tz}
    
    return offsets


def tz_to_ieee1003(tz_name: str) -> str:
    """
    Convert a timezone name (e.g., "Europe/Berlin") to its ISO IEEE 1003.1 timezone definition.
    
    Parameters
    ----------
    tz_name : str
        The name of the timezone (e.g., "Europe/Berlin").
   
    Returns
    -------
    out : str
        A string representing the ISO IEEE 1003.1 timezone definition 
        (e.g., "CET+01:00:00CEST+02:00:00,M3.5.0/02:00:00,M10.5.0/03:00:00" for Europe/Berlin)
    """

    # Get offset definitions
    offsets = tz_to_timezone_offset(tz_name, force_abbrev=False)

    # If timezone has no named abbreviations, cannot turn into IEEE 1003.1 standard
    if not offsets["is_named_tz"]:
        return ""

    std_str = f"{offsets["std_name"]}{offsets["std_offset"][0]:+03d}:{offsets["std_offset"][1]:02d}:{offsets["std_offset"][2]:02d}"
    dst_str = f"{offsets["dst_name"]}{offsets["dst_offset"][0]:+03d}:{offsets["dst_offset"][1]:02d}:{offsets["dst_offset"][2]:02d}"
    
    # Get DST transition rules by finding the transitions in 2025
    transitions = tz_to_transition_datetimes(tz_name, 2025)
    
    if not transitions:
        # No DST transitions found
        return std_str
    
    # Format transition rules
    start = transitions[0]
    end = transitions[1]
    transition_week_start, transition_week_stop = transition_correction(start, end)

    start_rule = f"M{start.month}.{transition_week_start}.{(start.weekday()+1)%7}/{start.hour:02d}:{start.minute:02d}:{start.second:02d}"
    end_rule = f"M{end.month}.{transition_week_stop}.{(end.weekday()+1)%7}/{end.hour:02d}:{end.minute:02d}:{end.second:02d}"
    
    return f"{std_str}{dst_str},{start_rule},{end_rule}"


def tz_to_datetimemolib_timezone(tz_name: str, force_abbrev: bool=False) -> str:
    """
    Convert a timezone name (e.g., "Europe/Berlin") to its ISO IEEE 1003.1 timezone definition.
    
    Parameters
    ----------
    tz_name : str
        The name of the timezone (e.g., "Europe/Berlin").

    force_abbrev : bool, optional
        If True, forces substitute abbreviations for standard and daylight saving time names 
        if tz_name has no named std offset names, like e.g. CET or CEST in case of "Europe/Berlin"        
    
    Returns
    -------
    out : str
        A string representation that instantiates a DateTime.Types.Timezone object, e.g. 

        constant Types.Timezone Berlin = Types.Timezone(
            standardName="CET",
            standardOffset=Types.Timefield(sign=1, hours=1, minutes=0, seconds=0.0),
            hasDaylightSaving=true,
            daylightName="CEST",
            daylightOffset=Types.Timefield(sign=1, hours=1, minutes=0, seconds=0.0),
            startMonth=3, startWeek=5, startDay=0,  // Last Sunday in March
            startTime=Types.Timefield(sign=1, hours=2, minutes=0, seconds=0.0),
            endMonth=10, endWeek=5, endDay=0,       // Last Sunday in October
            endTime=Types.Timefield(sign=1, hours=3, minutes=0, seconds=0.0)
        );
    """
    
    # Get offset definitions
    offsets = tz_to_timezone_offset(tz_name, force_abbrev)
    std_name = offsets["std_name"]
    std_hours = offsets["std_offset"][0]
    std_minutes = offsets["std_offset"][1]
    std_seconds = offsets["std_offset"][2]
    dst_name = offsets["dst_name"]
    dst_hours = offsets["dst_offset"][0]
    dst_minutes = offsets["dst_offset"][1]
    dst_seconds = offsets["dst_offset"][2]
    
    # Get DST transition rules by finding the transitions in 2025
    transitions = tz_to_transition_datetimes(tz_name, 2025)

    def sign(n):
        if n >= 0:
            return 1
        else:
            return -1    

    modelica_template = ""
    if not transitions:
        modelica_template = f"""Types.Timezone(
  standardName="{std_name}",
  standardOffset=Types.Timefield(sign={sign(std_hours)}, hours={abs(std_hours)}, minutes={std_minutes}, seconds={std_seconds}),
  hasDaylightSaving=false,
  daylightName="{std_name}",
  daylightOffset=Types.Timefield(sign=1, hours=0, minutes=0, seconds=0.0),
  startMonth=1, startWeek=1, startDay=0,
  startTime=Types.Timefield(sign=1, hours=0, minutes=0, seconds=0.0),
  endMonth=12, endWeek=5, endDay=0,
  endTime=Types.Timefield(sign=1, hours=0, minutes=0, seconds=0.0)
  )"""
    else:
        start = transitions[0]
        end = transitions[1]
        transition_week_start, transition_week_stop = transition_correction(start, end)      

        modelica_template = f"""Types.Timezone(
  standardName="{std_name}",
  standardOffset=Types.Timefield(sign={sign(std_hours)}, hours={abs(std_hours)}, minutes={std_minutes}, seconds={std_seconds}),
  hasDaylightSaving=true,
  daylightName="{dst_name}",
  daylightOffset=Types.Timefield(sign={sign(dst_hours)}, hours={abs(dst_hours)}, minutes={dst_minutes}, seconds={dst_seconds}),
  startMonth={start.month}, startWeek={transition_week_start}, startDay={(start.weekday()+1)%7}, 
  startTime=Types.Timefield(sign={sign(start.hour)}, hours={abs(start.hour)}, minutes={start.minute}, seconds={start.second}),
  endMonth={end.month}, endWeek={transition_week_stop}, endDay={(end.weekday()+1)%7},
  endTime=Types.Timefield(sign={sign(end.hour)}, hours={abs(end.hour)}, minutes={end.minute}, seconds={end.second})
)"""

    return modelica_template


def tz_name_modelica_compliant(tz_name: str) -> str:
    tz_name = re.sub(r"\+(\d)", r"_plus_\1", tz_name)
    tz_name = re.sub(r"-(\d)", r"_minus_\1", tz_name)
    tz_name = tz_name.replace(" ", "_").replace("-", "_")

    return tz_name


def tz_to_datetimemolib(region: str) -> str:
    """
    Converts a given timezone region into a Datetime-compatible timezone package definition.
    This function processes all timezones within the specified region, maps them to Datetime-compatible
    timezone definitions, and generates a Modelica package definition for the region. It ensures that
    duplicate timezone definitions are avoided and provides comments for IEEE 1003.1 definitions where applicable.
    
    Parameters
    ----------
    region : str
        The name of the timezone region (e.g., "Europe", "America") to process.
    
    Returns
    -------
    out : str
        A string containing the Modelica package definition for the specified timezone region.
    """

    # Get timezone identifiers in region according to pytz
    tzs_in_region = [tz for tz in pytz.all_timezones if tz.startswith(region)]

    tz_defs = {}
    
    # Walk over all timezone identifiers and create Datetime definition. Avoid duplicate definitions
    for tz_name in tzs_in_region:

        # We currently ignore a couple of special cases. Need to be handled manually. 
        # Most have DST start at midnight which derails heuristic to find transition times in tz_to_transition_datetimes
        to_ignore = [
            "Australia/Lord_Howe",  #  Australia/Lord_Howe has only 30 min DST shift. Will ignore. Make by hand if needed.
            "Africa/Cairo", 
            "America/Havana", 
            "America/Nuuk", 
            "America/Santiago", 
            "America/Scoresbysund",  
            "Asia/Beirut",
            "Atlantic/Azores"
        ]
        
        if tz_name in to_ignore:
            continue

        mo_tz = tz_to_datetimemolib_timezone(tz_name, force_abbrev=True)

        # Avoid duplicate definitions
        if mo_tz not in tz_defs.values(): 
            tz_defs[tz_name] = mo_tz
        # If already exists: Try to create an own timezone like {std_name}_{dst_name} and assign all following to this
        else:  
            # Search for std_name and dst_name: By construction we know there are matches
            std_name = re.findall(r"standardName=\"([^\"]*)\"", mo_tz)[0]
            dst_name = re.findall(r"daylightName=\"([^\"]*)\"", mo_tz)[0]

            if std_name != dst_name:
                repl_name = f"{std_name}_{dst_name}"
            else:
                repl_name = std_name

            repl_name = tz_name_modelica_compliant(repl_name)

            if repl_name not in tz_defs.keys():
                tz_defs = {k: (repl_name if v == mo_tz else v) for k, v in tz_defs.items()}

            tz_defs[tz_name] = repl_name
            tz_defs = dict({repl_name: mo_tz}, **tz_defs)                

    var_defs = []
    for tz_name in tz_defs.keys():
        region_name = tz_name.split("/")

        # Take identifier in region as variable name and normalize to be Modelica compliant
        var_name = tz_name_modelica_compliant(region_name[-1])

        # Sometimes it can happen that a previous replacement name matches a named timezone
        # E.g. when GMT is chosen as a replacement for recurring definitions, but Etc/GMC also exists
        if var_name == tz_defs[tz_name]:
            continue
        
        if tz_name in pytz.all_timezones:
            ieee1013 = tz_to_ieee1003(tz_name)
            if ieee1013:
                var_def = f"// {tz_name}: {ieee1013}\nconstant Types.Timezone {var_name} = {tz_defs[tz_name]};"
            else:
                var_def = f"// {tz_name}\nconstant Types.Timezone {var_name} = {tz_defs[tz_name]};"
        else:
            var_def = f"// {tz_name}\nconstant Types.Timezone {var_name} = {tz_defs[tz_name]};"
        
        var_defs.append(var_def)

    # Correct indentation
    indent = 2*" "
    for i in range(0, len(var_defs)):
        vd = var_defs[i]
        lines = vd.split("\n")
        lines = [indent + ln for ln in lines]
        vd = "\n".join(lines)
        var_defs[i] = vd

    all_defs = "\n\n".join(var_defs)

    # Create Modelica package for region
    package_def = f"""within DateTime.Data.Timezones;
package {region} "Auto-generated by the datetimedata.py file of this project. IMPORTANT: Might contain errors in timezone definitions. Validate before using."
  extends Modelica.Icons.RecordsPackage;

{all_defs}
end {region};
"""

    return package_def
   

if __name__ == "__main__":
    regions = sorted(["Europe", "America", "Africa", "Antarctica", "Arctic", "Asia", "Atlantic", "Australia", "Indian", "Pacific", "Etc"])

    this_folder = pathlib.Path(__file__).absolute().parent

    for region in regions:
        reg_pack = tz_to_datetimemolib(region)
        with open(this_folder / f"../DateTime/Data/Timezones/{region}.mo", "w") as f:
            f.write(reg_pack)

    with open(this_folder / "../DateTime/Data/Timezones/package.order", "w") as f:
        f.write("\n".join(regions))

