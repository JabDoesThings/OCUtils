-- Copyright (C) 2019 Jab
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation  and/or other materials provided with the distribution.
-- 3. Neither the names of the copyright holders nor the names of any
--    contributors may be used to endorse or promote products derived from this
--    software without specific prior written permission.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- The Banner3 library is made in reference to a ascii-generator style 'banner3'.
--
-- @author Jab 11/23/2019

local component = require("component")
local gpu = component.gpu

local banner3 = {}
banner3.chars = {}

--- Formats text to Banner3 format.
---
--- @text The text to format.
banner3.format = function(text)
  text = text:lower()
  local formatted_text = {}
  for i = 0, 7, 1 do
    formatted_text[i] = ""
  end
  for i = 1, #text do
    if i ~= 1 then
      for y = 1, 7, 1 do
        formatted_text[y] = formatted_text[y].." "
      end
    end
    local c = text:sub(i,i)
    local macro = banner3.chars[c]
    if macro == nil then
      macro = banner3.chars[' ']
    end
    for y = 1, 7, 1 do
        formatted_text[y] = formatted_text[y]..macro[y]
    end
  end
  return formatted_text
end

banner3.print_border = function(t, center, foreground_color, background_color, char_positive, char_negative, border_sides)
  local text = t.text
  if text == nil then text = t[0] end
  if text == nil then text = tostring(t) end
  if text == nil then
    error("No text given.")
    return
  end
  local center = t.center
  local foreground_color = t.foreground_color
  local background_color = t.background_color
  local char_positive = t.char_positive
  local char_negative = t.char_negative
  local border_sides = t.border_sides
  if center == nil then center = t[1] end
  if foreground_color == nil then foreground_color = t[2] end
  if background_color == nil then background_color = t[3] end
  if char_positive == nil then char_positive = t[4] end
  if char_negative == nil then char_negative = t[5] end
  if border_sides == nil then border_sides = t[6] end
  if center == nil then center = false end
  if foreground_color == nil then foreground_color = 0xffffff end
  if background_color == nil then background_color = 0x000000 end
  if char_positive == nil then char_positive = '#' end
  if char_negative == nil then char_negative = ' ' end
  if border_sides == nil then border_sides = true end
  local prev_foreground_color, prev_foreground_type = gpu.getForeground()
  local prev_background_color, prev_background_type = gpu.getBackground()
  gpu.setForeground(foreground_color)
  gpu.setBackground(background_color)
  local formatted_text = banner3.format(text)
  local length = string.len(formatted_text[1])
  if border_sides then length = length + 4 end
  
  -- Check to see if the text should be centered on the console.
  local print = _G.print
  if center then print = print_center end

  local border = ""
  local border_space = ""
  for i = 1, length, 1 do
   border = border..char_positive
  end
  if border_sides then
    local slength = length - 5
    for i = 0, slength, 1 do
      border_space = border_space.." " 
    end
    border_space = '# '..border_space..' #'
  end
  print(border)
  print(border_space)
  for i = 1, 7, 1 do
    local formatted_line = formatted_text[i]
    if char_positive ~= '#' then
      formatted_line = string.gsub(formatted_text[i], '#', char_positive)
    end
    if char_negative ~= ' ' then
      formatted_line = string.gsub(formatted_line, ' ', char_negative)
    end
    if border_sides then
      formatted_line = char_positive.." "..formatted_line.." "..char_positive
    end
    print(formatted_line)
  end
  print(border_space)
  print(border)
  gpu.setForeground(prev_foreground_color, prev_foreground_type)
  gpu.setBackground(prev_background_color, prev_background_type)
end

--- Prints out Banner3-formatted text.
--- 
--- @text The text to print, or table
--- @center
--- @foreground_color The foreground character color. (Default is white)
--- @background_color The background character color. (Default is black)
--- @char_positive The positive space character. (Default is '#')
--- @char_negative The negative space character. (Default is ' ')
banner3.print = function(t, center, foreground_color, background_color, char_positive, char_negative)
  local text = t.text
  if text == nil then text = t[0] end
  if text == nil then text = tostring(t) end
  if text == nil then
    error("No text given.")
    return
  end
  local center = t.center
  local foreground_color = t.foreground_color
  local background_color = t.background_color
  local char_positive = t.char_positive
  local char_negative = t.char_negative
  if center == nil then center = t[1] end
  if foreground_color == nil then foreground_color = t[2] end
  if background_color == nil then background_color = t[3] end
  if char_positive == nil then char_positive = t[4] end
  if char_negative == nil then char_negative = t[5] end
  if center == nil then center = false end
  if foreground_color == nil then foreground_color = 0xffffff end
  if background_color == nil then background_color = 0x000000 end
  if char_positive == nil then char_positive = '#' end
  if char_negative == nil then char_negative = ' ' end

  -- Check to see if the text should be centered on the console.
  local print = _G.print
  if center then print = print_center end

  local prev_foreground_color, prev_foreground_type = gpu.getForeground()
  local prev_background_color, prev_background_type = gpu.getBackground()
  gpu.setForeground(foreground_color)
  gpu.setBackground(background_color)
  local formatted_text = banner3.format(text)
  for i = 1, 7, 1 do
    local formatted_line = formatted_text[i]
    if char_positive ~= '#' then
      formatted_line = string.gsub(formatted_text[i], '#', char_positive)
    end
    if char_negative ~= ' ' then
      formatted_line = string.gsub(formatted_line, ' ', char_negative)
    end
    print(formatted_line)
  end
  gpu.setForeground(prev_foreground_color, prev_foreground_type)
  gpu.setBackground(prev_background_color, prev_background_type)
