package.path = package.path .. ";../?.lua" -- Relative paths for 'require'
local inspect = require('../util/inspect')

--http://lua-users.org/wiki/SimpleLuaClasses

-- class.lua
-- Compatible with Lua 5.1 (not 5.0).
function class(base, init)
  local c = {}    -- a new class instance
  if not init and type(base) == 'function' then
     init = base
     base = nil
  elseif type(base) == 'table' then
   -- our new class is a shallow copy of the base class!
     for i,v in pairs(base) do
        c[i] = v
     end
     c._base = base
  end
  -- the class will be the metatable for all its objects,
  -- and they will look up their methods in it.
  c.__index = c
  -- expose a constructor which can be called by <classname>(<args>)
  local mt = {}
  mt.__call = function(class_tbl, ...)
  local obj = {}
  setmetatable(obj,c)
  if init then
     init(obj,...)
  else 
     -- make sure that any stuff from the base class is initialized!
     if base and base.init then
     base.init(obj, ...)
     end
  end
  return obj
  end
  c.init = init
  c.is_a = function(self, klass)
     local m = getmetatable(self)
     while m do 
        if m == klass then return true end
        m = m._base
     end
     return false
  end
  setmetatable(c, mt)
  return c
end

function enum(...)
  local c = {}
  local index = 1
  for k, v in ipairs({...}) do
    c[tostring(v)] = index
    index = index + 1
  end
  local mt = {}
  mt.__call = function()
    error("Cannot instantiate a enum.")
  end
  setmetatable(c, mt)


  c.get = function(self, value)
    if type(value) == 'string' then
      return self[value]
    elseif type(value) == 'number' then
      for k in pairs(self) do
        local v = self[k]
        if v == value then return k end
      end
    end
    return nil
  end

  return c
end

--- Example:
---
--- try(function()
---     error "Error!"
--- end)
--- :catch(function(err)
---     print(err)
--- end)
--- :finally(function()
---     print "Finally!"
--- end)
function try(func)
    local ok, err = pcall(func)
    return {
        catch = function(self, handle)
            if not ok then
                handle(err)
            end
            return self
        end,
        finally = function(self, handle)
            handle()
            return self -- Optional
        end
    }
end