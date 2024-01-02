-- Send an event that can be matched by e.g. the following rules:
-- id=="dli.script.script_event" and script_data.coil_index==1
-- script_data and script_data.coil_state
function send_custom_event()
  outlet[1].state=on
  event.send("coil 1 energized",{coil_index=1,coil_state=true})
end

-- Dump all system events as seen by e.g. notification server with their timestamps
function dump_system_events()
  for _,t,data in event.stream(event.listener()) do
    dump({t,data})
  end
end

-- Flipping outlet 2's state tracking outlet 1's physical state
function mirror_outlet_1_to_2()
  outlet[2].state=outlet[1].physical_state
  for i,t,data in event.stream(event.change_listener(outlet[1])) do
    if data.key=="physical_state" then
      outlet[2].state=data.value
    end
  end
end

-- Checking outlet 1 state and reporting if it remains physically off for more than an hour
function monitor_outlet_1()
  local reported
  local off_since
  local changes=event.change_listener(outlet[1])
  if not outlet[1].physical_state then
    off_since=os.time() -- We don't know that for sure but that's when we start monitoring
  end
  for i,t,data in event.stream(changes,event.utc_time({sec=0})) do
    if i==2 then
      if off_since and t-off_since>3600 then
        if not reported then
          log.warning("Off for too long, since %s",os.date("%c",off_since))
          reported=true
        end
      end
    elseif data.key=="physical_state" then
      if data.value==true then
        off_since=nil
        if reported then
          log.notice("On again, phew")
          reported=true
        end
      elseif off_since==nil then
        off_since=t
      end
    end
  end
end

