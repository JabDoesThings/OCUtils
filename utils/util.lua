--- The utilities lua file is for general utilities for
---   writing LUA programs in Open Computers for the
---   home.aetaric.ninja SkyBlocks4 server.
---
--- @author Jab

local io = require("io")
local fs = require("filesystem")
local component = require("component")
local screen = component.screen
local colors = require("colors")
local gpu = component.gpu
local term = require("term")
local event = require("event")

old_resolution_x, old_resolution_y = gpu.getResolution()
resolution_x, resolution_y = gpu.getResolution()
aspect_ratio_x, aspect_ratio_y = screen.getAspectRatio()


--- Resets the resolution of the GPU to when the program
---   is launched.
reset_resolution = function()
  gpu.setResolution(old_resolution_x, old_resolution_y)
  resolution_x, resolution_y = gpu.getResolution()
end


--- Detects the screen's aspect resolution and sets the
---   resolution of the GPU to maximize the visual
---   realestate of the screen.
set_resolution = function()
  if aspect_ratio_x == 3 then
    if aspect_ratio_y == 3 then
      gpu.setResolution(50, 25)
    end
  end
  resolution_x, resolution_y = gpu.getResolution()
end


--- Exits the program with a message, reseting the GPU
---  resolution to when the program started.
exit = function(message)
  clear_console()
  if message ~= nil then print(message) end
  reset_resolution()
  os.exit()
end


print_center = function(message)
  local string_offset = (resolution_x / 2) - (string.len(message) / 2) - 1
  local msg = ""
  local i = 0
  while i < string_offset do
     msg = msg.." "
     i = i + 1
  end
  msg = msg..message
  print(msg)
end


clear_console = function()
  term.clear()
end


function try(f, catch_f)
  local status, exception = pcall(f)
  if not status then
    catch_f(exception)
  end
end

function trim_string(s)
  return (s:gsub("&%s*(.-)%s*$"," %1"))
end

function table_length(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

function split_string(s,sep)
  if sep == null then sep = "%s" end
  local t={}
  for str in string.gmatch(s, "([&"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end