-- Sample for switching an outlet depending on sunrise and sunset.
-- Algorithm currently available at: http://www.edwilliams.org/sunrise_sunset_algorithm.htm
-- Algorithm description:
-- Source:
-- 	Almanac for Computers, 1990
-- 	published by Nautical Almanac Office
-- 	United States Naval Observatory
-- 	Washington, DC 20392
-- Inputs:
-- 	day, month, year:      date of sunrise/sunset
-- 	latitude, longitude:   location for sunrise/sunset
-- 	zenith:                Sun's zenith for sunrise/sunset
-- 	  offical      = 90 degrees 50'
-- 	  civil        = 96 degrees
-- 	  nautical     = 102 degrees
-- 	  astronomical = 108 degrees
-- 	NOTE: longitude is positive for East and negative for West
--      NOTE: the algorithm assumes the use of a calculator with the
--         trig functions in "degree" (rather than "radian") mode. Most
--         programming languages assume radian arguments, requiring back
--         and forth convertions. The factor is 180/pi. So, for instance,
--         the equation RA = atan(0.91764 * tan(L)) would be coded as RA
--         = (180/pi)*atan(0.91764 * tan((pi/180)*L)) to give a degree
--         answer with a degree input for L.
-- Based on
-- https://gist.githubusercontent.com/alexander-yakushev/88531e23a89a0f2acbf1/raw/6faf8b2ef32f354920b0ac8ce3015e19e56acadb/lustrous.lua
-- Module for calculating sunrise/sunset times for a given location
-- Based on algorithm by United Stated Naval Observatory, Washington
-- Link: http://williams.best.vwh.net/sunrise_sunset_algorithm.htm
-- @author Alexander Yakushev
-- @license CC0 http://creativecommons.org/about/cc0

local rad = math.rad
local deg = math.deg
local floor = math.floor
local frac = function(n) return n - floor(n) end
local cos = function(d) return math.cos(rad(d)) end
local acos = function(d) return deg(math.acos(d)) end
local sin = function(d) return math.sin(rad(d)) end
local asin = function(d) return deg(math.asin(d)) end
local tan = function(d) return math.tan(rad(d)) end
local atan = function(d) return deg(math.atan(d)) end

local ZENITH_OFFICAL = 90 + 50/60 -- 90 degrees 50'
local ZENITH_CIVIL = 96 -- degrees
local ZENITH_NAUTICAL = 102 -- degrees
local ZENITH_ASTRONOMICAL = 108 -- degrees

local function fit_into_range(val, min, max)
    local range = max - min
    local count
    if val < min then
        count = floor((min - val) / range) + 1
        return val + count * range
    elseif val >= max then
        count = floor((val - max) / range) + 1
        return val - count * range
    else
        return val
    end
end

local function day_of_year(date)
    local n1 = floor(275 * date.month / 9)
    local n2 = floor((date.month + 9) / 12)
    local n3 = (1 + floor((date.year - 4 * floor(date.year / 4) + 2) / 3))
    return n1 - (n2 * n3) + date.day - 30
end

local function unwrapped_sunturn_hour_of_day(n, rising, latitude, longitude, zenith)
    -- Convert the longitude to hour value and calculate an approximate time
    local lng_hour = longitude / 15

    local t
    if rising then -- Rising time is desired
        t = n + ((6 - lng_hour) / 24)
    else -- Setting time is desired
        t = n + ((18 - lng_hour) / 24)
    end

    -- Calculate the Sun's mean anomaly
    local M = (0.9856 * t) - 3.289

    -- Calculate the Sun's true longitude
    local L = fit_into_range(M + (1.916 * sin(M)) + (0.020 * sin(2 * M)) + 282.634, 0, 360)

    -- Calculate the Sun's right ascension
    local RA = fit_into_range(atan(0.91764 * tan(L)), 0, 360)

    -- Right ascension value needs to be in the same quadrant as L
    local Lquadrant  = floor(L / 90) * 90
    local RAquadrant = floor(RA / 90) * 90
    RA = RA + Lquadrant - RAquadrant

    -- Right ascension value needs to be converted into hours
    RA = RA / 15

    -- Calculate the Sun's declination
    local sinDec = 0.39782 * sin(L)
    local cosDec = cos(asin(sinDec))

    -- Calculate the Sun's local hour angle
    local cosH = (cos(zenith or ZENITH_OFFICAL) - (sinDec * sin(latitude))) / (cosDec * cos(latitude))

    if cosH > 1 or cosH < -1 then
        return nil -- The sun never rises/sets on this location on the specified date
    end

    -- Finish calculating H and convert into hours
    local H
    if rising then
        H = 360 - acos(cosH)
    else
        H = acos(cosH)
    end
    H = H / 15

    -- Calculate local mean time of rising/setting
    local T = H + RA - (0.06571 * t) - 6.622

    return T - lng_hour
end

local function sunturn_hour_of_day(n, rising, latitude, longitude, zenith)
    return fit_into_range(unwrapped_sunturn_hour_of_day(n, rising, latitude, longitude, zenith), 0, 24)
end

local function sunturn_hour(date, rising, latitude, longitude, zenith)
    return sunturn_hour_of_day(day_of_year(date), rising, latitude, longitude, zenith)
