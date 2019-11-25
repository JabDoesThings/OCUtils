--- !!! DO NOT EDIT UNLESS YOU KNOW WHAT YOU'RE DOING !!!
---
--- t(^_^t)
---
--- @author Jab, aetaric 11/23/2019

TODO = {}

--- EDITABLE 
TODO.MAX_ENTRIES = 1000
TODO.txt = "todo.txt"
TODO.draw_borders = true
TODO.page = 0
TODO.selected_entry = 0
TODO.entries = {}

assert(loadfile "../utils/banner3.lua")()
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

TODO.loop = function(self)
  self:draw()
  while true do
    local event = event.pull()  
    if event == "key_down" then
      local pages = math.ceil(table_length(TODO.entries) / 5)
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
        TODO.selected_entry = TODO.selected_entry + 1
        if TODO.selected_entry == 5 then
          if TODO.selected_entry + (pages * 5) < TODO.MAX_ENTRIES then
            TODO.page = TODO.page + 1
            TODO.selected_entry = 0
          end
        end
      elseif keyboard.isKeyDown(keyboard.keys.up) then
        TODO.selected_entry = TODO.selected_entry - 1
        if TODO.selected_entry == -1 then 
          if TODO.page > 0 then
            TODO.selected_entry = 4
            TODO.page = TODO.page - 1
          else
            TODO.selected_entry = 0
          end
        end
      elseif keyboard.isKeyDown(keyboard.keys.enter) then
        num = TODO.selected_entry + (TODO.page * 5) + 1
      elseif keyboard.isKeyDown(keyboard.keys.lcontrol) then
        exit()
      else
        goto continue
      end
      if num > 0 then
        self:edit(num)
      end
    end
    ::continue::
  end
end

TODO.draw = function(self)
  set_resolution()
  clear_console()
  local todo_text = banner3.format("todo")
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
  local entry_start = 5 * self.page
  local entry_stop = 5 * (self.page + 1) - 1
  local se = TODO.selected_entry + (self.page * 5)
  for offset = entry_start, entry_stop, 1 do
    if se == offset then
      gpu.setForeground(0x00ff00)
    else
      gpu.setForeground(0xffffff)
    end
    local entry = TODO.entries[offset]
    if entry ~= nil and entry ~= "" then
      if offset == se then
        print_center("* - "..TODO.entries[offset].." - *")
      else
        print_center("- "..TODO.entries[offset].." -")
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
  print_center("Page "..tostring(self.page+1))
  print_center("Selected Entry "..tostring(se))
  print('draw_borders='..tostring(self.draw_borders))
  if self.draw_borders then
    gpu.fill(1,1,resolution_x,1,bar)
    gpu.fill(1,1,2,resolution_y,bar)
    gpu.fill(1,resolution_y, resolution_x,1,bar)
    gpu.fill(resolution_x-1,1,2,resolution_y,bar)  
  end
end

TODO.edit = function(self, entry_number)
  reset_resolution()
  clear_console()
  print("Enter the TODO item for slot "..tostring(entry_number)..":")
  local entry = trim_string(string.gsub(term.read(), "\n", ""))
  local offset = entry_number - 1
  self.entries[offset] = entry
  print(offset, entry)
  print(" ")
  TODO:write_entries()
end

TODO.read_entries = function(self)
  for line in io.lines(self.txt) do
    local index = nil
    local text = nil
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
    self.entries[index] = text
    ::continue::
  end
end

TODO.write_entries = function()
  local data = ""
  for k = 0, self.MAX_ENTRIES, 1 do
    local v = self.entries[k]
    if v ~= nil then
      data = data..tostring(k)..":"..v.."\n"
    end
  end
  local file = io.open(self.txt, "w")
  file:write(data)
  file:close()
end

__main = function()

  local todo = TODO()

  -- Check to make sure that the file selected exists.
  if not fs.exists(self.txt) then
    local file = io.open(self.txt, "w")
    file:write("1:Example\n")
    file:close()
  end
  TODO.read_entries()
  TODO.loop()
  exit()
end

TODO.__main()