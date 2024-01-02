-- returns true if it's a weekend day
local function weekend(day_of_week)
    return day_of_week==7 or day_of_week==1
end

-- returns true if it's a weekday day
local function weekday(day_of_week)
  return day_of_week>1 and day_of_week<7
  -- or, simpler,
  -- return not weekend(day_of_week)
end


-- Turn on an outlet every day at 8:00am
function schedule_outlet_1_on()
  while true do
    wait_until({hour=8,min=0, sec=0})
    outlet[1].on()
    delay (1) -- make sure it doesn't run twice
  end
end

-- Turn off an outlet every day at 5:00pm
function schedule_outlet_1_off()
  while true do
    wait_until({hour=17,min=0, sec=0})
    outlet[1].off()
    delay (1) -- make sure it doesn't run twice
  end
end

-- Turn outlet 5 on at 12:30 for 1 hour on weekends
function outlet_5_on_1_hour_weekends()
  local one_hour = 60*60;
  while true do
    -- 12:30 Saturday and Sunday
    wait_until({day=weekend,hour=12,min=30, sec=0})
    outlet[5].on()
    delay (one_hour) -- wait
    outlet[5].off()
  end
end

-- Turn on the sign for eight hours daily
function turn_on_sign_for_8_hours()
  one_hour = 3600
  while true do
    wait_until({hour=18,min=0,sec=0})
    outlet[8].on()
    delay(one_hour*8)
    outlet[8].off()
  end
end

-- The wait_until function is implemented internally but it
-- is not special; it could be implemented in the simplest
-- single-condition form in the user script like this:
--
-- function wait_until(conditions)
--   repeat
--     local ok=true
--     local date=os.date("*t")
--     for k,v in pairs(conditions) do
--       if type(v)=="function" then
--         ok=v(date[k])
--       else
--         ok=date[k]==v
--       end
--       if not ok then
--         break
--       end
--     end
--     if not ok then
--       delay(1)
--     end
--   until ok
--   return 1
-- end
