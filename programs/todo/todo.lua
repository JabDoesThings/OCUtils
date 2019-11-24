--- !!! DO NOT EDIT UNLESS YOU KNOW WHAT YOU'RE DOING !!!
---
--- t(^_^t)
---
--- @author Jab, aetaric 11/23/2019

--- EDITABLE 

---
MAX_ENTRIES = 1000

--- The directory that the program is stored.
local dir = "/programs/whiteboard/"

-- The file to read from.
local txt = "todo.txt"

local banner3 = assert(loadfile "../utils/banner3.lua")()
local util = assert(loadfile "../utils/util.lua")()
local io = require("io")
local fs = require("filesystem")
local component = require("component")
local keyboard = require("keyboard")
local screen = component.screen
local colors = require("colors")
local gpu = component.gpu
local term = require("term")
local event = require("event")

-- The directory that the program is stored.
local dir = "/programs/whiteboard/"

-- The file to read from.
local txt = "todo.txt"

-- Check to make sure that the file selected exists.
if not fs.exists(dir..txt) then
  exit("File does not exist: " .. txt)
end

local page = 0
local entries = {}
local selected_entry = 0

function read_entries()
  for line in io.lines(dir..txt) do
    local index = nil
    local text = nil
    t = {}
    local offset = 0
    for token in string.gmatch(line, "[^:]+") do
      if offset == 0 then
        index = tonumber(token)
      else
        text = token
      end
      offset = offset + 1
    end
    if index == nil or text == nil then goto continue end
    entries[index] = text
    ::continue::
  end
end

function write_entries()
  local data = ""
  for k = 0, MAX_ENTRIES, 1 do
    local v = entries[k]
    if v == nil then goto continue end
    data = data..tostring(k)..":"..v.."\n"
    ::continue::
  end
  local file = io.open(dir..txt, "w")
  file:write(data)
  file:close()
end

function draw()
  set_resolution()
  clear_console()
  local todo_text = banner3_format("todo")
  local bar = "\u{2588}"
  term.setCursor(1, 4)
  gpu.setForeground(0x444444)
  print_center(todo_text[1])
  gpu.setForeground(0x666666)
  print_center(todo_text[2])
  gpu.setForeground(0x888888)
  print_center(todo_text[3])
  gpu.setForeground(0xaaaaaa)
  print_center(todo_text[4])
  gpu.setForeground(0xcccccc)
  print_center(todo_text[5])
  gpu.setForeground(0xeeeeee)
  print_center(todo_text[6])
  gpu.setForeground(0xffffff)
  print_center(todo_text[7])
  print(" ")
  print(" ")
  local entry_start = 5 * page
  local entry_stop = 5 * (page + 1) - 1  
  local se = selected_entry + (page * 5)
  for offset = entry_start, entry_stop, 1 do
    if se == offset then
      gpu.setForeground(0x00ff00)
    else
      gpu.setForeground(0xffffff)
    end
    local entry = entries[offset]
    if entry ~= nil and entry ~= "" then
      if offset == se then
        print_center("* - "..entries[offset].." - *")
      else
        print_center("- "..entries[offset].." -")
      end
      print(" ")
    elseif offset == se then
      print_center("* - Enter Item - *")
      print(" ")
    else
      print(" ")
      print(" ")
    end
  end
  gpu.setForeground(0xffffff)
  print_center("Page "..tostring(page+1))
  print_center("Selected Entry "..tostring(se))

  -- Draw the border
  --  gpu.fill(1,1,resolution_x,1,bar)
  --  gpu.fill(1,1,2,resolution_y,bar)
  --  gpu.fill(1,resolution_y, resolution_x,1,bar)
  --  gpu.fill(resolution_x-1,1,2,resolution_y,bar)  
end

function edit(entry_number)
  reset_resolution()
  clear_console()
  print("Enter the TODO item for slot "..tostring(entry_number)..":")
  local entry = trim_string(string.gsub(term.read(), "\n", ""))
  local offset = entry_number - 1
  entries[offset] = entry
  print(offset, entry)
  print(" ")
  write_entries()
  draw()
end

read_entries()
draw()

while true do
  local event = event.pull()  
  if event == "key_down" then
    local pages = math.ceil(table_length(entries) / 5)
    local num = 0
    if keyboard.isKeyDown('1') then
      num = 1 + (page * 5)
    elseif keyboard.isKeyDown('2') then
      num = 2 + (page * 5)
    elseif keyboard.isKeyDown('3') then
      num = 3 + (page * 5)
    elseif keyboard.isKeyDown('4') then
      num = 4 + (page * 5)
    elseif keyboard.isKeyDown('5') then
      num = 5 + (page * 5)
    elseif keyboard.isKeyDown(keyboard.keys.down) then
      selected_entry = selected_entry + 1
      if selected_entry == 5 then
        if selected_entry + (pages * 5) < MAX_ENTRIES then
          page = page + 1
          selected_entry = 0
        end
      end
      draw()
    elseif keyboard.isKeyDown(keyboard.keys.up) then
      selected_entry = selected_entry - 1
      if selected_entry == -1 then 
        if page > 0 then
          selected_entry = 4
          page = page - 1
        else
          selected_entry = 0
        end
      end
      draw()
    elseif keyboard.isKeyDown(keyboard.keys.enter) then
      num = selected_entry + (page * 5) + 1
    elseif keyboard.isKeyDown(keyboard.keys.lcontrol) then
      exit()
    else
      goto continue
    end
    if num > 0 then
      edit(num)
    end
  end
  ::continue::
end

exit()