function measure_exp_ops_naively()
  local N=1000
  local start=os.clock()
  for i=1,N do
    math.exp(1.1,i)
  end
  local finish=os.clock()
  LOG(string.format("%g naive exponentiation operations per second",N/(finish-start)))
end

function measure_exp_ops_local()
  local exp=math.exp
  local N=1000
  local start=os.clock()
  for i=1,N do
    exp(1.1,i)
  end
  local finish=os.clock()
  LOG(string.format("%g slightly optimized exponentiation operations per second",N/(finish-start)))
end

local days_of_week={"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"}

function demonstrate_time_ops()
  local now=os.time()
  LOG(string.format("Today is %s (local time)",os.date("%Y-%m-%d %H:%M:%S",now)))
  LOG(string.format("Today is %s (UTC time)",os.date("!%Y-%m-%d %H:%M:%S",now)))
  local before=now-24*60*60
  LOG(string.format("24 hours before was %s (local time)",os.date("%Y-%m-%d %H:%M:%S",before)))
  LOG(string.format("24 hours before was %s (UTC time)",os.date("!%Y-%m-%d %H:%M:%S",before)))
  local expanded_time=os.date("*t",now)
  dump(expanded_time)
  LOG(string.format("Today is %s",days_of_week[expanded_time.wday]))
  expanded_time.year=2000
  local recollapsed_time=os.time(expanded_time)
  LOG(string.format("Over %d million seconds passed since the same moment in year 2000",math.floor((now-recollapsed_time)/1000000)))
  local reexpanded_time=os.date("*t",recollapsed_time)
  dump(reexpanded_time)
  LOG(string.format("It was %s back then",days_of_week[reexpanded_time.wday]))
end