end

print_center = function(message)
  local component = require("component")
  local gpu = component.gpu
  local resolution_x, resolution_y = gpu.getResolution()
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

banner3.chars["!"] = {"####","####","####"," ## ","    ","####","####"}
banner3.chars["#"] = {"  ## ##  ","  ## ##  ","#########","  ## ##  ","#########","  ## ##  ","  ## ##  "}
banner3.chars["+"] = {"      ","  ##  ","  ##  ","######","  ##  ","  ##  ","      "}
banner3.chars[","] = {"    ","    ","    ","####","####"," ## ","##  "}
banner3.chars['-'] = {"       ","       ","       ","#######","       ","       ","       "}
banner3.chars["."] = {"   ","   ","   ","   ","###","###"}
banner3.chars["0"] = {"  #####  "," ##   ## ","##     ##","##     ##","##     ##"," ##   ## ","  #####  "}
banner3.chars["1"] = {"  ##  ","####  ","  ##  ","  ##  ","  ##  ","  ##  ","######"}
banner3.chars["2"] = {" ####### ","##     ##","       ##"," ####### ","##       ","##       ","#########"}
banner3.chars["3"] = {" ####### ","##     ##","       ##"," ####### ","       ##","##     ##"," ####### "}
banner3.chars["4"] = {"##       ","##    ## ","##    ## ","##    ## ","#########","      ## ","      ## "}
banner3.chars["5"] = {"########","##      ","##      ","####### ","      ##","##    ##"," ###### "}
banner3.chars["6"] = {" ####### ","##     ##","##       ","######## ","##     ##","##     ##"," ####### "}
banner3.chars["7"] = {"########","##    ##","    ##  ","   ##   ","  ##    ","  ##    ","  ##    "}
banner3.chars["8"] = {" ####### ","##     ##","##     ##"," ####### ","##     ##","##     ##"," ####### "}
banner3.chars["9"] = {" ####### ","##     ##","##     ##"," ########","       ##","##     ##"," ####### "}
banner3.chars["a"] = {"   ###   ","  ## ##  "," ##   ## ","##     ##","#########","##     ##","##     ##"}
banner3.chars["b"] = {"######## ","##     ##","##     ##","######## ","##     ##","##     ##","#######  "}
banner3.chars["c"] = {" ###### ","##    ##","##      ","##      ","##      ","##    ##"," ###### "}
banner3.chars["d"] = {"######## ","##     ##","##     ##","##     ##","##     ##","##     ##","######## "}
banner3.chars["e"] = {"########","##      ","##      ","######  ","##      ","##      ","########",}
banner3.chars["f"] = { "######## ","##       ","##       ","######   ","##       ","##       ","##       "}
banner3.chars["g"] = {" ######  ","##    ## ","##       ","##   ####","##    ## ","##    ## "," ######  "}
banner3.chars["h"] = {"##     ##","##     ##","##     ##","#########","##     ##","##     ##","##     ##"}
banner3.chars["i"] = {"####"," ## "," ## "," ## "," ## "," ## ","####"}
banner3.chars["j"] = {"      ##","      ##","      ##","      ##","##    ##","##    ##"," ###### "}
banner3.chars["k"] = {"##    ##","##   ## ","##  ##  ","#####   ","##  ##  ","##   ## ","##    ##"}
banner3.chars["l"] = {"##      ","##      ","##      ","##      ","##      ","##      ","########"}
banner3.chars["m"] = {"##     ##","###   ###","#### ####","## ### ##","##     ##","##     ##","##     ##"}
banner3.chars["n"] = {"##    ##","###   ##","####  ##","## ## ##","##  ####","##   ###","##    ##"}
banner3.chars["o"] = {" ####### ","##     ##","##     ##","##     ##","##     ##","##     ##"," ####### "}
banner3.chars["p"] = {"######## ","##     ##","##     ##","######## ","##       ","##       ","##       "}
banner3.chars["q"] = {" ####### ","##     ##","##     ##","##     ##","##  ## ##","##    ## "," ##### ##"}
banner3.chars["r"] = {"######## ","##     ##","##     ##","######## ","##   ##  ","##    ## ","##     ##"}
banner3.chars["s"] = {" ###### ","##    ##","##      "," ###### ","      ##","##    ##"," ###### "}
banner3.chars["t"] = {"########","   ##   ","   ##   ","   ##   ","   ##   ","   ##   ","   ##   "}
banner3.chars["u"] = {"##     ##","##     ##","##     ##","##     ##","##     ##","##     ##"," ####### "}
banner3.chars["v"] = {"##     ##","##     ##","##     ##","##     ##"," ##   ## ","  ## ##  ","   ###   "}
banner3.chars["w"] = {"##      ##","##  ##  ##","##  ##  ##","##  ##  ##","##  ##  ##","##  ##  ##"," ###  ### "}
banner3.chars["x"] = {"##     ##"," ##   ## ","  ## ##  ","   ###   ","  ## ##  "," ##   ## ","##     ##"}
banner3.chars["y"] = {"##    ##"," ##  ## ","  ####  ","   ##   ","   ##   ","   ##   ","   ##   "}
banner3.chars["z"] = {"########","     ## ","    ##  ","   ##   ","  ##    "," ##     ","########"}
banner3.chars["_"] = {"       ","       ","       ","       ","       ","       ","#######"}
banner3.chars[" "] = {"   ","   ","   ","   ","   ","   ","   "}

return banner3