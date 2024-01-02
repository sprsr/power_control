function test_error_handling()
  local a=1
  local b,c
  local ok,value=pcall(function()
    b=a
    c=a
    return "ok"
  end)
  assert(ok)
  assert(value=="ok")
  assert(b==1)
  assert(c==1)
  a=2
  ok,value=pcall(function()
    b=a
    error "failure!"
    c=a
  end)
  assert(not ok)
  assert(b==2)
  assert(c==1)
  LOG("Error handling test passed")
end