end

local function make_fractional_hour(hour, min, sec)
    return hour + min/60 + sec/3600
end

local function split_hour(fractional_hour)
    local hour = floor(fractional_hour)
    local min_sec = (fractional_hour - hour) * 60
    local min = floor(min_sec)
    local sec = floor(frac(min_sec) * 60 + 0.5)
    return hour, min, sec
end

function show_sunrise_sunset_today_utc()
    local date = os.date("!*t")
    local lat = 37.352390
    local lon = -121.953079

    local rise_hour = sunturn_hour(date, true, lat, lon)
    local set_hour = sunturn_hour(date, false, lat, lon)

    log.notice("The Sun rises at %d:%d:%d UTC", split_hour(rise_hour))
    log.notice("The Sun sets at %d:%d:%d UTC", split_hour(set_hour))
end

-- NB: use os.timegm, if available, to convert the time to a UNIX
-- timestamp; see the scripting documentation for details.

local function make_timestamp(date, fractional_hour)
    local hour, min, sec = split_hour(fractional_hour)
    return os.timegm({ day = date.day, month = date.month, year = date.year,
                       hour = hour, min = min, sec = sec})
end

function show_sunrise_sunset_timestamps()
    local timestamp = os.timegm()
    local date = os.date("!*t", timestamp)
    local lat = 37.352390
    local lon = -121.953079

    local rise_hour = sunturn_hour(date, true, lat, lon)
    local set_hour = sunturn_hour(date, false, lat, lon)

    local rise_time_delta = make_timestamp(date, rise_hour) - timestamp
    if rise_time_delta > 0 then
        log.notice("The Sun will rise in %.17g seconds", rise_time_delta)
    else
        log.notice("The Sun rose %.17g seconds ago", -rise_time_delta)
    end
    local set_time_delta = make_timestamp(date, set_hour) - timestamp
    if set_time_delta > 0 then
        log.notice("The Sun will set in %.17g seconds", set_time_delta)
    else
        log.notice("The Sun set %.17g seconds ago", -set_time_delta)
    end
end

function handle_sunrise_sunset()
    local now = os.time()
    local date = os.date("!*t", now)
    local lat = 37.352390
    local lon = -121.953079

    local day = day_of_year(date)
    local hour = make_fractional_hour(date.hour, date.min, date.sec)
    local base = now - hour*3600
    local sun_state_change_hour
    local rise_hour_precedes_now
    local set_hour_precedes_now
    local rise_hour
    local set_hour
    local rise_shift = 0
    local set_shift = 0
    -- Find the immediately preceding sunset and sunrise
    while not (rise_hour_precedes_now and set_hour_precedes_now) do
        if not rise_hour_precedes_now then
            rise_hour = sunturn_hour_of_day(day + rise_shift, true, lat, lon)
            if rise_hour then
                rise_hour = rise_hour + rise_shift * 24
                rise_hour_precedes_now = rise_hour < hour
            end
        end
        if not rise_hour_precedes_now then
            rise_shift = rise_shift - 1
        end
        if not set_hour_precedes_now then
            set_hour = sunturn_hour_of_day(day + set_shift, false, lat, lon)
            if set_hour then
                set_hour = set_hour + set_shift * 24
                set_hour_precedes_now = set_hour < hour
            end
        end
        if not set_hour_precedes_now then
            set_shift = set_shift - 1
        end
    end
    local sun_is_up = set_hour < rise_hour
    sun_state_change_hour = sun_is_up and rise_hour or set_hour
    log.notice("The Sun has been %s for ~%.2g hours", sun_is_up and "up" or "down", hour - sun_state_change_hour)
    if sun_is_up then
        outlet[1].off()
    else
        outlet[1].on()
    end
    local scheduler = event.scheduler()
    local function schedule_next_sunrise()
        while true do
            rise_shift = rise_shift + 1
            local rise_hour = sunturn_hour_of_day(day + rise_shift, true, lat, lon)
            if rise_hour then
                local next_time = base + (rise_hour + rise_shift * 24) * 3600
                log.notice("Next sunrise in %dh %dm %ds", split_hour((next_time - os.time())/3600))
                scheduler.schedule_absolute(next_time, {sun_is_up = true})
                break
            end
        end
    end
    local function schedule_next_sunset()
        while true do
            set_shift = set_shift + 1
            local set_hour = sunturn_hour_of_day(day + set_shift, false, lat, lon)
            if set_hour then
                local next_time = base + (set_hour + set_shift * 24) * 3600
                log.notice("Next sunset in %dh %dm %ds", split_hour((next_time - os.time())/3600))
                scheduler.schedule_absolute(next_time, {sun_is_up = false})
                break
            end
        end
    end
    schedule_next_sunrise()
    schedule_next_sunset()
    for i,t,data in event.stream(scheduler) do
        sun_is_up = data.sun_is_up
        if sun_is_up then
            schedule_next_sunrise()
        else
            schedule_next_sunset()
        end
        log.notice("The Sun has %s", sun_is_up and "risen" or "set")
        if sun_is_up then
            outlet[1].off()
        else
            outlet[1].on()
        end
    end
end
