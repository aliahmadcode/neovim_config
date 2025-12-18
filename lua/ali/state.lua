local M = {}

function printShouldFormat()
  print("M.should_format " .. tostring(M.should_format))
end

function initShouldFormat()
  M.should_format = true
end

function dontFormat()
  M.should_format = false
end

if not _G.__STATE_INIT__ then
  _G.__STATE_INIT__ = true
  initShouldFormat()
end

return M
