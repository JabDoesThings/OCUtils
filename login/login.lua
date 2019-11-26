package.path = package.path .. ";../?.lua" -- Relative paths for 'require'

local os = require("os")
local io = require("io")
local fs = require("filesystem")
local term = require("term")
local component = require("component")
local gpu = component.gpu

assert(loadfile "oop.lua")()
local hash = require("../utils/hash")
local JSON = require("../utils/json")
local inspect = require("../utils/inspect")
local banner3 = require("../utils/banner3")

local user_file = "users.json"
local config_file = "config.json"

--------------------------------------------------------------------------
-- LOGINSYSTEM
--
LoginSystem = class(function(o)
  if not fs.exists(config_file) then
    o.config = o.create_config()
  else
    o.config = o.read_config()
  end
  --if not fs.exists(user_file) then
  --  o.users = o.create_users()
  --else
    o.users = o.load_users()
  --end
end)

LoginSystem.create_config = function()
  local secret_hash = hash.sha256(os.date()) 
  local config = {}
  config.secret_key = secret_hash:finish()
  local json = JSON:encode_pretty(config)
  local file = io.open(config_file, "w")
  file:write(json)
  file:close()
  return config
end

LoginSystem.read_config = function()
  local json = ""
  for line in io.lines(config_file) do json = json..line end
  return JSON:decode(json)
end

LoginSystem.create_users = function()
  local file = io.open(user_file, "w")
  file:write("{}")
  file:close()
  return {}
end

LoginSystem.load_users = function()
  local users = {}
  local json = ""
  for line in io.lines(user_file) do json = json..line end
  local table = JSON:decode(json)
  local offset = 1
  for entry in pairs(table) do
    local user_table = table[entry]
    local name = user_table.name
    local password = user_table.password
    local user = User(name, password)
    users[offset] = user
    offset = offset + 1
  end
  return users
end

LoginSystem.save_users = function(self)
  local users = {}
  for k in pairs(self.users) do
    local user = self.users[k]
    local _user = {}
    _user.name = user.name
    _user.password = user.password
    table.insert(users, _user)
  end
  local json = JSON:encode_pretty(users)
  local file = io.open(user_file, "w")
  file:write(json)
  file:close()
end

LoginSystem.get_user = function(self, name)
  name = name:lower()
  for k in pairs(self.users) do
    local user = self.users[k]
    if user.name:lower() == name then return user end
  end
  return nil
end

LoginSystem.screen = function(self)
  term.clear()
  local res_x, res_y = gpu.getResolution()
  term.setCursor(1, res_y / 2 - 9)
  banner3.print{text="Welcome", center=true, char_positive="#"}
  print()
  print_line(bar_horizontal)
  print()
  print_center("Press any key to log in. ")
end

LoginSystem.login = function(self)

  local attempts = 0

  ::attempt::
  if attempts > 2 then return false end
  attempts = attempts + 1

  print("Enter the account name: ")
  local name = string.gsub(term.read(), "\n", "")
  local user = self:get_user(name)
  if user == nil then
    print("User does not exist.")
    goto attempt
  end

  print("Enter the password: ")
  local pass = string.gsub(term.read(), "\n", "")

  local hash = hash.sha256(pass)
  hash:process(self.config.secret_key)
  local pass_hash = hash:finish()

  if user.password ~= pass_hash then
    print("Invalid password.")
    goto attempt
  end

  print("Login successful.")
end

LoginSystem.create_user = function(self)
  -- term.clear()
  local attempts = 0

  ::attempt::
  if attempts > 2 then return false end
  attempts = attempts + 1

  print("Enter the account name: ")
  local name = string.gsub(term.read(), "\n", "")

  local user = self:get_user(name)
  if user ~= nil then
    print("Account name is already in use.")
    goto attempt
  end

  print("Enter the password: ")
  local password = string.gsub(term.read(), "\n", "")
  print("Confirm the password: ")
  local password2 = string.gsub(term.read(), "\n", "")

  if password ~= password2 then
    print("Passwords do not match.")
    goto attempt
  end

  local password_hash = hash.sha256(password)
  password_hash:process(self.config.secret_key)
  
  local user = User(name, password_hash:finish())
  table.insert(self.users, user)

  self:save_users()
  return user
end

------------------------------------------------------------
-- USER
--
User = class(function(o, name, password)
  o.name = name
  o.password = password
end)

User.getName = function(self)
  return self.name
end

User.getPassword = function(self)
  return self.password
end

------------------------------------------------------------
-- UTILITIES
--

bar_horizontal = "\u{2550}"
bar_vertical = "\u{2551}"


print_line = function(char, length)
  local res_x, res_y = gpu.getResolution()
  if length == nil then length = res_x end
  line = ""
  for i = 1, length, 1 do line = line..char end
  if res_x == length then
    print(line)
  else
    print_center(line)
  end
end

------------------------------------------------------------
-- MAIN CODE
--
login_system = LoginSystem()
login_system:login()
--login_system:create_user()
--login_system:screen()