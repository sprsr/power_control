-- Holiday table for a given year accounting for adjustments
local holiday_table_year
-- Table index is the day of year
local holiday_table
-- Constants for convenience
local Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec=1,2,3,4,5,6,7,8,9,10,11,12
local Sun,Mon,Tue,Wed,Thu,Fri,Sat=1,2,3,4,5,6,7

local function normalized_date(date)
  return os.date("*t",os.time(date))
end

-- Generate a holiday table for US
local function make_US_holiday_table(base_year)
  local ret={}
  -- Nested local function we'll use further
  local function holiday(name,month,day,year)
    year=year or base_year
    local yday
    if type(day)=="number" then
      local date={year=year,month=month,day=day}
      date=normalized_date(date)
      if date.wday==Sun then
        -- Holidays on Sunday get adjusted to following
        -- Monday, that's 1 day later
        date.day=date.day+1
        date=normalized_date(date)
      elseif date.wday==Sat then
        -- Holidays on Saturday get adjusted to preceding
        -- Friday, that's 1 day earlier
        date.day=date.day-1
        date=normalized_date(date)
      end
      -- If a holiday moves to a different year as a result of
      -- an adjustment, it's not counted
      if date.year==base_year then
        yday=date.yday
      end
    else
      local index=day[1]
      local wday=day[2]
      local all_matching_days={}
      -- We could really speed this up, but it's simpler this way
      local date={year=year,month=month,day=0}
      while true do
        date.day=date.day+1
        date=normalized_date(date)
        if date.month~=month then
          break
        end
        if date.wday==wday then
          all_matching_days[#all_matching_days+1]=date.yday
        end
      end
      if index>0 then
        yday=all_matching_days[index]
      else
        yday=all_matching_days[#all_matching_days+1+index]
      end
    end
    if yday then
      ret[yday]=name
    end
  end
  holiday("New_Year's_Day",         Jan, 1                   )
  -- New Year is special, as it can move in from the next year,
  -- e.g. see 2010->2011
  holiday("New_Year's_Day",         Jan, 1,      base_year+1 )
  holiday("Martin_Luther_King_Day", Jan, {3,  Mon}           )
  holiday("Presidents'_Day",        Feb, {3,  Mon}           )
  holiday("Memorial_Day",           May, {-1, Mon}           )
  holiday("Independence_Day",       Jul, 4                   )
  holiday("Labor_Day",              Sep, {1,  Mon}           )
  holiday("Columbus_Day",           Oct, {2,  Mon}           )
  holiday("Veterans_Day",           Nov, 11                  )
  holiday("Thanksgiving_Day",       Nov, {4,  Thu}           )
  holiday("Christmas_Day",          Dec, 25                  )
  -- You can add more to your liking
  return ret
end

function is_working_day(d)
  if holiday_table_year~=d.year then
    holiday_table=make_US_holiday_table(d.year)
    holiday_table_year=d.year
  end
  return d.wday>=Mon and d.wday<=Fri and not holiday_table[d.yday]
end

