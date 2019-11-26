local component = require("component")
local fs = require("filesystem")
local io = require("io")

local function __request(url, data, headers, method)
  checkArg(1, url, "string")
  checkArg(2, data, "string", "table", "nil")
  checkArg(3, headers, "table", "nil")
  checkArg(4, method, "string", "nil")
  if not component.isAvailable("internet") then
    error("no primary internet card found", 2)
  end
  local inet = component.internet
  local post
  if type(data) == "string" then
    post = data
  elseif type(data) == "table" then
    for k, v in pairs(data) do
      post = post and (post .. "&") or ""
      post = post .. tostring(k) .. "=" .. tostring(v)
    end
  end
  local request, reason = inet.request(url, post, headers, method)
  if not request then
    error(reason, 2)
  end
  return setmetatable(
  {
    ["()"] = "function():string -- Tries to read data from the socket stream and return the read byte array.",
    close = setmetatable({},
    {
      __call = request.close,
      __tostring = function() return "function() -- closes the connection" end
    })
  },
  {
    __call = function()
      while true do
        local data, reason = request.read()
        if not data then
          request.close()
          if reason then
            return nil, reason
--            error(reason, 2)
          else
            return nil -- eof
          end
        elseif #data > 0 then
          return data, reason
        end
        -- else: no data, block
        os.sleep(0)
      end
    end,
    __index = request,
  })
end

--- Downloads and returns data for a given URL.
---
--- @return Returns data result as a string.
function download(url)
  local header = {}
  header["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36"
  local request, reason = __request(url, nil, header, "GET")
  local response = ""  
  for chunk in request do response = response..chunk end
  return response, request, reason
end

function download_to_file(url, path)
  local data = download(url)
  local file = io.open(path, "w")
  file:write(data)
  file:close()
end