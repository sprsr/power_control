local function is_between(x,a,b)
  return a<=x and x<b
end

function test_basic_math()
  assert(math.max(1,2,3)==3)
  assert(math.min(1,2,3)==1)
  for x=1,10 do
    assert(is_between(math.pow(math.cos(x),2)+math.pow(math.sin(x),2),1-1e-6,1+1e-6))
  end
end

function cycle_random_outlet()
  outlet[math.random(#outlet)].cycle()
end

