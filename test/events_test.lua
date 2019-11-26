package.path = package.path .. ";../?.lua"

local event = require("event")

local inspect = require("../inspect")
local keyboard = require("keyboard")

local handle_screen_event = function(event)

  local event_table = {}
  event_table.type = event[1]
  event_table.screen_address = event[2]
  event_table.x = event[3]
  event_table.y = event[4]
  event_table.button = event[5]
  event_table.player_button = event[6]
  
  event_table.shift_down = keyboard.isShiftDown()
  event_table.ctrl_down = keyboard.isControlDown()
  event_table.alt_down = keyboard.isAltDown()
  if not event_table.shift_down then event_table.shift_down = false end
  if not event_table.ctrl_down then event_table.ctrl_down = false end
  if not event_table.alt_down then event_table.alt_down = false end  

  print(inspect(event_table))
end

local handle_key_event = function(event)

  local event_table = {}
  event_table.type = event[1]
  event_table.keyboard_address = event[2]
  event_table.char = string.char(event[3])
  event_table.code = event[4]
  event_table.player_name = event[5]

  event_table.shift_down = keyboard.isShiftDown()
  event_table.ctrl_down = keyboard.isControlDown()
  event_table.alt_down = keyboard.isAltDown()
  if not event_table.shift_down then event_table.shift_down = false end
  if not event_table.ctrl_down then event_table.ctrl_down = false end
  if not event_table.alt_down then event_table.alt_down = false end

  print(inspect(event_table))
end

local handle_scroll_event = function(event)
  
  local event_table = {}
  event_table.type = event[1]
  event_table.screen_address = event[2]
  event_table.x = event[3]
  event_table.y = event[4]
  event_table.direction = event[5]
  event_table.player_name = event[6]

  event_table.shift_down = keyboard.isShiftDown()
  event_table.ctrl_down = keyboard.isControlDown()
  event_table.alt_down = keyboard.isAltDown()
  if not event_table.shift_down then event_table.shift_down = false end
  if not event_table.ctrl_down then event_table.ctrl_down = false end
  if not event_table.alt_down then event_table.alt_down = false end

  print(inspect(event_table))  
end

while true do
  local next = {event.pull()}
  
   --print(inspect(next))
 
  local event_name = next[1]
  print("Event: "..tostring(event_name))
  if event_name == 'interrupted' then
    print(inspect(next))
    os.exit()
  elseif event_name:find('key') then
    handle_key_event(next)
  elseif event_name == 'touch' or event_name == 'drag' or event_name == 'drop' then
    handle_screen_event(next)
  elseif event_name == 'scroll' then
    handle_scroll_event(next)
  else
    print(inspect(next))
  end
end